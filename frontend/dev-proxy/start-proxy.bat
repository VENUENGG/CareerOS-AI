@echo off
REM CareerOS Frontend Development Proxy - Windows
REM Serves Flutter Web and proxies /api/* to Spring Boot backend

cd /d "%~dp0"

echo ╔══════════════════════════════════════════════════════════╗
echo ║  CareerOS Frontend Development Proxy (Windows)            ║
echo ╚══════════════════════════════════════════════════════════╝
echo.
echo Prerequisites:
echo   1. Backend running on http://localhost:8080
echo   2. Flutter built: flutter build web --release --dart-define=API_BASE_URL=/api
echo.
echo Starting proxy on http://localhost:3000 ...
echo Proxying /api/* -> http://localhost:8080
echo.

REM Check if node_modules exists
if not exist "node_modules" (
    echo Installing dependencies...
    npm install
    if errorlevel 1 (
        echo Failed to install dependencies
        pause
        exit /b 1
    )
)

echo Starting proxy server...
node proxy.js

pause