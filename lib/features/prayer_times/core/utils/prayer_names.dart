import 'package:adhan_dart/adhan_dart.dart';

/// 📝 أسماء الصلوات بالعربية والإنجليزية
class PrayerNames {
  /// Get Arabic name for prayer
  static String getArabicName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'Fajr';
      case Prayer.sunrise:
        return 'Sunrise';
      case Prayer.dhuhr:
        return 'Dhuhr';
      case Prayer.asr:
        return 'Asr';
      case Prayer.maghrib:
        return 'Maghrib';
      case Prayer.isha:
        return 'Isha';
      default:
        return '';
    }
  }

  /// Get English name for prayer
  static String getEnglishName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'Fajr';
      case Prayer.sunrise:
        return 'Sunrise';
      case Prayer.dhuhr:
        return 'Dhuhr';
      case Prayer.asr:
        return 'Asr';
      case Prayer.maghrib:
        return 'Maghrib';
      case Prayer.isha:
        return 'Isha';
      default:
        return '';
    }
  }

  /// Get short Arabic name (for compact display)
  static String getShortArabicName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'Fajr';
      case Prayer.sunrise:
        return 'Sunrise';
      case Prayer.dhuhr:
        return 'Dhuhr';
      case Prayer.asr:
        return 'Asr';
      case Prayer.maghrib:
        return 'Maghrib';
      case Prayer.isha:
        return 'Isha';
      default:
        return '';
    }
  }

  /// Get prayer description in Arabic
  static String getArabicDescription(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'Fajr prayer - from dawn until sunrise';
      case Prayer.sunrise:
        return 'Sunrise time - start of the day';
      case Prayer.dhuhr:
        return 'Dhuhr prayer - from the sun\'s zenith until Asr';
      case Prayer.asr:
        return 'Asr prayer - from mid-afternoon until Maghrib';
      case Prayer.maghrib:
        return 'Maghrib prayer - from sunset until Isha';
      case Prayer.isha:
        return 'Isha prayer - from the disappearance of twilight until midnight';
      default:
        return '';
    }
  }

  /// Check if prayer is obligatory (فرض)
  static bool isObligatory(Prayer prayer) {
    return prayer != Prayer.sunrise;
  }

  /// Get prayer order number (1-6)
  static int getPrayerOrder(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 1;
      case Prayer.sunrise:
        return 2;
      case Prayer.dhuhr:
        return 3;
      case Prayer.asr:
        return 4;
      case Prayer.maghrib:
        return 5;
      case Prayer.isha:
        return 6;
      default:
        return 0;
    }
  }
}
