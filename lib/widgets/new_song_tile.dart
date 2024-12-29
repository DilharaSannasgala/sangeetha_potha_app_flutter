import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NewSongTile extends StatelessWidget {
  final String avatarUrl;
  final String title;
  final String artist;

  const NewSongTile({
    super.key,
    required this.avatarUrl,
    required this.title,
    required this.artist,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Art
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                avatarUrl,
                width: 128,
                height: 128,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            // Title
            Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis, // Truncate text
              maxLines: 1, // Limit to one line
            ),
            const SizedBox(height: 4),
            // Artist
            Text(
              artist,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis, // Truncate text
              maxLines: 1, // Limit to one line
            ),
          ],
        ),
      ),
    );
  }
}
