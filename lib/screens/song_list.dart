import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sangeetha_potha_app_flutter/screens/home_screen.dart';
import 'package:sangeetha_potha_app_flutter/services/manage_favorite.dart';
import 'package:sangeetha_potha_app_flutter/utils/app_color.dart';
import '../utils/app_components.dart';
import '../widgets/song_tile.dart';
import 'song_screen.dart';
import '../services/service.dart';

class SongList extends StatefulWidget {
  const SongList({super.key});

  @override
  State<SongList> createState() => _SongListState();
}

class _SongListState extends State<SongList> {
  final Service _service = Service();
  List<Map<String, dynamic>> songs = [];
  String searchQuery = '';
  bool isSearching = false;
  bool isLoading = true;  // Track loading state

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Fetch songs with enriched artist details
  Future<void> _fetchData() async {
    final fetchedSongs = await _service.fetchSongs();
    for (var song in fetchedSongs) {
      final isFav = await FavoritesManager.isFavorite(song['title']);
      song['isFav'] = isFav;
    }
    setState(() {
      songs = fetchedSongs;
      isLoading = false;  // Set loading to false after data is fetched
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

  // Method to filter songs based on the search query
  List<Map<String, dynamic>> getFilteredSongs() {
    if (searchQuery.isEmpty) {
      return songs;
    }
    return songs.where((song) {
      final titleLower = song['title']?.toLowerCase() ?? '';
      final artistNameLower = song['artistName']?.toLowerCase() ?? '';
      final queryLower = searchQuery.toLowerCase();
      return titleLower.contains(queryLower) || artistNameLower.contains(queryLower);
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
                  'All Songs',
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
                ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentColor),
              ),
            )
                : filteredSongs.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'No songs found.',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 20,
                  ),
                ),
              ),
            )
                : ListView.builder(
              itemCount: filteredSongs.length,
              itemBuilder: (context, index) {
                final song = filteredSongs[index];

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
