import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

import 'package:imaanly/core/models/notification_model.dart';
import 'package:imaanly/core/repositories/notification_repository.dart';

/// Client-side notification service.
///
/// FCM HTTP v1 sending requires Firebase Admin credentials and therefore must
/// run in a trusted backend, not inside the Flutter application. This class
/// retains the public API used by the app while making that security boundary
/// explicit. Device/topic subscription and receiving notifications remain
/// client-side responsibilities of Firebase Messaging.
class FcmService {
  FcmService({
    NotificationRepository? repository,
  }) : _repository = repository ?? NotificationRepository();

  final NotificationRepository _repository;

  /// Returns false because privileged FCM sending is intentionally disabled in
  /// the client application. A backend/cloud function should own this action.
  Future<String?> _getAccessToken() async => null;

  /// Sends a notification to all users (topic: "all") and logs it to Firestore.
  ///
  /// The actual FCM send must be performed by a trusted backend.
  Future<bool> sendToAll({
    required String title,
    required String body,
    String? imageUrl,
    Map<String, String>? data,
  }) async {
    return _send(
      target: 'all',
      title: title,
      body: body,
      imageUrl: imageUrl,
      data: data,
      audience: NotificationAudience.all,
      isTopic: true,
    );
  }

  Future<bool> sendToTopic({
    required String topic,
    required String title,
    required String body,
    String? imageUrl,
    Map<String, String>? data,
  }) async {
    return _send(
      target: topic,
      title: title,
      body: body,
      imageUrl: imageUrl,
      data: data,
      audience: NotificationAudience.topic,
      isTopic: true,
    );
  }

  Future<bool> sendToDevice({
    required String token,
    required String title,
    required String body,
    String? imageUrl,
    Map<String, String>? data,
  }) async {
    return _send(
      target: token,
      title: title,
      body: body,
      imageUrl: imageUrl,
      data: data,
      audience: NotificationAudience.individual,
      isTopic: false,
    );
  }

  Future<bool> _send({
    required String target,
    required String title,
    required String body,
    String? imageUrl,
    Map<String, String>? data,
    required NotificationAudience audience,
    required bool isTopic,
  }) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        log(
          'FCM send skipped: privileged HTTP v1 credentials belong in a backend.',
          name: 'FcmService',
        );
        return false;
      }

      final message = <String, dynamic>{
        if (isTopic) 'topic': target else 'token': target,
        'notification': {
          'title': title,
          'body': body,
          if (imageUrl != null && imageUrl.isNotEmpty) 'image': imageUrl,
        },
        if (data != null && data.isNotEmpty) 'data': data,
        'android': {
          'priority': 'high',
          'notification': {
            'channel_id': 'imaanly_updates',
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'sound': 'default',
          },
        },
      };

      final payload = {'message': message};
      const fcmUrl = 'https://fcm.googleapis.com/v1/projects/imaanly-app/messages:send';
      final response = await http.post(
        Uri.parse(fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      final success = response.statusCode == 200;
      if (!success) log('FCM Error Response: ${response.body}', name: 'FcmService');

      final logEntry = NotificationLog.create(
        title: title,
        body: body,
        imageUrl: imageUrl ?? '',
        audience: audience,
        topicOrToken: target,
        data: data ?? {},
        sentCount: success ? 1 : 0,
        failedCount: success ? 0 : 1,
      );
      await _repository.logNotification(logEntry);
      return success;
    } catch (e, st) {
      log('FCM send error: $e', name: 'FcmService', stackTrace: st);
      return false;
    }
  }
}
