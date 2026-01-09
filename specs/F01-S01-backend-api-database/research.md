# Research: Backend API & Database Technologies

**Feature**: Backend API & Database (F01-S01)
**Date**: 2026-01-09
**Status**: Complete

## Overview

This document captures research findings and technical decisions for implementing a FastAPI backend with SQLModel ORM and Neon Serverless PostgreSQL for a multi-user todo task management system.

---

## 1. FastAPI Best Practices for RESTful CRUD APIs

### Decision: APIRouter with Layered Architecture

**Approach**:
- Use `APIRouter` to organize endpoints by resource type
- Follow REST conventions: `/api/tasks` for collections, `/api/tasks/{id}` for resources
- Implement layered architecture: Router → Service → Model
- Use FastAPI dependency injection for database sessions and common parameters

**Code Example**:
```python
# src/api/routes/tasks.py
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlmodel import Session
from src.database import get_db
from src.services.task_service import TaskService
from src.schemas.task_schemas import TaskCreate, TaskUpdate, TaskResponse

router = APIRouter(prefix="/api/tasks", tags=["tasks"])

@router.post("/", response_model=TaskResponse, status_code=201)
def create_task(
    task_data: TaskCreate,
    user_id: str = Query(..., description="User ID"),
    db: Session = Depends(get_db)
):
    service = TaskService(db, user_id)
    return service.create_task(task_data)

@router.get("/", response_model=list[TaskResponse])
def list_tasks(
    user_id: str = Query(...),
    status: str | None = Query(None),
    priority: str | None = Query(None),
    tags: str | None = Query(None),
    sort: str | None = Query(None),
    db: Session = Depends(get_db)
):
    service = TaskService(db, user_id)
    return service.list_tasks(status, priority, tags, sort)
```

**Rationale**:
- FastAPI's dependency injection system reduces code duplication
- Service layer centralizes business logic and user-scoping
- Clear separation makes testing easier (can mock services)
- APIRouter allows modular endpoint organization

**Alternatives Considered**:
- **Flat function structure**: Rejected because it leads to code duplication for user_id validation and database sessions
- **Class-based views**: Rejected because FastAPI's function-based approach is more Pythonic and has better type inference

---

## 2. SQLModel Schema Definition

### Decision: SQLModel with Hybrid Models (Table + API Models)

**Approach**:
- Use SQLModel `table=True` for database models
- Use separate Pydantic models for API requests/responses
- UUID primary key with `uuid.uuid4()` default
- PostgreSQL ARRAY for tags using `sa_column=Column(ARRAY(String))`
- DateTime with `datetime.utcnow` default for timestamps

**Code Example**:
```python
# src/models/task.py
from sqlmodel import SQLModel, Field, Column
from sqlalchemy import ARRAY, String
from datetime import datetime
from uuid import UUID, uuid4
from enum import Enum

class TaskStatus(str, Enum):
    TODO = "todo"
    IN_PROGRESS = "in-progress"
    COMPLETED = "completed"

class TaskPriority(str, Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"

class Task(SQLModel, table=True):
    __tablename__ = "tasks"

    id: UUID = Field(default_factory=uuid4, primary_key=True)
    user_id: str = Field(index=True)
    title: str = Field(max_length=255)
    description: str | None = Field(default=None, max_length=5000)
    status: TaskStatus = Field(default=TaskStatus.TODO)
    priority: TaskPriority = Field(default=TaskPriority.MEDIUM)
    tags: list[str] = Field(default=[], sa_column=Column(ARRAY(String)))
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
```

**Rationale**:
- SQLModel combines SQLAlchemy and Pydantic, providing type safety and ORM in one
- `Field()` allows both database constraints (index) and validation (max_length)
- Python Enums map cleanly to database VARCHAR columns
- Separate API models prevent exposing internal fields or allowing direct model manipulation

**Alternatives Considered**:
- **Pure SQLAlchemy**: Rejected because it requires more boilerplate and loses Pydantic validation
- **JSON column for tags**: Rejected because PostgreSQL ARRAY supports indexing and querying better
- **Separate created_by/updated_by**: Rejected because user_id serves this purpose (simplified for this spec)

---

## 3. Neon PostgreSQL Connection Patterns

### Decision: SQLModel Engine with Connection Pooling

**Approach**:
- Use `create_engine()` with connection string from environment variable
- Enable connection pooling with `pool_pre_ping=True` for serverless reliability
- Use `Session` from `sqlmodel` for dependency injection
- Connection string format: `postgresql://user:password@host/database?sslmode=require`

**Code Example**:
```python
# src/database.py
from sqlmodel import create_engine, Session, SQLModel
from src.config import settings

# Connection string from environment
DATABASE_URL = settings.DATABASE_URL

# Create engine with pooling
engine = create_engine(
    DATABASE_URL,
    echo=True,  # Log SQL queries in development
    pool_pre_ping=True,  # Verify connections before using (important for serverless)
    pool_recycle=3600,  # Recycle connections after 1 hour
)

# Create tables (use Alembic in production)
def create_db_and_tables():
    SQLModel.metadata.create_all(engine)

# Dependency for FastAPI
def get_db():
    with Session(engine) as session:
        yield session
```

**Rationale**:
- `pool_pre_ping=True` handles Neon's serverless connection drops gracefully
- `pool_recycle` prevents stale connections in long-running applications
- SQLModel's `Session` integrates seamlessly with FastAPI's dependency system
- Neon requires SSL, specified in connection string

**Alternatives Considered**:
- **asyncpg with async SQLModel**: Rejected because sync SQLModel is simpler for this spec; async can be added later if needed
- **Manual connection management**: Rejected because connection pooling improves performance
- **SQLAlchemy Session directly**: Rejected because SQLModel's Session is a thin wrapper that's more convenient

---

## 4. User-Scoped Query Patterns

### Decision: Service Layer with Mandatory user_id Filter

**Approach**:
- All database queries go through a `TaskService` class initialized with `user_id`
- Service methods automatically add `WHERE user_id = ?` to all queries
- Return 403 Forbidden for cross-user access attempts (not 404)
- Never trust client-provided IDs without verifying ownership

**Code Example**:
```python
# src/services/task_service.py
from sqlmodel import Session, select
from fastapi import HTTPException
from uuid import UUID
from src.models.task import Task
from src.schemas.task_schemas import TaskCreate, TaskUpdate

class TaskService:
    def __init__(self, db: Session, user_id: str):
        self.db = db
        self.user_id = user_id

    def list_tasks(self, status=None, priority=None, tags=None, sort=None):
        # Base query ALWAYS filters by user_id
        query = select(Task).where(Task.user_id == self.user_id)

        if status:
            query = query.where(Task.status == status)
        if priority:
            query = query.where(Task.priority == priority)
        if tags:
            # PostgreSQL array contains filter
            tag_list = tags.split(',')
            for tag in tag_list:
                query = query.where(Task.tags.contains([tag]))

        results = self.db.exec(query).all()
        return results

    def get_task_by_id(self, task_id: UUID) -> Task:
        # CRITICAL: Filter by both id AND user_id
        task = self.db.exec(
            select(Task).where(Task.id == task_id, Task.user_id == self.user_id)
        ).first()

        if not task:
            # Return 403, not 404, to prevent information disclosure
            raise HTTPException(status_code=403, detail="Access denied")

        return task

    def update_task(self, task_id: UUID, task_update: TaskUpdate) -> Task:
        # Verify ownership first
        task = self.get_task_by_id(task_id)  # Raises 403 if not owned

        # Update only provided fields
        update_data = task_update.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(task, field, value)

        # Refresh updated_at
        task.updated_at = datetime.utcnow()

        self.db.add(task)
        self.db.commit()
        self.db.refresh(task)
        return task
```

**Rationale**:
- Service class encapsulates user-scoping logic in one place
- Impossible to accidentally query without user_id (constructor requires it)
- 403 vs 404 distinction prevents attackers from probing for task IDs
- All queries are parameterized, preventing SQL injection

**Alternatives Considered**:
- **SQLModel query filters as decorators**: Rejected because Python doesn't have great AOP support
- **Database row-level security**: Rejected because it requires complex PostgreSQL RLS setup and complicates testing
- **Return 404 for missing tasks**: Rejected because it leaks information about task existence

---

## 5. Pydantic V2 Validation and Error Messages

### Decision: Pydantic V2 Validators with Custom Error Messages

**Approach**:
- Use Pydantic v2's `@field_validator` for custom validation
- Use `Field()` with `min_length`, `max_length` for declarative validation
- Customize error messages via `ValidationError` exception
- FastAPI automatically converts Pydantic validation errors to 422 responses

**Code Example**:
```python
# src/schemas/task_schemas.py
from pydantic import BaseModel, Field, field_validator, ValidationError
from uuid import UUID
from datetime import datetime
from enum import Enum

class TaskStatus(str, Enum):
    TODO = "todo"
    IN_PROGRESS = "in-progress"
    COMPLETED = "completed"

class TaskPriority(str, Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"

class TaskCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=255, description="Task title")
    description: str | None = Field(None, max_length=5000, description="Task description")
    status: TaskStatus = Field(TaskStatus.TODO, description="Task status")
    priority: TaskPriority = Field(TaskPriority.MEDIUM, description="Task priority")
    tags: list[str] = Field(default=[], description="Task tags")

    @field_validator('title')
    @classmethod
    def title_not_empty(cls, v: str) -> str:
        if not v or not v.strip():
            raise ValueError('Title cannot be empty or whitespace')
        return v.strip()

    @field_validator('tags')
    @classmethod
    def deduplicate_tags(cls, v: list[str]) -> list[str]:
        # Remove duplicates and empty strings
        return list(set(tag.strip() for tag in v if tag.strip()))

class TaskUpdate(BaseModel):
    # All fields optional for PATCH semantics
    title: str | None = Field(None, min_length=1, max_length=255)
    description: str | None = Field(None, max_length=5000)
    status: TaskStatus | None = None
    priority: TaskPriority | None = None
    tags: list[str] | None = None

    @field_validator('title')
    @classmethod
    def title_not_empty(cls, v: str | None) -> str | None:
        if v is not None and (not v or not v.strip()):
            raise ValueError('Title cannot be empty or whitespace')
        return v.strip() if v else None

class TaskResponse(BaseModel):
    id: UUID
    user_id: str
    title: str
    description: str | None
    status: TaskStatus
    priority: TaskPriority
    tags: list[str]
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True  # Pydantic v2 config for ORM mode
```

**Rationale**:
- Pydantic v2's `@field_validator` is more explicit than v1's `@validator`
- `Field()` constraints generate automatic OpenAPI documentation
- Validation happens before business logic, reducing error handling in services
- `from_attributes=True` allows converting SQLModel objects to Pydantic responses

**Alternatives Considered**:
- **Manual validation in service layer**: Rejected because it duplicates validation logic
- **Pydantic v1 style validators**: Rejected because v2 is current standard
- **No custom validators**: Rejected because spec requires empty string rejection and tag deduplication

---

## 6. FastAPI Exception Handling

### Decision: Global Exception Handlers with Structured Errors

**Approach**:
- Define custom exception classes for domain errors
- Register global exception handlers in `main.py`
- Return structured JSON error responses matching spec format
- Log errors with context (user_id, request_id) but don't expose to client

**Code Example**:
```python
# src/utils/errors.py
class TaskError(Exception):
    """Base exception for task-related errors"""
    def __init__(self, message: str, status_code: int = 400):
        self.message = message
        self.status_code = status_code
        super().__init__(self.message)

class TaskNotFoundError(TaskError):
    def __init__(self, task_id: str):
        super().__init__(f"Task {task_id} not found", status_code=404)

class UnauthorizedAccessError(TaskError):
    def __init__(self):
        super().__init__("Access denied", status_code=403)

# src/main.py
from fastapi import FastAPI, Request, status
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from src.utils.errors import TaskError
import logging

app = FastAPI()

@app.exception_handler(TaskError)
async def task_error_handler(request: Request, exc: TaskError):
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "error": {
                "code": exc.status_code,
                "message": exc.message
            }
        }
    )

@app.exception_handler(RequestValidationError)
async def validation_error_handler(request: Request, exc: RequestValidationError):
    # Convert Pydantic validation errors to spec format
    errors = exc.errors()
    error_messages = []
    for error in errors:
        field = " -> ".join(str(loc) for loc in error["loc"])
        error_messages.append(f"{field}: {error['msg']}")

    return JSONResponse(
        status_code=400,
        content={
            "error": {
                "code": 400,
                "message": "; ".join(error_messages)
            }
        }
    )

@app.exception_handler(Exception)
async def general_exception_handler(request: Request, exc: Exception):
    # Log full error with stack trace
    logging.error(f"Unhandled exception: {exc}", exc_info=True)

    # Return generic error to client (per FR-026)
    return JSONResponse(
        status_code=500,
        content={
            "error": {
                "code": 500,
                "message": "Internal server error"
            }
        }
    )
```

**Rationale**:
- Global handlers ensure consistent error format across all endpoints
- Custom exceptions make error handling explicit in service layer
- Logging captures full context for debugging without exposing to clients
- Matches spec requirement for structured JSON errors (FR-025)

**Alternatives Considered**:
- **HTTPException everywhere**: Rejected because it couples business logic to HTTP layer
- **Per-endpoint error handling**: Rejected because it leads to inconsistent error formats
- **Expose stack traces**: Rejected because spec explicitly forbids it (FR-026)

---

## 7. Database Indexing Strategy

### Decision: Composite Index on user_id + status

**Approach**:
- Primary key index on `id` (automatic with UUID primary key)
- Single-column index on `user_id` for user-scoped queries
- Single-column index on `status` for filtering
- Consider composite index `(user_id, status)` if filtering by status is common

**Code Example**:
```python
# In SQLModel (automatic single-column indexes)
class Task(SQLModel, table=True):
    id: UUID = Field(default_factory=uuid4, primary_key=True)
    user_id: str = Field(index=True)  # Creates: CREATE INDEX idx_task_user_id
    status: TaskStatus = Field(default=TaskStatus.TODO, index=True)  # Creates index

# For composite index, use SQLAlchemy directly
from sqlalchemy import Index

class Task(SQLModel, table=True):
    # ... fields ...

    __table_args__ = (
        Index('idx_user_status', 'user_id', 'status'),  # Composite index
    )

# Or via Alembic migration
"""
def upgrade():
    op.create_index('idx_tasks_user_id', 'tasks', ['user_id'])
    op.create_index('idx_tasks_status', 'tasks', ['status'])
    op.create_index('idx_tasks_user_status', 'tasks', ['user_id', 'status'])
"""
```

**Rationale**:
- Every query filters by `user_id`, so this index is critical (FR-033)
- Status filtering is common (completed vs todo), so indexing improves performance
- Composite index `(user_id, status)` covers both filters in one index lookup
- PostgreSQL query planner can use composite index for `user_id`-only queries too

**Alternatives Considered**:
- **No indexes**: Rejected because performance would degrade with large datasets
- **Index on tags**: Rejected because PostgreSQL GIN index would be needed for array queries (can add later)
- **Index on created_at**: Rejected because sorting by timestamp is less common than filtering by status

---

## 8. Partial Update Handling (PATCH Semantics)

### Decision: Pydantic's `model_dump(exclude_unset=True)`

**Approach**:
- Define `TaskUpdate` schema with all fields optional
- Use `.model_dump(exclude_unset=True)` to get only fields provided in request
- Update only those fields on the database model
- Automatically refresh `updated_at` timestamp on any update

**Code Example**:
```python
# src/schemas/task_schemas.py
class TaskUpdate(BaseModel):
    title: str | None = None
    description: str | None = None
    status: TaskStatus | None = None
    priority: TaskPriority | None = None
    tags: list[str] | None = None

# src/services/task_service.py
def update_task(self, task_id: UUID, task_update: TaskUpdate) -> Task:
    task = self.get_task_by_id(task_id)  # Verify ownership

    # Get only fields that were actually provided in request
    update_data = task_update.model_dump(exclude_unset=True)

    # Update only those fields
    for field, value in update_data.items():
        setattr(task, field, value)

    # Always refresh timestamp
    task.updated_at = datetime.utcnow()

    self.db.add(task)
    self.db.commit()
    self.db.refresh(task)
    return task
```

**Rationale**:
- `exclude_unset=True` distinguishes between "field not provided" and "field set to None"
- Meets spec requirement that PATCH only updates provided fields (FR-017)
- Simple and Pythonic approach without complex conditional logic
- Automatically handles edge cases (e.g., empty PATCH body → no changes except timestamp)

**Alternatives Considered**:
- **Manual field checking**: Rejected because it's error-prone and verbose
- **PUT instead of PATCH**: Rejected because spec explicitly requires PATCH semantics
- **JSON Patch RFC 6902**: Rejected because it's overly complex for this simple use case

---

## Summary of Decisions

| Area | Decision | Rationale |
|------|----------|-----------|
| **API Structure** | FastAPI APIRouter with layered architecture | Modularity, testability, dependency injection |
| **ORM** | SQLModel with hybrid models | Type safety, Pydantic integration, simplicity |
| **Database** | Neon PostgreSQL with connection pooling | Managed service, serverless compatibility |
| **Security** | Service layer with mandatory user_id scoping | Centralized authorization, prevents leakage |
| **Validation** | Pydantic v2 field validators | Declarative, auto-documented, reusable |
| **Error Handling** | Global exception handlers with structured JSON | Consistency, logging, spec compliance |
| **Indexing** | Single-column indexes on user_id and status | Query optimization per FR-033 |
| **PATCH Semantics** | `model_dump(exclude_unset=True)` | Simplicity, correctness per FR-017 |

---

## Technology Stack (Finalized)

**Core Dependencies**:
```
fastapi==0.109.0
sqlmodel==0.0.14
pydantic==2.5.0
uvicorn[standard]==0.27.0
psycopg2-binary==2.9.9
python-dotenv==1.0.0
```

**Development Dependencies**:
```
pytest==7.4.4
pytest-asyncio==0.23.3
httpx==0.26.0
alembic==1.13.1
```

---

## Next Steps

1. **Phase 1: Design & Contracts** - Create data-model.md, contracts/api-openapi.yaml, quickstart.md
2. **Update Agent Context** - Run update-agent-context.ps1 to inform agents of technology choices
3. **Generate Tasks** - Run /sp.tasks to create atomic implementation tasks
4. **Implementation** - Use fastapi-backend-agent and database-optimizer for code generation

---

**Research Status**: ✅ Complete
**All 8 research questions answered and decisions documented.**
