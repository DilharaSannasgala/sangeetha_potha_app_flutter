import 'package:flutter_dotenv/flutter_dotenv.dart';

/// A utility class to access environment variables from .env file
class Environment {
  /// Get a value from .env file
  static String get(String key) {
    return dotenv.env[key] ?? '';
  }

  // Firebase Web configuration
  static String get firebaseWebApiKey => get('FIREBASE_WEB_API_KEY');
  static String get firebaseWebAppId => get('FIREBASE_WEB_APP_ID');
  static String get firebaseWebMessagingSenderId => get('FIREBASE_WEB_MESSAGING_SENDER_ID');
  static String get firebaseWebProjectId => get('FIREBASE_WEB_PROJECT_ID');
  static String get firebaseWebAuthDomain => get('FIREBASE_WEB_AUTH_DOMAIN');
  static String get firebaseWebStorageBucket => get('FIREBASE_WEB_STORAGE_BUCKET');

  // Firebase Android configuration
  static String get firebaseAndroidApiKey => get('FIREBASE_ANDROID_API_KEY');
  static String get firebaseAndroidAppId => get('FIREBASE_ANDROID_APP_ID');

  // Firebase iOS configuration
  static String get firebaseIosApiKey => get('FIREBASE_IOS_API_KEY');
  static String get firebaseIosAppId => get('FIREBASE_IOS_APP_ID');
  static String get firebaseIosBundleId => get('FIREBASE_IOS_BUNDLE_ID');

  // Firebase Windows configuration
  static String get firebaseWindowsApiKey => get('FIREBASE_WINDOWS_API_KEY');
  static String get firebaseWindowsAppId => get('FIREBASE_WINDOWS_APP_ID');
}