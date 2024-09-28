import 'package:flutter/material.dart';
import 'package:sangeetha_potha_app_flutter/screens/language_select_screen.dart';
import 'package:sangeetha_potha_app_flutter/screens/splash_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LanguageSelector(),
    );
  }
}
