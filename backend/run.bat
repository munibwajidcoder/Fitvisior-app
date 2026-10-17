@echo off
echo ========================================================
echo  DresKode 3D Avatar AI Backend Server
echo ========================================================

cd /d "%~dp0"

if exist ".venv\Scripts\python.exe" (
    echo [INFO] Starting FastAPI server using .venv...
    ".venv\Scripts\python.exe" -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
) else (
    where uv >nul 2>&1
    if %ERRORLEVEL% equ 0 (
        echo [INFO] Starting FastAPI server using uv...
        uv run uvicorn main:app --host 0.0.0.0 --port 8000 --reload
    ) else (
        echo [INFO] Starting FastAPI server using system python...
        python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
    )
)
pause
