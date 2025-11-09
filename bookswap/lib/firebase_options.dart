// File generated / adapted for manual configuration.
// Replace the WEB_* placeholders with values from your Firebase Console.
// ignore_for_file: type=lint

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Web configuration — REPLACE the placeholder values with your web app config
  // from the Firebase console.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'WEB_API_KEY_GOES_HERE', // e.g. 'AIza...'
    authDomain: 'BOOKSWAP-PROJECT.firebaseapp.com', // e.g. 'your-project.firebaseapp.com'
    projectId: 'bookswap-d71af',
    storageBucket: 'bookswap-d71af.firebasestorage.app',
    messagingSenderId: 'WEB_MESSAGING_SENDER_ID', // e.g. '1234567890'
    appId: 'WEB_APP_ID_GOES_HERE', // e.g. '1:1234567890:web:abcdef123456'
    measurementId: 'WEB_MEASUREMENT_ID', // optional, e.g. 'G-XXXXXXX'
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB08zuwDzlqXuxPF0yagWeVpYGM4iKq-Wk',
    appId: '1:872832157007:android:60501ae96033ba6335b13a',
    messagingSenderId: '872832157007',
    projectId: 'bookswap-d71af',
    storageBucket: 'bookswap-d71af.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD15ZkFyOz9SITSAnSFw9L6BOBqzJH2DLk',
    appId: '1:872832157007:ios:fdcfa598ebb2a7a235b13a',
    messagingSenderId: '872832157007',
    projectId: 'bookswap-d71af',
    storageBucket: 'bookswap-d71af.firebasestorage.app',
    iosBundleId: 'com.example.bookswap',
  );
}
