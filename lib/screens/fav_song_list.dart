import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_components.dart';
import '../widgets/song_tile.dart';
import 'song_screen.dart';

class FavList extends StatefulWidget {
  const FavList({super.key});

  @override
  State<FavList> createState() => _SongListState();
}

class _SongListState extends State<FavList> {
  final List<Map<String, String>> songs = [
    {
      'avatarUrl':
      'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2FOBUI8qgdzH8n79bpoj6t%2F281862ef03ad7767ba8b904992c2115d8042c54aimage%201.png?alt=media&token=d750e875-508f-4119-88ae-55b4da7bcc61',
      'title': 'නාඩගම් ගීය - Naadagam geeya',
      'subtitle': 'Charitha Attalage',
      'lyrics': '''හෙට නාඩගමේ මං රජාට අඳිනවා
                  අජාසත්ත නාමෙන්
                  මුළු ගමේම අඟනුන් මට වහ වැටෙනවා
                  බලාපල්ලා බොරුනම්
                  හෙට නාඩගමේ මං රජාට අඳිනවා
                  අජාසත්ත නාමෙන්
                  මුළු ගමේම අඟනුන් මට හිත වැටෙනවා
                  බලාපල්ලා බොරුනම්
                  දමා කඩුක්කන් ඔටුනු නළල් පටි
                  කඩුව කරකවා සබයට එන හැටි
                  දමා කඩුක්කන් ඔටුනු නළල් පටි
                  කඩුව කරකවා සබයට එන හැටි
                  බලාහිඳින අඟනුන් සත්තයි
                  ආලේ බඳී රහසින්
                  ආ... බලාහිඳින අඟනුන්
                  ආලේ බඳී රහසින්
                  පවර අජාසත් නිරිඳුන් මම වෙමි
                  පියා නසා රජකම අරගන්නෙමි
                  පවර අජාසත් නිරිඳුන් මම වෙමි
                  පියා නසා රජකම අරගන්නෙමි
                  කියා එද්දි අද මං සත්තයි
                  ආලේ බදියි අඟනුන්
                  ආ... කියා එද්දි අද මං
                  ආලේ බදියි අඟනුන්
                  හෙට නාඩගමේ මං රජාට අඳිනවා
                  අජාසත්ත නාමෙන්
                  මුළු ගමේම අඟනුන් මට වහ වැටෙනවා
                  බලාපල්ලා බොරුනම්
                  හෙට නාඩගමේ මං රජාට අඳිනවා
                  අජාසත්ත නාමෙන්
                  මුළු ගමේම අඟනුන් මට හිත වැටෙනවා
                  බලාපල්ලා බොරුනම්'''
    },
    {
      'avatarUrl':
      'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2FOBUI8qgdzH8n79bpoj6t%2F41419a5cc0f0eaf0a97e9abe721dbee82ff54179image%202.png?alt=media&token=435315c6-75b9-40d5-a5df-e556a6b4707f',
      'title': 'රහත් හිමිවරුන් - Rahath himiwarun',
      'subtitle': 'Dhayan Hewage ft Ravi Jay',
      'lyrics': 'Here are the lyrics for Rahath himiwarun...'
    },
    {
      'avatarUrl':
      'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2FOBUI8qgdzH8n79bpoj6t%2F02653ef297798a327de62ddbfc137be4636831aeimage%203.png?alt=media&token=c29c3408-bce4-4908-8c6e-2a8470243cae',
      'title': 'ඔබට තියෙන ආදරේ - Obata thiyena adare',
      'subtitle': 'M.S. Fernando',
      'lyrics': 'Here are the lyrics for Obata thiyena adare...'
    },
  ];

  String searchQuery = '';
  bool isSearching = false;

  // Method to toggle search mode
  void startSearch() {
    setState(() {
      isSearching = true;
    });
  }

  // Method to close search
  void stopSearch() {
    setState(() {
      isSearching = false;
      searchQuery = '';
    });
  }

  // Method to filter songs based on the search query
  List<Map<String, String>> getFilteredSongs() {
    if (searchQuery.isEmpty) {
      return songs;
    }
    return songs.where((song) {
      final titleLower = song['title']!.toLowerCase();
      final subtitleLower = song['subtitle']!.toLowerCase();
      final queryLower = searchQuery.toLowerCase();
      return titleLower.contains(queryLower) ||
          subtitleLower.contains(queryLower);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredSongs = getFilteredSongs();

    return Scaffold(
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
                    : Text(
                  'Favourites',
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
          Positioned(
            top: 70,
            left: 0,
            right: 0,
            bottom: 0,
            child: ListView.builder(
              itemCount: filteredSongs.length,
              itemBuilder: (context, index) {
                final song = filteredSongs[index];
                return GestureDetector(
                  onTap: () {
                    // Navigate to SongScreen on tap
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SongScreen(
                          avatarUrl: song['avatarUrl']!,
                          title: song['title']!,
                          subtitle: song['subtitle']!,
                          lyrics: song['lyrics']!,
                        ),
                      ),
                    );
                  },
                  child: SongTile(
                    avatarUrl: song['avatarUrl']!,
                    title: song['title']!,
                    subtitle: song['subtitle']!,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
