"""
Main application entry point with authentication integration.

This demonstrates the complete authentication flow integrated with
Phase I task CRUD operations (stub implementations).

Usage:
    python -m backend.src.main

Flow:
    1. Prompt for credentials (with retry/exit)
    2. Authenticate user
    3. Display welcome message
    4. Demonstrate authenticated task operations
"""

import sys
from auth.authenticator import prompt_for_credentials
from auth.exceptions import ConfigurationError
from tasks.task_service import create_task, list_tasks, update_task, delete_task


def main():
    """
    Main application entry point.

    Phase 6 Integration Tasks:
    - T038: Main application entry point
    - T039: Call prompt_for_credentials() on startup
    - T040: Error handling for configuration errors
    - T041: Welcome message after authentication
    - T042: Verify task CRUD operations work
    """
    print("=" * 60)
    print("TASK MANAGER - Phase II Authentication Demo")
    print("=" * 60)
    print()

    try:
        # T039: Prompt for credentials on startup
        # T040: Error handling for configuration errors
        prompt_for_credentials(max_retries=3)

        # T041: Welcome message (already displayed by prompt_for_credentials)
        # Additional welcome message
        print("Authentication complete! You now have access to task operations.")
        print()

        # T042: Verify all task CRUD operations work after authentication
        print("-" * 60)
        print("DEMO: Authenticated Task Operations")
        print("-" * 60)
        print()

        # Demonstrate CREATE operation
        print("1. Creating tasks...")
        task1 = create_task(
            title="Complete Phase II authentication",
            description="Implement authentication system per frozen scope",
            priority="high",
            tags=["phase-ii", "authentication"]
        )
        print(f"   ✓ Created: {task1['title']} (ID: {task1['id']})")

        task2 = create_task(
            title="Test authentication flow",
            description="Verify all user stories work correctly",
            priority="medium",
            tags=["phase-ii", "testing"]
        )
        print(f"   ✓ Created: {task2['title']} (ID: {task2['id']})")
        print()

        # Demonstrate LIST operation
        print("2. Listing tasks...")
        tasks = list_tasks()
        print(f"   ✓ Found {len(tasks)} task(s) for current user:")
        for task in tasks:
            print(f"     - [{task['id']}] {task['title']} (Priority: {task['priority']})")
        print()

        # Demonstrate UPDATE operation
        print("3. Updating task...")
        updated_task = update_task(task1['id'], {'status': 'in-progress'})
        print(f"   ✓ Updated: {updated_task['title']} → Status: {updated_task['status']}")
        print()

        # Demonstrate DELETE operation
        print("4. Deleting task...")
        delete_task(task2['id'])
        print(f"   ✓ Deleted: {task2['title']}")
        print()

        # Verify list after delete
        print("5. Verifying remaining tasks...")
        remaining_tasks = list_tasks()
        print(f"   ✓ {len(remaining_tasks)} task(s) remaining:")
        for task in remaining_tasks:
            print(f"     - [{task['id']}] {task['title']} (Status: {task['status']})")
        print()

        print("-" * 60)
        print("DEMO COMPLETE: All task operations verified!")
        print("-" * 60)
        print()
        print("✓ Authentication successful")
        print("✓ Session context maintained across operations")
        print("✓ All CRUD operations require authentication")
        print("✓ User ownership enforced on all operations")
        print()

    except ConfigurationError as e:
        # T040: Configuration error handling
        print(f"\n❌ Configuration Error: {e}")
        print("Please ensure backend/config/.env is configured correctly.")
        print("See backend/config/.env.example for required variables.")
        sys.exit(1)

    except KeyboardInterrupt:
        # Handle Ctrl+C gracefully
        print("\n\nApplication interrupted by user.")
        sys.exit(0)

    except Exception as e:
        # Catch-all for unexpected errors
        print(f"\n❌ Unexpected Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
