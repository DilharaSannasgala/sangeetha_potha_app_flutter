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
  final ValueNotifier<String> _searchQuery = ValueNotifier('');
  late final ValueNotifier<List<Map<String, dynamic>>> _selectedSongs;
  late final ValueNotifier<List<Map<String, String>>> _selectedArtists;

  @override
  void initState() {
    super.initState();
    _initializeRandomData();
    _searchController.addListener(_onSearchChanged);
  }

  void _initializeRandomData() {
    // Randomly select initial data
    final randomSongs = List<Map<String, dynamic>>.from(widget.songs)..shuffle();
    final randomArtists = List<Map<String, String>>.from(widget.artists)..shuffle();

    // Get the first 4 songs and 3 artists
    _selectedSongs = ValueNotifier(randomSongs.take(4).toList());
    _selectedArtists = ValueNotifier(randomArtists.take(3).toList());
  }

  void _onSearchChanged() {
    _searchQuery.value = _searchController.text;
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchQuery.dispose();
    _selectedSongs.dispose();
    _selectedArtists.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredSongs(String query) {
    if (query.isEmpty) {
      return _selectedSongs.value;
    }
    
    final queryLower = query.toLowerCase();
    return _selectedSongs.value.where((song) {
      final title = song['title']?.toString().toLowerCase() ?? '';
      final artist = song['artistName']?.toString().toLowerCase() ?? '';
      return title.contains(queryLower) || artist.contains(queryLower);
    }).toList();
  }

  List<Map<String, String>> _getFilteredArtists(String query) {
    if (query.isEmpty) {
      return _selectedArtists.value;
    }
    
    final queryLower = query.toLowerCase();
    return _selectedArtists.value.where((artist) {
      final name = artist['name']?.toString().toLowerCase() ?? '';
      return name.contains(queryLower);
    }).toList();
  }

  Future<void> _toggleFavorite(Map<String, dynamic> song, bool isFavorited) async {
    try {
      final success = await FavoritesManager.setFavorite(song['title'], isFavorited);
      if (success) {
        setState(() {
          song['isFav'] = isFavorited;
        });
      } else {
        // Show error message if favorite toggle fails
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
      debugPrint('Error toggling favorite: $e');
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred while updating favorites'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _navigateToSongScreen(Map<String, dynamic> song) {
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

  void _navigateToArtistScreen(Map<String, String> artist) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArtistSongList(
          artistName: artist['name'] ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildBackground(),
          _buildContent(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
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
            ),
          ),
          ValueListenableBuilder<String>(
            valueListenable: _searchQuery,
            builder: (context, query, _) {
              return query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        _searchController.clear();
                        // No need to explicitly set _searchQuery.value as the listener handles it
                      },
                    )
                  : const SizedBox.shrink();
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
            (route) => false, // This will remove all routes from the stack
          );
        },
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
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
      ],
    );
  }

  Widget _buildContent() {
    return ValueListenableBuilder<String>(
      valueListenable: _searchQuery,
      builder: (context, query, _) {
        final filteredSongs = _getFilteredSongs(query);
        final filteredArtists = _getFilteredArtists(query);

        if (filteredSongs.isEmpty && filteredArtists.isEmpty) {
          return Center(
            child: Text(
              'No results found',
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
            ),
          );
        }

        return ListView(
          children: [
            if (filteredSongs.isNotEmpty) ...[
              _buildSectionHeader('Songs'),
              ..._buildSongsList(filteredSongs),
            ],
            if (filteredArtists.isNotEmpty) ...[
              _buildSectionHeader('Artists'),
              ..._buildArtistsList(filteredArtists),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          color: AppColors.accentColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List<Widget> _buildSongsList(List<Map<String, dynamic>> songs) {
    return songs.map((song) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          splashColor: AppColors.accentColorDark.withOpacity(0.2),
          highlightColor: AppColors.accentColorDark.withOpacity(0.1),
          onTap: () => _navigateToSongScreen(song),
          child: SongTile(
            key: ValueKey('song_${song['title']}'),
            avatarUrl: song['coverArtPath'] ?? '',
            title: song['title'] ?? '',
            subtitle: song['artistName'] ?? 'Unknown Artist',
            isFav: song['isFav'] ?? false,
            onFavoriteToggle: (isFavorited) => _toggleFavorite(song, isFavorited),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildArtistsList(List<Map<String, String>> artists) {
    return artists.map((artist) {
      return ArtistTile(
        key: ValueKey('artist_${artist['name']}'),
        avatarUrl: artist['avatarUrl'] ?? '',
        title: artist['name'] ?? 'Unknown Artist',
        onTap: () => _navigateToArtistScreen(artist),
      );
    }).toList();
  }
}