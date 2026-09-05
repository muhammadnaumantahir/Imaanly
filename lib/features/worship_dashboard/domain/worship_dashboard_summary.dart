class WorshipDashboardSummary {
  const WorshipDashboardSummary({
    required this.prayersCompleted,
    required this.prayersTotal,
    required this.quranPages,
    required this.dhikrCompleted,
    required this.dhikrGoal,
    required this.readingStreak,
  });

  final int prayersCompleted;
  final int prayersTotal;
  final int quranPages;
  final int dhikrCompleted;
  final int dhikrGoal;
  final int readingStreak;

  double get prayerProgress => prayersTotal == 0
      ? 0
      : (prayersCompleted / prayersTotal).clamp(0.0, 1.0);

  double get dhikrProgress => dhikrGoal == 0
      ? 0
      : (dhikrCompleted / dhikrGoal).clamp(0.0, 1.0);
}
