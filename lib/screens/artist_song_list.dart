import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sangeetha_potha_app_flutter/screens/home_screen.dart';
import 'package:sangeetha_potha_app_flutter/services/manage_favorite.dart';
import 'package:sangeetha_potha_app_flutter/utils/app_color.dart';
import '../widgets/song_tile.dart';
import '../services/service.dart';
import '../utils/app_components.dart';

class ArtistSongList extends StatefulWidget {
  final String artistName;

  const ArtistSongList({
    Key? key,
    required this.artistName,
  }) : super(key: key);

  @override
  State<ArtistSongList> createState() => _ArtistSongListState();
}

class _ArtistSongListState extends State<ArtistSongList> {
  final Service _service = Service();
  List<Map<String, dynamic>> songs = [];
  String searchQuery = '';
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Fetch songs for the selected artist
  Future<void> _fetchData() async {
    final fetchedSongs = await _service.fetchSongsByArtist(widget.artistName);
    for (var song in fetchedSongs) {
      final isFav = await FavoritesManager.isFavorite(song['title']);
      song['isFav'] = isFav;
    }
    setState(() {
      songs = fetchedSongs;
    });
  }

  // Start search mode
  void startSearch() {
    setState(() {
      isSearching = true;
    });
  }

  // Stop search mode
  void stopSearch() {
    setState(() {
      isSearching = false;
      searchQuery = '';
    });
  }

  // Filter songs based on search query
  List<Map<String, dynamic>> getFilteredSongs() {
    if (searchQuery.isEmpty) {
      return songs;
    }
    return songs.where((song) {
      final titleLower = song['title']?.toLowerCase() ?? '';
      final queryLower = searchQuery.toLowerCase();
      return titleLower.contains(queryLower);
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
                  widget.artistName,
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
                    Navigator.pop(context);
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
            child: ListView.builder(
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
                      // Navigate to song screen
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
