#!/bin/bash
# Build script for Flutter web deployment
# Usage: ./build.sh [API_BASE_URL]

API_URL=${1:-"http://127.0.0.1:8000"}

echo "Building Flutter web app..."
echo "API Base URL: $API_URL"

flutter clean
flutter pub get
flutter build web --release --dart-define=API_BASE_URL=$API_URL

echo "Build complete! Output in build/web/"
echo "Deploy the build/web folder to your hosting provider."
