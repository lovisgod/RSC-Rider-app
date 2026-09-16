// Generated values match android/app/google-services.json (rider app entry,
// package com.rsc.rsc_rider). Regenerate with `flutterfire configure` if the
// Firebase project changes.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCJwN3pGhzYABadcPuJdVi0ZgalCX1NyMk',
    appId: '1:254265809328:android:1dc8032e858d06d2d29e75',
    messagingSenderId: '254265809328',
    projectId: 'rsc-project-500321',
    storageBucket: 'rsc-project-500321.firebasestorage.app',
  );
}
