// T024, T025, T026, T027, T028: TaskForm component with validation and submission

'use client';

import { useState, FormEvent } from 'react';
import { apiClient } from '@/lib/api';
import { Task, CreateTaskInput } from '@/lib/types';

interface TaskFormProps {
  onTaskCreated: () => void;
}

export default function TaskForm({ onTaskCreated }: TaskFormProps) {
  const [title, setTitle] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // T026: Form submission with POST /api/tasks
  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setError(null);

    // T025: Client-side validation - required title
    if (!title.trim()) {
      setError('Title is required');
      return;
    }

    setSubmitting(true);

    try {
      const taskInput: CreateTaskInput = {
        title: title.trim(),
      };

      // T026: POST /api/tasks
      await apiClient<Task>('/tasks', {
        method: 'POST',
        body: JSON.stringify(taskInput),
      });

      // T027: Update list state after successful creation
      setTitle(''); // Clear form
      onTaskCreated(); // Trigger parent to refresh task list
    } catch (err) {
      // T028: Error handling
      setError(err instanceof Error ? err.message : 'Failed to create task');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="mb-6">
      <form onSubmit={handleSubmit} className="flex gap-2">
        <div className="flex-1">
          <input
            type="text"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            placeholder="Enter task title..."
            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            disabled={submitting}
          />
        </div>
        <button
          type="submit"
          disabled={submitting}
          className="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:bg-gray-400 disabled:cursor-not-allowed"
        >
          {submitting ? 'Adding...' : 'Add Task'}
        </button>
      </form>

      {/* T028: Error display */}
      {error && (
        <div className="mt-2 p-2 bg-red-50 border border-red-200 text-red-700 text-sm rounded">
          {error}
        </div>
      )}
    </div>
  );
}
