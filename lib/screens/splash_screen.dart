import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sangeetha_potha_app_flutter/utils/app_color.dart';
import '../services/service.dart';
import '../utils/app_components.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final double _loaderSize = 50.0;
  String currentAction = "Initializing..."; // Track the current action
  double progressValue = 0.0; // Track the progress percentage

  @override
  void initState() {
    super.initState();
    _syncDataAndNavigate();
  }

  Future<void> _syncDataAndNavigate() async {
    try {
      // Step 1: Initialize the SQLite database
      setState(() {
        currentAction = "Initializing database...";
        progressValue = 0.2;
      });
      await Service().initDatabase();

      // Step 2: Fetch songs from Firebase
      setState(() {
        currentAction = "Searching for new songs...";
        progressValue = 0.5;
      });
      await Service().fetchSongsFromFirebase();

      // Step 3: Fetch artists from Firebase
      setState(() {
        currentAction = "Downloading artist details...";
        progressValue = 0.8;
      });
      await Service().fetchArtistsFromFirebase();

      // Navigate to the HomeScreen if the widget is still mounted
      if (mounted) {
        setState(() {
          currentAction = "Finalizing...";
          progressValue = 1.0;
        });
        await Future.delayed(const Duration(seconds: 1)); // Optional delay for smooth transition
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      print('Error during data sync: $e');
      if (mounted) {
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
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Action Text
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    currentAction,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Progress Bar
                LinearProgressIndicator(
                  value: progressValue,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentColorDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
