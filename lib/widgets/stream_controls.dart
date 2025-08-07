import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class StreamControls extends StatefulWidget {
  final String streamId;
  final VoidCallback onTogglePlay;
  final Function(String) onQualityChange;
  final Function(double) onVolumeChange;
  
  const StreamControls({
    Key? key,
    required this.streamId,
    required this.onTogglePlay,
    required this.onQualityChange,
    required this.onVolumeChange,
  }) : super(key: key);
  
  @override
  _StreamControlsState createState() => _StreamControlsState();
}

class _StreamControlsState extends State<StreamControls> {
  bool _isPlaying = true;
  bool _showVolumeSlider = false;
  
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final volumeLevel = userProvider.getPreference('volumeLevel', 80);
        
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withOpacity(0.8),
                Colors.transparent,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_showVolumeSlider) _buildVolumeSlider(volumeLevel.toDouble()),
              _buildControlsRow(volumeLevel.toDouble()),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildVolumeSlider(double volumeLevel) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.volume_down, color: Colors.white, size: 20),
          Expanded(
            child: Slider(
              value: volumeLevel,
              min: 0,
              max: 100,
              activeColor: Colors.white,
              inactiveColor: Colors.white38,
              onChanged: (value) {
                widget.onVolumeChange(value);
              },
            ),
          ),
          Icon(Icons.volume_up, color: Colors.white, size: 20),
          SizedBox(width: 8),
          Text(
            '${volumeLevel.round()}%',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
  
  Widget _buildControlsRow(double volumeLevel) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          // Play/Pause button
          IconButton(
            onPressed: () {
              setState(() {
                _isPlaying = !_isPlaying;
              });
              widget.onTogglePlay();
            },
            icon: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 32,
            ),
          ),
          
          SizedBox(width: 16),
          
          // Volume button
          IconButton(
            onPressed: () {
              setState(() {
                _showVolumeSlider = !_showVolumeSlider;
              });
            },
            icon: Icon(
              volumeLevel == 0 
                  ? Icons.volume_off
                  : volumeLevel < 50 
                      ? Icons.volume_down 
                      : Icons.volume_up,
              color: Colors.white,
            ),
          ),
          
          Spacer(),
          
          // Quality selector
          _buildQualityButton(),
          
          SizedBox(width: 8),
          
          // Fullscreen button
          IconButton(
            onPressed: _toggleFullscreen,
            icon: Icon(Icons.fullscreen, color: Colors.white),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQualityButton() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final currentQuality = userProvider.getPreference('preferredQuality', 'STREAM_QUALITY_HIGH');
        String displayText;
        
        switch (currentQuality) {
          case 'STREAM_QUALITY_ULTRA':
            displayText = '4K';
            break;
          case 'STREAM_QUALITY_HIGH':
            displayText = 'HD';
            break;
          case 'STREAM_QUALITY_MEDIUM':
            displayText = 'SD';
            break;
          case 'STREAM_QUALITY_LOW':
            displayText = 'LOW';
            break;
          default:
            displayText = 'AUTO';
        }
        
        return TextButton(
          onPressed: _showQualitySelector,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.black38,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            minimumSize: Size.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            displayText,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }
  
  void _showQualitySelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) {
        return Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            final qualities = [
              {'value': 'STREAM_QUALITY_ULTRA', 'label': '4K Ultra'},
              {'value': 'STREAM_QUALITY_HIGH', 'label': 'HD (1080p)'},
              {'value': 'STREAM_QUALITY_MEDIUM', 'label': 'SD (720p)'},
              {'value': 'STREAM_QUALITY_LOW', 'label': 'Low (480p)'},
            ];
            
            final currentQuality = userProvider.getPreference('preferredQuality', 'STREAM_QUALITY_HIGH');
            
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Video Quality',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    ...qualities.map((quality) {
                      return ListTile(
                        title: Text(
                          quality['label']!,
                          style: TextStyle(color: Colors.white),
                        ),
                        trailing: currentQuality == quality['value']
                            ? Icon(Icons.check, color: Colors.blue)
                            : null,
                        onTap: () {
                          userProvider.updatePreference('preferredQuality', quality['value']!);
                          widget.onQualityChange(quality['value']!);
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  
  void _toggleFullscreen() {
    // In a real app, you would implement fullscreen functionality here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Fullscreen toggle - Coming soon!')),
    );
  }
}
