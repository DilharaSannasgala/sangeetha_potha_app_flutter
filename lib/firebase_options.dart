import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:sangeetha_potha_app_flutter/utils/environment.dart';

/// Custom Firebase options that use environment variables from .env file
class CustomFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'CustomFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'CustomFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static FirebaseOptions get web => FirebaseOptions(
        apiKey: Environment.firebaseWebApiKey,
        appId: Environment.firebaseWebAppId,
        messagingSenderId: Environment.firebaseWebMessagingSenderId,
        projectId: Environment.firebaseWebProjectId,
        authDomain: Environment.firebaseWebAuthDomain,
        storageBucket: Environment.firebaseWebStorageBucket,
      );

  static FirebaseOptions get android => FirebaseOptions(
        apiKey: Environment.firebaseAndroidApiKey,
        appId: Environment.firebaseAndroidAppId,
        messagingSenderId: Environment.firebaseWebMessagingSenderId,
        projectId: Environment.firebaseWebProjectId,
        storageBucket: Environment.firebaseWebStorageBucket,
      );

  static FirebaseOptions get ios => FirebaseOptions(
        apiKey: Environment.firebaseIosApiKey,
        appId: Environment.firebaseIosAppId,
        messagingSenderId: Environment.firebaseWebMessagingSenderId,
        projectId: Environment.firebaseWebProjectId,
        storageBucket: Environment.firebaseWebStorageBucket,
        iosBundleId: Environment.firebaseIosBundleId,
      );

  static FirebaseOptions get macos => FirebaseOptions(
        apiKey: Environment.firebaseIosApiKey,
        appId: Environment.firebaseIosAppId,
        messagingSenderId: Environment.firebaseWebMessagingSenderId,
        projectId: Environment.firebaseWebProjectId,
        storageBucket: Environment.firebaseWebStorageBucket,
        iosBundleId: Environment.firebaseIosBundleId,
      );

  static FirebaseOptions get windows => FirebaseOptions(
        apiKey: Environment.firebaseWindowsApiKey,
        appId: Environment.firebaseWindowsAppId,
        messagingSenderId: Environment.firebaseWebMessagingSenderId,
        projectId: Environment.firebaseWebProjectId,
        authDomain: Environment.firebaseWebAuthDomain,
        storageBucket: Environment.firebaseWebStorageBucket,
      );
}