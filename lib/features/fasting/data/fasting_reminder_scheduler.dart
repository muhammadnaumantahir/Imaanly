import '../../notifications/services/local_notification_service.dart';

class FastingReminderScheduler {
  static const int notificationId = 7401;

  FastingReminderScheduler({LocalNotificationService? notifications})
      : _notifications = notifications ?? LocalNotificationService.instance;

  final LocalNotificationService _notifications;

  Future<void> schedule({required DateTime time}) {
    return _notifications.scheduleDailyReminder(
      id: notificationId,
      title: 'Fasting check-in',
      body: "Record today's fasting status in Imaanly.",
      time: time,
    );
  }

  Future<void> cancel() => _notifications.cancel(notificationId);
}
