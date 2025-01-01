import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sangeetha_potha_app_flutter/screens/artist_song_list.dart';
import 'package:sangeetha_potha_app_flutter/screens/song_screen.dart';
import 'package:sangeetha_potha_app_flutter/utils/app_color.dart';

import '../services/manage_favorite.dart';
import '../services/service.dart';
import '../utils/app_components.dart';
import '../widgets/artist_tile.dart';
import '../widgets/new_song_tile.dart';
import '../widgets/song_tile.dart';
import 'app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedTabIndex = 0;
  final Service _service = Service();
  List<Map<String, dynamic>> songs = [];
  List<Map<String, String>> artists = [];

  final List<Map<String, String>> newlyAddedSongs = [
    {
      'avatarUrl':
      'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2FOBUI8qgdzH8n79bpoj6t%2F281862ef03ad7767ba8b904992c2115d8042c54aimage%201.png?alt=media&token=d750e875-508f-4119-88ae-55b4da7bcc61',
      'title': 'නාඩගම් ගීය - Naadagam Geeya',
      'artist': 'Charitha Attalage',
    },
    {
      'avatarUrl':
      'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2FOBUI8qgdzH8n79bpoj6t%2F41419a5cc0f0eaf0a97e9abe721dbee82ff54179image%202.png?alt=media&token=435315c6-75b9-40d5-a5df-e556a6b4707f',
      'title': 'රහත් හිමිවරුන් - Rahath Himiwarun',
      'artist': 'Dhayan Hewage ft Ravi Jay',
    },
    {
      'avatarUrl':
      'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2FOBUI8qgdzH8n79bpoj6t%2F02653ef297798a327de62ddbfc137be4636831aeimage%203.png?alt=media&token=c29c3408-bce4-4908-8c6e-2a8470243cae',
      'title': 'ඔබට තියෙන ආදරේ - Obata Thiyena Adare',
      'artist': 'M.S. Fernando',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchSongData();
    _fetchArtistData();
  }

  Future<void> _fetchSongData() async {
    final fetchedSongs = await _service.fetchSongs();
    for (var song in fetchedSongs) {
      final isFav = await FavoritesManager.isFavorite(song['title']); // Use title or unique ID
      song['isFav'] = isFav;
    }
    setState(() {
      songs = fetchedSongs;
    });
  }

  Future<void> _fetchArtistData() async {
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

  @override
  Widget build(BuildContext context) {
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
                title: null, // No title for the home screen
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Text(
                              'Newly Added Songs',
                              style: GoogleFonts.getFont(
                                'Poppins',
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 180,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: newlyAddedSongs.length,
                          itemBuilder: (context, index) {
                            final song = newlyAddedSongs[index];
                            return Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: NewSongTile(
                                avatarUrl: song['avatarUrl']!,
                                title: song['title']!,
                                artist: song['artist']!,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Tab Section for Songs and Artists
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // "Songs" Button
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  selectedTabIndex = 0;
                                });
                              },
                              child: Text(
                                'Songs',
                                style: GoogleFonts.poppins(
                                  color: selectedTabIndex == 0
                                      ? AppColors.accentColor
                                      : Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // "Artists" Button
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  selectedTabIndex = 1;
                                });
                              },
                              child: Text(
                                'Artists',
                                style: GoogleFonts.poppins(
                                  color: selectedTabIndex == 1
                                      ? AppColors.accentColor
                                      : Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 0),
                      // Conditional Content Based on Selected Tab
                      if (selectedTabIndex == 0) ...[
                        // Songs List
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: songs.length,
                          itemBuilder: (context, index) {
                            final song = songs[index];
                            return Material(
                              color: Colors.transparent, // To make the background color consistent
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
                      ] else if (selectedTabIndex == 1) ...[
                        // Artists List
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: artists.length,
                          itemBuilder: (context, index) {
                            return ArtistTile(
                              avatarUrl: artists[index]['avatarUrl']!.isEmpty
                                  ? 'assets/fallback_avatar.png' // Fallback image path
                                  : artists[index]['avatarUrl']!,
                              title: artists[index]['name']!.isEmpty
                                  ? 'Unknown Artist'
                                  : artists[index]['name']!,
                              onTap: () {
                                // Navigate to SongsByArtistScreen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ArtistSongList(
                                      artistName: artists[index]['name']!,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
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
