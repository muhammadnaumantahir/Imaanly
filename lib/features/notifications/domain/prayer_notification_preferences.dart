/// Per-prayer notification controls used by the scheduling layer.
class PrayerNotificationPreferences {
  const PrayerNotificationPreferences({
    this.fajr = true,
    this.dhuhr = true,
    this.asr = true,
    this.maghrib = true,
    this.isha = true,
    this.reminderMinutes = 10,
    this.silent = false,
  });

  final bool fajr;
  final bool dhuhr;
  final bool asr;
  final bool maghrib;
  final bool isha;
  final int reminderMinutes;
  final bool silent;

  bool isEnabled(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return fajr;
      case 'dhuhr':
      case 'zuhr':
        return dhuhr;
      case 'asr':
        return asr;
      case 'maghrib':
        return maghrib;
      case 'isha':
        return isha;
      default:
        return false;
    }
  }

  PrayerNotificationPreferences copyWith({
    bool? fajr,
    bool? dhuhr,
    bool? asr,
    bool? maghrib,
    bool? isha,
    int? reminderMinutes,
    bool? silent,
  }) {
    return PrayerNotificationPreferences(
      fajr: fajr ?? this.fajr,
      dhuhr: dhuhr ?? this.dhuhr,
      asr: asr ?? this.asr,
      maghrib: maghrib ?? this.maghrib,
      isha: isha ?? this.isha,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      silent: silent ?? this.silent,
    );
  }

  Map<String, dynamic> toMap() => {
        'fajr': fajr,
        'dhuhr': dhuhr,
        'asr': asr,
        'maghrib': maghrib,
        'isha': isha,
        'reminderMinutes': reminderMinutes,
        'silent': silent,
      };

  factory PrayerNotificationPreferences.fromMap(Map<dynamic, dynamic> map) {
    final rawMinutes = map['reminderMinutes'];
    final minutes = rawMinutes is num ? rawMinutes.toInt() : 10;
    bool readBool(String key, bool fallback) =>
        map[key] is bool ? map[key] as bool : fallback;

    return PrayerNotificationPreferences(
      fajr: readBool('fajr', true),
      dhuhr: readBool('dhuhr', true),
      asr: readBool('asr', true),
      maghrib: readBool('maghrib', true),
      isha: readBool('isha', true),
      reminderMinutes: minutes.clamp(0, 60).toInt(),
      silent: readBool('silent', false),
    );
  }
}
