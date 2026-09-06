import 'package:flutter_test/flutter_test.dart';
import 'package:al_furkan/features/worship/domain/worship_activity.dart';
import 'package:al_furkan/features/worship/domain/worship_daily_summary.dart';

void main() {
  test('aggregates one day without counting duplicate salah completion', () {
    final day = DateTime(2026, 9, 6);
    final activities = [
      WorshipActivity.salah(prayer: 'Fajr', completedAt: day.add(const Duration(hours: 5))),
      WorshipActivity.salah(prayer: 'Fajr', completedAt: day.add(const Duration(hours: 6))),
      WorshipActivity.salah(prayer: 'Dhuhr', completedAt: day.add(const Duration(hours: 13))),
      WorshipActivity.quranPages(pages: 4, recordedAt: day.add(const Duration(hours: 14))),
      WorshipActivity.dhikr(count: 33, recordedAt: day.add(const Duration(hours: 15))),
    ];

    final summary = WorshipDailySummary.fromActivities(activities, date: day);

    expect(summary.prayersCompleted, 2);
    expect(summary.prayersTotal, 5);
    expect(summary.quranPages, 4);
    expect(summary.dhikrCount, 33);
  });

  test('ignores activities from another day', () {
    final day = DateTime(2026, 9, 6);
    final activities = [
      WorshipActivity.quranPages(pages: 2, recordedAt: day),
      WorshipActivity.quranPages(pages: 8, recordedAt: day.add(const Duration(days: 1))),
    ];

    final summary = WorshipDailySummary.fromActivities(activities, date: day);

    expect(summary.quranPages, 2);
  });
}
