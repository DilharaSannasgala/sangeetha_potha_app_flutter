import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_color.dart';
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
              _buildCoverArt(),
              const SizedBox(height: 10),
              _buildSongInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverArt() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: _buildImage(),
    );
  }

  Widget _buildImage() {
    if (avatarUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: avatarUrl,
        width: 125,
        height: 125,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildFallbackImage(),
      );
    } else {
      return _buildFileImage();
    }
  }

  Widget _buildFileImage() {
    return Image.file(
      File(avatarUrl),
      width: 125,
      height: 125,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildFallbackImage(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 125,
      height: 125,
      color: Colors.grey[850],
    );
  }

  Widget _buildFallbackImage() {
    return Image.asset(
      AppComponents.fallbackIcon,
      width: 125,
      height: 125,
      fit: BoxFit.cover,
    );
  }

  Widget _buildSongInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 12,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }
}