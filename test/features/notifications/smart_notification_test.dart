import 'package:flutter_test/flutter_test.dart';
import 'package:imaanly/features/notifications/domain/smart_notification.dart';

void main() {
  const planner = SmartNotificationPlanner();
  final now = DateTime(2026, 9, 7, 18, 0);

  group('SmartNotificationPlanner', () {
    test('prefers an upcoming prayer over other reminders', () {
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

    test('does not remind for a prayer that is too close', () {
      final result = planner.evaluate(
        now: now,
        nextPrayerAt: now.add(const Duration(minutes: 2)),
        nextPrayerName: 'Maghrib',
        quranMinutesToday: 10,
        dhikrCompletedToday: 10,
      );

      expect(result, isNull);
    });

    test('falls back to Quran when no Quran was recorded', () {
      final result = planner.evaluate(
        now: now,
        quranMinutesToday: 0,
        dhikrCompletedToday: 0,
      );

      expect(result?.category, SmartNotificationCategory.quran);
      expect(result?.reason, 'no_quran_today');
    });

    test('falls back to Dhikr when Quran is already recorded', () {
      final result = planner.evaluate(
        now: now,
        quranMinutesToday: 12,
        dhikrCompletedToday: 0,
      );

      expect(result?.category, SmartNotificationCategory.dhikr);
      expect(result?.reason, 'no_dhikr_today');
    });

    test('stays silent when the day already has activity', () {
      final result = planner.evaluate(
        now: now,
        quranMinutesToday: 12,
        dhikrCompletedToday: 33,
      );

      expect(result, isNull);
    });
  });
}
