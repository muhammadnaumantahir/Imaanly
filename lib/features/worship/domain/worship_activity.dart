enum WorshipActivityType { salah, quran, dhikr }

/// A small, serializable description of one locally recorded worship action.
///
/// The model deliberately contains no Hive or Flutter dependencies so the
/// aggregation rules can be tested independently from storage and UI.
class WorshipActivity {
  const WorshipActivity({
    required this.id,
    required this.type,
    required this.dateKey,
    required this.recordedAt,
    required this.amount,
    this.target,
    this.reference,
  });

  factory WorshipActivity.salah({
    required String prayer,
    required DateTime completedAt,
  }) {
    final day = dayKey(completedAt);
    return WorshipActivity(
      id: 'salah:$prayer:$day',
      type: WorshipActivityType.salah,
      dateKey: day,
      recordedAt: completedAt,
      amount: 1,
      target: 1,
      reference: prayer,
    );
  }

  factory WorshipActivity.quranPages({
    required int pages,
    required DateTime recordedAt,
  }) {
    if (pages < 0) {
      throw ArgumentError.value(pages, 'pages', 'must not be negative');
    }
    return WorshipActivity(
      id: 'quran:${recordedAt.microsecondsSinceEpoch}',
      type: WorshipActivityType.quran,
      dateKey: dayKey(recordedAt),
      recordedAt: recordedAt,
      amount: pages,
    );
  }

  factory WorshipActivity.dhikr({
    required int count,
    required DateTime recordedAt,
    String? category,
  }) {
    if (count < 0) {
      throw ArgumentError.value(count, 'count', 'must not be negative');
    }
    return WorshipActivity(
      id: 'dhikr:${recordedAt.microsecondsSinceEpoch}',
      type: WorshipActivityType.dhikr,
      dateKey: dayKey(recordedAt),
      recordedAt: recordedAt,
      amount: count,
      reference: category,
    );
  }

  final String id;
  final WorshipActivityType type;
  final String dateKey;
  final DateTime recordedAt;
  final int amount;
  final int? target;
  final String? reference;

  /// Stable key used to make a Salah completion idempotent for a given day.
  String get completionKey => id;

  static String dayKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
