import 'package:flutter/material.dart';
import 'package:sangeetha_potha_app_flutter/screens/search_page.dart';
import 'package:sangeetha_potha_app_flutter/screens/song_list.dart';
import 'package:sangeetha_potha_app_flutter/services/database_service.dart';
import 'package:sangeetha_potha_app_flutter/widgets/newly_added_songs.dart';
import 'package:sangeetha_potha_app_flutter/widgets/shimmer_loading.dart';
import '../services/manage_favorite.dart';
import '../utils/app_components.dart';
import 'app_drawer.dart';
import '../widgets/tab_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _dbService = DatabaseService();
  bool _isLoading = true;

  // Use ValueNotifier for reactive state management
  final ValueNotifier<List<Map<String, dynamic>>> _songs = ValueNotifier([]);
  final ValueNotifier<List<Map<String, String>>> _artists = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      await Future.wait([
        _fetchSongData(),
        _fetchArtistData(),
      ]);
    } catch (e) {
      debugPrint('Error loading data: $e');
      // Consider showing an error message to the user
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _fetchSongData() async {
    try {
      final fetchedSongs = await _dbService.fetchSongs();
      _songs.value = await _processFavorites(fetchedSongs);
    } catch (e) {
      debugPrint('Error fetching songs: $e');
      // Handle error appropriately
    }
  }

  Future<List<Map<String, dynamic>>> _processFavorites(
      List<Map<String, dynamic>> songs) async {
    return Future.wait(
      songs.map((song) async {
        final isFav = await FavoritesManager.isFavorite(song['title']);
        return {...song, 'isFav': isFav};
      }),
    );
  }

  Future<void> _fetchArtistData() async {
    try {
      final fetchedArtists = await _dbService.fetchArtists();
      _artists.value = _processArtists(fetchedArtists);
    } catch (e) {
      debugPrint('Error fetching artists: $e');
      // Handle error appropriately
    }
  }

  List<Map<String, String>> _processArtists(
      List<Map<String, dynamic>> artists) {
    return artists
        .map((artist) => {
              'avatarUrl': artist['coverArtPath']?.toString() ?? '',
              'name': artist['name']?.toString() ?? '',
            })
        .toList();
  }

  @override
  void dispose() {
    _songs.dispose();
    _artists.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      body: _isLoading
        ? const ShimmerLoading()
        : _HomeBody(
            songs: _songs,
            artists: _artists,
          ),
    );
  }
}

// Separate widget for the body to improve maintainability
class _HomeBody extends StatelessWidget {
  final ValueNotifier<List<Map<String, dynamic>>> songs;
  final ValueNotifier<List<Map<String, String>>> artists;

  const _HomeBody({
    required this.songs,
    required this.artists,
  });

  @override
  Widget build(BuildContext context) {
    // Determine if the device is in landscape mode
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Stack(
      fit: StackFit.expand,
      children: [
        _buildBackground(),
        Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: _buildContent(context, isLandscape),
            ),
          ],
        ),
      ],
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

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: null,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () => _navigateToSearch(context),
        ),
      ],
    );
  }

  void _navigateToSearch(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchPage(
          songs: songs.value,
          artists: artists.value,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isLandscape) {
    return ValueListenableBuilder(
      valueListenable: songs,
      builder: (context, songsList, _) {
        final recentSongs = _getRecentSongs(songsList);
        final sortedSongs = _getSortedSongs(songsList);

        return ValueListenableBuilder(
          valueListenable: artists,
          builder: (context, artistsList, _) {
            final topArtists = artistsList.take(10).toList();

            return SingleChildScrollView(
              child: Column(
                children: [
                  // Only show banner in portrait mode
                  if (!isLandscape) ...[
                    _buildBanner(),
                    const SizedBox(height: 24),
                  ],
                  NewlyAddedSongs(
                    songs: recentSongs,
                    onSeeMore: () => _navigateToSongList(context),
                  ),
                  const SizedBox(height: 16),
                  TabSection(
                    sortedSongs: sortedSongs,
                    topArtists: topArtists,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.yellow.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 60,
              offset: const Offset(0, 50),
            ),
          ],
        ),
        child: Image.asset(
          AppComponents.banner,
          fit: BoxFit.fill,
          width: double.infinity,
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getRecentSongs(List<Map<String, dynamic>> songs) {
    final recentSongs = List<Map<String, dynamic>>.from(songs)
      ..sort((a, b) => (b['createdAt'] ?? 0).compareTo(a['createdAt'] ?? 0));
    return recentSongs.take(10).toList();
  }

  List<Map<String, dynamic>> _getSortedSongs(List<Map<String, dynamic>> songs) {
    return List<Map<String, dynamic>>.from(songs)
      ..sort((a, b) => a['title'].compareTo(b['title']));
  }

  void _navigateToSongList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SongList(),
      ),
    );
  }
}