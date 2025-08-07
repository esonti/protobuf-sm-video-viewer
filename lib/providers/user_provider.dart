import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  String _userId = '';
  String _username = '';
  String _displayName = '';
  Map<String, dynamic> _preferences = {};
  bool _isLoggedIn = false;
  
  // Getters
  String get userId => _userId;
  String get username => _username;
  String get displayName => _displayName;
  Map<String, dynamic> get preferences => _preferences;
  bool get isLoggedIn => _isLoggedIn;
  
  // Initialize user from storage
  Future<void> initializeUser() async {
    final prefs = await SharedPreferences.getInstance();
    
    _userId = prefs.getString('user_id') ?? '';
    _username = prefs.getString('username') ?? '';
    _displayName = prefs.getString('display_name') ?? '';
    _isLoggedIn = _userId.isNotEmpty;
    
    // Load preferences
    _preferences = {
      'preferredQuality': prefs.getString('preferred_quality') ?? 'STREAM_QUALITY_HIGH',
      'autoPlay': prefs.getBool('auto_play') ?? true,
      'volumeLevel': prefs.getInt('volume_level') ?? 80,
      'enableSubtitles': prefs.getBool('enable_subtitles') ?? false,
      'preferredLanguage': prefs.getString('preferred_language') ?? 'en',
      'theme': prefs.getString('theme') ?? 'VIEWER_THEME_AUTO',
    };
    
    notifyListeners();
  }
  
  // Login user
  Future<void> loginUser({
    required String userId,
    required String username,
    String? displayName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    _userId = userId;
    _username = username;
    _displayName = displayName ?? username;
    _isLoggedIn = true;
    
    // Save to storage
    await prefs.setString('user_id', _userId);
    await prefs.setString('username', _username);
    await prefs.setString('display_name', _displayName);
    
    notifyListeners();
  }
  
  // Logout user
  Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.remove('user_id');
    await prefs.remove('username');
    await prefs.remove('display_name');
    
    _userId = '';
    _username = '';
    _displayName = '';
    _isLoggedIn = false;
    
    notifyListeners();
  }
  
  // Update user profile
  Future<void> updateProfile({
    String? username,
    String? displayName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (username != null) {
      _username = username;
      await prefs.setString('username', _username);
    }
    
    if (displayName != null) {
      _displayName = displayName;
      await prefs.setString('display_name', _displayName);
    }
    
    notifyListeners();
  }
  
  // Update preferences
  Future<void> updatePreferences(Map<String, dynamic> newPreferences) async {
    final prefs = await SharedPreferences.getInstance();
    
    _preferences.addAll(newPreferences);
    
    // Save individual preferences to storage
    for (final entry in newPreferences.entries) {
      final key = entry.key;
      final value = entry.value;
      
      if (value is String) {
        await prefs.setString(key, value);
      } else if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      }
    }
    
    notifyListeners();
  }
  
  // Get specific preference
  T getPreference<T>(String key, T defaultValue) {
    return _preferences[key] as T? ?? defaultValue;
  }
  
  // Update single preference
  Future<void> updatePreference<T>(String key, T value) async {
    await updatePreferences({key: value});
  }
  
  // Generate a temporary user ID for demo purposes
  void generateTemporaryUser() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _userId = 'user_$timestamp';
    _username = 'viewer_$timestamp';
    _displayName = 'Viewer $timestamp';
    _isLoggedIn = true;
    
    notifyListeners();
  }
  
  // Get device info for session tracking
  Map<String, dynamic> getDeviceInfo() {
    return {
      'device_type': _getDeviceType(),
      'os': _getOperatingSystem(),
      'app_version': '1.0.0',
      'screen_info': {
        'width': 0, // Would be populated from MediaQuery
        'height': 0,
        'density': 1.0,
        'is_fullscreen': false,
      },
      'network_info': {
        'connection_type': 'wifi', // Simplified
        'quality': 'excellent',
        'estimated_bandwidth': 0,
      },
    };
  }
  
  String _getDeviceType() {
    if (defaultTargetPlatform == TargetPlatform.iOS || 
        defaultTargetPlatform == TargetPlatform.android) {
      return 'mobile';
    } else if (defaultTargetPlatform == TargetPlatform.macOS ||
               defaultTargetPlatform == TargetPlatform.windows ||
               defaultTargetPlatform == TargetPlatform.linux) {
      return 'desktop';
    }
    return 'unknown';
  }
  
  String _getOperatingSystem() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'iOS';
      case TargetPlatform.android:
        return 'Android';
      case TargetPlatform.macOS:
        return 'macOS';
      case TargetPlatform.windows:
        return 'Windows';
      case TargetPlatform.linux:
        return 'Linux';
      default:
        return 'Unknown';
    }
  }
}
