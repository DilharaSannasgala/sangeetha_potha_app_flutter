import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  late Database _database;

  Future<void> initDatabase() async {
    String path = await getDatabasesPath();
    String dbPath = join(path, 'songs.db');
    _database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''CREATE TABLE artists (
      id TEXT PRIMARY KEY,
      name TEXT,
      coverArtUrl TEXT,
      coverArtPath TEXT,
      isImageLoaded INTEGER DEFAULT 0
    )''');

    await db.execute('''CREATE TABLE songs (
      id TEXT PRIMARY KEY,
      title TEXT,
      lyrics TEXT,
      coverArtUrl TEXT,
      coverArtPath TEXT,
      isFav INTEGER,
      artistId TEXT,
      createdAt TEXT,
      isImageLoaded INTEGER DEFAULT 0,
      FOREIGN KEY (artistId) REFERENCES artists (id)
    )''');
  }

  Future<void> insertArtist(Map<String, dynamic> artist) async {
    final existing = await _database.query(
      'artists',
      where: 'id = ?',
      whereArgs: [artist['id']],
    );

    artist['isImageLoaded'] = artist['coverArtPath']?.isNotEmpty == true ? 1 : 0;

    if (existing.isEmpty) {
      await _database.insert('artists', artist);
    } else {
      await _database.update(
        'artists',
        artist,
        where: 'id = ?',
        whereArgs: [artist['id']],
      );
    }
  }

  Future<void> insertSong(Map<String, dynamic> song) async {
    final existing = await _database.query(
      'songs',
      where: 'id = ?',
      whereArgs: [song['id']],
    );

    song['isImageLoaded'] = song['coverArtPath']?.isNotEmpty == true ? 1 : 0;

    if (existing.isEmpty) {
      await _database.insert('songs', song);
    } else {
      await _database.update(
        'songs',
        song,
        where: 'id = ?',
        whereArgs: [song['id']],
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchSongs() async {
    final List<Map<String, dynamic>> songs = await _database.query('songs');
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
          'artistName': artist['name'],
          'artistCoverArtPath': artist['coverArtPath'],
          'isArtistImageLoaded': artist['isImageLoaded'] == 1,
          'isSongImageLoaded': song['isImageLoaded'] == 1,
          'createdAt': song['createdAt'],
        });
      }
    }
    return enrichedSongs;
  }

  Future<List<Map<String, dynamic>>> fetchSongsByArtist(String artistName) async {
    final List<Map<String, dynamic>> artistData = await _database.query(
      'artists',
      where: 'name = ?',
      whereArgs: [artistName],
    );

    if (artistData.isEmpty) return [];

    final artistId = artistData.first['id'];
    final List<Map<String, dynamic>> songs = await _database.query(
      'songs',
      where: 'artistId = ?',
      whereArgs: [artistId],
    );

    return songs.map((song) => {
      ...song,
      'artistName': artistData.first['name'],
      'artistCoverArtPath': artistData.first['coverArtPath'],
      'isArtistImageLoaded': artistData.first['isImageLoaded'] == 1,
      'isSongImageLoaded': song['isImageLoaded'] == 1,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> fetchArtists() async {
    try {
      print('Fetching artists from local database');
      final List<Map<String, dynamic>> artists = await _database.query('artists');
      print('Database contents: $artists');

      if (artists.isEmpty) {
        print('No artists found in the local database.');
      } else {
        print('Fetched ${artists.length} artists from the local database.');
      }

      return artists;
    } catch (e) {
      print('Error fetching artists: $e');
      return [];
    }
  }

  Future<void> deleteArtist(String artistId) async {
    try {
      await _database.delete(
        'artists',
        where: 'id = ?',
        whereArgs: [artistId],
      );
      print('Artist deleted from local database: $artistId');
    } catch (e) {
      print('Error deleting artist from local database: $e');
    }
  }

  Future<void> deleteSong(String songId) async {
    try {
      await _database.delete(
        'songs',
        where: 'id = ?',
        whereArgs: [songId],
      );
      print('Song deleted from local database: $songId');
    } catch (e) {
      print('Error deleting song from local database: $e');
    }
  }
}
