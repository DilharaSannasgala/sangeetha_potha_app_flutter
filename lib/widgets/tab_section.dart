import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sangeetha_potha_app_flutter/screens/artist_list.dart';
import 'package:sangeetha_potha_app_flutter/screens/artist_song_list.dart';
import 'package:sangeetha_potha_app_flutter/screens/song_list.dart';
import 'package:sangeetha_potha_app_flutter/screens/song_screen.dart';
import 'package:sangeetha_potha_app_flutter/utils/app_color.dart';
import 'package:sangeetha_potha_app_flutter/utils/app_components.dart';
import 'package:sangeetha_potha_app_flutter/widgets/song_tile.dart';
import 'package:sangeetha_potha_app_flutter/widgets/artist_tile.dart';
import '../services/manage_favorite.dart';

class TabSection extends StatefulWidget {
  final List<Map<String, dynamic>> sortedSongs;
  final List<Map<String, String>> topArtists;

  const TabSection({
    super.key,
    required this.sortedSongs,
    required this.topArtists,
  });

  @override
  State<TabSection> createState() => _TabSectionState();
}

class _TabSectionState extends State<TabSection> {
  int selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // "Songs" Button
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedTabIndex = 0;
                  });
                },
                child: Text(
                  'Songs',
                  style: GoogleFonts.poppins(
                    color: selectedTabIndex == 0
                        ? AppColors.accentColor
                        : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // "Artists" Button
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedTabIndex = 1;
                  });
                },
                child: Text(
                  'Artists',
                  style: GoogleFonts.poppins(
                    color: selectedTabIndex == 1
                        ? AppColors.accentColor
                        : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 0),
        // Conditional Content Based on Selected Tab
        if (selectedTabIndex == 0) ...[
          // Songs List Sorted Alphabetically
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: widget.sortedSongs.length,
            itemBuilder: (context, index) {
              final song = widget.sortedSongs[index];
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  splashColor: AppColors.accentColorDark.withOpacity(0.2),
                  highlightColor: AppColors.accentColorDark.withOpacity(0.1),
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
                  child: SongTile(
                    avatarUrl: song['coverArtPath'] ?? '',
                    title: song['title'] ?? '',
                    subtitle: song['artistName'] ?? 'Unknown Artist',
                    isFav: song['isFav'] ?? false,
                    onFavoriteToggle: (isFavorited) async {
                      await FavoritesManager.setFavorite(song['title'], isFavorited);
                      setState(() {
                        widget.sortedSongs[index]['isFav'] = isFavorited;
                      });
                    },
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 20),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SongList(),
                    ),
                  );
                },
                splashColor: AppColors.accentColorDark.withOpacity(0.2),
                highlightColor: AppColors.accentColorDark.withOpacity(0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'See More',
                      style: GoogleFonts.poppins(
                        color: AppColors.accentColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SvgPicture.asset(
                      AppComponents.seeMoreIcon,
                      height: 24,
                      color: AppColors.accentColorDark,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ] else if (selectedTabIndex == 1) ...[
          // Artists List
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: widget.topArtists.length,
            itemBuilder: (context, index) {
              return ArtistTile(
                avatarUrl: widget.topArtists[index]['avatarUrl']!.isEmpty
                    ? 'assets/fallback_avatar.png' // Fallback image path
                    : widget.topArtists[index]['avatarUrl']!,
                title: widget.topArtists[index]['name']!.isEmpty
                    ? 'Unknown Artist'
                    : widget.topArtists[index]['name']!,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArtistSongList(
                        artistName: widget.topArtists[index]['name']!,
                      ),
                    ),
                  );
                },
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 20),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ArtistList(),
                    ),
                  );
                },
                splashColor: AppColors.accentColorDark.withOpacity(0.2),
                highlightColor: AppColors.accentColorDark.withOpacity(0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'See More',
                      style: GoogleFonts.poppins(
                        color: AppColors.accentColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SvgPicture.asset(
                      AppComponents.seeMoreIcon,
                      height: 24,
                      color: AppColors.accentColorDark,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
