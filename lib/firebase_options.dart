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
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBb2SIig2GDZKvl560MBMDa6cIsVGPdqww',
    appId: '1:936919588774:web:4ec483d76ec1a39db0b967',
    messagingSenderId: '936919588774',
    projectId: 'cs-interview-66fb7',
    authDomain: 'cs-interview-66fb7.firebaseapp.com',
    storageBucket: 'cs-interview-66fb7.firebasestorage.app',
    measurementId: 'G-R5H5XRV4MS',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCfSuP22XmCR7xqyL0ZlWoJ3whdTvMl8JY',
    appId: '1:936919588774:android:2522cb1d37a50337b0b967',
    messagingSenderId: '936919588774',
    projectId: 'cs-interview-66fb7',
    storageBucket: 'cs-interview-66fb7.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyChg5KUgPtB25Jxyic16vBx6nQYcwLkUn4',
    appId: '1:936919588774:ios:c4230f0a9ee2d940b0b967',
    messagingSenderId: '936919588774',
    projectId: 'cs-interview-66fb7',
    storageBucket: 'cs-interview-66fb7.firebasestorage.app',
    iosClientId:
        '936919588774-i8f9q82tqe5aoak31biov3dopcc8tfrq.apps.googleusercontent.com',
    iosBundleId: 'com.yongjunlee.csInterview',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyChg5KUgPtB25Jxyic16vBx6nQYcwLkUn4',
    appId: '1:936919588774:ios:c4230f0a9ee2d940b0b967',
    messagingSenderId: '936919588774',
    projectId: 'cs-interview-66fb7',
    storageBucket: 'cs-interview-66fb7.firebasestorage.app',
    iosClientId:
        '936919588774-i8f9q82tqe5aoak31biov3dopcc8tfrq.apps.googleusercontent.com',
    iosBundleId: 'com.yongjunlee.csInterview',
  );
}
