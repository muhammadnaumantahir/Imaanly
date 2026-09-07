import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:imaanly/features/notifications/domain/smart_notification.dart';
import 'package:imaanly/features/notifications/domain/smart_notification_category.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  static const String khatmaChannelKey = 'smart_khatma_channel';
  static const String werdChannelKey = 'daily_werd_channel';
  static const String smartChannelKey = 'contextual_worship_channel';

  Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'khatma_group',
          channelKey: khatmaChannelKey,
          channelName: 'إشعارات الختمة الذكية',
          channelDescription: 'تنبيهات لمتابعة الختمة الذكية',
          defaultColor: const Color(0xFF0F8C69),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          criticalAlerts: true,
        ),
        NotificationChannel(
          channelGroupKey: 'werd_group',
          channelKey: werdChannelKey,
          channelName: 'إشعارات الورد اليومي',
          channelDescription: 'تذكير بقراءة الورد اليومي من القرآن',
          defaultColor: const Color(0xFF0F8C69),
          ledColor: Colors.white,
          importance: NotificationImportance.Default,
        ),
        NotificationChannel(
          channelGroupKey: 'contextual_worship_group',
          channelKey: smartChannelKey,
          channelName: 'تذكيرات العبادة السياقية',
          channelDescription: 'تذكيرات محلية هادئة مبنية على نشاطك اليومي',
          defaultColor: const Color(0xFF0F8C69),
          ledColor: Colors.white,
          importance: NotificationImportance.Default,
          channelShowBadge: true,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
            channelGroupKey: 'khatma_group', channelGroupName: 'الختمة الذكية'),
        NotificationChannelGroup(
            channelGroupKey: 'werd_group', channelGroupName: 'الورد اليومي'),
        NotificationChannelGroup(
          channelGroupKey: 'contextual_worship_group',
          channelGroupName: 'التذكيرات السياقية',
        ),
      ],
      debug: false,
    );
  }

  Future<bool> requestPermission() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      isAllowed = await AwesomeNotifications().requestPermissionToSendNotifications();
    }
    return isAllowed;
  }

  /// Delivers one decision from the local contextual notification engine.
  ///
  /// The decision engine remains platform-agnostic; this method is the concrete
  /// Awesome Notifications adapter used by the application layer.
  Future<void> deliverSmartNotification(
    SmartNotificationCandidate candidate,
  ) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: _smartNotificationId(candidate.category),
        channelKey: smartChannelKey,
        title: candidate.title,
        body: candidate.body,
        category: NotificationCategory.Reminder,
        wakeUpScreen: false,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  int _smartNotificationId(SmartNotificationCategory category) {
    switch (category) {
      case SmartNotificationCategory.prayer:
        return 2101;
      case SmartNotificationCategory.quran:
        return 2102;
      case SmartNotificationCategory.dhikr:
        return 2103;
      case SmartNotificationCategory.streak:
        return 2104;
    }
  }

  Future<void> scheduleDailyWerdReminder({
    required TimeOfDay time,
    String title = 'حان وقت الورد اليومي',
    String body = 'لا تنسَ نصيبك من القرآن اليوم، نور قلبك بآياته.',
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 100,
        channelKey: werdChannelKey,
        title: title,
        body: body,
        category: NotificationCategory.Reminder,
        wakeUpScreen: true,
      ),
      schedule: NotificationCalendar(
        hour: time.hour,
        minute: time.minute,
        second: 0,
        millisecond: 0,
        repeats: true,
      ),
    );
  }

  Future<void> scheduleKhatmaReminder({
    required int id,
    required DateTime scheduleTime,
    String title = 'تذكير الختمة الذكية',
    String body = 'موعد قراءة الجزء المخصص لختمتك',
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: khatmaChannelKey,
        title: title,
        body: body,
        category: NotificationCategory.Alarm,
        wakeUpScreen: true,
      ),
      schedule: NotificationCalendar.fromDate(date: scheduleTime),
    );
  }

  Future<void> cancelDailyWerdReminder() async {
    await AwesomeNotifications().cancel(100);
  }

  Future<void> cancelKhatmaReminder(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  Future<void> cancelAll() async {
    await AwesomeNotifications().cancelAll();
  }
}
