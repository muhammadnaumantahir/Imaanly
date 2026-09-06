import 'package:flutter_test/flutter_test.dart';

import 'package:imaanly/features/analytics/domain/worship_analytics.dart';
import 'package:imaanly/features/worship/domain/worship_daily_summary.dart';

void main() {
  WorshipDailySummary summary({
    required String dateKey,
    int salah = 0,
    int quran = 0,
    int dhikr = 0,
  }) {
    return WorshipDailySummary(
      dateKey: dateKey,
      prayersCompleted: salah,
      prayersTotal: 5,
      quranPages: quran,
      dhikrCount: dhikr,
      dhikrGoal: 33,
    );
  }

  test('weekly report calculates average, totals and active days', () {
    final days = [
      for (var index = 0; index < 7; index++)
        WorshipAnalyticsDay(
          date: DateTime(2026, 9, index + 1),
          summary: summary(
            dateKey: '2026-09-0${index + 1}',
            salah: index == 6 ? 5 : 2,
            quran: index + 1,
            dhikr: 10 + index,
          ),
        ),
    ];

    final report = WorshipAnalyticsReport(days: days);

    expect(report.activeDays, 7);
    expect(report.currentStreak, 7);
    expect(report.completedSalah, 17);
    expect(report.quranPages, 28);
    expect(report.dhikrCount, 91);
    expect(report.averageScore, greaterThan(0));
  });

  test('streak stops at the first inactive day', () {
    final days = [
      WorshipAnalyticsDay(
        date: DateTime(2026, 9, 1),
        summary: summary(dateKey: '2026-09-01', salah: 5),
      ),
      WorshipAnalyticsDay(
        date: DateTime(2026, 9, 2),
        summary: summary(dateKey: '2026-09-02'),
      ),
      WorshipAnalyticsDay(
        date: DateTime(2026, 9, 3),
        summary: summary(dateKey: '2026-09-03', quran: 2),
      ),
    ];

    expect(WorshipAnalyticsReport(days: days).currentStreak, 1);
  });

  test('an empty week reports zero progress', () {
    final days = [
      for (var index = 0; index < 7; index++)
        WorshipAnalyticsDay(
          date: DateTime(2026, 9, index + 1),
          summary: summary(dateKey: '2026-09-${index + 1}'),
        ),
    ];
    final report = WorshipAnalyticsReport(days: days);

    expect(report.averageScore, 0);
    expect(report.activeDays, 0);
    expect(report.currentStreak, 0);
    expect(report.completedSalah, 0);
    expect(report.quranPages, 0);
    expect(report.dhikrCount, 0);
  });
}
