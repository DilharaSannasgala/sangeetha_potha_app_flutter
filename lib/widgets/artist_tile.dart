import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
              // Circular Avatar with fallback image
              ClipOval(
                child: Image.network(
                  avatarUrl,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.network(
                      'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2FOBUI8qgdzH8n79bpoj6t%2Fc261c1403acce274325fd766f37742a0179e87d8image%208.png?alt=media&token=1fb77fd2-ec20-47f3-939f-445a1b4fe557',
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Title (Artist's Name)
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.getFont(
                    'Poppins',
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
}
