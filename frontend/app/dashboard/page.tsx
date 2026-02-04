// T017, T018: Dashboard page with auth check and task fetching

'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { apiClient } from '@/lib/api';
import { isAuthenticated, clearToken } from '@/lib/auth';
import { Task } from '@/lib/types';
import TaskList from '@/components/TaskList';
import TaskForm from '@/components/TaskForm';

export default function DashboardPage() {
  const router = useRouter();
  const [tasks, setTasks] = useState<Task[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // T017: Auth check - redirect unauthenticated users
  useEffect(() => {
    if (!isAuthenticated()) {
      router.push('/login');
    }
  }, [router]);

  // T018: Fetch tasks from GET /api/tasks
  const fetchTasks = async () => {
    setLoading(true);
    setError(null);

    try {
      const data = await apiClient<Task[]>('/tasks', {
        method: 'GET',
      });
      setTasks(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load tasks');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (isAuthenticated()) {
      fetchTasks();
    }
  }, []);

  // T038: Logout logic - clear token and redirect to /login
  const handleLogout = () => {
    clearToken();
    router.push('/login');
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-4xl mx-auto py-8 px-4">
        <div className="bg-white shadow rounded-lg p-6">
          <div className="flex items-center justify-between mb-6">
            <h1 className="text-2xl font-bold">My Tasks</h1>
            {/* T037: Logout button */}
            <button
              onClick={handleLogout}
              className="px-4 py-2 text-sm bg-gray-600 text-white rounded hover:bg-gray-700"
            >
              Logout
            </button>
          </div>

          <TaskForm onTaskCreated={fetchTasks} />

          <TaskList
            tasks={tasks}
            loading={loading}
            error={error}
            onTaskUpdate={fetchTasks}
          />
        </div>
      </div>
    </div>
  );
}
