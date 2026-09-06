import 'package:flutter_test/flutter_test.dart';
import 'package:imaanly/features/worship_dashboard/domain/worship_dashboard_summary.dart';

void main() {
  test('clamps prayer progress to one', () {
    const summary = WorshipDashboardSummary(
      prayersCompleted: 7,
      prayersTotal: 5,
      quranPages: 2,
      dhikrCompleted: 33,
      dhikrGoal: 33,
      readingStreak: 4,
    );
    expect(summary.prayerProgress, 1.0);
    expect(summary.dhikrProgress, 1.0);
  });

  test('returns zero progress when goal is zero', () {
    const summary = WorshipDashboardSummary(
      prayersCompleted: 0,
      prayersTotal: 0,
      quranPages: 0,
      dhikrCompleted: 0,
      dhikrGoal: 0,
      readingStreak: 0,
    );
    expect(summary.prayerProgress, 0.0);
    expect(summary.dhikrProgress, 0.0);
  });
}
