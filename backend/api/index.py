"""Vercel serverless function entry point for FastAPI.

This file serves as the entry point for Vercel's serverless Python runtime.
It imports and exposes the FastAPI application from src/main.py.
"""
import sys
from pathlib import Path

# Add the backend directory to the Python path
backend_dir = Path(__file__).parent.parent
sys.path.insert(0, str(backend_dir))

# Import the FastAPI app
from src.main import app

# Vercel expects an 'app' variable for ASGI applications
# The app is already defined in src/main.py, so we just re-export it
