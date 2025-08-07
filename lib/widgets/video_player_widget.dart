import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../providers/webrtc_provider.dart';

class VideoPlayerWidget extends StatefulWidget {
  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  final RTCVideoRenderer _renderer = RTCVideoRenderer();
  bool _isRendererInitialized = false;
  
  @override
  void initState() {
    super.initState();
    _initRenderer();
  }
  
  Future<void> _initRenderer() async {
    await _renderer.initialize();
    setState(() {
      _isRendererInitialized = true;
    });
  }
  
  @override
  void dispose() {
    _renderer.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<WebRtcProvider>(
      builder: (context, webrtcProvider, child) {
        if (!_isRendererInitialized) {
          return _buildLoadingView();
        }
        
        if (webrtcProvider.remoteStream != null) {
          _renderer.srcObject = webrtcProvider.remoteStream;
        }
        
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          child: webrtcProvider.remoteStream != null
              ? RTCVideoView(
                  _renderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                )
              : _buildNoStreamView(webrtcProvider),
        );
      },
    );
  }
  
  Widget _buildLoadingView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Initializing video player...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNoStreamView(WebRtcProvider webrtcProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.videocam_off,
            size: 64,
            color: Colors.white54,
          ),
          SizedBox(height: 16),
          Text(
            webrtcProvider.isConnecting 
                ? 'Connecting to stream...'
                : webrtcProvider.error != null
                    ? 'Connection failed'
                    : 'No video stream',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          if (webrtcProvider.error != null) ...[
            SizedBox(height: 8),
            Text(
              webrtcProvider.error!,
              style: TextStyle(
                color: Colors.red[300],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (webrtcProvider.isConnecting) ...[
            SizedBox(height: 16),
            CircularProgressIndicator(color: Colors.white),
          ],
        ],
      ),
    );
  }
}
