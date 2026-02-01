# Data Model: F01-S02 Authentication & Security Integration

**Feature**: F01-S02-auth-security
**Date**: 2026-01-25
**Database**: Neon Serverless PostgreSQL

---

## Entity Relationship Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                          USERS                                   │
├─────────────────────────────────────────────────────────────────┤
│ id              UUID          PK                                 │
│ email           VARCHAR(255)  UNIQUE, NOT NULL (normalized)      │
│ password_hash   VARCHAR(255)  NOT NULL                           │
│ created_at      TIMESTAMP     DEFAULT NOW()                      │
│ updated_at      TIMESTAMP     DEFAULT NOW()                      │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ 1:N
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      REFRESH_TOKENS                              │
├─────────────────────────────────────────────────────────────────┤
│ id              UUID          PK                                 │
│ user_id         UUID          FK → users(id) ON DELETE CASCADE   │
│ token_hash      VARCHAR(64)   NOT NULL, UNIQUE (SHA-256 hex)     │
│ expires_at      TIMESTAMP     NOT NULL                           │
│ created_at      TIMESTAMP     DEFAULT NOW()                      │
│ revoked_at      TIMESTAMP     NULL (NULL if active)              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ N:1 (via user_id)
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                          TASKS                                   │
│                    (existing from F01-S01)                       │
├─────────────────────────────────────────────────────────────────┤
│ id              UUID          PK                                 │
│ user_id         UUID          FK → users(id) ON DELETE CASCADE   │
│ title           VARCHAR(255)  NOT NULL                           │
│ description     TEXT          NULL                               │
│ status          VARCHAR(50)   NOT NULL                           │
│ priority        VARCHAR(50)   NULL                               │
│ tags            TEXT[]        NULL                               │
│ created_at      TIMESTAMP     DEFAULT NOW()                      │
│ updated_at      TIMESTAMP     DEFAULT NOW()                      │
└─────────────────────────────────────────────────────────────────┘
```

---

## Entity: User

### Description
Represents an authenticated user in the system. Users own tasks and refresh tokens.

### Fields

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY, DEFAULT gen_random_uuid() | Unique identifier |
| `email` | VARCHAR(255) | UNIQUE, NOT NULL | User's email (normalized lowercase) |
| `password_hash` | VARCHAR(255) | NOT NULL | Bcrypt-hashed password |
| `created_at` | TIMESTAMP | DEFAULT NOW() | Account creation time |
| `updated_at` | TIMESTAMP | DEFAULT NOW() | Last profile update |

### SQLModel Definition

```python
from sqlmodel import SQLModel, Field
from uuid import UUID, uuid4
from datetime import datetime

class User(SQLModel, table=True):
    __tablename__ = "users"

    id: UUID = Field(default_factory=uuid4, primary_key=True)
    email: str = Field(max_length=255, unique=True, index=True)
    password_hash: str = Field(max_length=255)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
```

### Validation Rules

| Rule | Validation | Error Message |
|------|------------|---------------|
| Email format | Regex pattern for valid email | "Invalid email format" |
| Email uniqueness | Database UNIQUE constraint | "Email already registered" |
| Email normalization | Lowercase before storage | N/A (transparent) |
| Password minimum | >= 8 characters | "Password must be at least 8 characters" |
| Password complexity | At least one letter and one number | "Password must contain at least one letter and one number" |

### Indexes

```sql
CREATE UNIQUE INDEX idx_users_email ON users(email);
```

---

## Entity: RefreshToken

### Description
Represents an active or revoked refresh token for session management. Tokens are stored hashed for security.

### Fields

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY, DEFAULT gen_random_uuid() | Unique identifier |
| `user_id` | UUID | FOREIGN KEY → users(id), ON DELETE CASCADE | Token owner |
| `token_hash` | VARCHAR(64) | NOT NULL, UNIQUE | SHA-256 hash of raw token |
| `expires_at` | TIMESTAMP | NOT NULL | Token expiration time |
| `created_at` | TIMESTAMP | DEFAULT NOW() | Token issuance time |
| `revoked_at` | TIMESTAMP | NULL | Revocation time (NULL if active) |

### SQLModel Definition

```python
from sqlmodel import SQLModel, Field
from uuid import UUID, uuid4
from datetime import datetime
from typing import Optional

class RefreshToken(SQLModel, table=True):
    __tablename__ = "refresh_tokens"

    id: UUID = Field(default_factory=uuid4, primary_key=True)
    user_id: UUID = Field(foreign_key="users.id", index=True)
    token_hash: str = Field(max_length=64, unique=True, index=True)
    expires_at: datetime
    created_at: datetime = Field(default_factory=datetime.utcnow)
    revoked_at: Optional[datetime] = Field(default=None)
```

### State Transitions

```
                    ┌─────────────┐
                    │   CREATED   │
                    │  (active)   │
                    └──────┬──────┘
                           │
          ┌────────────────┼────────────────┐
          │                │                │
          ▼                ▼                ▼
    ┌───────────┐   ┌───────────┐   ┌───────────┐
    │  EXPIRED  │   │  REVOKED  │   │  ROTATED  │
    │ (natural) │   │ (logout)  │   │ (refresh) │
    └───────────┘   └───────────┘   └───────────┘
```

- **CREATED → EXPIRED**: expires_at < current_time
- **CREATED → REVOKED**: User logout (revoked_at set)
- **CREATED → ROTATED**: Token refresh (old token revoked, new token created)

### Indexes

```sql
CREATE INDEX idx_refresh_tokens_user_id ON refresh_tokens(user_id);
CREATE UNIQUE INDEX idx_refresh_tokens_token_hash ON refresh_tokens(token_hash);
CREATE INDEX idx_refresh_tokens_expires_at ON refresh_tokens(expires_at);
```

### Cleanup Query (periodic job)

```sql
-- Delete expired and revoked tokens older than 30 days
DELETE FROM refresh_tokens
WHERE (expires_at < NOW() OR revoked_at IS NOT NULL)
  AND created_at < NOW() - INTERVAL '30 days';
```

---

## Entity: Task (Existing from F01-S01)

### Description
Represents a todo task owned by a user. No changes required for F01-S02.

### Relationship Update

The Task entity already has a `user_id` field. The only change is that `user_id` will now come from verified JWT instead of client parameter.

### SQLModel Definition (Existing)

```python
class Task(SQLModel, table=True):
    __tablename__ = "tasks"

    id: UUID = Field(default_factory=uuid4, primary_key=True)
    user_id: str = Field(index=True)  # Will receive UUID from JWT
    title: str = Field(max_length=255)
    description: Optional[str] = Field(default=None)
    status: str = Field(default="todo")
    priority: Optional[str] = Field(default=None)
    tags: Optional[List[str]] = Field(default=None, sa_column=Column(ARRAY(String)))
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
```

### Note on user_id Type

The existing Task model uses `str` for user_id. For F01-S02 integration:
- Option A: Keep as `str`, convert UUID to string when storing
- Option B: Migrate to `UUID` type (requires migration)

**Decision**: Keep as `str` for backward compatibility. UUID.hex provides a valid string representation.

---

## Database Migration

### Migration: Add Users and RefreshTokens Tables

```python
# alembic/versions/xxx_add_auth_tables.py

def upgrade():
    # Create users table
    op.create_table(
        'users',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True,
                  server_default=sa.text('gen_random_uuid()')),
        sa.Column('email', sa.String(255), nullable=False),
        sa.Column('password_hash', sa.String(255), nullable=False),
        sa.Column('created_at', sa.DateTime(), server_default=sa.text('NOW()')),
        sa.Column('updated_at', sa.DateTime(), server_default=sa.text('NOW()')),
    )
    op.create_index('idx_users_email', 'users', ['email'], unique=True)

    # Create refresh_tokens table
    op.create_table(
        'refresh_tokens',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True,
                  server_default=sa.text('gen_random_uuid()')),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('token_hash', sa.String(64), nullable=False),
        sa.Column('expires_at', sa.DateTime(), nullable=False),
        sa.Column('created_at', sa.DateTime(), server_default=sa.text('NOW()')),
        sa.Column('revoked_at', sa.DateTime(), nullable=True),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
    )
    op.create_index('idx_refresh_tokens_user_id', 'refresh_tokens', ['user_id'])
    op.create_index('idx_refresh_tokens_token_hash', 'refresh_tokens', ['token_hash'], unique=True)

def downgrade():
    op.drop_table('refresh_tokens')
    op.drop_table('users')
```

---

## Relationships Summary

| Parent | Child | Relationship | On Delete |
|--------|-------|--------------|-----------|
| User | RefreshToken | 1:N | CASCADE |
| User | Task | 1:N | CASCADE |

---

## Query Patterns

### Find User by Email (Login)
```python
user = db.exec(select(User).where(User.email == email)).first()
```

### Find Active Refresh Token
```python
token = db.exec(
    select(RefreshToken)
    .where(RefreshToken.token_hash == computed_hash)
    .where(RefreshToken.revoked_at.is_(None))
    .where(RefreshToken.expires_at > datetime.utcnow())
).first()
```

### Revoke All User Tokens (Logout)
```python
db.exec(
    update(RefreshToken)
    .where(RefreshToken.user_id == user_id)
    .where(RefreshToken.revoked_at.is_(None))
    .values(revoked_at=datetime.utcnow())
)
```

### User's Tasks (with JWT auth)
```python
# user_id extracted from verified JWT
tasks = db.exec(
    select(Task).where(Task.user_id == str(user_id))
).all()
```
