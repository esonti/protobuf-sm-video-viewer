import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../providers/stream_provider.dart';
import '../providers/user_provider.dart';
import '../providers/webrtc_provider.dart';
import '../widgets/video_player_widget.dart';
import '../widgets/stream_controls.dart';
import '../widgets/stream_info_panel.dart';

class StreamViewerScreen extends StatefulWidget {
  final String streamId;
  
  const StreamViewerScreen({Key? key, required this.streamId}) : super(key: key);
  
  @override
  _StreamViewerScreenState createState() => _StreamViewerScreenState();
}

class _StreamViewerScreenState extends State<StreamViewerScreen> {
  String? _currentSessionId;
  bool _isInitialized = false;
  bool _showControls = true;
  bool _showInfoPanel = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeStream();
    });
  }
  
  Future<void> _initializeStream() async {
    final streamProvider = Provider.of<StreamProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final webrtcProvider = Provider.of<WebRtcProvider>(context, listen: false);
    
    try {
      // Initialize WebRTC
      await webrtcProvider.initialize();
      
      // Load stream details
      await streamProvider.loadStreamDetails(widget.streamId);
      
      // Join the stream
      final joinResult = await streamProvider.joinStream(
        widget.streamId,
        userProvider.userId,
      );
      
      if (joinResult != null && joinResult['success'] == true) {
        // Record viewer activity - joined
        await streamProvider.recordActivity(
          viewerId: userProvider.userId,
          streamId: widget.streamId,
          action: 'VIEWER_ACTION_JOINED',
        );
        
        // Connect WebRTC
        await webrtcProvider.connectViaHTTP(widget.streamId);
        
        setState(() {
          _isInitialized = true;
        });
      } else {
        _showError('Failed to join stream');
      }
    } catch (e) {
      _showError('Error initializing stream: $e');
    }
  }
  
  @override
  void dispose() {
    if (_isInitialized) {
      _recordViewerLeft();
    }
    super.dispose();
  }
  
  Future<void> _recordViewerLeft() async {
    try {
      final streamProvider = Provider.of<StreamProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      await streamProvider.recordActivity(
        viewerId: userProvider.userId,
        streamId: widget.streamId,
        action: 'VIEWER_ACTION_LEFT',
      );
    } catch (e) {
      debugPrint('Failed to record viewer left: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }
  
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.info_outline, color: Colors.white),
          onPressed: () {
            setState(() {
              _showInfoPanel = !_showInfoPanel;
            });
          },
        ),
      ],
    );
  }
  
  Widget _buildBody() {
    if (!_isInitialized) {
      return _buildLoadingView();
    }
    
    return Stack(
      children: [
        // Video player
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _showControls = !_showControls;
              });
            },
            child: VideoPlayerWidget(),
          ),
        ),
        
        // Stream controls overlay
        if (_showControls)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: Duration(milliseconds: 300),
              child: StreamControls(
                streamId: widget.streamId,
                onTogglePlay: _togglePlayPause,
                onQualityChange: _changeQuality,
                onVolumeChange: _changeVolume,
              ),
            ),
          ),
        
        // Stream info panel
        if (_showInfoPanel)
          Positioned(
            top: AppBar().preferredSize.height + MediaQuery.of(context).padding.top,
            right: 0,
            bottom: 0,
            width: MediaQuery.of(context).size.width * 0.3,
            child: StreamInfoPanel(streamId: widget.streamId),
          ),
        
        // Connection status indicator
        Positioned(
          top: AppBar().preferredSize.height + MediaQuery.of(context).padding.top + 16,
          left: 16,
          child: _buildConnectionStatus(),
        ),
      ],
    );
  }
  
  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Connecting to stream...',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
  
  Widget _buildConnectionStatus() {
    return Consumer<WebRtcProvider>(
      builder: (context, webrtcProvider, child) {
        Color statusColor;
        String statusText;
        
        if (webrtcProvider.isConnected) {
          statusColor = Colors.green;
          statusText = 'Live';
        } else if (webrtcProvider.isConnecting) {
          statusColor = Colors.orange;
          statusText = 'Connecting';
        } else {
          statusColor = Colors.red;
          statusText = 'Disconnected';
        }
        
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 4),
              Text(
                statusText,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _togglePlayPause() async {
    // Record activity
    final streamProvider = Provider.of<StreamProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    // For demo purposes, we'll assume we're pausing/resuming
    await streamProvider.recordActivity(
      viewerId: userProvider.userId,
      streamId: widget.streamId,
      action: 'VIEWER_ACTION_PAUSED', // or VIEWER_ACTION_RESUMED
    );
    
    // Hide controls after interaction
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }
  
  void _changeQuality(String quality) async {
    // Record quality change activity
    final streamProvider = Provider.of<StreamProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    await streamProvider.recordActivity(
      viewerId: userProvider.userId,
      streamId: widget.streamId,
      action: 'VIEWER_ACTION_QUALITY_CHANGED',
      metadata: {'new_quality': quality},
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Quality changed to $quality')),
    );
  }
  
  void _changeVolume(double volume) async {
    // Update user preferences
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.updatePreference('volumeLevel', volume.round());
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Retry',
          onPressed: _initializeStream,
        ),
      ),
    );
  }
}
