#!/bin/bash
# Production startup script for backend
# Handles PORT environment variable from hosting providers

PORT=${PORT:-8000}
HOST=${HOST:-0.0.0.0}

echo "Starting backend server on $HOST:$PORT"
cd "$(dirname "$0")"
uvicorn app.main:app --host $HOST --port $PORT
