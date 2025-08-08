# Makefile for Protobuf Sub-Module Video Viewer Flutter Implementation
# Uses buf CLI for all code generation

.PHONY: all clean proto-gen build run test flutter-deps

# Configuration
APP_NAME := video_viewer
GENERATED_DIR := lib/generated

# Default target
all: proto-gen flutter-deps build

# Clean generated files and build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	rm -rf $(GENERATED_DIR)
	flutter clean
	@echo "✅ Clean complete"

# Generate protocol buffer code using buf CLI
proto-gen:
	@echo "🔄 Generating protocol buffer code from GitHub APIs..."
	@echo "   APIs Implemented: github.com/esonti/protobuf-sm-video-viewer-api"
	@echo "   APIs Consumed:"
	@echo "   - github.com/esonti/protobuf-sm-timestamp-api"
	@echo "   - github.com/esonti/protobuf-sm-media-stream-api"
	buf generate
	@echo "✅ Code generation complete"

# Install Flutter dependencies
flutter-deps:
	@echo "📦 Installing Flutter dependencies..."
	flutter pub get
	@echo "✅ Flutter dependencies installed"

# Build the Flutter app
build: proto-gen flutter-deps
	@echo "🔨 Building Flutter video viewer app..."
	flutter build apk --debug
	@echo "✅ Build complete"

# Build for release
build-release: proto-gen flutter-deps
	@echo "🔨 Building Flutter app for release..."
	flutter build apk --release
	@echo "✅ Release build complete"

# Run the Flutter app
run: proto-gen flutter-deps
	@echo "🚀 Running Flutter video viewer app..."
	flutter run

# Run tests
test: proto-gen flutter-deps
	@echo "🧪 Running tests..."
	flutter test
	@echo "✅ Tests complete"

# Run widget tests
test-widget: proto-gen flutter-deps
	@echo "🧪 Running widget tests..."
	flutter test test/widget_test.dart
	@echo "✅ Widget tests complete"

# Run integration tests
test-integration: proto-gen flutter-deps
	@echo "🧪 Running integration tests..."
	flutter drive --target=test_driver/app.dart
	@echo "✅ Integration tests complete"

# Lint Dart code
lint-dart:
	@echo "🔍 Linting Dart code..."
	flutter analyze
	@echo "✅ Dart lint complete"

# Lint protocol buffers
lint:
	@echo "🔍 Linting protocol buffers..."
	buf lint
	@echo "✅ Protocol buffer lint complete"

# Format Dart code
format-dart:
	@echo "🎨 Formatting Dart code..."
	dart format lib/ test/
	@echo "✅ Dart format complete"

# Format protocol buffers
format:
	@echo "🎨 Formatting protocol buffers..."
	buf format --write
	@echo "✅ Protocol buffer format complete"

# Show dependency information
deps:
	@echo "📦 API Dependencies:"
	@echo "   APIs Implemented:"
	@echo "   - video-viewer-api (github.com/esonti/protobuf-sm-video-viewer-api)"
	@echo "   APIs Consumed:"
	@echo "   - timestamp-api (github.com/esonti/protobuf-sm-timestamp-api)"
	@echo "   - media-stream-api (github.com/esonti/protobuf-sm-media-stream-api)"
	buf mod ls-lint-deps

# Development mode with hot reload
dev: proto-gen flutter-deps
	@echo "🛠️  Starting development mode with hot reload..."
	flutter run --hot

# Help target
help:
	@echo "🚀 Protobuf Sub-Module Video Viewer Flutter App"
	@echo ""
	@echo "Available targets:"
	@echo "  proto-gen       Generate code from GitHub APIs"
	@echo "  flutter-deps    Install Flutter dependencies"
	@echo "  build           Build debug Flutter app"
	@echo "  build-release   Build release Flutter app"
	@echo "  run             Run the Flutter app"
	@echo "  dev             Development mode with hot reload"
	@echo "  test            Run all tests"
	@echo "  test-widget     Run widget tests"
	@echo "  test-integration Run integration tests"
	@echo "  clean           Clean build artifacts"
	@echo "  lint-dart       Lint Dart code"
	@echo "  lint            Lint protocol buffers"
	@echo "  format-dart     Format Dart code"
	@echo "  format          Format protocol buffers"
	@echo "  deps            Show API dependency information"
	@echo "  help            Show this help message"
