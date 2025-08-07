import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stream_provider.dart';

class StreamInfoPanel extends StatelessWidget {
  final String streamId;
  
  const StreamInfoPanel({Key? key, required this.streamId}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Consumer<StreamProvider>(
        builder: (context, streamProvider, child) {
          final streamDetails = streamProvider.currentStreamDetails;
          
          if (streamDetails == null) {
            return Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: 16),
                _buildStreamInfo(streamDetails),
                SizedBox(height: 16),
                _buildPublisherInfo(streamDetails),
                SizedBox(height: 16),
                _buildViewerStats(streamDetails),
                SizedBox(height: 16),
                _buildTechnicalInfo(streamDetails),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.info_outline, color: Colors.white),
        SizedBox(width: 8),
        Text(
          'Stream Info',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStreamInfo(Map<String, dynamic> streamDetails) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoSection('Title', streamDetails['title'] ?? 'Unknown'),
        _buildInfoSection('Description', streamDetails['description'] ?? 'No description'),
        _buildInfoSection('Status', _formatStatus(streamDetails['status'])),
        _buildInfoSection('Quality', _formatQuality(streamDetails['quality'])),
      ],
    );
  }
  
  Widget _buildPublisherInfo(Map<String, dynamic> streamDetails) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Publisher',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 16, color: Colors.white),
            ),
            SizedBox(width: 8),
            Text(
              streamDetails['publisherId'] ?? 'Unknown Publisher',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildViewerStats(Map<String, dynamic> streamDetails) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistics',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.visibility, color: Colors.grey[400], size: 16),
            SizedBox(width: 4),
            Text(
              '${streamDetails['currentViewers'] ?? 0} viewers',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.schedule, color: Colors.grey[400], size: 16),
            SizedBox(width: 4),
            Text(
              'Started: ${_formatCreatedAt(streamDetails['createdAt'])}',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildTechnicalInfo(Map<String, dynamic> streamDetails) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Technical',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        _buildInfoSection('Stream ID', streamId),
        _buildInfoSection('Protocol', 'WebRTC'),
        _buildInfoSection('Codec', 'H.264/VP8'),
      ],
    );
  }
  
  Widget _buildInfoSection(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatStatus(String? status) {
    switch (status) {
      case 'STREAM_STATUS_LIVE':
        return 'Live';
      case 'STREAM_STATUS_PREPARING':
        return 'Preparing';
      case 'STREAM_STATUS_ENDED':
        return 'Ended';
      default:
        return 'Unknown';
    }
  }
  
  String _formatQuality(String? quality) {
    switch (quality) {
      case 'STREAM_QUALITY_ULTRA':
        return '4K Ultra (2160p)';
      case 'STREAM_QUALITY_HIGH':
        return 'HD (1080p)';
      case 'STREAM_QUALITY_MEDIUM':
        return 'SD (720p)';
      case 'STREAM_QUALITY_LOW':
        return 'Low (480p)';
      default:
        return 'Auto';
    }
  }
  
  String _formatCreatedAt(String? createdAt) {
    if (createdAt == null) return 'Unknown';
    
    try {
      final dateTime = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inMinutes < 60) {
        return '${difference.inMinutes} min ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hr ago';
      } else {
        return '${difference.inDays} days ago';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}
