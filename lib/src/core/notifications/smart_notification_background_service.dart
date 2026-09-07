import 'package:flutter/widgets.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'package:imaanly/features/goals/data/daily_goals_repository.dart';
import 'package:imaanly/features/notifications/data/smart_notification_coordinator.dart';
import 'package:imaanly/features/notifications/domain/smart_notification_preferences.dart';
import 'package:imaanly/features/worship/data/worship_activity_repository.dart';
import 'package:imaanly/features/worship/domain/worship_daily_summary.dart';
import 'package:imaanly/src/core/notifications/notification_service.dart';

const String smartNotificationTaskName = 'imaanly.contextual-notifications';
const String smartNotificationUniqueName = 'imaanly.contextual-notifications.periodic';

@pragma('vm:entry-point')
void smartNotificationCallbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName != smartNotificationTaskName) return true;

    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();

    try {
      final notificationService = NotificationService();
      await notificationService.initialize();

      final repository = await WorshipActivityRepository.openLocal();
      final activities = await repository.getAll();
      final now = DateTime.now();
      final today = WorshipDailySummary.fromActivities(activities, date: now);

      var currentStreak = 0;
      DateTime? lastActiveDay;
      for (var offset = 1; offset <= 7; offset++) {
        final date = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: offset));
        final summary = WorshipDailySummary.fromActivities(
          activities,
          date: date,
        );
        final active = summary.prayersCompleted > 0 ||
            summary.quranPages > 0 ||
            summary.dhikrCount > 0;
        if (!active) break;
        currentStreak++;
        lastActiveDay ??= date;
      }

      final goals = DailyGoalsRepository(
        await SharedPreferences.getInstance(),
      ).load();

      final coordinator = SmartNotificationCoordinator();
      await coordinator.evaluateAndDeliver(
        now: now,
        quranMinutesToday: today.quranPages,
        quranGoalMinutes: goals.quranPages,
        dhikrCompletedToday: today.dhikrCount,
        dhikrGoal: goals.dhikr,
        currentStreak: currentStreak,
        lastActiveDay: lastActiveDay,
        preferences: const SmartNotificationPreferences(),
        deliver: notificationService.deliverSmartNotification,
      );

      return true;
    } catch (_) {
      return false;
    }
  });
}

class SmartNotificationBackgroundService {
  const SmartNotificationBackgroundService._();

  static Future<void> initialize() async {
    await Workmanager().initialize(
      smartNotificationCallbackDispatcher,
      isInDebugMode: false,
    );
    await Workmanager().registerPeriodicTask(
      smartNotificationUniqueName,
      smartNotificationTaskName,
      frequency: const Duration(hours: 1),
      initialDelay: const Duration(minutes: 15),
    );
  }
}
