import "dart:ui";

/// Imaanly uses English as its only application UI language.
/// Arabic Quran text and other source content remain available as content;
/// they are not application interface languages.
List<MyAppLocalization> usedAppLanguageMap = [
  MyAppLocalization(
    english: "English",
    native: "English",
    locale: const Locale("en", "US"),
  ),
];

class MyAppLocalization {
  String english;
  String native;
  Locale locale;

  MyAppLocalization({
    required this.english,
    required this.native,
    required this.locale,
  });

  Map<String, dynamic> toJson() {
    return {
      "english": english,
      "native": native,
      "locale": {
        "languageCode": locale.languageCode,
        "countryCode": locale.countryCode,
      },
    };
  }

  factory MyAppLocalization.fromJson(Map<String, dynamic> json) {
    return MyAppLocalization(
      english: json["english"] as String,
      native: json["native"] as String,
      locale: Locale(
        json["locale"]["languageCode"] as String,
        json["locale"]["countryCode"] as String?,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MyAppLocalization &&
        other.english == english &&
        other.native == native &&
        other.locale == locale;
  }

  @override
  int get hashCode => english.hashCode ^ native.hashCode ^ locale.hashCode;
}
