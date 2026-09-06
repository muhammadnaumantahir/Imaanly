import 'package:imaanly/features/worship/domain/worship_daily_summary.dart';

class WorshipAnalyticsDay {
  const WorshipAnalyticsDay({required this.date, required this.summary});

  final DateTime date;
  final WorshipDailySummary summary;

  bool get hasActivity =>
      summary.prayersCompleted > 0 ||
      summary.quranPages > 0 ||
      summary.dhikrCount > 0;

  double get score =>
      ((summary.prayerProgress + summary.quranProgress + summary.dhikrProgress) /
              3)
          .clamp(0.0, 1.0);
}

class WorshipAnalyticsReport {
  const WorshipAnalyticsReport({required this.days});

  final List<WorshipAnalyticsDay> days;

  WorshipAnalyticsDay get today => days.last;

  double get averageScore {
    if (days.isEmpty) return 0;
    return days.map((day) => day.score).reduce((a, b) => a + b) / days.length;
  }

  int get activeDays => days.where((day) => day.hasActivity).length;

  int get currentStreak {
    var streak = 0;
    for (var index = days.length - 1; index >= 0; index--) {
      if (!days[index].hasActivity) break;
      streak++;
    }
    return streak;
  }

  int get completedSalah =>
      days.fold(0, (total, day) => total + day.summary.prayersCompleted);

  int get quranPages =>
      days.fold(0, (total, day) => total + day.summary.quranPages);

  int get dhikrCount =>
      days.fold(0, (total, day) => total + day.summary.dhikrCount);
}
