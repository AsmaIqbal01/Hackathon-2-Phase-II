// T020, T029, T030, T031, T032: TaskItem with toggle status functionality

'use client';

import { useState } from 'react';
import { Task, TaskStatus } from '@/lib/types';
import { apiClient } from '@/lib/api';

interface TaskItemProps {
  task: Task;
  onUpdate: () => void;
}

export default function TaskItem({ task, onUpdate }: TaskItemProps) {
  const [toggling, setToggling] = useState(false);
  const [deleting, setDeleting] = useState(false);

  // T030: Toggle status with PATCH /api/tasks/{id}
  const handleToggleStatus = async () => {
    setToggling(true);

    try {
      // Determine new status
      const newStatus: TaskStatus =
        task.status === 'completed' ? 'todo' : 'completed';

      // T030: PATCH request
      await apiClient(`/tasks/${task.id}`, {
        method: 'PATCH',
        body: JSON.stringify({ status: newStatus }),
      });

      // T031: Update list state after successful toggle
      onUpdate();
    } catch (err) {
      console.error('Failed to toggle task:', err);
    } finally {
      setToggling(false);
    }
  };

  // T034: Delete task with DELETE /api/tasks/{id}
  const handleDelete = async () => {
    if (!confirm('Are you sure you want to delete this task?')) {
      return;
    }

    setDeleting(true);

    try {
      // T034: DELETE request
      await apiClient(`/tasks/${task.id}`, {
        method: 'DELETE',
      });

      // T035: Remove from list state after successful deletion
      onUpdate();
    } catch (err) {
      console.error('Failed to delete task:', err);
    } finally {
      setDeleting(false);
    }
  };
  return (
    <div className="bg-white border border-gray-200 rounded-lg p-4 hover:shadow-md transition-shadow">
      <div className="flex items-start justify-between gap-4">
        <div className="flex-1">
          <h3 className="font-medium text-gray-900">{task.title}</h3>
          {task.description && (
            <p className="text-sm text-gray-600 mt-1">{task.description}</p>
          )}
          <div className="flex items-center gap-2 mt-2">
            <span
              className={`inline-block px-2 py-1 text-xs rounded ${
                task.status === 'completed'
                  ? 'bg-green-100 text-green-800'
                  : task.status === 'in-progress'
                  ? 'bg-yellow-100 text-yellow-800'
                  : 'bg-gray-100 text-gray-800'
              }`}
            >
              {task.status}
            </span>
            {task.priority && (
              <span className="text-xs text-gray-500">Priority: {task.priority}</span>
            )}
          </div>
        </div>

        <div className="flex items-center gap-2">
          {/* T029: Toggle button, T032: Loading state */}
          <button
            onClick={handleToggleStatus}
            disabled={toggling || deleting}
            className="px-3 py-1 text-sm bg-blue-600 text-white rounded hover:bg-blue-700 disabled:bg-gray-400 disabled:cursor-not-allowed"
          >
            {toggling ? '...' : task.status === 'completed' ? 'Undo' : 'Complete'}
          </button>

          {/* T033: Delete button, T036: Loading state */}
          <button
            onClick={handleDelete}
            disabled={toggling || deleting}
            className="px-3 py-1 text-sm bg-red-600 text-white rounded hover:bg-red-700 disabled:bg-gray-400 disabled:cursor-not-allowed"
          >
            {deleting ? '...' : 'Delete'}
          </button>
        </div>
      </div>
    </div>
  );
}
