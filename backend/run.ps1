Write-Host "========================================================" -ForegroundColor Cyan
Write-Host " DresKode 3D Avatar AI Backend Server" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

Set-Location -Path $PSScriptRoot

$venvPython = Join-Path $PSScriptRoot ".venv\Scripts\python.exe"

if (Test-Path $venvPython) {
    Write-Host "[INFO] Starting FastAPI server using .venv..." -ForegroundColor Green
    & $venvPython -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
} elseif (Get-Command uv -ErrorAction SilentlyContinue) {
    Write-Host "[INFO] Starting FastAPI server using uv..." -ForegroundColor Green
    uv run uvicorn main:app --host 0.0.0.0 --port 8000 --reload
} elseif (Get-Command python -ErrorAction SilentlyContinue) {
    Write-Host "[INFO] Starting FastAPI server using system python..." -ForegroundColor Yellow
    python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
} else {
    Write-Error "[ERROR] Python or .venv not found. Please install Python or setup .venv."
}
