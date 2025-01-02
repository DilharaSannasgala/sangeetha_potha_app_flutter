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
  double _fontSize = 16.0;
  bool _showAdjustableBar = false;

  @override
  Widget build(BuildContext context) {
    // Step 1: Clean the lyrics
    String cleanedLyrics = widget.lyrics
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceAll('\t', '')
        .replaceAll('"', '')
        .replaceAll(',', '\n')
        .trim();

    // Debug: Print the cleaned lyrics to check for truncation
    debugPrint("Cleaned Lyrics: '$cleanedLyrics'", wrapWidth: 1024);

    // Step 2: Split into lines
    List<String> lyricsLines = cleanedLyrics
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();

    // Step 3: Debug each line
    for (int i = 0; i < lyricsLines.length; i++) {
      debugPrint("Line $i: '${lyricsLines[i]}'", wrapWidth: 1024);
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Color
          Container(color: Colors.black),
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
          // Animated App Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0.0, -1.0), end: Offset.zero).animate(animation),
                  child: child,
                );
              },
              child: _showAdjustableBar
                  ? _buildAdjustableBar()
                  : _buildDefaultAppBar(),
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
              isFav: false,
              onFavoriteToggle: (isFavorited) {
                setState(() {
                  print('Favorite status changed: $isFavorited');
                });
              },
              onTap: () {
                print('Song Tile tapped!');
              },
            ),
          ),
          Positioned(
            top: 200,
            left: 16,
            right: 16,
            bottom: 16,
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      'Lyrics',
                      style: GoogleFonts.getFont(
                        'Poppins',
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Display lyrics using Text
                    Text(
                      cleanedLyrics, // Directly use cleanedLyrics
                      style: GoogleFonts.getFont(
                        'Poppins',
                        color: Colors.white.withOpacity(0.8),
                        fontSize: _fontSize,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.left,
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

  // Default App Bar
  Widget _buildDefaultAppBar() {
    return AppBar(
      key: const ValueKey('DefaultAppBar'), // Key for AnimatedSwitcher
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
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: SvgPicture.asset(
              AppComponents.logo,
              height: 40,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.text_fields, color: Colors.white),
          onPressed: () {
            setState(() {
              _showAdjustableBar = true;
            });
          },
        ),
      ],
    );
  }

  // Adjustable App Bar with Slider
  Widget _buildAdjustableBar() {
    return Container(
      key: const ValueKey('AdjustableBar'), // Key for AnimatedSwitcher
      color: Colors.black.withOpacity(0.8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 42),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              setState(() {
                _showAdjustableBar = false;
              });
            },
          ),
          Expanded(
            child: Slider(
              value: _fontSize,
              min: 12.0,
              max: 32.0,
              divisions: 20,
              activeColor: Colors.white,
              inactiveColor: Colors.white.withOpacity(0.5),
              onChanged: (value) {
                setState(() {
                  _fontSize = value;
                });
              },
            ),
          ),
          Text(
            _fontSize.toStringAsFixed(0),
            style: GoogleFonts.getFont(
              'Poppins',
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
