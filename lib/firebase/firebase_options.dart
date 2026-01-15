// TODO: Replace this placeholder with the generated file from `flutterfire configure`.
// The real file will contain your Firebase project IDs, API keys, and app IDs
// for each platform. Without real values, Firebase will not connect.
//
// Steps:
// 1) Install the FlutterFire CLI: `dart pub global activate flutterfire_cli`
// 2) Run from project root: `flutterfire configure`
// 3) Choose your Firebase project and platforms (android/ios/web).
// 4) It will generate this file with actual values. Replace this placeholder.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        // Desktop/web may need to use web options; adjust if you target these.
        return web;
    }
  }

  // Android/iOS/macOS can still use placeholder values for now because
  // Android is configured via google-services.json and iOS/macOS are not used yet.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME',
    iosBundleId: 'REPLACE_ME',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME',
    iosBundleId: 'REPLACE_ME',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyACj_69KaXUvfeP6wDswt1d2UMlt0jhcg8',
    appId: '1:1002465098657:web:af2147877994f75d3369e0',
    messagingSenderId: '1002465098657',
    projectId: 'smart-search-984a7',
    authDomain: 'smart-search-984a7.firebaseapp.com',
    storageBucket: 'smart-search-984a7.firebasestorage.app',
    measurementId: '',
  );
}
