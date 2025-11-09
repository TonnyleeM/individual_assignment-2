// File generated / adapted for manual configuration.
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

  // Web configuration generated from your Firebase console
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAJXnqfXs29gojsLk5hp_B1pdxQJGiODk8',
    authDomain: 'bookswap-d71af.firebaseapp.com',
    projectId: 'bookswap-d71af',
    storageBucket: 'bookswap-d71af.firebasestorage.app',
    messagingSenderId: '872832157007',
    appId: '1:872832157007:web:dcb3ecb357afeda235b13a',
    measurementId: 'G-R7GDRXC4X3',
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
