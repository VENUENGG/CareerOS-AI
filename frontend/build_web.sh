#!/bin/bash
# Build Flutter Web and copy to backend static resources for same-origin deployment
# Usage: ./build_web.sh [--base-url=/api]

set -e

BASE_URL="${1:-/api}"
FRONTEND_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_STATIC_DIR="${FRONTEND_DIR}/../backend/src/main/resources/static"

echo "Building Flutter Web with base URL: $BASE_URL"
cd "$FRONTEND_DIR"

flutter clean
flutter pub get
flutter build web --dart-define=API_BASE_URL="$BASE_URL" --release

echo "Copying build output to backend static resources..."
rm -rf "$BACKEND_STATIC_DIR"/*
cp -r build/web/* "$BACKEND_STATIC_DIR"/

echo "Done! Flutter Web app is now served from backend at http://localhost:8080"
echo "Backend must be running to serve the frontend."