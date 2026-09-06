enum FastingStatus { fasted, missed, excused }

class FastingEntry {
  const FastingEntry({
    required this.date,
    required this.status,
    this.note,
  });

  final DateTime date;
  final FastingStatus status;
  final String? note;

  String get dateKey => _dayKey(date);

  FastingEntry copyWith({
    DateTime? date,
    FastingStatus? status,
    String? note,
    bool clearNote = false,
  }) {
    return FastingEntry(
      date: date ?? this.date,
      status: status ?? this.status,
      note: clearNote ? null : note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'status': status.name,
        if (note != null && note!.trim().isNotEmpty) 'note': note,
      };

  factory FastingEntry.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'] as String?;
    final status = FastingStatus.values.firstWhere(
      (value) => value.name == rawStatus,
      orElse: () => FastingStatus.missed,
    );
    return FastingEntry(
      date: DateTime.parse(json['date'] as String),
      status: status,
      note: json['note'] as String?,
    );
  }

  static String _dayKey(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}
