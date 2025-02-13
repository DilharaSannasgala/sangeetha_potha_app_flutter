import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sangeetha_potha_app_flutter/screens/artist_list.dart';
import 'package:sangeetha_potha_app_flutter/screens/fav_song_list.dart';
import 'package:sangeetha_potha_app_flutter/screens/home_screen.dart';
import 'package:sangeetha_potha_app_flutter/screens/song_list.dart';
import 'package:sangeetha_potha_app_flutter/screens/splash_screen.dart';
import 'package:sangeetha_potha_app_flutter/services/service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter binding is initialized
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Initialize Firebase
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