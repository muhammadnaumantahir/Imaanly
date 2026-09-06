import 'package:flutter_test/flutter_test.dart';
import 'package:al_furkan/features/worship/domain/worship_activity.dart';

void main() {
  test('creates a stable day key from a local date', () {
    final key = WorshipActivity.dateKey(DateTime(2026, 9, 6, 23, 45));

    expect(key, '2026-09-06');
  });

  test('same salah completion is identified by prayer and day', () {
    final first = WorshipActivity.salah(
      prayer: 'Fajr',
      completedAt: DateTime(2026, 9, 6, 6),
    );
    final second = WorshipActivity.salah(
      prayer: 'Fajr',
      completedAt: DateTime(2026, 9, 6, 7),
    );
    final otherPrayer = WorshipActivity.salah(
      prayer: 'Dhuhr',
      completedAt: DateTime(2026, 9, 6, 13),
    );

    expect(first.completionKey, second.completionKey);
    expect(first.completionKey, isNot(otherPrayer.completionKey));
  });

  test('quran and dhikr activities preserve their amounts', () {
    final quran = WorshipActivity.quranPages(
      pages: 3,
      recordedAt: DateTime(2026, 9, 6),
    );
    final dhikr = WorshipActivity.dhikr(
      count: 33,
      category: 'Morning',
      recordedAt: DateTime(2026, 9, 6),
    );

    expect(quran.type, WorshipActivityType.quran);
    expect(quran.amount, 3);
    expect(dhikr.type, WorshipActivityType.dhikr);
    expect(dhikr.amount, 33);
    expect(dhikr.reference, 'Morning');
  });
}
