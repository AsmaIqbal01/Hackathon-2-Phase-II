"""
Entry point for Hugging Face Spaces deployment.

This file is required by Hugging Face Spaces to identify the FastAPI application.
It imports and exposes the main FastAPI app instance.
"""
from src.main import app

# Hugging Face Spaces will automatically detect and run this app
if __name__ == "__main__":
    import uvicorn
    import os

    # Hugging Face Spaces uses port 7860 by default
    port = int(os.getenv("PORT", 7860))

    uvicorn.run(
        app,
        host="0.0.0.0",
        port=port,
        log_level="info"
    )
