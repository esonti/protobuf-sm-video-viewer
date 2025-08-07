import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'dart:async';

class WebRtcProvider extends ChangeNotifier {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  WebSocketChannel? _websocketChannel;
  
  bool _isConnected = false;
  bool _isConnecting = false;
  String? _error;
  String? _currentStreamId;
  
  // WebRTC configuration
  final Map<String, dynamic> _configuration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ],
  };
  
  // Getters
  RTCPeerConnection? get peerConnection => _peerConnection;
  MediaStream? get localStream => _localStream;
  MediaStream? get remoteStream => _remoteStream;
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String? get error => _error;
  String? get currentStreamId => _currentStreamId;
  
  // Initialize WebRTC
  Future<void> initialize() async {
    try {
      await _createPeerConnection();
    } catch (e) {
      _setError('Failed to initialize WebRTC: $e');
    }
  }
  
  // Create peer connection
  Future<void> _createPeerConnection() async {
    try {
      _peerConnection = await createPeerConnection(_configuration);
      
      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        _sendIceCandidate(candidate);
      };
      
      _peerConnection!.onAddStream = (MediaStream stream) {
        _remoteStream = stream;
        notifyListeners();
      };
      
      _peerConnection!.onRemoveStream = (MediaStream stream) {
        _remoteStream = null;
        notifyListeners();
      };
      
      _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
        switch (state) {
          case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
            _isConnected = true;
            _isConnecting = false;
            break;
          case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
          case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
          case RTCPeerConnectionState.RTCPeerConnectionStateClosed:
            _isConnected = false;
            _isConnecting = false;
            break;
          case RTCPeerConnectionState.RTCPeerConnectionStateConnecting:
            _isConnecting = true;
            _isConnected = false;
            break;
          default:
            break;
        }
        notifyListeners();
      };
      
    } catch (e) {
      throw Exception('Failed to create peer connection: $e');
    }
  }
  
  // Connect to stream via WebSocket
  Future<void> connectToStream(String streamId, {String? websocketUrl}) async {
    _setConnecting(true);
    _clearError();
    _currentStreamId = streamId;
    
    try {
      // Default WebSocket URL
      websocketUrl ??= 'ws://localhost:8080/ws';
      
      // Create WebSocket connection
      _websocketChannel = WebSocketChannel.connect(Uri.parse(websocketUrl));
      
      // Listen to WebSocket messages
      _websocketChannel!.stream.listen(
        (message) => _handleWebSocketMessage(message),
        onError: (error) => _setError('WebSocket error: $error'),
        onDone: () => _handleWebSocketDisconnect(),
      );
      
      // Send offer to join stream
      await _sendOffer(streamId);
      
    } catch (e) {
      _setError('Failed to connect to stream: $e');
      _setConnecting(false);
    }
  }
  
  // Connect via HTTP API
  Future<void> connectViaHTTP(String streamId, {String? httpUrl}) async {
    _setConnecting(true);
    _clearError();
    _currentStreamId = streamId;
    
    try {
      // Create offer
      RTCSessionDescription offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);
      
      // Send offer via HTTP
      // This would typically use the http package to POST to the media stream service
      // For now, we'll simulate the connection
      await Future.delayed(Duration(seconds: 1));
      
      // Simulate receiving answer
      // In real implementation, this would come from the HTTP response
      await _handleAnswer({
        'type': 'answer',
        'sdp': 'mock-answer-sdp',
      });
      
    } catch (e) {
      _setError('Failed to connect via HTTP: $e');
      _setConnecting(false);
    }
  }
  
  // Send offer
  Future<void> _sendOffer(String streamId) async {
    try {
      RTCSessionDescription offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);
      
      final message = {
        'type': 'offer',
        'streamId': streamId,
        'sdp': {
          'type': offer.type,
          'sdp': offer.sdp,
        },
      };
      
      _websocketChannel?.sink.add(jsonEncode(message));
    } catch (e) {
      _setError('Failed to send offer: $e');
    }
  }
  
  // Handle WebSocket messages
  void _handleWebSocketMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      final type = data['type'];
      
      switch (type) {
        case 'answer':
          _handleAnswer(data['sdp']);
          break;
        case 'ice-candidate':
          _handleIceCandidate(data['iceCandidate']);
          break;
        default:
          debugPrint('Unknown WebSocket message type: $type');
      }
    } catch (e) {
      _setError('Failed to handle WebSocket message: $e');
    }
  }
  
  // Handle answer
  Future<void> _handleAnswer(Map<String, dynamic> answerData) async {
    try {
      RTCSessionDescription answer = RTCSessionDescription(
        answerData['sdp'],
        answerData['type'],
      );
      
      await _peerConnection!.setRemoteDescription(answer);
    } catch (e) {
      _setError('Failed to handle answer: $e');
    }
  }
  
  // Handle ICE candidate
  Future<void> _handleIceCandidate(Map<String, dynamic> candidateData) async {
    try {
      RTCIceCandidate candidate = RTCIceCandidate(
        candidateData['candidate'],
        candidateData['sdpMid'],
        candidateData['sdpMLineIndex'],
      );
      
      await _peerConnection!.addCandidate(candidate);
    } catch (e) {
      _setError('Failed to handle ICE candidate: $e');
    }
  }
  
  // Send ICE candidate
  void _sendIceCandidate(RTCIceCandidate candidate) {
    if (_websocketChannel != null) {
      final message = {
        'type': 'ice-candidate',
        'streamId': _currentStreamId,
        'iceCandidate': {
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex,
        },
      };
      
      _websocketChannel!.sink.add(jsonEncode(message));
    }
  }
  
  // Handle WebSocket disconnect
  void _handleWebSocketDisconnect() {
    _isConnected = false;
    _isConnecting = false;
    _websocketChannel = null;
    notifyListeners();
  }
  
  // Disconnect from stream
  Future<void> disconnect() async {
    try {
      // Close peer connection
      await _peerConnection?.close();
      _peerConnection = null;
      
      // Close WebSocket
      await _websocketChannel?.sink.close();
      _websocketChannel = null;
      
      // Clean up streams
      await _localStream?.dispose();
      await _remoteStream?.dispose();
      _localStream = null;
      _remoteStream = null;
      
      _isConnected = false;
      _isConnecting = false;
      _currentStreamId = null;
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to disconnect: $e');
    }
  }
  
  // Get connection stats
  Future<Map<String, dynamic>> getConnectionStats() async {
    if (_peerConnection == null) {
      return {'error': 'No active connection'};
    }
    
    try {
      // Get basic connection info
      final connectionState = _peerConnection!.connectionState;
      final iceConnectionState = _peerConnection!.iceConnectionState;
      
      return {
        'connectionState': connectionState?.toString() ?? 'unknown',
        'iceConnectionState': iceConnectionState?.toString() ?? 'unknown',
        'isConnected': _isConnected,
        'isConnecting': _isConnecting,
        'streamId': _currentStreamId,
        'hasRemoteStream': _remoteStream != null,
      };
    } catch (e) {
      return {'error': 'Failed to get stats: $e'};
    }
  }
  
  // Helper methods
  void _setConnecting(bool connecting) {
    _isConnecting = connecting;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    debugPrint('WebRTC Error: $error');
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
  }
  
  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
