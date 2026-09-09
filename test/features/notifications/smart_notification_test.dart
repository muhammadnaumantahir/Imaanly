import 'package:flutter_test/flutter_test.dart';
import 'package:imaanly/features/notifications/domain/smart_notification.dart';
import 'package:imaanly/features/notifications/domain/smart_notification_category.dart';
import 'package:imaanly/features/notifications/domain/smart_notification_preferences.dart';

void main() {
  const planner = SmartNotificationPlanner();
  final now = DateTime(2026, 9, 7, 18);

  group('SmartNotificationPlanner', () {
    test('nearby prayer takes priority and formats remaining minutes', () {
      final result = planner.evaluate(
        now: now,
        nextPrayerAt: now.add(const Duration(minutes: 20)),
        nextPrayerName: 'Maghrib',
        quranMinutesToday: 0,
        dhikrCompletedToday: 0,
      );

      expect(result?.category, SmartNotificationCategory.prayer);
      expect(result?.reason, 'upcoming_prayer');
      expect(result?.body, contains('20 minutes'));
    });

    test('prayer inside minimum lead is skipped', () {
      final result = planner.evaluate(
        now: now,
        nextPrayerAt: now.add(const Duration(minutes: 2)),
        nextPrayerName: 'Maghrib',
        quranMinutesToday: 10,
        dhikrCompletedToday: 10,
      );

      expect(result, isNull);
    });

    test('no Quran today falls back to Quran reminder', () {
      final result = planner.evaluate(
        now: now,
        quranMinutesToday: 0,
        dhikrCompletedToday: 0,
      );

      expect(result?.category, SmartNotificationCategory.quran);
      expect(result?.reason, 'no_quran_today');
    });

    test('Quran goal reports the remaining minutes', () {
      final result = planner.evaluate(
        now: now,
        quranMinutesToday: 10,
        quranGoalMinutes: 20,
        dhikrCompletedToday: 10,
      );

      expect(result?.category, SmartNotificationCategory.quran);
      expect(result?.reason, 'quran_goal');
      expect(result?.body, contains('10 minutes short'));
    });

    test('completed Quran with no Dhikr falls back to Dhikr reminder', () {
      final result = planner.evaluate(
        now: now,
        quranMinutesToday: 15,
        dhikrCompletedToday: 0,
      );

      expect(result?.category, SmartNotificationCategory.dhikr);
      expect(result?.reason, 'no_dhikr_today');
    });

    test('Dhikr goal reports the remaining count', () {
      final result = planner.evaluate(
        now: now,
        quranMinutesToday: 15,
        dhikrCompletedToday: 20,
        dhikrGoal: 33,
      );

      expect(result?.category, SmartNotificationCategory.dhikr);
      expect(result?.reason, 'dhikr_goal');
      expect(result?.body, contains('13 Dhikr remaining'));
    });

    test('streak reminder is used when daily worship goals are otherwise met', () {
      final result = planner.evaluate(
        now: now,
        quranMinutesToday: 15,
        dhikrCompletedToday: 33,
        currentStreak: 7,
        lastActiveDay: DateTime(2026, 9, 6, 12),
      );

      expect(result?.category, SmartNotificationCategory.streak);
      expect(result?.reason, 'streak_risk');
    });

    test('quiet hours suppress notifications', () {
      final result = planner.evaluate(
        now: DateTime(2026, 9, 7, 23),
        quranMinutesToday: 0,
        dhikrCompletedToday: 0,
      );

      expect(result, isNull);
    });

    test('disabled categories are skipped', () {
      final result = planner.evaluate(
        now: now,
        quranMinutesToday: 0,
        dhikrCompletedToday: 0,
        preferences: const SmartNotificationPreferences(quranEnabled: false),
      );

      expect(result?.category, SmartNotificationCategory.dhikr);
    });

    test('active Quran and Dhikr remain silent', () {
      final result = planner.evaluate(
        now: now,
        quranMinutesToday: 15,
        dhikrCompletedToday: 33,
      );

      expect(result, isNull);
    });
  });
}
