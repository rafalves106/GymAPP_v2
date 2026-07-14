#!/bin/bash
# GymApp Release Build Script
# Builds the iOS app for release (for personal iPhone deployment)

set -e

echo "🔨 Building GymApp for iOS release..."

# Clean first
echo "Cleaning previous builds..."
flutter clean

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Run code generation if needed
# flutter pub run build_runner build --delete-conflicting-outputs

# Analyze
echo "Running analysis..."
flutter analyze

# Run tests
echo "Running tests..."
flutter test

# Build iOS release (no codesign for development, use for TestFlight/App Store)
echo "Building iOS release..."
flutter build ios --release --no-codesign

echo ""
echo "✅ Build complete!"
echo ""
echo "📱 To deploy to your iPhone:"
echo "   1. Open ios/Runner.xcworkspace in Xcode"
echo "   2. Select your iPhone as the build target"
echo "   3. Set your signing team (Personal Team or Apple Developer)"
echo "   4. Click Run (▶) or use Product > Archive for TestFlight"
echo ""
echo "🔧 For development (with hot reload):"
echo "   flutter run --release"
echo ""
