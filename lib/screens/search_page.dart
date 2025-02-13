import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sangeetha_potha_app_flutter/screens/song_screen.dart';
import 'package:sangeetha_potha_app_flutter/screens/artist_song_list.dart';
import 'package:sangeetha_potha_app_flutter/services/manage_favorite.dart';
import 'package:sangeetha_potha_app_flutter/utils/app_color.dart';
import 'package:sangeetha_potha_app_flutter/utils/app_components.dart';
import 'package:sangeetha_potha_app_flutter/widgets/song_tile.dart';
import 'package:sangeetha_potha_app_flutter/widgets/artist_tile.dart';
import 'package:sangeetha_potha_app_flutter/screens/home_screen.dart';

class SearchPage extends StatefulWidget {
  final List<Map<String, dynamic>> songs;
  final List<Map<String, String>> artists;

  const SearchPage({
    super.key,
    required this.songs,
    required this.artists,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Shuffle the lists to get random songs and artists
    final randomSongs = List<Map<String, dynamic>>.from(widget.songs)..shuffle();
    final randomArtists = List<Map<String, String>>.from(widget.artists)..shuffle();

    // Get the first 4 songs and 3 artists
    final selectedSongs = randomSongs.take(4).toList();
    final selectedArtists = randomArtists.take(3).toList();

    // Filter Songs and Artists based on searchQuery
    final filteredSongs = selectedSongs.where((song) {
      final title = song['title']?.toLowerCase() ?? '';
      return title.contains(searchQuery.toLowerCase());
    }).toList();

    final filteredArtists = selectedArtists.where((artist) {
      final name = artist['name']?.toLowerCase() ?? '';
      return name.contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: GoogleFonts.poppins(color: Colors.white70),
                  border: InputBorder.none,
                ),
                style: GoogleFonts.poppins(color: Colors.white),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),
            if (_searchController.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    searchQuery = '';
                  });
                },
              ),
          ],
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
                  (route) => false,  // This will remove all routes from the stack
            );
          },
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Container(
            color: Colors.black,
          ),
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.23),
              BlendMode.dstATop,
            ),
            child: Image.asset(
              AppComponents.background,
              fit: BoxFit.cover,
            ),
          ),
          // Main Content
          ListView(
            children: [
              if (filteredSongs.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Songs',
                    style: GoogleFonts.poppins(
                      color: AppColors.accentColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...filteredSongs.map((song) {
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
                            song['isFav'] = isFavorited;
                          });
                        },
                      ),
                    ),
                  );
                }),
              ],
              if (filteredArtists.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Artists',
                    style: GoogleFonts.poppins(
                      color: AppColors.accentColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...filteredArtists.map((artist) {
                  return ArtistTile(
                    avatarUrl: artist['avatarUrl'] ?? '',
                    title: artist['name'] ?? 'Unknown Artist',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ArtistSongList(
                            artistName: artist['name'] ?? '',
                          ),
                        ),
                      );
                    },
                  );
                }),
              ],
              if (filteredSongs.isEmpty && filteredArtists.isEmpty) ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      'No results found',
                      style: GoogleFonts.poppins(color: Colors.white70),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
