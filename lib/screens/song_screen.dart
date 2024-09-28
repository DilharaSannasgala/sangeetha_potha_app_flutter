import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sangeetha_potha_app_flutter/utils/app_components.dart';
import '../widgets/song_tile.dart';

class SongScreen extends StatefulWidget {
  final String avatarUrl;
  final String title;
  final String subtitle;
  final String lyrics;

  const SongScreen({
    super.key,
    required this.avatarUrl,
    required this.title,
    required this.subtitle,
    required this.lyrics,
  });

  @override
  State<SongScreen> createState() => _SongScreenState();
}

class _SongScreenState extends State<SongScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Color
          Container(
            color: Colors.black,
          ),
          // Background Image with reduced opacity
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.23),
              BlendMode.dstATop,
            ),
            child: Image.asset(
              AppComponents.background,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Row(
                children: [
                  // Logo SVG
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: SvgPicture.asset(
                      AppComponents.logo,
                      height: 40,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 90,
            left: 0,
            right: 0,
            child: SongTile(
              avatarUrl: widget.avatarUrl,
              title: widget.title,
              subtitle: widget.subtitle,
              onTap: () {
                print('Song Tile tapped!');
              },
            ),
          ),
          Positioned(
            top: 220,
            left: 16,
            right: 16,
            bottom: 16,
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5), // Slightly transparent background
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lyrics',
                      style: GoogleFonts.getFont(
                        'Poppins',
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.lyrics,
                      style: GoogleFonts.getFont(
                        'Poppins',
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
