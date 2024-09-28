import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../utils/app_components.dart';

class SplashScreen extends StatelessWidget {
  final double _kSize = 50.0;

  const SplashScreen({super.key});

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
                  size: _kSize, // Loader size
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
