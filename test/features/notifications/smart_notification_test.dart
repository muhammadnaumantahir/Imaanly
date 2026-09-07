import 'package:flutter_test/flutter_test.dart';
import 'package:imaanly/features/notifications/domain/smart_notification.dart';

void main() {
  const planner = SmartNotificationPlanner();
  final now = DateTime(2026, 9, 7, 10);

  test('nearby prayer takes priority', () {
    final result = planner.evaluate(
      now: now,
      nextPrayerAt: now.add(const Duration(minutes: 10)),
      nextPrayerName: 'Dhuhr',
      quranMinutesToday: 0,
      dhikrCompletedToday: 0,
    );

    expect(result?.category, SmartNotificationCategory.prayer);
    expect(result?.reason, 'upcoming_prayer');
  });

  test('prayer inside minimum lead is skipped', () {
    final result = planner.evaluate(
      now: now,
      nextPrayerAt: now.add(const Duration(minutes: 2)),
      nextPrayerName: 'Dhuhr',
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

  test('completed Quran with no Dhikr falls back to Dhikr reminder', () {
    final result = planner.evaluate(
      now: now,
      quranMinutesToday: 15,
      dhikrCompletedToday: 0,
    );

    expect(result?.category, SmartNotificationCategory.dhikr);
    expect(result?.reason, 'no_dhikr_today');
  });

  test('active Quran and Dhikr remain silent', () {
    final result = planner.evaluate(
      now: now,
      quranMinutesToday: 15,
      dhikrCompletedToday: 33,
    );

    expect(result, isNull);
  });
}
