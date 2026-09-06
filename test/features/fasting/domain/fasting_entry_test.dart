import 'package:flutter_test/flutter_test.dart';
import 'package:imaanly/features/fasting/domain/fasting_entry.dart';

void main() {
  test('serializes and restores a fasting entry', () {
    final entry = FastingEntry(
      date: DateTime(2026, 9, 6, 18, 30),
      status: FastingStatus.fasted,
      note: 'Personal journal note',
    );

    final restored = FastingEntry.fromJson(entry.toJson());

    expect(restored.date, entry.date);
    expect(restored.dateKey, '2026-09-06');
    expect(restored.status, FastingStatus.fasted);
    expect(restored.note, 'Personal journal note');
  });

  test('invalid status falls back to missed', () {
    final entry = FastingEntry.fromJson({
      'date': '2026-09-06T00:00:00.000',
      'status': 'unknown',
    });

    expect(entry.status, FastingStatus.missed);
  });

  test('copyWith can clear note', () {
    final entry = FastingEntry(
      date: DateTime(2026, 9, 6),
      status: FastingStatus.fasted,
      note: 'note',
    );

    expect(entry.copyWith(clearNote: true).note, isNull);
  });
}
