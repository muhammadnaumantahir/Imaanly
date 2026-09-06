enum DailyGoalType { quranPages, quranAyahs, dhikr, salah }

class DailyGoals {
  const DailyGoals({
    this.quranPages = 5,
    this.quranAyahs = 0,
    this.dhikr = 33,
    this.salah = 5,
  });

  final int quranPages;
  final int quranAyahs;
  final int dhikr;
  final int salah;

  DailyGoals copyWith({
    int? quranPages,
    int? quranAyahs,
    int? dhikr,
    int? salah,
  }) {
    return DailyGoals(
      quranPages: quranPages ?? this.quranPages,
      quranAyahs: quranAyahs ?? this.quranAyahs,
      dhikr: dhikr ?? this.dhikr,
      salah: salah ?? this.salah,
    );
  }

  Map<String, dynamic> toJson() => {
        'quranPages': quranPages,
        'quranAyahs': quranAyahs,
        'dhikr': dhikr,
        'salah': salah,
      };

  factory DailyGoals.fromJson(Map<String, dynamic> json) {
    int value(String key, int fallback) {
      final raw = json[key];
      return raw is num ? raw.toInt().clamp(0, 100000) : fallback;
    }

    return DailyGoals(
      quranPages: value('quranPages', 5),
      quranAyahs: value('quranAyahs', 0),
      dhikr: value('dhikr', 33),
      salah: value('salah', 5),
    );
  }
}
