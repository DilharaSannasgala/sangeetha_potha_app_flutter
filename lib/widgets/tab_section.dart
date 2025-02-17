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
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTabSelector(),
        _selectedTabIndex == 0 ? _buildSongsTab() : _buildArtistsTab(),
      ],
    );
  }

  Widget _buildTabSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildTabButton('Songs', 0),
          const SizedBox(width: 16),
          _buildTabButton('Artists', 1),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isSelected = _selectedTabIndex == index;

    return TextButton(
      onPressed: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Text(
        title,
        style: GoogleFonts.poppins(
          color: isSelected ? AppColors.accentColor : Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSongsTab() {
    return Column(
      children: [
        _buildSongsList(),
        _buildSeeMoreButton(() {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SongList(),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildArtistsTab() {
    return Column(
      children: [
        _buildArtistsList(),
        _buildSeeMoreButton(() {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ArtistList(),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSongsList() {
    return ListView.builder(
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
            onTap: () => _navigateToSongScreen(context, song),
            child: SongTile(
              avatarUrl: song['coverArtPath'] ?? '',
              title: song['title'] ?? '',
              subtitle: song['artistName'] ?? 'Unknown Artist',
              isFav: song['isFav'] ?? false,
              onFavoriteToggle: (isFavorited) =>
                  _toggleFavorite(index, isFavorited),
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleFavorite(int index, bool isFavorited) async {
    final song = widget.sortedSongs[index];
    await FavoritesManager.setFavorite(song['title'], isFavorited);
    setState(() {
      widget.sortedSongs[index]['isFav'] = isFavorited;
    });
  }

  void _navigateToSongScreen(BuildContext context, Map<String, dynamic> song) {
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
  }

  Widget _buildArtistsList() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: widget.topArtists.length,
      itemBuilder: (context, index) {
        final artist = widget.topArtists[index];
        final avatarUrl = artist['avatarUrl']!.isEmpty
            ? 'assets/fallback_avatar.png' // Fallback image path
            : artist['avatarUrl']!;
        final artistName =
            artist['name']!.isEmpty ? 'Unknown Artist' : artist['name']!;

        return ArtistTile(
          avatarUrl: avatarUrl,
          title: artistName,
          onTap: () => _navigateToArtistSongList(context, artistName),
        );
      },
    );
  }

  void _navigateToArtistSongList(BuildContext context, String artistName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArtistSongList(
          artistName: artistName,
        ),
      ),
    );
  }

  Widget _buildSeeMoreButton(VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
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
    );
  }
}
