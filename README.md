# Video Viewer Flutter Application

A Flutter application for viewing WebRTC video streams with integrated timestamp tracking and comprehensive viewing analytics.

## Overview

The Video Viewer app provides a rich video streaming experience with:
- **Real-time WebRTC Streaming**: Direct peer-to-peer video streaming
- **Timestamp Integration**: Precise activity tracking using the Timestamp service
- **Stream Discovery**: Browse and search available streams
- **User Preferences**: Customizable quality, volume, and interface settings
- **Activity Tracking**: Record viewing behaviors with timestamps
- **Multi-service Integration**: Consumes APIs from Media Stream and Timestamp services

## Features

### Core Functionality
- Browse available video streams
- Real-time video playback via WebRTC
- Adaptive quality streaming
- Volume and playback controls
- Fullscreen viewing mode

### User Experience
- Search and filter streams
- User profiles and preferences
- Viewing history tracking
- Dark/light theme support
- Responsive design for multiple screen sizes

### Integration
- **Timestamp Service**: Precise timestamp generation for all activities
- **Media Stream Service**: Stream discovery and WebRTC signaling
- **Central Registry**: Unified API access via Protocol Buffers

## Prerequisites

### Development Environment
- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / Xcode for mobile development
- VS Code or preferred IDE

### System Dependencies
```bash
# macOS
brew install protobuf

# Ubuntu/Debian
sudo apt-get install protobuf-compiler

# Install Protocol Buffer plugins for Dart
dart pub global activate protoc_plugin
```

## Setup

### 1. Clone Repository
```bash
git clone <protobuf-sm-video-viewer-repo>
cd protobuf-sm-video-viewer
```

### 2. Copy API Definitions
```bash
# Copy proto files from central registry
mkdir -p lib/proto/gen/dart
cp -r ../central-registry/timestamp lib/proto/
cp -r ../central-registry/mediastream lib/proto/
cp -r ../central-registry/videoviewer lib/proto/

# Generate Dart protobuf code
protoc --proto_path=lib/proto \
       --dart_out=grpc:lib/proto/gen/dart \
       lib/proto/timestamp/timestamp.proto \
       lib/proto/mediastream/media_stream.proto \
       lib/proto/videoviewer/video_viewer.proto
```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Configure Services
Update service addresses in `lib/services/grpc_service.dart`:
```dart
// Update these constants with your service addresses
static const String _timestampServiceAddress = 'your-timestamp-service';
static const int _timestampServicePort = 50051;
static const String _mediaStreamServiceAddress = 'your-media-stream-service';
static const int _mediaStreamServicePort = 50052;
```

### 5. Run the Application
```bash
# For development
flutter run

# For Android
flutter run -d android

# For iOS  
flutter run -d ios

# For web
flutter run -d chrome
```

## Project Structure

```
lib/
├── main.dart                    # App entry point and routing
├── services/
│   └── grpc_service.dart       # gRPC client for all services
├── providers/                  # State management
│   ├── user_provider.dart      # User authentication and preferences
│   ├── stream_provider.dart    # Stream management and API calls
│   └── webrtc_provider.dart    # WebRTC connection management
├── screens/                    # UI screens
│   ├── home_screen.dart        # Stream browsing and discovery
│   ├── stream_viewer_screen.dart # Video playback interface
│   └── profile_screen.dart     # User profile and settings
├── widgets/                    # Reusable UI components
│   ├── stream_list_item.dart   # Stream list display component
│   ├── video_player_widget.dart # WebRTC video renderer
│   ├── stream_controls.dart    # Playback controls
│   └── stream_info_panel.dart  # Stream metadata display
└── proto/                      # Protocol Buffer definitions
    ├── gen/dart/              # Generated Dart code
    ├── timestamp/             # Timestamp API definitions
    ├── mediastream/           # Media Stream API definitions
    └── videoviewer/           # Video Viewer API definitions
```

## Usage

### Starting the App

1. **Launch**: Open the app to see available streams
2. **Browse**: Search and filter streams by title, publisher, or quality
3. **Watch**: Tap a stream to start viewing
4. **Control**: Use playback controls for quality, volume, and fullscreen
5. **Profile**: Access settings and viewing history

### Key Interactions

**Stream Browsing**:
- Search by title, description, or publisher
- Filter by quality (4K, HD, SD, Low)
- Filter by status (Live, Preparing)
- Refresh to get latest streams

**Video Viewing**:
- Tap to show/hide controls
- Play/pause with central button
- Adjust volume with slider
- Change quality with quality button
- Toggle fullscreen mode
- View stream info panel

**User Management**:
- Automatic temporary user generation for demo
- Customizable preferences (quality, volume, theme)
- Viewing history tracking
- Activity recording with timestamps

## API Integration

### Timestamp Service Integration
```dart
// Get current timestamp for activity tracking
final timestamp = await grpcService.getCurrentTimestamp(
  source: 'video-viewer-app:user_123',
  precision: 'TIMESTAMP_PRECISION_NANOSECONDS',
);

// Record viewer activity
await grpcService.recordViewerActivity(
  viewerId: userId,
  streamId: streamId,
  action: 'VIEWER_ACTION_JOINED',
);
```

### Media Stream Service Integration
```dart
// Get available streams
final streams = await grpcService.getAvailableStreams();

// Join a stream
final result = await grpcService.joinStream(
  streamId: streamId,
  viewerId: userId,
  webrtcAnswer: answer,
);
```

### WebRTC Integration
```dart
// Connect to stream
await webrtcProvider.connectViaHTTP(streamId);

// Handle video rendering
return RTCVideoView(renderer);
```

## Configuration

### Service Endpoints
Configure service addresses in `lib/services/grpc_service.dart`.

### User Preferences
Stored locally using SharedPreferences:
- Preferred video quality
- Volume level
- Auto-play setting
- Subtitle preferences
- Theme selection

### WebRTC Configuration
Update STUN/TURN servers in `lib/providers/webrtc_provider.dart`:
```dart
final Map<String, dynamic> _configuration = {
  'iceServers': [
    {'urls': 'stun:stun.l.google.com:19302'},
    // Add TURN servers for production
  ],
};
```

## Building for Production

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter drive --target=test_driver/app.dart
```

### Manual Testing Checklist
- [ ] Stream browsing and search
- [ ] Video playback with WebRTC
- [ ] Quality adjustment
- [ ] Volume control
- [ ] User preferences persistence
- [ ] Activity tracking
- [ ] Error handling and recovery

## Performance Optimization

### WebRTC Performance
- Implement connection quality monitoring
- Add adaptive bitrate streaming
- Handle network interruptions gracefully
- Optimize video rendering for different screen sizes

### App Performance
- Implement lazy loading for stream lists
- Use efficient state management
- Optimize image and asset loading
- Minimize rebuild cycles

## Troubleshooting

### Common Issues

**gRPC Connection Errors**:
- Verify service addresses and ports
- Check network connectivity
- Ensure services are running

**WebRTC Connection Failures**:
- Check STUN/TURN server configuration
- Verify WebRTC permissions
- Test with different networks

**Video Playback Issues**:
- Verify video codec support
- Check device hardware acceleration
- Monitor memory usage

### Debug Mode
Enable debug logging by setting log level in main.dart:
```dart
Logger.level = Level.debug;
```

## Contributing

1. Follow Flutter style guidelines
2. Add tests for new features
3. Update documentation
4. Test on multiple platforms

## Dependencies

### Core Flutter Packages
- `flutter_webrtc`: WebRTC functionality
- `grpc`: Protocol Buffer gRPC client
- `provider`: State management
- `shared_preferences`: Local storage

### UI Packages  
- `cupertino_icons`: iOS-style icons

### Utility Packages
- `http`: HTTP networking
- `web_socket_channel`: WebSocket support
- `logger`: Logging functionality
- `intl`: Internationalization

## License

[Your license information]
