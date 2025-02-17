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
        color: Colors.black,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            _buildHeader(),
            const SizedBox(height: 16),
            Expanded(
              child: _buildNavigationMenu(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
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
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationMenu(BuildContext context) {
    // Define navigation items for better maintainability
    final navigationItems = [
      NavigationItem(
        icon: AppComponents.songIcon,
        title: 'Songs',
        route: '/songs',
      ),
      NavigationItem(
        icon: AppComponents.artistIcon,
        title: 'Artists',
        route: '/artists',
      ),
      NavigationItem(
        icon: AppComponents.favIcon,
        title: 'Favorites',
        route: '/favorites',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: navigationItems.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = navigationItems[index];
          return _buildNavigationTile(
            context: context,
            leading: SvgPicture.asset(item.icon, height: 40),
            title: item.title,
            route: item.route,
          );
        },
      ),
    );
  }

  Widget _buildNavigationTile({
    required BuildContext context,
    required Widget leading,
    required String title,
    required String route,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        splashColor: AppColors.accentColorDark.withOpacity(0.2),
        highlightColor: AppColors.accentColorDark.withOpacity(0.1),
        onTap: () => Navigator.pushNamed(context, route),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 18.0),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
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

/// Navigation item model to encapsulate navigation data
class NavigationItem {
  final String icon;
  final String title;
  final String route;

  const NavigationItem({
    required this.icon,
    required this.title,
    required this.route,
  });
}