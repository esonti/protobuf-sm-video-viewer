import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stream_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/stream_list_item.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }
  
  Future<void> _initializeApp() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final streamProvider = Provider.of<StreamProvider>(context, listen: false);
    
    // Initialize user
    await userProvider.initializeUser();
    
    // If no user is logged in, create a temporary one for demo
    if (!userProvider.isLoggedIn) {
      userProvider.generateTemporaryUser();
    }
    
    // Load available streams
    await streamProvider.loadStreams();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Viewer'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(child: _buildStreamList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshStreams,
        child: Icon(Icons.refresh),
        tooltip: 'Refresh Streams',
      ),
    );
  }
  
  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search streams...',
          prefixIcon: Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }
  
  Widget _buildFilterChips() {
    return Container(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          _buildFilterChip('All', ''),
          _buildFilterChip('Live', 'STREAM_STATUS_LIVE'),
          _buildFilterChip('Preparing', 'STREAM_STATUS_PREPARING'),
          _buildFilterChip('High Quality', 'STREAM_QUALITY_HIGH'),
          _buildFilterChip('Medium Quality', 'STREAM_QUALITY_MEDIUM'),
        ],
      ),
    );
  }
  
  Widget _buildFilterChip(String label, String filter) {
    return Padding(
      padding: EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: false, // You could implement filter state management here
        onSelected: (selected) {
          // Implement filtering logic
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Filter by $label - Coming soon!')),
          );
        },
      ),
    );
  }
  
  Widget _buildStreamList() {
    return Consumer<StreamProvider>(
      builder: (context, streamProvider, child) {
        if (streamProvider.isLoading && streamProvider.streams.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (streamProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Error loading streams',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 8),
                Text(
                  streamProvider.error!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshStreams,
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        final streams = _getFilteredStreams(streamProvider.streams);
        
        if (streams.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.video_library_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  _searchQuery.isNotEmpty ? 'No streams found' : 'No streams available',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (_searchQuery.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Text(
                    'Try adjusting your search terms',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          );
        }
        
        return RefreshIndicator(
          onRefresh: _refreshStreams,
          child: ListView.builder(
            itemCount: streams.length,
            itemBuilder: (context, index) {
              final stream = streams[index];
              return StreamListItem(
                stream: stream,
                onTap: () => _openStream(stream['streamId']),
              );
            },
          ),
        );
      },
    );
  }
  
  List<Map<String, dynamic>> _getFilteredStreams(List<Map<String, dynamic>> streams) {
    if (_searchQuery.isEmpty) {
      return streams;
    }
    
    final streamProvider = Provider.of<StreamProvider>(context, listen: false);
    return streamProvider.searchStreams(_searchQuery);
  }
  
  Future<void> _refreshStreams() async {
    final streamProvider = Provider.of<StreamProvider>(context, listen: false);
    await streamProvider.refreshStreams();
  }
  
  void _openStream(String streamId) {
    Navigator.pushNamed(
      context,
      '/stream',
      arguments: streamId,
    );
  }
}
