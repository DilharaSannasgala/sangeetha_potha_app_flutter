import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../services/service.dart';
import '../utils/app_components.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final double _loaderSize = 50.0;

  @override
  void initState() {
    super.initState();
    _syncDataAndNavigate();
  }

  Future<void> _syncDataAndNavigate() async {
    try {
      // Initialize the SQLite database before data operations
      await Service().initDatabase();

      // Attempt to fetch songs from Firebase
      await Service().fetchSongsFromFirebase();

      // Attempt to fetch artists from Firebase
      await Service().fetchArtistsFromFirebase();

      // Navigate to the HomeScreen if the widget is still mounted
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      print('Error during data sync: $e');
      if (mounted) {
        // Navigate to an error or retry screen if required
        Navigator.pushReplacementNamed(context, '/error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            AppComponents.background,
            fit: BoxFit.cover,
          ),
          Align(
            alignment: const Alignment(0, -0.3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Centered Logo
                SvgPicture.asset(
                  AppComponents.logo,
                  height: 100,
                  width: 100,
                ),
                SizedBox(height: screenHeight * 0.2),

                // Loader (staggered dots wave)
                LoadingAnimationWidget.staggeredDotsWave(
                  color: Colors.white,
                  size: _loaderSize,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
