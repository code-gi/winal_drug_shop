#!/bin/bash

# Pre-deployment test script for Flutter Web
set -e

echo "🧪 Running pre-deployment tests for Flutter Web..."

# Check Flutter installation
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

echo "✅ Flutter is installed"
flutter --version

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Run flutter analyze
echo "🔍 Running Flutter analyze..."
# flutter analyze

# Test web build
echo "🏗️ Testing web build..."
flutter build web --release

# Check if build was successful
if [ -d "build/web" ]; then
    echo "✅ Web build successful!"
    echo "📁 Build output size:"
    du -sh build/web
    echo "📄 Generated files:"
    ls -la build/web/
else
    echo "❌ Web build failed!"
    exit 1
fi

# Optional: Start local server for testing
read -p "🌐 Do you want to start a local server to test the build? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🚀 Starting local server on http://localhost:8080"
    echo "Press Ctrl+C to stop the server"
    cd build/web && python -m http.server 8080
fi

echo "🎉 Pre-deployment checks completed successfully!"
echo "📋 Next steps:"
echo "   1. Commit your changes to Git"
echo "   2. Push to your repository"
echo "   3. Deploy to Vercel using the dashboard or CLI"
