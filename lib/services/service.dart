import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class Service {
  static final Service _instance = Service._internal();
  factory Service() => _instance;

  Service._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  late Database _database;

  Future<void> initDatabase() async {
    String path = await getDatabasesPath();
    String dbPath = path + '/songs.db';
    print('Initializing database at path: $dbPath');
    _database = await openDatabase(dbPath, version: 1, onCreate: _createDb);
    print('Database initialized');
  }

  Future<void> _createDb(Database db, int version) async {
    print('Creating tables in the database');
    await db.execute('''CREATE TABLE artists (
        id TEXT PRIMARY KEY,
        name TEXT,
        coverArtUrl TEXT,
        coverArtPath TEXT
      )''');
    await db.execute('''CREATE TABLE songs (
        id TEXT PRIMARY KEY,
        title TEXT,
        lyrics TEXT,
        coverArtUrl TEXT,
        coverArtPath TEXT,
        isFav INTEGER,
        artistId TEXT,
        FOREIGN KEY (artistId) REFERENCES artists (id)
      )''');
    print('Tables created');
  }

  // Insert artist only if it doesn't already exist using doc.id
  Future<void> insertArtist(Map<String, dynamic> artist) async {
    print('Inserting artist into database: $artist');

    final existing = await _database.query(
      'artists',
      where: 'id = ?',
      whereArgs: [artist['id']],  // Check by document id
    );

    if (existing.isEmpty) {
      await _database.insert('artists', artist, conflictAlgorithm: ConflictAlgorithm.replace);
      print('Artist inserted');
    } else {
      print('Artist already exists in the database');
    }
  }

  // Insert song only if it doesn't already exist using doc.id
  Future<void> insertSong(Map<String, dynamic> song) async {
    print('Inserting song into database: $song');

    final existing = await _database.query(
      'songs',
      where: 'id = ?',  // Check by Firebase document id
      whereArgs: [song['id']],
    );

    if (existing.isEmpty) {
      await _database.insert('songs', song, conflictAlgorithm: ConflictAlgorithm.replace);
      print('Song inserted');
    } else {
      print('Song already exists in the database');
    }
  }

  Future<List<Map<String, dynamic>>> fetchSongs() async {
    print('Fetching songs from local database');

    final List<Map<String, dynamic>> songs = await _database.query('songs');

    // Enrich each song with artist details
    List<Map<String, dynamic>> enrichedSongs = [];
    for (var song in songs) {
      final List<Map<String, dynamic>> artistData = await _database.query(
        'artists',
        where: 'id = ?',
        whereArgs: [song['artistId']],
      );

      if (artistData.isNotEmpty) {
        final artist = artistData.first;
        enrichedSongs.add({
          ...song,
          'artistName': artist['name'], // Add artist name
          'artistCoverArtPath': artist['coverArtPath'], // Add artist cover art path
        });
      } else {
        // Add the song as-is if no artist is found
        enrichedSongs.add(song);
      }
    }

    print('Fetched ${enrichedSongs.length} enriched songs');
    return enrichedSongs;
  }

  Future<List<Map<String, dynamic>>> fetchArtists() async {
    print('Fetching artists from local database');

    // Query all artists from the local database
    final List<Map<String, dynamic>> artists = await _database.query('artists');
    print('Database contents: $artists');

    if (artists.isEmpty) {
      print('No artists found in the local database.');
    } else {
      print('Fetched ${artists.length} artists from the local database.');
    }

    return artists;
  }

  Future<List<Map<String, dynamic>>> fetchSongsByArtist(String artistName) async {
    print('Fetching songs by artist: $artistName');

    // First, get the artist record from the 'artists' table
    final List<Map<String, dynamic>> artistData = await _database.query(
      'artists',
      where: 'name = ?',
      whereArgs: [artistName],
    );

    if (artistData.isEmpty) {
      print('Artist not found: $artistName');
      return []; // Return an empty list if the artist is not found
    }

    final artistId = artistData.first['id'];

    // Now, fetch songs related to this artistId
    final List<Map<String, dynamic>> songs = await _database.query(
      'songs',
      where: 'artistId = ?',
      whereArgs: [artistId],
    );

    // Enrich each song with artist details
    List<Map<String, dynamic>> enrichedSongs = [];
    for (var song in songs) {
      enrichedSongs.add({
        ...song,
        'artistName': artistData.first['name'], // Add artist name
        'artistCoverArtPath': artistData.first['coverArtPath'], // Add artist cover art path
      });
    }

    print('Fetched ${enrichedSongs.length} songs for artist: $artistName');
    return enrichedSongs;
  }

  Future<bool> isConnected() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    bool isConnected = connectivityResult != ConnectivityResult.none;
    print('Internet connectivity: ${isConnected ? "Connected" : "Not connected"}');
    return isConnected;
  }

  Future<void> fetchArtistsFromFirebase() async {
    if (await isConnected()) {
      print('Fetching artists from Firebase Firestore');
      QuerySnapshot artistsSnapshot = await _firestore.collection('artists').get();
      print('Fetched ${artistsSnapshot.docs.length} artists from Firestore');

      for (var doc in artistsSnapshot.docs) {
        String id = doc.id; // Firebase document ID as the unique identifier
        String name = doc['name'];
        String coverArtUrl = doc['artistCoverUrl'];

        print('Downloading cover art for artist: $name');
        String coverArtPath = await _downloadImage(coverArtUrl, 'artist_$id');
        print('Cover art downloaded to path: $coverArtPath');

        Map<String, dynamic> artistData = {
          'id': id,  // Use doc.id as the unique identifier
          'name': name,
          'coverArtUrl': coverArtUrl,
          'coverArtPath': coverArtPath,
        };

        await insertArtist(artistData);
      }
    } else {
      print('No internet connection. Skipping artist fetch.');
    }
  }

  Future<void> fetchSongsFromFirebase() async {
    if (await isConnected()) {
      print('Fetching songs from Firebase Firestore');
      QuerySnapshot songsSnapshot = await _firestore.collection('songs').get();
      print('Fetched ${songsSnapshot.docs.length} songs from Firestore');

      for (var doc in songsSnapshot.docs) {
        String id = doc.id;
        String title = doc['title'];
        String lyrics = doc['lyrics'];
        String coverArtUrl = doc['songCoverUrl'];
        bool isFav = doc['isFav'];
        String artistId = doc['artistId'];

        print('Downloading cover art for song: $title');
        String coverArtPath = await _downloadImage(coverArtUrl, 'song_$id');
        print('Cover art downloaded to path: $coverArtPath');

        Map<String, dynamic> songData = {
          'id': id,  // Use doc.id as the unique identifier
          'title': title,
          'lyrics': lyrics,
          'coverArtUrl': coverArtUrl,
          'coverArtPath': coverArtPath,
          'isFav': isFav ? 1 : 0,
          'artistId': artistId,
        };

        await insertSong(songData);
      }
    } else {
      print('No internet connection. Skipping song fetch.');
    }
  }

  Future<String> _downloadImage(String url, String fileName) async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String localPath = '${appDocDir.path}/$fileName.jpg';

      print('Downloading image from: $url');
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final file = File(localPath);
        await file.writeAsBytes(response.bodyBytes);
        print('Image downloaded and saved at: $localPath');
        return localPath;
      } else {
        throw Exception('Failed to download image');
      }
    } catch (e) {
      print('Error downloading image: $e');
      return '';
    }
  }

  Future<List<Map<String, dynamic>>> loadSongData() async {
    print('Loading song data...');
    List<Map<String, dynamic>> songs = await fetchSongs();

    if (songs.isEmpty) {
      print('No songs found locally, fetching from Firebase');
      await fetchArtistsFromFirebase(); // Fetch artists first
      await fetchSongsFromFirebase();
      songs = await fetchSongs();
    } else {
      print('Loaded ${songs.length} songs from local storage');
    }

    return songs;
  }
}

