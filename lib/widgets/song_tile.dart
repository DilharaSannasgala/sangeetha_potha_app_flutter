import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/manage_favorite.dart';
import '../utils/app_components.dart';

class SongTile extends StatefulWidget {
  final String avatarUrl;
  final String title;
  final String subtitle;
  final bool isFav; // New property to track favorite status
  final VoidCallback? onTap;
  final ValueChanged<bool>? onFavoriteToggle; // Callback to notify favorite state changes

  const SongTile({
    Key? key,
    required this.avatarUrl,
    required this.title,
    required this.subtitle,
    required this.isFav,
    this.onTap,
    this.onFavoriteToggle,
  }) : super(key: key);

  @override
  _SongTileState createState() => _SongTileState();
}

class _SongTileState extends State<SongTile> {
  late bool isFavorited; // Local state for the favorite icon

  @override
  void initState() {
    super.initState();
    isFavorited = widget.isFav; // Initialize from passed property
  }

  void _toggleFavorite() async {
    setState(() {
      isFavorited = !isFavorited;
    });
    await FavoritesManager.setFavorite(widget.title, isFavorited);
    widget.onFavoriteToggle?.call(isFavorited);
  }


  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
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
            // Avatar with fallback
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: widget.avatarUrl.startsWith('http')
                  ? Image.network(
                widget.avatarUrl,
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
              )
                  : Image.file(
                File(widget.avatarUrl),
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
              ),
            ),
            const SizedBox(width: 16),
            // Text Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: GoogleFonts.getFont(
                      'Poppins',
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle,
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Favorite Icon
            GestureDetector(
              onTap: _toggleFavorite,
              child: SvgPicture.asset(
                isFavorited
                    ? AppComponents.heartSelect
                    : AppComponents.heartUnselect,
                width: 30,
                height: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
