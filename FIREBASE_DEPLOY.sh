#!/bin/bash

# Firebase Web Hosting Deploy Script
# Asegura que se compila y despliegue correctamente a Firebase Hosting

set -e

echo "🚀 Flutter Firebase Hosting Deploy Script"
echo "=========================================="

# Detectar directorio del proyecto
if [ -d "./aparcamientoszaragoza" ]; then
    PROJECT_DIR="./aparcamientoszaragoza"
elif [ -f "pubspec.yaml" ]; then
    PROJECT_DIR="."
else
    PROJECT_DIR=$(find . -maxdepth 3 -type f -name pubspec.yaml | head -n1 | xargs -I{} dirname {})
fi

echo "📁 Project directory: $PROJECT_DIR"

# Step 1: Clean previous builds
echo ""
echo "🧹 Cleaning previous builds..."
cd "$PROJECT_DIR"
flutter clean
rm -rf build/web

# Step 2: Get dependencies
echo ""
echo "📦 Installing dependencies..."
flutter pub get

# Step 3: Build web release
echo ""
echo "🔨 Building web release..."
flutter build web --release --dart-define-from-file=.env.production.json 2>/dev/null || flutter build web --release

# Step 4: Verify build output
echo ""
echo "✅ Verifying build output..."
if [ ! -d "build/web" ]; then
    echo "❌ ERROR: build/web directory not found!"
    exit 1
fi

BUILD_FILES=$(find build/web -type f | wc -l)
echo "✅ Build successful! Found $BUILD_FILES files in build/web"
echo ""
ls -lh build/web/index.html

# Step 5: Deploy to Firebase
echo ""
echo "📤 Deploying to Firebase Hosting..."
cd - > /dev/null

# Check if firebase is installed
if ! command -v firebase &> /dev/null; then
    echo "⚠️  Firebase CLI not found. Installing..."
    npm install -g firebase-tools
fi

# Deploy only hosting
firebase deploy --only hosting --project aparcamientodisponible

echo ""
echo "✅ Deployment complete!"
echo "🌐 Check your site at: https://aparcamientodisponible.web.app"
