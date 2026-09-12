@echo off
REM Build Flutter Web and copy to backend static resources for same-origin deployment
REM Usage: build_web.bat [/api]

set BASE_URL=%1
if "%BASE_URL%"=="" set BASE_URL=/api

set FRONTEND_DIR=%~dp0
set BACKEND_STATIC_DIR=%FRONTEND_DIR%..\backend\src\main\resources\static

echo Building Flutter Web with base URL: %BASE_URL%
cd /d "%FRONTEND_DIR%"

flutter clean
flutter pub get
flutter build web --dart-define=API_BASE_URL="%BASE_URL%" --release

echo Copying build output to backend static resources...
if exist "%BACKEND_STATIC_DIR%" rmdir /s /q "%BACKEND_STATIC_DIR%"
mkdir "%BACKEND_STATIC_DIR%"
xcopy /E /I /Y build\web\* "%BACKEND_STATIC_DIR%\"

echo Done! Flutter Web app is now served from backend at http://localhost:8080
echo Backend must be running to serve the frontend.