import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sangeetha_potha_app_flutter/utils/app_color.dart';
import 'package:sangeetha_potha_app_flutter/utils/app_components.dart';
import '../services/image_service.dart';

class ArtistTile extends StatelessWidget {
  final String avatarUrl;
  final String title;
  final VoidCallback? onTap;

  const ArtistTile({
    super.key,
    required this.avatarUrl,
    required this.title,
    this.onTap,
  });

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
              ClipOval(child: _buildAvatar()),
              const SizedBox(width: 16),
              Expanded(child: _buildTitle()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (_isNetworkImage) {
      return _buildNetworkAvatar();
    } else if (_isLocalFile) {
      return _buildLocalAvatar();
    }
    return _buildFallbackAvatar();
  }

  Widget _buildNetworkAvatar() {
    return FutureBuilder<String>(
      future: ImageService().downloadImage(avatarUrl, title),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _buildImageFromFile(snapshot.data!);
        }
        return _buildFallbackAvatar();
      },
    );
  }

  Widget _buildImageFromFile(String path) {
    return Image.file(
      File(path),
      width: 70,
      height: 70,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildFallbackAvatar(),
    );
  }

  Widget _buildLocalAvatar() {
    return Image.file(
      File(avatarUrl),
      width: 70,
      height: 70,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildFallbackAvatar(),
    );
  }

  Widget _buildFallbackAvatar() {
    return Image.asset(
      AppComponents.fallbackIcon,
      width: 70,
      height: 70,
      fit: BoxFit.cover,
    );
  }

  Widget _buildTitle() {
    return Text(
      title.isNotEmpty ? title : 'Unknown Artist',
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }

  bool get _isNetworkImage =>
      avatarUrl.startsWith('http') || avatarUrl.startsWith('https');

  bool get _isLocalFile => 
      avatarUrl.isNotEmpty && File(avatarUrl).existsSync();
}