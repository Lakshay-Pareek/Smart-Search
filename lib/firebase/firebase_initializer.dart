import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';

/// Initializes Firebase for the current platform using the generated options.
/// Returns true on success, false on failure. Errors are logged.
Future<bool> initializeFirebase() async {
  try {
    // For Android/iOS/macOS, Firebase can initialize from platform config files:
    // - Android: android/app/google-services.json
    // - iOS: ios/Runner/GoogleService-Info.plist
    // - macOS: macOS/Runner/GoogleService-Info.plist (if configured)
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      await Firebase.initializeApp();
      log('Firebase initialized successfully for ${defaultTargetPlatform}');
      return true;
    }

    // For web and other platforms, use the generated options file.
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    log('Firebase initialized successfully for web');
    return true;
  } catch (e, st) {
    log(
      'Firebase initialization failed. Error: $e',
      stackTrace: st,
    );
    // On web, if Firebase fails, we'll still allow the app to run
    // but auth features won't work
    return false;
  }
}
