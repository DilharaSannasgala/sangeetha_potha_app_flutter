import 'package:shared_preferences/shared_preferences.dart';

class FavoritesManager {
  static const String _favoritesKey = 'favorites';
  static SharedPreferences? _prefsInstance;

  // Initialize SharedPreferences instance
  static Future<SharedPreferences> get _prefs async {
    _prefsInstance ??= await SharedPreferences.getInstance();
    return _prefsInstance!;
  }

  // Get all favorites
  static Future<Set<String>> getAllFavorites() async {
    final prefs = await _prefs;
    return Set<String>.from(prefs.getStringList(_favoritesKey) ?? []);
  }

  // Save favorite status for a song
  static Future<bool> setFavorite(String songId, bool isFav) async {
    try {
      final prefs = await _prefs;
      final favorites = Set<String>.from(prefs.getStringList(_favoritesKey) ?? []);
      
      if (isFav) {
        favorites.add(songId);
      } else {
        favorites.remove(songId);
      }
      
      return await prefs.setStringList(_favoritesKey, favorites.toList());
    } catch (e) {
      print('Error setting favorite: $e');
      return false;
    }
  }

  // Get favorite status for a song
  static Future<bool> isFavorite(String songId) async {
    try {
      final prefs = await _prefs;
      final favorites = prefs.getStringList(_favoritesKey) ?? [];
      return favorites.contains(songId);
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }
}