import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/app_components.dart';

class SongTile extends StatelessWidget {
  final String avatarUrl;
  final String title;
  final String subtitle;
  final bool isFav;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onFavoriteToggle;

  const SongTile({
    super.key,
    required this.avatarUrl,
    required this.title,
    required this.subtitle,
    required this.isFav,
    this.onTap,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 16),
              Expanded(child: _buildSongInfo()),
              _buildFavoriteButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: _buildImage(),
    );
  }

  Widget _buildImage() {
    if (avatarUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: avatarUrl,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildFallbackImage(),
      );
    }
    return Image.file(
      File(avatarUrl),
      width: 70,
      height: 70,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildFallbackImage(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 70,
      height: 70,
      color: Colors.grey[850],
    );
  }

  Widget _buildFallbackImage() {
    return Image.asset(
      AppComponents.fallbackIcon,
      width: 70,
      height: 70,
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
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 16,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _buildFavoriteButton() {
    return GestureDetector(
      onTap: () => onFavoriteToggle?.call(!isFav),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: SvgPicture.asset(
          isFav ? AppComponents.heartSelect : AppComponents.heartUnselect,
          width: 30,
          height: 30,
        ),
      ),
    );
  }
}