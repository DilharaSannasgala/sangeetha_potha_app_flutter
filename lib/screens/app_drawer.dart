import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sangeetha_potha_app_flutter/utils/app_color.dart';
import 'package:sangeetha_potha_app_flutter/utils/app_components.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.black, // Set the drawer background color to black
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    AppComponents.logo,
                    height: 80,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Sangeetha Potha',
                      style: GoogleFonts.getFont(
                        'Poppins',
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildTile(
                      leading: SvgPicture.asset(AppComponents.songIcon, height: 40),
                      title: 'Songs',
                      onTap: () {
                        Navigator.pushNamed(context, '/songs'); // Navigate to Songs screen
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildTile(
                      leading: SvgPicture.asset(AppComponents.artistIcon, height: 40),
                      title: 'Artists',
                      onTap: () {
                        Navigator.pushNamed(context, '/artists'); // Navigate to Artists screen
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildTile(
                      leading: SvgPicture.asset(AppComponents.favIcon, height: 40),
                      title: 'Favorites',
                      onTap: () {
                        Navigator.pushNamed(context, '/favorites'); // Navigate to Favorites screen
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile({required Widget leading, required String title, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        splashColor: AppColors.accentColorDark.withOpacity(0.2),
        highlightColor: AppColors.accentColorDark.withOpacity(0.1),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 18.0),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.getFont(
                    'Poppins',
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
