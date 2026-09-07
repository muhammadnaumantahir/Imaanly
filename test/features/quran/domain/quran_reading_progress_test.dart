import 'package:flutter_test/flutter_test.dart';

import 'package:imaanly/features/quran/domain/quran_reading_progress.dart';

void main() {
  test('calculates bounded daily goal progress', () {
    const progress = QuranReadingProgress(
      surahNumber: 2,
      ayahNumber: 10,
      dailyPages: 3,
      dailyPageGoal: 2,
      dateKey: '2026-09-07',
    );

    expect(progress.goalComplete, isTrue);
    expect(progress.goalProgress, 1.0);
  });

  test('normalizes invalid persisted values', () {
    final progress = QuranReadingProgress.fromMap({
      'surahNumber': 0,
      'ayahNumber': -4,
      'dailyPages': -1,
      'dailyPageGoal': 0,
      'dateKey': '2026-09-07',
    });

    expect(progress.surahNumber, 1);
    expect(progress.ayahNumber, 1);
    expect(progress.dailyPages, 0);
    expect(progress.dailyPageGoal, 2);
  });
}
