#!/bin/bash
# CareerOS Frontend Development Proxy - Linux/macOS
# Serves Flutter Web and proxies /api/* to Spring Boot backend

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "╔══════════════════════════════════════════════════════════╗"
echo "║  CareerOS Frontend Development Proxy (Linux/macOS)        ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
echo "Prerequisites:"
echo "  1. Backend running on http://localhost:8080"
echo "  2. Flutter built: flutter build web --release --dart-define=API_BASE_URL=/api"
echo ""
echo "Starting proxy on http://localhost:3000 ..."
echo "Proxying /api/* -> http://localhost:8080"
echo ""

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    npm install
    if [ $? -ne 0 ]; then
        echo "Failed to install dependencies"
        exit 1
    fi
fi

echo "Starting proxy server..."
node proxy.js