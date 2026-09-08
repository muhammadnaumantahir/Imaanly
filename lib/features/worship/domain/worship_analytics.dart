import 'worship_daily_summary.dart';

/// Aggregated worship metrics over a caller-selected date range.
class WorshipAnalytics {
  const WorshipAnalytics({
    required this.days,
    required this.activeDays,
    required this.prayerCompletions,
    required this.prayerOpportunities,
    required this.quranPages,
    required this.dhikrCount,
  });

  factory WorshipAnalytics.fromSummaries(Iterable<WorshipDailySummary> summaries) {
    final values = summaries.toList(growable: false);
    var activeDays = 0;
    var prayerCompletions = 0;
    var prayerOpportunities = 0;
    var quranPages = 0;
    var dhikrCount = 0;

    for (final summary in values) {
      if (summary.prayersCompleted > 0 || summary.quranPages > 0 || summary.dhikrCount > 0) {
        activeDays++;
      }
      prayerCompletions += summary.prayersCompleted;
      prayerOpportunities += summary.prayersTotal;
      quranPages += summary.quranPages;
      dhikrCount += summary.dhikrCount;
    }

    return WorshipAnalytics(
      days: values.length,
      activeDays: activeDays,
      prayerCompletions: prayerCompletions,
      prayerOpportunities: prayerOpportunities,
      quranPages: quranPages,
      dhikrCount: dhikrCount,
    );
  }

  final int days;
  final int activeDays;
  final int prayerCompletions;
  final int prayerOpportunities;
  final int quranPages;
  final int dhikrCount;

  double get prayerCompletionRate => prayerOpportunities == 0
      ? 0
      : (prayerCompletions / prayerOpportunities).clamp(0.0, 1.0);

  double get averageQuranPages => days == 0 ? 0 : quranPages / days;

  double get averageDhikr => days == 0 ? 0 : dhikrCount / days;
}
