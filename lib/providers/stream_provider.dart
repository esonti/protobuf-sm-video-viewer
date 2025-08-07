import 'package:flutter/foundation.dart';
import '../services/grpc_service.dart';

class StreamProvider extends ChangeNotifier {
  final GrpcService _grpcService;
  
  List<Map<String, dynamic>> _streams = [];
  Map<String, dynamic>? _currentStreamDetails;
  bool _isLoading = false;
  String? _error;
  
  StreamProvider(this._grpcService);
  
  // Getters
  List<Map<String, dynamic>> get streams => _streams;
  Map<String, dynamic>? get currentStreamDetails => _currentStreamDetails;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Load available streams
  Future<void> loadStreams() async {
    _setLoading(true);
    _clearError();
    
    try {
      _streams = await _grpcService.getAvailableStreams();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load streams: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Load stream details
  Future<void> loadStreamDetails(String streamId) async {
    _setLoading(true);
    _clearError();
    
    try {
      _currentStreamDetails = await _grpcService.getStreamDetails(streamId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load stream details: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Join a stream
  Future<Map<String, dynamic>?> joinStream(String streamId, String viewerId, {String? webrtcAnswer}) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _grpcService.joinStream(
        streamId: streamId,
        viewerId: viewerId,
        webrtcAnswer: webrtcAnswer,
      );
      
      // Update current stream details if successful
      if (result['success'] == true) {
        _currentStreamDetails = result['streamMetadata'];
        notifyListeners();
      }
      
      return result;
    } catch (e) {
      _setError('Failed to join stream: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  // Record viewer activity
  Future<void> recordActivity({
    required String viewerId,
    required String streamId,
    required String action,
    Map<String, String>? metadata,
  }) async {
    try {
      await _grpcService.recordViewerActivity(
        viewerId: viewerId,
        streamId: streamId,
        action: action,
        sessionMetadata: metadata,
      );
    } catch (e) {
      // Log error but don't show to user as this is background activity
      debugPrint('Failed to record viewer activity: $e');
    }
  }
  
  // Refresh streams
  Future<void> refreshStreams() async {
    await loadStreams();
  }
  
  // Clear current stream
  void clearCurrentStream() {
    _currentStreamDetails = null;
    notifyListeners();
  }
  
  // Filter streams by status
  List<Map<String, dynamic>> getStreamsByStatus(String status) {
    return _streams.where((stream) => stream['status'] == status).toList();
  }
  
  // Search streams by title
  List<Map<String, dynamic>> searchStreams(String query) {
    if (query.isEmpty) return _streams;
    
    return _streams.where((stream) {
      final title = stream['title']?.toString().toLowerCase() ?? '';
      final description = stream['description']?.toString().toLowerCase() ?? '';
      final publisherId = stream['publisherId']?.toString().toLowerCase() ?? '';
      final searchQuery = query.toLowerCase();
      
      return title.contains(searchQuery) || 
             description.contains(searchQuery) ||
             publisherId.contains(searchQuery);
    }).toList();
  }
  
  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
  }
}
