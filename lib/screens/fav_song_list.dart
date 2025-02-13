import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sangeetha_potha_app_flutter/screens/home_screen.dart';
import 'package:sangeetha_potha_app_flutter/services/database_service.dart';
import 'package:sangeetha_potha_app_flutter/services/manage_favorite.dart';
import 'package:sangeetha_potha_app_flutter/utils/app_color.dart';
import '../utils/app_components.dart';
import '../widgets/song_tile.dart';
import 'song_screen.dart';
import '../services/service.dart';

class FavList extends StatefulWidget {
  const FavList({super.key});

  @override
  State<FavList> createState() => _SongListState();
}

class _SongListState extends State<FavList> {
  List<Map<String, dynamic>> songs = [];
  String searchQuery = '';
  bool isSearching = false;
  bool isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Fetch songs with enriched artist details
  Future<void> _fetchData() async {
    // Create an instance of DatabaseService
    final DatabaseService dbService = DatabaseService();

    // Call fetchSongs on the instance
    final fetchedSongs = await dbService.fetchSongs();

    for (var song in fetchedSongs) {
      final isFav = await FavoritesManager.isFavorite(song['title']);
      song['isFav'] = isFav;
    }

    setState(() {
      songs = fetchedSongs;
      isLoading = false;
    });
  }


  // Method to toggle search mode
  void startSearch() {
    setState(() {
      isSearching = true;
    });
  }

  // Method to close search
  void stopSearch() {
    setState(() {
      isSearching = false;
      searchQuery = '';
    });
  }

  // Method to filter songs based on the search query and only show favorited songs
  List<Map<String, dynamic>> getFilteredSongs() {
    if (searchQuery.isEmpty) {
      return songs.where((song) => song['isFav'] == true).toList();
    }
    return songs.where((song) {
      final titleLower = song['title']?.toLowerCase() ?? '';
      final artistNameLower = song['artistName']?.toLowerCase() ?? '';
      final queryLower = searchQuery.toLowerCase();
      return (titleLower.contains(queryLower) ||
          artistNameLower.contains(queryLower)) &&
          song['isFav'] == true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredSongs = getFilteredSongs();

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Color
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
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: isSearching
                    ? TextField(
                  key: const ValueKey('searchField'),
                  autofocus: true,
                  style: GoogleFonts.getFont(
                    'Poppins',
                    color: Colors.white,
                    fontSize: 20,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Search Songs...',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                  ),
                  onChanged: (query) {
                    setState(() {
                      searchQuery = query;
                    });
                  },
                )
                    : Text(
                  'Favorites',
                  key: const ValueKey('titleText'),
                  style: GoogleFonts.getFont(
                    'Poppins',
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
              leading: IconButton(
                icon: isSearching
                    ? const Icon(Icons.close, color: Colors.white)
                    : const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  if (isSearching) {
                    stopSearch();
                  } else {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                          (route) => false,
                    );
                  }
                },
              ),
              actions: [
                if (!isSearching)
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: startSearch,
                  ),
              ],
            ),
          ),
          Positioned(
            top: 70,
            left: 0,
            right: 0,
            bottom: 0,
            child: isLoading
                ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.accentColor,
              ),
            ) // Show loading spinner while data is loading
                : filteredSongs.isEmpty
                ? Center(
              child: Text(
                'No favorite songs found...',
                style: GoogleFonts.getFont(
                  'Poppins',
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ) // Show empty message when no songs are found
                : ListView.builder(
              itemCount: filteredSongs.length,
              itemBuilder: (context, index) {
                final song = filteredSongs[index];

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    splashColor:
                    AppColors.accentColorDark.withOpacity(0.2),
                    highlightColor:
                    AppColors.accentColorDark.withOpacity(0.1),
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
                        await FavoritesManager.setFavorite(
                            song['title'], isFavorited);
                        setState(() {
                          songs[index]['isFav'] = isFavorited;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
