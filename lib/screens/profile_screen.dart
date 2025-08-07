import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _usernameController.text = userProvider.username;
    _displayNameController.text = userProvider.displayName;
  }
  
  @override
  void dispose() {
    _usernameController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            SizedBox(height: 32),
            _buildProfileForm(),
            SizedBox(height: 32),
            _buildPreferencesSection(),
            SizedBox(height: 32),
            _buildActionsSection(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProfileHeader() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue,
                  child: Text(
                    userProvider.displayName.isNotEmpty 
                        ? userProvider.displayName[0].toUpperCase()
                        : 'U',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userProvider.displayName.isNotEmpty 
                            ? userProvider.displayName 
                            : 'User',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        '@${userProvider.username}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'ID: ${userProvider.userId}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildProfileForm() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile Information',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _displayNameController,
                decoration: InputDecoration(
                  labelText: 'Display Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a display name';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildPreferencesSection() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Preferences',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 16),
                
                // Preferred Quality
                ListTile(
                  leading: Icon(Icons.hd),
                  title: Text('Preferred Quality'),
                  subtitle: Text(userProvider.getPreference('preferredQuality', 'STREAM_QUALITY_HIGH')),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () => _showQualitySelector(userProvider),
                ),
                
                // Auto Play
                SwitchListTile(
                  secondary: Icon(Icons.play_arrow),
                  title: Text('Auto Play'),
                  subtitle: Text('Automatically start playing streams'),
                  value: userProvider.getPreference('autoPlay', true),
                  onChanged: (value) => userProvider.updatePreference('autoPlay', value),
                ),
                
                // Volume Level
                ListTile(
                  leading: Icon(Icons.volume_up),
                  title: Text('Volume Level'),
                  subtitle: Slider(
                    value: userProvider.getPreference('volumeLevel', 80).toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 20,
                    label: '${userProvider.getPreference('volumeLevel', 80)}%',
                    onChanged: (value) => userProvider.updatePreference('volumeLevel', value.round()),
                  ),
                ),
                
                // Enable Subtitles
                SwitchListTile(
                  secondary: Icon(Icons.subtitles),
                  title: Text('Enable Subtitles'),
                  subtitle: Text('Show subtitles when available'),
                  value: userProvider.getPreference('enableSubtitles', false),
                  onChanged: (value) => userProvider.updatePreference('enableSubtitles', value),
                ),
                
                // Theme
                ListTile(
                  leading: Icon(Icons.palette),
                  title: Text('Theme'),
                  subtitle: Text(userProvider.getPreference('theme', 'VIEWER_THEME_AUTO')),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () => _showThemeSelector(userProvider),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildActionsSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('Viewing History'),
              subtitle: Text('View your stream watching history'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: _showViewingHistory,
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('App Settings'),
              subtitle: Text('Configure app behavior'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: _showAppSettings,
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Sign Out', style: TextStyle(color: Colors.red)),
              subtitle: Text('Sign out of your account'),
              onTap: _signOut,
            ),
          ],
        ),
      ),
    );
  }
  
  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.updateProfile(
          username: _usernameController.text,
          displayName: _displayNameController.text,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }
  
  void _showQualitySelector(UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) {
        final qualities = [
          'STREAM_QUALITY_LOW',
          'STREAM_QUALITY_MEDIUM', 
          'STREAM_QUALITY_HIGH',
          'STREAM_QUALITY_ULTRA',
        ];
        
        return AlertDialog(
          title: Text('Select Quality'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: qualities.map((quality) {
              return RadioListTile<String>(
                title: Text(quality.split('_').last),
                value: quality,
                groupValue: userProvider.getPreference('preferredQuality', 'STREAM_QUALITY_HIGH'),
                onChanged: (value) {
                  userProvider.updatePreference('preferredQuality', value!);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
  
  void _showThemeSelector(UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) {
        final themes = [
          'VIEWER_THEME_LIGHT',
          'VIEWER_THEME_DARK',
          'VIEWER_THEME_AUTO',
        ];
        
        return AlertDialog(
          title: Text('Select Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: themes.map((theme) {
              return RadioListTile<String>(
                title: Text(theme.split('_').last),
                value: theme,
                groupValue: userProvider.getPreference('theme', 'VIEWER_THEME_AUTO'),
                onChanged: (value) {
                  userProvider.updatePreference('theme', value!);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
  
  void _showViewingHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing history - Coming soon!')),
    );
  }
  
  void _showAppSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('App settings - Coming soon!')),
    );
  }
  
  void _signOut() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Sign Out'),
          content: Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Sign Out'),
            ),
          ],
        );
      },
    );
    
    if (result == true) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.logoutUser();
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }
}
