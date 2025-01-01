import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sangeetha_potha_app_flutter/screens/artist_song_list.dart';
import '../services/service.dart';
import '../utils/app_components.dart';
import '../widgets/artist_tile.dart';
import 'home_screen.dart';

class ArtistList extends StatefulWidget {
  const ArtistList({super.key});

  @override
  State<ArtistList> createState() => _ArtistListState();
}

class _ArtistListState extends State<ArtistList> {
  final Service _service = Service();
  List<Map<String, String>> artists = [];
  bool isSearching = false;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final fetchedArtists = await _service.fetchArtists();
    print('Fetched artists: $fetchedArtists'); // Debug the fetched data

    setState(() {
      artists = fetchedArtists.map((artist) {
        return {
          'avatarUrl': artist['coverArtPath']?.toString() ?? '',
          'name': artist['name']?.toString() ?? '',
        };
      }).toList();
      print('Mapped artists: $artists');
    });
  }

  void startSearch() {
    setState(() {
      isSearching = true;
    });
  }

  void stopSearch() {
    setState(() {
      isSearching = false;
      searchQuery = '';
    });
  }

  List<Map<String, String>> getFilteredArtists() {
    if (searchQuery.isEmpty) {
      return artists;
    }
    return artists.where((artist) {
      final nameLower = (artist['name'] ?? '').toLowerCase();
      final queryLower = searchQuery.toLowerCase();
      return nameLower.contains(queryLower);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredArtists = getFilteredArtists();

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: Colors.black),
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
                    hintText: 'Search artists...',
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
                  'All Artists',
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
            top: MediaQuery.of(context).padding.top + kToolbarHeight,
            left: 0,
            right: 0,
            bottom: 0,
            child: ListView.builder(
              itemCount: filteredArtists.length,
              itemBuilder: (context, index) {
                return ArtistTile(
                  avatarUrl: filteredArtists[index]['avatarUrl']!.isEmpty
                      ? 'assets/fallback_avatar.png' // Fallback image path
                      : filteredArtists[index]['avatarUrl']!,
                  title: filteredArtists[index]['name']!.isEmpty
                      ? 'Unknown Artist'
                      : filteredArtists[index]['name']!,
                  onTap: () {
                    // Navigate to SongsByArtistScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ArtistSongList(
                          artistName: filteredArtists[index]['name']!,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
