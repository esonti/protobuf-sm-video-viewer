import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/stream_viewer_screen.dart';
import 'screens/profile_screen.dart';
import 'providers/stream_provider.dart';
import 'providers/user_provider.dart';
import 'providers/webrtc_provider.dart';
import 'services/grpc_service.dart';

void main() {
  runApp(VideoViewerApp());
}

class VideoViewerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => StreamProvider(GrpcService())),
        ChangeNotifierProvider(create: (_) => WebRtcProvider()),
      ],
      child: MaterialApp(
        title: 'Video Viewer',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomeScreen(),
        routes: {
          '/home': (context) => HomeScreen(),
          '/profile': (context) => ProfileScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/stream') {
            final String streamId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => StreamViewerScreen(streamId: streamId),
            );
          }
          return null;
        },
      ),
    );
  }
}
