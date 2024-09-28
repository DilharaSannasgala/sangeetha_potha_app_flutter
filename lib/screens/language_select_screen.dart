import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/custom_button.dart';
import '../utils/app_components.dart';

class LanguageSelector extends StatefulWidget {
  const LanguageSelector({super.key});

  @override
  _LanguageSelectorState createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  String? selectedLanguage;

  @override
  Widget build(BuildContext context) {
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
            alignment: const Alignment(0, 0.8),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                SvgPicture.asset(
                  AppComponents.glassContainer,
                  fit: BoxFit.cover,
                  height: 400,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: SvgPicture.asset(
                        AppComponents.logo,
                        height: 75,
                        width: 85,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select a language',
                      style: GoogleFonts.getFont(
                        'Poppins',
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(
                        height: 25),
                    CustomDropdown(
                      selectedValue: selectedLanguage,
                      items: const [
                        'සිංහල - Sinhala',
                        'English',
                        'தமிழ் - Tamil',
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedLanguage =
                              value;
                        });
                      },
                      width: 230, // Custom width
                      height: 45, // Custom height
                    ),
                    const SizedBox(
                        height: 20),
                    CustomButton(
                      text: 'Select',
                      onPressed: () {
                        print('Selected language: $selectedLanguage');
                      },
                      width: 230, // Custom width
                      height: 45, // Custom height
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
