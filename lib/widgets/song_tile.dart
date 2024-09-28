import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sangeetha_potha_app_flutter/utils/app_color.dart';

class SongTile extends StatelessWidget {
  final String avatarUrl;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const SongTile({
    Key? key,
    required this.avatarUrl,
    required this.title,
    required this.subtitle,
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
          padding: const EdgeInsets.only(
            top: 16.0,
            bottom: 16.0,
            left: 20.0,
            right: 20.0,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Square Avatar with fallback image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
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
              // Text Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.getFont(
                        'Poppins',
                        color: Colors.white,
                        fontSize: 20,
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
