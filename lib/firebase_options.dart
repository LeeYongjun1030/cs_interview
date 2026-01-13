// File generated manually to avoid firebase login
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
    // TODO: Add other platforms (Android/iOS) if needed later
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  // TODO: Replace these values with your actual Firebase config
  // You can find them in Firebase Console > Project Settings > General > Your Apps > Web App
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBb2SIig2GDZKvl560MBMDa6cIsVGPdqww',
    appId: '1:936919588774:web:4ec483d76ec1a39db0b967',
    messagingSenderId: '936919588774',
    projectId: 'cs-interview-66fb7', // You already provided this
    authDomain: 'cs-interview-66fb7.firebaseapp.com',
    storageBucket: 'cs-interview-66fb7.firebasestorage.app',
    measurementId: 'G-R5H5XRV4MS', // Optional
  );
}
