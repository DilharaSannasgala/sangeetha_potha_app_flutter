import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
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
  String currentAction = "Loading...";

  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    try {
      setState(() => currentAction = "Initializing...");

      // Quick initialization with essential data
      await MainService().initializeApp();

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      print('Error during initialization: $e');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppComponents.background,
            fit: BoxFit.cover,
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  AppComponents.logo,
                  height: 100,
                  width: 100,
                ),
                const SizedBox(height: 40),
                LoadingAnimationWidget.staggeredDotsWave(
                  color: Colors.white,
                  size: _loaderSize,
                ),
                const SizedBox(height: 20),
                Text(
                  currentAction,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}