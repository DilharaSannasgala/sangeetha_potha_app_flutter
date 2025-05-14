import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:sangeetha_potha_app_flutter/firebase_options.dart';
import 'package:sangeetha_potha_app_flutter/screens/artist_list.dart';
import 'package:sangeetha_potha_app_flutter/screens/fav_song_list.dart';
import 'package:sangeetha_potha_app_flutter/screens/home_screen.dart';
import 'package:sangeetha_potha_app_flutter/screens/song_list.dart';
import 'package:sangeetha_potha_app_flutter/screens/splash_screen.dart';
import 'package:sangeetha_potha_app_flutter/services/service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter binding is initialized
  
  // Load environment variables from .env file
  await dotenv.load(fileName: '.env');
  
  // Initialize Firebase with options from custom_firebase_options.dart
  await Firebase.initializeApp(
    options: CustomFirebaseOptions.currentPlatform,
  );

  // Initialize MainService
  final mainService = MainService();
  await mainService.initializeApp(); // Initialize the app (database, sync, etc.)

  runApp(
    ChangeNotifierProvider(
      create: (context) => mainService, // Provide MainService to the app
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove debug banner
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/songs': (context) => const SongList(),
        '/artists': (context) => const ArtistList(),
        '/favorites': (context) => const FavList(),
      },
    );
  }
}