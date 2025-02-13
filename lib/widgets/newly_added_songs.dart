import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sangeetha_potha_app_flutter/utils/app_components.dart';
import '../screens/song_screen.dart';
import '../utils/app_color.dart';
import '../widgets/new_song_tile.dart';

class NewlyAddedSongs extends StatelessWidget {
  final List<Map<String, dynamic>> songs;
  final VoidCallback onSeeMore;

  const NewlyAddedSongs({
    super.key,
    required this.songs,
    required this.onSeeMore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Newly Added Songs',
            style: GoogleFonts.getFont(
              'Poppins',
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Horizontal List
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: songs.length + 1,
            itemBuilder: (context, index) {
              if (index == songs.length) {
                // "See More" button
                return Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      splashColor: AppColors.accentColorDark.withOpacity(0.2),
                      highlightColor: AppColors.accentColorDark.withOpacity(0.1),
                      onTap: onSeeMore,
                      child: Container(
                        width: 130,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              AppComponents.seeMoreIcon,
                              height: 40,
                              color: AppColors.accentColorDark,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'See More',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
              final song = songs[index];
              return Padding(
                padding: const EdgeInsets.only(left: 16),
                child: NewSongTile(
                  avatarUrl: song['coverArtPath'] ?? '',
                  title: song['title'] ?? '',
                  subtitle: song['artistName'] ?? 'Unknown Artist',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SongScreen(
                          avatarUrl: song['coverArtPath'] ?? '',
                          title: song['title'] ?? '',
                          subtitle: song['artistName'] ?? 'Unknown Artist',
                          lyrics: song['lyrics'] ?? '',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
