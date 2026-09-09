// File generated from the Firebase configuration supplied for Imaanly.
// This file contains public Firebase client configuration only; do not place
// service-account credentials or other private secrets here.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCOJmM2Ka6yUdqO0UuAfUM7jJhniaID3Ms',
    appId: '1:236963004422:web:0d295b0fdf960deee4c387',
    messagingSenderId: '236963004422',
    projectId: 'imaanly-99c5a',
    authDomain: 'imaanly-99c5a.firebaseapp.com',
    storageBucket: 'imaanly-99c5a.firebasestorage.app',
    measurementId: 'G-2X9RK3LLZF',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC0BENhgW2dlWOzKLJSuO2dYjxec14Rqeg',
    appId: '1:236963004422:android:96c512653316d590e4c387',
    messagingSenderId: '236963004422',
    projectId: 'imaanly-99c5a',
    storageBucket: 'imaanly-99c5a.firebasestorage.app',
  );
}
