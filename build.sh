#!/bin/bash

# Vercel build script for Flutter Web
set -e

echo "🚀 Starting Flutter Web build for Vercel..."

# Install Flutter if not present
if ! command -v flutter &> /dev/null; then
    echo "📥 Installing Flutter..."
    git clone https://github.com/flutter/flutter.git -b stable /opt/flutter
    export PATH="$PATH:/opt/flutter/bin"
fi

# Verify Flutter installation
echo "🔍 Flutter version:"
flutter --version

# Get dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Build for web with optimizations
echo "🏗️ Building Flutter web app..."
flutter build web \
  --release \
  --web-renderer html \
  --dart-define=FLUTTER_WEB_USE_SKIA=false \
  --source-maps

echo "✅ Build completed successfully!"
echo "📁 Build output is in build/web/"
