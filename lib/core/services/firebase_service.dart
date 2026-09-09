import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:imaanly/firebase_options.dart';

/// Centralized Firebase initialization and setup.
class FirebaseService {
  FirebaseService._();
  static final instance = FirebaseService._();

  bool _initialized = false;

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: kIsWeb ? DefaultFirebaseOptions.web : null,
      );
    }
    log(
      'Handling a background message: ${message.messageId}',
      name: 'FirebaseService',
    );
  }

  /// Initialize Firebase + FCM + timeago locale.
  Future<void> init() async {
    if (_initialized) return;

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: kIsWeb ? DefaultFirebaseOptions.web : null,
        );
      }

      // FCM is supported on Android/iOS and the web. Desktop Firebase
      // initialization remains available, but desktop FCM is not configured.
      if (!kIsWeb &&
          defaultTargetPlatform != TargetPlatform.windows &&
          defaultTargetPlatform != TargetPlatform.linux &&
          defaultTargetPlatform != TargetPlatform.macOS) {
        await _configureMessaging();
      } else if (kIsWeb) {
        await _configureMessaging();
      }

      // Setup Arabic timeago locale.
      timeago.setLocaleMessages('ar', timeago.ArMessages());
      timeago.setDefaultLocale('ar');

      _initialized = true;
      log('✅ FirebaseService initialized', name: 'FirebaseService');
    } catch (e, st) {
      log(
        '❌ FirebaseService init error: $e',
        name: 'FirebaseService',
        stackTrace: st,
      );
    }
  }

  Future<void> _configureMessaging() async {
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();

    // Subscribe to "all" topic for broadcast notifications. Topic messaging
    // is supported by FCM on Android/iOS; on web, topic subscription is not
    // available from the client SDK, so skip it there.
    if (!kIsWeb) {
      await messaging.subscribeToTopic('all');
    }

    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(
      _firebaseMessagingBackgroundHandler,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log(
        'Got a message whilst in the foreground!',
        name: 'FirebaseService',
      );
      log(
        'Message data: ${message.data}',
        name: 'FirebaseService',
      );
      if (message.notification != null) {
        log(
          'Message also contained a notification: ${message.notification}',
          name: 'FirebaseService',
        );
      }
    });
  }

  /// Gets the current FCM token for this device.
  Future<String?> getToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (_) {
      return null;
    }
  }
}
