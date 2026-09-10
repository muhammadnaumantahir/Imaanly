import "package:imaanly/src/resources/translation/languages.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:shared_preferences/shared_preferences.dart";

class LanguageCubit extends Cubit<MyAppLocalization> {
  LanguageCubit(MyAppLocalization initialLocale) : super(_english);

  static const String _selectedLanguageCodeKey = "selectedLanguageCode";

  static MyAppLocalization get _english => usedAppLanguageMap.firstWhere(
        (element) => element.locale.languageCode == "en",
      );

  /// Imaanly is intentionally English-only at the application UI level.
  /// Quran/Islamic source content can still contain Arabic and other content;
  /// this cubit only controls the application interface locale.
  Future<void> changeLanguage(MyAppLocalization localeInfo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedLanguageCodeKey, "en");
    emit(_english);
  }

  static Future<MyAppLocalization> getInitialLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_selectedLanguageCodeKey);
    if (languageCode != null && languageCode == "en") {
      return _english;
    }

    // Clear any legacy non-English selection and always launch in English.
    if (languageCode != null) {
      await prefs.setString(_selectedLanguageCodeKey, "en");
    }
    return _english;
  }
}
