import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sangeetha_potha_app_flutter/screens/song_screen.dart';
import 'package:sangeetha_potha_app_flutter/utils/app_color.dart';

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
  bool isSearching = false;
  String searchQuery = "";
  int selectedTabIndex = 0;

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

  final List<Map<String, String>> songs = [
    {
      'avatarUrl':
      'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2FOBUI8qgdzH8n79bpoj6t%2F281862ef03ad7767ba8b904992c2115d8042c54aimage%201.png?alt=media&token=d750e875-508f-4119-88ae-55b4da7bcc61',
      'title': 'නාඩගම් ගීය - Naadagam geeya',
      'artist': 'Charitha Attalage',
      'lyrics': 'Here are the lyrics for Naadagam geeya...'
    },
    {
      'avatarUrl':
      'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2FOBUI8qgdzH8n79bpoj6t%2F41419a5cc0f0eaf0a97e9abe721dbee82ff54179image%202.png?alt=media&token=435315c6-75b9-40d5-a5df-e556a6b4707f',
      'title': 'රහත් හිමිවරුන් - Rahath himiwarun',
      'artist': 'Dhayan Hewage ft Ravi Jay',
      'lyrics': 'Here are the lyrics for Rahath himiwarun...'
    },
    {
      'avatarUrl':
      'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2FOBUI8qgdzH8n79bpoj6t%2F02653ef297798a327de62ddbfc137be4636831aeimage%203.png?alt=media&token=c29c3408-bce4-4908-8c6e-2a8470243cae',
      'title': 'ඔබට තියෙන ආදරේ - Obata thiyena adare',
      'artist': 'M.S. Fernando',
      'lyrics': 'Here are the lyrics for Obata thiyena adare...'
    },
  ];

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

  void startSearch() {
    setState(() {
      isSearching = true;
    });
  }

  void stopSearch() {
    setState(() {
      isSearching = false;
      searchQuery = "";
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
                title: isSearching
                    ? TextField(
                  key: const ValueKey('searchField'),
                  autofocus: true,
                  style: GoogleFonts.poppins(
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
                    : null, // No title for the home screen
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
                actions: [
                  if (!isSearching)
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: startSearch,
                    ),
                  if (isSearching)
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: stopSearch,
                    ),
                ],
              ),
              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Banner
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SongScreen(
                                      avatarUrl: song['avatarUrl']!,
                                      title: song['title']!,
                                      subtitle: song['artist']!,
                                      lyrics: song['lyrics']!,
                                    ),
                                  ),
                                );
                              },
                              child: SongTile(
                                avatarUrl: song['avatarUrl']!,
                                title: song['title']!,
                                subtitle: song['artist']!,
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
                              avatarUrl: artists[index]['avatarUrl']!,
                              title: artists[index]['name']!,
                              onTap: () {
                                print('Tapped on ${artists[index]['name']}');
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
