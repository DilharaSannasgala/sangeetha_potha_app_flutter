// artist_list.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sangeetha_potha_app_flutter/model/artist_model.dart';
import 'package:sangeetha_potha_app_flutter/screens/artist_song_list.dart';
import 'package:sangeetha_potha_app_flutter/services/database_service.dart';
import '../utils/app_color.dart';
import '../utils/app_components.dart';
import '../widgets/artist_tile.dart';
import 'home_screen.dart';

class ArtistList extends StatefulWidget {
  const ArtistList({super.key});

  @override
  State<ArtistList> createState() => _ArtistListState();
}

class _ArtistListState extends State<ArtistList> {
  final DatabaseService _dbService = DatabaseService();
  final ValueNotifier<List<ArtistModel>> _artists = ValueNotifier([]);
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
    _artists.dispose();
    _isLoading.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      final fetchedArtists = await _dbService.fetchArtists();
      if (!mounted) return;

      _artists.value = fetchedArtists.map((artist) => ArtistModel(
        avatarUrl: artist['coverArtPath']?.toString() ?? '',
        name: artist['name']?.toString() ?? '',
      )).toList();
    } catch (e) {
      debugPrint('Error fetching artists: $e');
      // Handle error appropriately
    } finally {
      _isLoading.value = false;
    }
  }

  List<ArtistModel> _getFilteredArtists(String query, List<ArtistModel> artists) {
    if (query.isEmpty) return artists;
    
    final queryLower = query.toLowerCase();
    return artists.where((artist) => 
      artist.name.toLowerCase().contains(queryLower)
    ).toList();
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
                child: _buildArtistList(),
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
                  hintText: 'Search Artists...',
                  hintStyle: GoogleFonts.poppins(color: Colors.white54),
                  border: InputBorder.none,
                ),
                onChanged: (query) => setState(() {}),
              )
            : Text(
                'All Artists',
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

  Widget _buildArtistList() {
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

        return ValueListenableBuilder<List<ArtistModel>>(
          valueListenable: _artists,
          builder: (context, artists, _) {
            final filteredArtists = _getFilteredArtists(_searchController.text, artists);

            if (filteredArtists.isEmpty) {
              return Center(
                child: Text(
                  'No artists found.',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 20,
                  ),
                ),
              );
            }

            return ListView.builder(
              itemCount: filteredArtists.length,
              padding: const EdgeInsets.only(top: 16),
              itemBuilder: (context, index) {
                final artist = filteredArtists[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ArtistTile(
                    key: ValueKey(artist.name),
                    avatarUrl: artist.avatarUrl.isEmpty
                        ? 'assets/fallback_avatar.png'
                        : artist.avatarUrl,
                    title: artist.name.isEmpty ? 'Unknown Artist' : artist.name,
                    onTap: () => _navigateToArtistSongs(artist.name),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _navigateToArtistSongs(String artistName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArtistSongList(artistName: artistName),
      ),
    );
  }
}

