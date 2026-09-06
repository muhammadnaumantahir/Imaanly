import 'worship_activity.dart';

class WorshipDailySummary {
  const WorshipDailySummary({
    required this.dateKey,
    required this.prayersCompleted,
    required this.prayersTotal,
    required this.quranPages,
    required this.dhikrCount,
    this.dhikrGoal = 33,
  });

  factory WorshipDailySummary.fromActivities(
    Iterable<WorshipActivity> activities, {
    required DateTime date,
  }) {
    final key = WorshipActivity.dayKey(date);
    final completedPrayers = <String>{};
    var quranPages = 0;
    var dhikrCount = 0;
    var dhikrGoal = 0;
    var hasDhikrGoal = false;

    for (final activity in activities) {
      if (activity.dateKey != key) continue;
      switch (activity.type) {
        case WorshipActivityType.salah:
          if (activity.reference != null) {
            completedPrayers.add(activity.reference!);
          }
        case WorshipActivityType.quran:
          quranPages += activity.amount;
        case WorshipActivityType.dhikr:
          dhikrCount += activity.amount;
          if (activity.target != null) {
            dhikrGoal += activity.target!;
            hasDhikrGoal = true;
          }
      }
    }

    return WorshipDailySummary(
      dateKey: key,
      prayersCompleted: completedPrayers.length,
      prayersTotal: 5,
      quranPages: quranPages,
      dhikrCount: dhikrCount,
      dhikrGoal: hasDhikrGoal ? dhikrGoal : 33,
    );
  }

  final String dateKey;
  final int prayersCompleted;
  final int prayersTotal;
  final int quranPages;
  final int dhikrCount;
  final int dhikrGoal;

  double get prayerProgress => prayersTotal == 0
      ? 0
      : (prayersCompleted / prayersTotal).clamp(0.0, 1.0);

  double get quranProgress => (quranPages / 5).clamp(0.0, 1.0);

  double get dhikrProgress => dhikrGoal == 0
      ? 0
      : (dhikrCount / dhikrGoal).clamp(0.0, 1.0);
}
