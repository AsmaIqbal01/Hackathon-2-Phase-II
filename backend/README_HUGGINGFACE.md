---
title: Todo Backend API
emoji: 📝
colorFrom: blue
colorTo: green
sdk: docker
pinned: false
license: mit
---

# Todo Backend API

A production-ready FastAPI backend for multi-user Todo management with JWT authentication and user ownership enforcement.

## Features

- 🔐 JWT-based authentication
- 👤 User registration and login
- ✅ Full CRUD operations for todos
- 🔒 User ownership enforcement
- 📊 SQLite database (can be upgraded to PostgreSQL)
- 🚀 RESTful API design
- 📝 Automatic API documentation (Swagger UI)

## API Documentation

Once deployed, access the interactive API documentation at:
- Swagger UI: `https://your-space-name.hf.space/docs`
- ReDoc: `https://your-space-name.hf.space/redoc`

## Environment Variables

Configure these in the Hugging Face Space settings:

- `ENVIRONMENT`: Set to `production`
- `SECRET_KEY`: Your JWT secret key (generate a secure random string)
- `CORS_ORIGINS`: Comma-separated list of allowed origins (e.g., `https://your-frontend.vercel.app`)
- `DATABASE_URL`: Optional - for PostgreSQL (default uses SQLite)

## Endpoints

### Authentication
- `POST /api/register` - Register a new user
- `POST /api/login` - Login and get JWT token

### Tasks
- `GET /api/tasks` - Get all user's tasks
- `POST /api/tasks` - Create a new task
- `GET /api/tasks/{id}` - Get a specific task
- `PUT /api/tasks/{id}` - Update a task
- `PATCH /api/tasks/{id}` - Partially update a task
- `DELETE /api/tasks/{id}` - Delete a task

## Usage

All task endpoints require authentication. Include the JWT token in the Authorization header:

```
Authorization: Bearer <your-jwt-token>
```

## Tech Stack

- FastAPI
- SQLModel/SQLAlchemy
- Pydantic
- PyJWT
- Uvicorn
- PostgreSQL/SQLite
