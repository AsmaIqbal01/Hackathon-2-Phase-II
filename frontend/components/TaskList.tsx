// T019, T021, T022, T023: TaskList component with loading/error/empty states

import { Task } from '@/lib/types';
import TaskItem from './TaskItem';

interface TaskListProps {
  tasks: Task[];
  loading: boolean;
  error: string | null;
  onTaskUpdate: () => void;
}

export default function TaskList({ tasks, loading, error, onTaskUpdate }: TaskListProps) {
  // T021: Loading state
  if (loading) {
    return (
      <div className="text-center py-8">
        <p className="text-gray-500">Loading tasks...</p>
      </div>
    );
  }

  // T023: Error state
  if (error) {
    return (
      <div className="bg-red-50 border border-red-200 text-red-700 rounded p-4">
        <p className="font-medium">Error loading tasks</p>
        <p className="text-sm mt-1">{error}</p>
      </div>
    );
  }

  // T022: Empty state
  if (tasks.length === 0) {
    return (
      <div className="text-center py-8 bg-gray-50 rounded border border-gray-200">
        <p className="text-gray-500">No tasks yet. Create your first task above!</p>
      </div>
    );
  }

  // Task list
  return (
    <div className="space-y-2">
      {tasks.map((task) => (
        <TaskItem key={task.id} task={task} onUpdate={onTaskUpdate} />
      ))}
    </div>
  );
}
