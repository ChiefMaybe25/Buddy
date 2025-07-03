#!/bin/bash

# Kill all running uvicorn processes for the backend
echo "Stopping all running backend (uvicorn) processes..."
pkill -f "uvicorn app:app"

# Wait a moment to ensure processes are stopped
sleep 2

# Start the backend with 4 workers for parallel requests (no --reload for true parallelism)
echo "Starting backend with 4 workers (no reload)..."
uvicorn app:app --host 0.0.0.0 --port 8000 --workers 4 