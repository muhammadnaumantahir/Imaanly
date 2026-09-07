import '../../notifications/services/local_notification_service.dart';

/// Schedules an optional daily Dhikr reminder using the existing notification adapter.
class DhikrReminderScheduler {
  const DhikrReminderScheduler();

  Future<void> schedule({
    required DateTime time,
    String title = 'Dhikr reminder',
    String body = 'Take a moment for your daily Dhikr.',
  }) async {
    final service = LocalNotificationService.instance;
    await service.initialize();
    // The existing notification service is intentionally used as the single
    // platform adapter. Delivery details remain centralized there.
    await service.scheduleGenericReminder(
      title: title,
      body: body,
      scheduledAt: time,
    );
  }
}
