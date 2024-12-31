import 'package:shared_preferences/shared_preferences.dart';

class FavoritesManager {
  static const String _favoritesKey = 'favorites';

  // Save favorite status for a song
  static Future<void> setFavorite(String songId, bool isFav) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];
    if (isFav) {
      if (!favorites.contains(songId)) {
        favorites.add(songId);
      }
    } else {
      favorites.remove(songId);
    }
    await prefs.setStringList(_favoritesKey, favorites);
  }

  // Get favorite status for a song
  static Future<bool> isFavorite(String songId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];
    return favorites.contains(songId);
  }
}
