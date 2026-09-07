import 'dart:convert';

class ImaanlyPersonalization {
  const ImaanlyPersonalization({
    this.homeShortcuts = const <String>['quran', 'dhikr', 'qibla'],
    this.themeMode = 'system',
    this.quranScript = 'uthmanic',
    this.quranShowTranslation = true,
    this.dhikrDailyGoal = 33,
    this.dashboardCompact = false,
  });

  final List<String> homeShortcuts;
  final String themeMode;
  final String quranScript;
  final bool quranShowTranslation;
  final int dhikrDailyGoal;
  final bool dashboardCompact;

  ImaanlyPersonalization copyWith({
    List<String>? homeShortcuts,
    String? themeMode,
    String? quranScript,
    bool? quranShowTranslation,
    int? dhikrDailyGoal,
    bool? dashboardCompact,
  }) {
    return ImaanlyPersonalization(
      homeShortcuts: homeShortcuts ?? this.homeShortcuts,
      themeMode: themeMode ?? this.themeMode,
      quranScript: quranScript ?? this.quranScript,
      quranShowTranslation: quranShowTranslation ?? this.quranShowTranslation,
      dhikrDailyGoal: dhikrDailyGoal ?? this.dhikrDailyGoal,
      dashboardCompact: dashboardCompact ?? this.dashboardCompact,
    );
  }

  Map<String, dynamic> toJson() => {
        'homeShortcuts': homeShortcuts,
        'themeMode': themeMode,
        'quranScript': quranScript,
        'quranShowTranslation': quranShowTranslation,
        'dhikrDailyGoal': dhikrDailyGoal,
        'dashboardCompact': dashboardCompact,
      };

  factory ImaanlyPersonalization.fromJson(Map<String, dynamic> json) {
    final rawShortcuts = json['homeShortcuts'];
    final shortcuts = rawShortcuts is List
        ? rawShortcuts.whereType<String>().take(6).toList(growable: false)
        : const <String>[];

    final rawGoal = json['dhikrDailyGoal'];
    final goal = rawGoal is num ? rawGoal.toInt().clamp(0, 100000) : 33;

    return ImaanlyPersonalization(
      homeShortcuts: shortcuts.isEmpty
          ? const <String>['quran', 'dhikr', 'qibla']
          : shortcuts,
      themeMode: _allowedTheme(json['themeMode']?.toString()),
      quranScript: json['quranScript']?.toString() == 'indopak'
          ? 'indopak'
          : 'uthmanic',
      quranShowTranslation: json['quranShowTranslation'] is bool
          ? json['quranShowTranslation'] as bool
          : true,
      dhikrDailyGoal: goal,
      dashboardCompact: json['dashboardCompact'] is bool
          ? json['dashboardCompact'] as bool
          : false,
    );
  }

  static String _allowedTheme(String? value) {
    switch (value) {
      case 'light':
      case 'dark':
      case 'system':
        return value!;
      default:
        return 'system';
    }
  }

  String encode() => jsonEncode(toJson());

  factory ImaanlyPersonalization.decode(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) throw const FormatException('Invalid personalization');
    return ImaanlyPersonalization.fromJson(Map<String, dynamic>.from(decoded));
  }
}
