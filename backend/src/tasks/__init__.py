"""
Task management module - Phase I CRUD with Phase II authentication integration.

Note: This module contains minimal stub implementations to demonstrate
authentication integration. Full Phase I task logic should be imported
from the Phase I repository.
"""

from .task_service import create_task, list_tasks, update_task, delete_task

__all__ = [
    'create_task',
    'list_tasks',
    'update_task',
    'delete_task',
]
