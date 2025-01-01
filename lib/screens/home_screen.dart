import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sangeetha_potha_app_flutter/screens/artist_list.dart';
import 'package:sangeetha_potha_app_flutter/screens/song_list.dart';
import 'package:sangeetha_potha_app_flutter/utils/app_color.dart';
import 'package:sangeetha_potha_app_flutter/widgets/newly_added_songs.dart';

import '../services/manage_favorite.dart';
import '../services/service.dart';
import '../utils/app_components.dart';
import 'app_drawer.dart';
import '../widgets/tab_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Service _service = Service();
  List<Map<String, dynamic>> songs = [];
  List<Map<String, String>> artists = [];

  @override
  void initState() {
    super.initState();
    _fetchSongData();
    _fetchArtistData();
  }

  Future<void> _fetchSongData() async {
    final fetchedSongs = await _service.fetchSongs();
    for (var song in fetchedSongs) {
      final isFav = await FavoritesManager.isFavorite(song['title']);
      song['isFav'] = isFav;
    }
    setState(() {
      songs = fetchedSongs;
    });
  }

  Future<void> _fetchArtistData() async {
    final fetchedArtists = await _service.fetchArtists();
    setState(() {
      artists = fetchedArtists.map((artist) {
        return {
          'avatarUrl': artist['coverArtPath']?.toString() ?? '',
          'name': artist['name']?.toString() ?? '',
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final recentSongs = List<Map<String, dynamic>>.from(songs)
      ..sort((a, b) => (b['createdAt'] ?? 0).compareTo(a['createdAt'] ?? 0));
    final topRecentSongs = recentSongs.take(10).toList();

    final sortedSongs = List<Map<String, dynamic>>.from(songs)
      ..sort((a, b) => a['title'].compareTo(b['title']));

    final topArtists = artists.take(10).toList();

    return Scaffold(
      drawer: const AppDrawer(),
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
          Column(
            children: [
              // Fixed AppBar
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: Builder(
                  builder: (context) {
                    return IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    );
                  },
                ),
              ),
              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Banner
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.yellow.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 60,
                                offset: Offset(0, 50),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            AppComponents.banner,
                            fit: BoxFit.fill,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Newly Added Songs Section
                      NewlyAddedSongs(
                        songs: topRecentSongs,
                        onSeeMore: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SongList(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      // Reusable Tab Section for Songs and Artists
                      TabSection(
                        sortedSongs: sortedSongs,
                        topArtists: topArtists,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
