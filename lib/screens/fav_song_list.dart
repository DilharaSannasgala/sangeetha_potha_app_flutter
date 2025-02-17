import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sangeetha_potha_app_flutter/screens/home_screen.dart';
import 'package:sangeetha_potha_app_flutter/services/database_service.dart';
import 'package:sangeetha_potha_app_flutter/services/manage_favorite.dart';
import 'package:sangeetha_potha_app_flutter/utils/app_color.dart';
import '../utils/app_components.dart';
import '../widgets/song_tile.dart';
import 'song_screen.dart';

class FavList extends StatefulWidget {
  const FavList({super.key});

  @override
  State<FavList> createState() => _FavListState();
}

class _FavListState extends State<FavList> {
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
      _songs.value = songsWithFavorites.where((song) => song['isFav'] == true).toList();
    } catch (e) {
      debugPrint('Error fetching favorite songs: $e');
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load favorite songs')),
        );
      }
    } finally {
      _isLoading.value = false;
    }
  }

  Future<List<Map<String, dynamic>>> _processFavorites(List<Map<String, dynamic>> songs) async {
    try {
      final allFavorites = await FavoritesManager.getAllFavorites();
      return songs.map((song) {
        final isFav = allFavorites.contains(song['title']);
        return {...song, 'isFav': isFav};
      }).toList();
    } catch (e) {
      debugPrint('Error processing favorites: $e');
      return songs;
    }
  }

  List<Map<String, dynamic>> _getFilteredSongs(String query) {
    if (query.isEmpty) return _songs.value;
    
    final queryLower = query.toLowerCase();
    return _songs.value.where((song) {
      final titleLower = song['title']?.toString().toLowerCase() ?? '';
      final artistNameLower = song['artistName']?.toString().toLowerCase() ?? '';
      return titleLower.contains(queryLower) || artistNameLower.contains(queryLower);
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

  Future<void> _updateFavorite(int index, bool isFavorited) async {
    try {
      final song = _songs.value[index];
      final success = await FavoritesManager.setFavorite(song['title'], isFavorited);
      
      if (success) {
        if (!isFavorited) {
          // Remove from favorites list
          final List<Map<String, dynamic>> updatedSongs = List.from(_songs.value);
          updatedSongs.removeAt(index);
          _songs.value = updatedSongs;
        }
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update favorite status')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error updating favorite: $e');
    }
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
                  hintText: 'Search Favorites...',
                  hintStyle: GoogleFonts.poppins(color: Colors.white54),
                  border: InputBorder.none,
                ),
                onChanged: (query) => setState(() {}),
              )
            : Text(
                'Favorites',
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
            final filteredSongs = _getFilteredSongs(_searchController.text);

            if (filteredSongs.isEmpty) {
              return Center(
                child: Text(
                  'No favorite songs found...',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 18,
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
}