import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<QuerySnapshot> fetchRecentSongs(int limit) async {
    return await _firestore
        .collection('songs')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
  }

  Future<DocumentSnapshot> fetchArtist(String artistId) async {
    return await _firestore.collection('artists').doc(artistId).get();
  }

  Future<QuerySnapshot> fetchAllArtists() async {
    return await _firestore.collection('artists').get();
  }

  Future<QuerySnapshot> fetchAllSongs() async {
    return await _firestore.collection('songs').get();
  }
}