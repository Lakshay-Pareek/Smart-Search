@echo off
REM Production startup script for backend (Windows)
REM Handles PORT environment variable from hosting providers

if "%PORT%"=="" set PORT=8000
if "%HOST%"=="" set HOST=0.0.0.0

echo Starting backend server on %HOST%:%PORT%
cd /d %~dp0
uvicorn app.main:app --host %HOST% --port %PORT%
