import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sangeetha_potha_app_flutter/utils/app_color.dart';
import '../utils/app_components.dart';

class NewSongTile extends StatelessWidget {
  final String avatarUrl;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const NewSongTile({
    super.key,
    required this.avatarUrl,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          splashColor: AppColors.accentColorDark.withOpacity(0.2),
          highlightColor: AppColors.accentColorDark.withOpacity(0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cover Art with fallback handling
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: avatarUrl.startsWith('http')
                    ? Image.network(
                  avatarUrl,
                  width: 125,
                  height: 125,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      AppComponents.fallbackIcon,
                      width: 125,
                      height: 125,
                      fit: BoxFit.cover,
                    );
                  },
                )
                    : Image.file(
                  File(avatarUrl),
                  width: 125,
                  height: 125,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      AppComponents.fallbackIcon,
                      width: 125,
                      height: 125,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              // Title
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    subtitle,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis, // Truncate text
                    maxLines: 1, // Limit to one line
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
