import 'dart:io'; // For File handling
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sangeetha_potha_app_flutter/utils/app_components.dart';

import '../utils/app_color.dart';

class ArtistTile extends StatelessWidget {
  final String avatarUrl;
  final String title;
  final VoidCallback? onTap;

  const ArtistTile({
    Key? key,
    required this.avatarUrl,
    required this.title,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        splashColor: AppColors.accentColorDark.withOpacity(0.2),
        highlightColor: AppColors.accentColorDark.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 20.0,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Circular Avatar with fallback
              ClipOval(
                child: _getAvatarWidget(),
              ),
              const SizedBox(width: 16),
              // Title (Artist's Name)
              Expanded(
                child: Text(
                  title.isNotEmpty ? title : 'Unknown Artist',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to decide whether to use Image.network or Image.file
  Widget _getAvatarWidget() {
    // Check if the avatarUrl is a valid file path or a URL
    if (avatarUrl.startsWith('http') || avatarUrl.startsWith('https')) {
      // If it's a URL, use Image.network
      return Image.network(
        avatarUrl,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            AppComponents.fallbackIcon,
            width: 70,
            height: 70,
            fit: BoxFit.cover,
          );
        },
      );
    } else if (File(avatarUrl).existsSync()) {
      // If it's a local file path, use Image.file
      return Image.file(
        File(avatarUrl),
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            AppComponents.fallbackIcon,
            width: 70,
            height: 70,
            fit: BoxFit.cover,
          );
        },
      );
    } else {
      // If neither, show a fallback image
      return Image.asset(
        AppComponents.fallbackIcon,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
      );
    }
  }
}
