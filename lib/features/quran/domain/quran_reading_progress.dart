/// Local-first reading position and daily Quran reading goal.
class QuranReadingProgress {
  const QuranReadingProgress({
    required this.surahNumber,
    required this.ayahNumber,
    required this.dailyPages,
    required this.dailyPageGoal,
    required this.dateKey,
  });

  final int surahNumber;
  final int ayahNumber;
  final int dailyPages;
  final int dailyPageGoal;
  final String dateKey;

  bool get goalComplete => dailyPages >= dailyPageGoal;

  double get goalProgress =>
      (dailyPages / dailyPageGoal).clamp(0.0, 1.0).toDouble();

  QuranReadingProgress copyWith({
    int? surahNumber,
    int? ayahNumber,
    int? dailyPages,
    int? dailyPageGoal,
    String? dateKey,
  }) {
    return QuranReadingProgress(
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      dailyPages: dailyPages ?? this.dailyPages,
      dailyPageGoal: dailyPageGoal ?? this.dailyPageGoal,
      dateKey: dateKey ?? this.dateKey,
    );
  }

  Map<String, dynamic> toMap() => {
        'surahNumber': surahNumber,
        'ayahNumber': ayahNumber,
        'dailyPages': dailyPages,
        'dailyPageGoal': dailyPageGoal,
        'dateKey': dateKey,
      };

  factory QuranReadingProgress.fromMap(Map<dynamic, dynamic> map) {
    return QuranReadingProgress(
      surahNumber: _positive(map['surahNumber'], fallback: 1),
      ayahNumber: _positive(map['ayahNumber'], fallback: 1),
      dailyPages: _nonNegative(map['dailyPages']),
      dailyPageGoal: _positive(map['dailyPageGoal'], fallback: 2),
      dateKey: map['dateKey']?.toString() ?? '',
    );
  }

  static int _positive(dynamic value, {required int fallback}) {
    final parsed = value is num ? value.toInt() : int.tryParse('$value');
    return parsed != null && parsed > 0 ? parsed : fallback;
  }

  static int _nonNegative(dynamic value) {
    final parsed = value is num ? value.toInt() : int.tryParse('$value');
    return parsed != null && parsed >= 0 ? parsed : 0;
  }
}
