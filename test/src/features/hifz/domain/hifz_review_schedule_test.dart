import 'package:flutter_test/flutter_test.dart';
import 'package:imaanly/src/features/hifz/domain/entities/hifz.dart';
import 'package:imaanly/src/features/hifz/domain/hifz_review_schedule.dart';

void main() {
  final reviewed = DateTime(2026, 9, 1, 10);

  HifzProgress progress(HifzMasteryLevel mastery) => HifzProgress(
        surahId: 2,
        ayahStart: 1,
        ayahEnd: 10,
        totalAyahs: 286,
        lastReviewed: reviewed,
        mastery: mastery,
        reviewCount: 10,
        correctCount: 9,
        mistakeCount: 1,
      );

  test('uses mastery-specific spaced repetition intervals', () {
    expect(HifzReviewSchedule.intervalFor(HifzMasteryLevel.learning), const Duration(days: 1));
    expect(HifzReviewSchedule.intervalFor(HifzMasteryLevel.familiar), const Duration(days: 3));
    expect(HifzReviewSchedule.intervalFor(HifzMasteryLevel.confident), const Duration(days: 7));
    expect(HifzReviewSchedule.intervalFor(HifzMasteryLevel.mastered), const Duration(days: 14));
  });

  test('calculates the next review date from the last review', () {
    expect(
      HifzReviewSchedule.nextReviewAt(progress(HifzMasteryLevel.confident)),
      DateTime(2026, 9, 8, 10),
    );
  });

  test('marks a progress item due at or after its scheduled time', () {
    final item = progress(HifzMasteryLevel.familiar);
    expect(HifzReviewSchedule.isDue(item, now: DateTime(2026, 9, 4, 10)), isTrue);
    expect(HifzReviewSchedule.isDue(item, now: DateTime(2026, 9, 4, 9, 59)), isFalse);
  });

  test('does not report negative days remaining', () {
    final item = progress(HifzMasteryLevel.learning);
    expect(HifzReviewSchedule.daysUntil(item, now: DateTime(2026, 9, 5)), 0);
  });
}
