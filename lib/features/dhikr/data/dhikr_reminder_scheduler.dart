import '../../notifications/services/local_notification_service.dart';

/// Schedules the user's daily Dhikr reminder using the shared notification adapter.
class DhikrReminderScheduler {
  const DhikrReminderScheduler();

  static const int notificationId = 7301;

  Future<void> schedule({
    required DateTime time,
    String title = 'Dhikr reminder',
    String body = 'Take a moment for your daily Dhikr.',
  }) async {
    final service = LocalNotificationService.instance;
    await service.initialize();
    await service.scheduleDailyReminder(
      id: notificationId,
      title: title,
      body: body,
      time: time,
    );
  }

  Future<void> cancel() async {
    final service = LocalNotificationService.instance;
    await service.initialize();
    await service.cancel(notificationId);
  }
}
