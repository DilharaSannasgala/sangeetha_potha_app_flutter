import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_components.dart';
import '../widgets/artist_tile.dart';

class ArtistList extends StatefulWidget {
  const ArtistList({super.key});

  @override
  State<ArtistList> createState() => _ArtistListState();
}

class _ArtistListState extends State<ArtistList> {
  bool isSearching = false;
  String searchQuery = '';

  // Sample mock data for artists
  final List<Map<String, String>> artists = [
    {
      'avatarUrl': 'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2FOBUI8qgdzH8n79bpoj6t%2F868ff930ba88066f692ccbc294bb8a3953f53794image%204.png?alt=media&token=91416d66-31b1-4ae8-8a71-a8637b0c4a96',
      'name': 'කසුන් කල්හාර - Kasun Kalhara',
    },
    {
      'avatarUrl': 'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2FOBUI8qgdzH8n79bpoj6t%2F36f47d55a9324620e5dd5726947f1388f6b3333bimage%205.png?alt=media&token=b94fab2d-7375-4daf-956e-fa856a3d2a8c',
      'name': 'ජෝතිපාල - Jothipala',
    },
    {
      'avatarUrl': 'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2FOBUI8qgdzH8n79bpoj6t%2F1040942ecbf4777b65f23a1d1a456c137833c6adimage%206.png?alt=media&token=4c5e850c-8c14-4227-8696-0a4c6f4758b8',
      'name': 'සනුක වික්‍රමසිංහ - Sanuka Wikramasingha',
    },
  ];

  // Method to start search mode
  void startSearch() {
    setState(() {
      isSearching = true;
    });
  }

  // Method to stop search mode
  void stopSearch() {
    setState(() {
      isSearching = false;
      searchQuery = '';
    });
  }

  // Method to filter artists based on the search query
  List<Map<String, String>> getFilteredArtists() {
    if (searchQuery.isEmpty) {
      return artists;
    }
    return artists.where((artist) {
      final nameLower = artist['name']!.toLowerCase();
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
          // Background Color
          Container(
            color: Colors.black,
          ),
          // Background Image with reduced opacity
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
          // AppBar with back button and search button
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
          // List of Artist Tiles
          Positioned(
            top: 80, // Adjust to position below AppBar
            left: 0,
            right: 0,
            bottom: 0,
            child: ListView.builder(
              itemCount: filteredArtists.length,
              itemBuilder: (context, index) {
                return ArtistTile(
                  avatarUrl: filteredArtists[index]['avatarUrl']!,
                  title: filteredArtists[index]['name']!,
                  onTap: () {
                    print('Tapped on ${filteredArtists[index]['name']}');
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
