import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sangeetha_potha_app_flutter/services/database_service.dart';
import 'package:sangeetha_potha_app_flutter/services/firebase_service.dart';
import 'package:sangeetha_potha_app_flutter/services/image_service.dart';
import 'package:sangeetha_potha_app_flutter/services/sync_service.dart';

class MainService extends ChangeNotifier with WidgetsBindingObserver {
  final DatabaseService _db = DatabaseService();
  final ImageService _imageService = ImageService();
  final FirebaseService _firebase = FirebaseService();
  final SyncService _sync = SyncService();

  Timer? _syncTimer;
  StreamSubscription? _artistsSubscription;
  StreamSubscription? _songsSubscription;

  Future<void> initializeApp() async {
    await _db.initDatabase();
    WidgetsBinding.instance.addObserver(this); // Add lifecycle observer
    List<Map<String, dynamic>> songs = await _db.fetchSongs();

    if (songs.isEmpty) {
      await performInitialSync();
    } else {
      _triggerBackgroundSync();
    }

    _startPeriodicSync(); // Start periodic sync timer
    _startFirestoreListeners(); // Start Firestore listeners
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove lifecycle observer
    _syncTimer?.cancel(); // Cancel the timer when the service is disposed
    _artistsSubscription?.cancel(); // Cancel the Firestore listeners
    _songsSubscription?.cancel();
    super.dispose();
  }

  void _startFirestoreListeners() {
    print('Starting Firestore listeners...');

    // Listen for changes in the artists collection
    _artistsSubscription = FirebaseFirestore.instance
        .collection('artists')
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.removed) {
          // Handle deleted artist
          final deletedArtistId = change.doc.id;
          print('Artist deleted: $deletedArtistId');
          _deleteArtistLocally(deletedArtistId);
        } else if (change.type == DocumentChangeType.added || change.type == DocumentChangeType.modified) {
          // Handle added or modified artist
          print('Artist added/modified: ${change.doc.id}');
          _processArtistDocument(change.doc);
        }
      }
    });

    // Listen for changes in the songs collection
    _songsSubscription = FirebaseFirestore.instance
        .collection('songs')
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.removed) {
          // Handle deleted song
          final deletedSongId = change.doc.id;
          print('Song deleted: $deletedSongId');
          _deleteSongLocally(deletedSongId);
        } else if (change.type == DocumentChangeType.added || change.type == DocumentChangeType.modified) {
          // Handle added or modified song
          print('Song added/modified: ${change.doc.id}');
          _processSongDocument(change.doc);
        }
      }
    });
  }

  Future<void> _deleteArtistLocally(String artistId) async {
    try {
      await _db.deleteArtist(artistId);
      print('Artist deleted locally: $artistId');
      notifyListeners(); // Notify listeners to update the UI
    } catch (e) {
      print('Error deleting artist locally: $e');
    }
  }

  Future<void> _deleteSongLocally(String songId) async {
    try {
      await _db.deleteSong(songId);
      print('Song deleted locally: $songId');
      notifyListeners(); // Notify listeners to update the UI
    } catch (e) {
      print('Error deleting song locally: $e');
    }
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('App resumed: Triggering background sync...');
      _triggerBackgroundSync(); // Trigger sync when the app resumes
    }
  }

  void _startPeriodicSync() {
    const syncInterval = Duration(minutes: 1); // Sync every 1 minute
    print('Starting periodic sync with interval: $syncInterval');
    _syncTimer = Timer.periodic(syncInterval, (timer) {
      print('Periodic sync triggered at: ${DateTime.now()}');
      _triggerBackgroundSync(); // Trigger sync periodically
    });
  }

  Future<void> performInitialSync() async {
    if (await _sync.isConnected()) {
      print('Performing initial sync...');
      await _fetchEssentialData();
    } else {
      print('No internet connection: Skipping initial sync.');
    }
  }

  Future<void> _fetchEssentialData() async {
    print('Fetching essential data from Firebase...');
    final recentSongs = await _firebase.fetchRecentSongs(10);
    Set<String> artistIds = {};

    for (var doc in recentSongs.docs) {
      artistIds.add(doc['artistId']);
      await _processSongDocument(doc);
    }

    for (String artistId in artistIds) {
      final artistDoc = await _firebase.fetchArtist(artistId);
      if (artistDoc.exists) {
        await _processArtistDocument(artistDoc);
      }
    }
  }

  Future<void> _processSongDocument(DocumentSnapshot doc) async {
    try {
      print('Processing song document: ${doc.id}');
      Map<String, dynamic> songData = {
        'id': doc.id,
        'title': doc['title'],
        'lyrics': doc['lyrics'],
        'coverArtUrl': doc['songCoverUrl'],
        'coverArtPath': '',
        'isFav': doc['isFav'] ? 1 : 0,
        'artistId': doc['artistId'],
        'createdAt': (doc['createdAt'] as Timestamp).toDate().toIso8601String(),
        'isImageLoaded': 0,
      };

      // Insert the song with an empty coverArtPath
      await _db.insertSong(songData);

      // Download the cover art and update the song
      String imagePath = await _imageService.downloadImage(
        doc['songCoverUrl'],
        'song_${doc.id}',
      );

      if (imagePath.isNotEmpty) {
        songData['coverArtPath'] = imagePath;
        songData['isImageLoaded'] = 1;
        await _db.insertSong(songData); // Update the song with the image path
        notifyListeners();
      }
    } catch (e) {
      print('Error processing song document: $e');
    }
  }

  Future<void> _processArtistDocument(DocumentSnapshot doc) async {
    try {
      print('Processing artist document: ${doc.id}');
      Map<String, dynamic> artistData = {
        'id': doc.id,
        'name': doc['name'],
        'coverArtUrl': doc['artistCoverUrl'],
        'coverArtPath': '',
        'isImageLoaded': 0,
      };

      // Insert the artist with an empty coverArtPath
      await _db.insertArtist(artistData);

      // Download the cover art and update the artist
      String imagePath = await _imageService.downloadImage(
        doc['artistCoverUrl'],
        'artist_${doc.id}',
      );

      if (imagePath.isNotEmpty) {
        artistData['coverArtPath'] = imagePath;
        artistData['isImageLoaded'] = 1;
        await _db.insertArtist(artistData); // Update the artist with the image path
        notifyListeners();
      }
    } catch (e) {
      print('Error processing artist document: $e');
    }
  }

  Future<void> _triggerBackgroundSync() async {
    print('Checking if background sync is needed...');
    if (!await _sync.shouldSync()) {
      print('Sync not needed: Skipping background sync.');
      return;
    }

    try {
      print('Starting background sync...');
      final artists = await _firebase.fetchAllArtists();
      final songs = await _firebase.fetchAllSongs();

      for (var doc in artists.docs) {
        await _processArtistDocument(doc);
      }

      for (var doc in songs.docs) {
        await _processSongDocument(doc);
      }

      await _sync.updateLastSyncTime();
      print('Background sync completed successfully.');
    } catch (e) {
      print('Background sync error: $e');
    }
  }
}