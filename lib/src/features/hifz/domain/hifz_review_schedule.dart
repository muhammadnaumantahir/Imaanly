import 'entities/hifz.dart';

/// Spaced-repetition scheduling rules shared by Hifz UI and background work.
class HifzReviewSchedule {
  const HifzReviewSchedule._();

  static Duration intervalFor(HifzMasteryLevel mastery) {
    return switch (mastery) {
      HifzMasteryLevel.notStarted => const Duration(days: 1),
      HifzMasteryLevel.learning => const Duration(days: 1),
      HifzMasteryLevel.familiar => const Duration(days: 3),
      HifzMasteryLevel.confident => const Duration(days: 7),
      HifzMasteryLevel.mastered => const Duration(days: 14),
    };
  }

  static DateTime nextReviewAt(HifzProgress progress) {
    return progress.lastReviewed.add(intervalFor(progress.mastery));
  }

  static bool isDue(HifzProgress progress, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    return !nextReviewAt(progress).isAfter(reference);
  }

  static int daysUntil(HifzProgress progress, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final difference = nextReviewAt(progress).difference(reference).inDays;
    return difference < 0 ? 0 : difference;
  }
}
