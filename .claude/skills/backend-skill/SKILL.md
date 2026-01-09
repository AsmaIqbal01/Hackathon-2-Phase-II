name: database-skill
description: Manage database operations including table creation, schema design, and migrations for relational databases like PostgreSQL, MySQL, or SQLite.
---

# Database Skill

## Purpose
This skill provides functionality to design, create, and maintain database schemas. It can be used by backend agents or any other systems requiring database operations, ensuring consistency, integrity, and best practices.

---

## Core Responsibilities

1. **Schema Design**
   - Design database schemas based on application requirements  
   - Normalize data where appropriate to avoid redundancy  
   - Define relationships between tables (one-to-one, one-to-many, many-to-many)  
   - Include indexes, unique constraints, and foreign keys to optimize queries  

2. **Table Creation**
   - Generate SQL statements or ORM models to create tables  
   - Ensure proper column types, default values, and constraints  
   - Support common relational databases (PostgreSQL, MySQL, SQLite)  

3. **Migrations**
   - Create migration scripts to modify schema without losing data  
   - Support version-controlled migrations for development and production  
   - Rollback migrations safely when necessary  
   - Keep schema changes consistent across multiple environments  

4. **Database Operations**
   - Validate schema changes before applying  
   - Suggest optimizations for queries and indexing  
   - Maintain database integrity and prevent common pitfalls  

---

## Best Practices

- Use descriptive table and column names  
- Enforce constraints to maintain data integrity  
- Keep migrations incremental and reversible  
- Use indexes wisely to improve query performance  
- Version-control all schema changes  
- Avoid destructive operations in production without backups  

---

## Example Usage

```python
from sqlalchemy import Column, Integer, String, ForeignKey, create_engine, MetaData
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship, sessionmaker

Base = declarative_base()
engine = create_engine("postgresql://user:pass@localhost/dbname")
Session = sessionmaker(bind=engine)
session = Session()

# Schema design example
class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True)
    email = Column(String, unique=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    posts = relationship("Post", back_populates="author")

class Post(Base):
    __tablename__ = "posts"
    id = Column(Integer, primary_key=True)
    title = Column(String, nullable=False)
    content = Column(String)
    author_id = Column(Integer, ForeignKey("users.id"))
    author = relationship("User", back_populates="posts")

# Create tables
Base.metadata.create_all(engine)

# Migration example: add a new column (SQLAlchemy Alembic)
# alembic revision --autogenerate -m "Add last_login column"
