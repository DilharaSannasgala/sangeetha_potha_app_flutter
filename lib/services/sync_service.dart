import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncService {
  static const String LAST_SYNC_TIME = 'last_sync_time';
  static const Duration SYNC_INTERVAL = Duration(minutes: 1); // Sync every 1 minute

  Future<bool> shouldSync() async {
    if (!await isConnected()) {
      print('No internet connection: Skipping sync.');
      return false;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final lastSync = prefs.getString(LAST_SYNC_TIME);

    if (lastSync == null) {
      print('First sync: Performing sync.');
      return true;
    }

    final lastSyncTime = DateTime.parse(lastSync);
    final now = DateTime.now();

    if (now.difference(lastSyncTime) > SYNC_INTERVAL) {
      print('Sync interval elapsed: Performing sync.');
      return true;
    }

    print('Sync not needed: Last sync was at $lastSyncTime.');
    return false;
  }

  Future<bool> isConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> updateLastSyncTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(LAST_SYNC_TIME, DateTime.now().toIso8601String());
    print('Last sync time updated to: ${DateTime.now()}');
  }
}