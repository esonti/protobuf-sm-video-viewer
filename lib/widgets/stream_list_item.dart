import 'package:flutter/material.dart';

class StreamListItem extends StatelessWidget {
  final Map<String, dynamic> stream;
  final VoidCallback onTap;
  
  const StreamListItem({
    Key? key,
    required this.stream,
    required this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      stream['title'] ?? 'Untitled Stream',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusChip(stream['status']),
                ],
              ),
              SizedBox(height: 8),
              Text(
                stream['description'] ?? 'No description available',
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    stream['publisherId'] ?? 'Unknown',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Spacer(),
                  Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    '${stream['currentViewers'] ?? 0} viewers',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  SizedBox(width: 16),
                  _buildQualityChip(stream['quality']),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatusChip(String? status) {
    Color chipColor;
    String displayText;
    
    switch (status) {
      case 'STREAM_STATUS_LIVE':
        chipColor = Colors.red;
        displayText = 'LIVE';
        break;
      case 'STREAM_STATUS_PREPARING':
        chipColor = Colors.orange;
        displayText = 'PREPARING';
        break;
      case 'STREAM_STATUS_ENDED':
        chipColor = Colors.grey;
        displayText = 'ENDED';
        break;
      default:
        chipColor = Colors.grey;
        displayText = 'OFFLINE';
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildQualityChip(String? quality) {
    String displayText;
    
    switch (quality) {
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
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[400]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
