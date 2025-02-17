import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_service.dart';
import '../services/manage_favorite.dart';
import '../utils/app_color.dart';
import '../utils/app_components.dart';
import '../widgets/song_tile.dart';
import 'home_screen.dart';
import 'song_screen.dart';

class SongList extends StatefulWidget {
  const SongList({super.key});

  @override
  State<SongList> createState() => _SongListState();
}

class _SongListState extends State<SongList> {
  final DatabaseService _dbService = DatabaseService();
  final ValueNotifier<List<Map<String, dynamic>>> _songs = ValueNotifier([]);
  final ValueNotifier<bool> _isLoading = ValueNotifier(true);
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _songs.dispose();
    _isLoading.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      final fetchedSongs = await _dbService.fetchSongs();
      final songsWithFavorites = await _processFavorites(fetchedSongs);
      _songs.value = songsWithFavorites;
    } catch (e) {
      debugPrint('Error fetching songs: $e');
      // Handle error appropriately
    } finally {
      _isLoading.value = false;
    }
  }

  Future<List<Map<String, dynamic>>> _processFavorites(List<Map<String, dynamic>> songs) async {
    try {
      // Get all favorites at once to reduce SharedPreferences calls
      final allFavorites = await FavoritesManager.getAllFavorites();
      
      return songs.map((song) {
        final isFav = allFavorites.contains(song['title']);
        return {...song, 'isFav': isFav};
      }).toList();
    } catch (e) {
      debugPrint('Error processing favorites: $e');
      return songs.map((song) => {...song, 'isFav': false}).toList();
    }
  }

  List<Map<String, dynamic>> _getFilteredSongs(
      String query, List<Map<String, dynamic>> songs) {
    if (query.isEmpty) return songs;

    final queryLower = query.toLowerCase();
    return songs.where((song) {
      final titleLower = song['title']?.toString().toLowerCase() ?? '';
      final artistNameLower =
          song['artistName']?.toString().toLowerCase() ?? '';
      return titleLower.contains(queryLower) ||
          artistNameLower.contains(queryLower);
    }).toList();
  }

  void _toggleSearch() {
    setState(() {
      if (_isSearching) {
        _searchController.clear();
      }
      _isSearching = !_isSearching;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildBackground(),
          Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: _buildSongList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Colors.black),
        Positioned.fill(
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.23),
              BlendMode.dstATop,
            ),
            child: Image.asset(
              AppComponents.background,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isSearching
            ? TextField(
                key: const ValueKey('searchField'),
                controller: _searchController,
                autofocus: true,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                ),
                decoration: InputDecoration(
                  hintText: 'Search Songs...',
                  hintStyle: GoogleFonts.poppins(color: Colors.white54),
                  border: InputBorder.none,
                ),
                onChanged: (query) => setState(() {}),
              )
            : Text(
                'All Songs',
                key: const ValueKey('titleText'),
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
      ),
      leading: IconButton(
        icon: Icon(
          _isSearching ? Icons.close : Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: () {
          if (_isSearching) {
            _toggleSearch();
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
            );
          }
        },
      ),
      actions: [
        if (!_isSearching)
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: _toggleSearch,
          ),
      ],
    );
  }

  Widget _buildSongList() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoading,
      builder: (context, isLoading, _) {
        if (isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentColor),
            ),
          );
        }

        return ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: _songs,
          builder: (context, songs, _) {
            final filteredSongs =
                _getFilteredSongs(_searchController.text, songs);

            if (filteredSongs.isEmpty) {
              return Center(
                child: Text(
                  'No songs found.',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 20,
                  ),
                ),
              );
            }

            return ListView.builder(
              itemCount: filteredSongs.length,
              padding: const EdgeInsets.only(top: 16),
              itemBuilder: (context, index) {
                final song = filteredSongs[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      splashColor: AppColors.accentColorDark.withOpacity(0.2),
                      highlightColor: AppColors.accentColorDark.withOpacity(0.1),
                      onTap: () => _navigateToSongScreen(context, song),
                      child: SongTile(
                        key: ValueKey(song['title']),
                        avatarUrl: song['coverArtPath'] ?? '',
                        title: song['title'] ?? '',
                        subtitle: song['artistName'] ?? 'Unknown Artist',
                        isFav: song['isFav'] ?? false,
                        onFavoriteToggle: (isFavorited) => _updateFavorite(index, isFavorited),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
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

  Future<void> _updateFavorite(int index, bool isFavorited) async {
    try {
      final song = _songs.value[index];
      final success =
          await FavoritesManager.setFavorite(song['title'], isFavorited);

      if (success) {
        final List<Map<String, dynamic>> updatedSongs = List.from(_songs.value);
        updatedSongs[index] = {...updatedSongs[index], 'isFav': isFavorited};
        _songs.value = updatedSongs;
      } else {
        // Handle failure - revert UI if needed
        setState(() {
          // Revert the favorite toggle in the UI
          final List<Map<String, dynamic>> revertedSongs =
              List.from(_songs.value);
          revertedSongs[index] = {
            ...revertedSongs[index],
            'isFav': !isFavorited
          };
          _songs.value = revertedSongs;
        });

        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update favorite status'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error in _updateFavorite: $e');
      // Handle error appropriately
    }
  }
}
