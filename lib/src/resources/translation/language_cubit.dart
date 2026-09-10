import "package:imaanly/src/resources/translation/languages.dart";
import "package:dartx/dartx.dart";
import "package:flutter/widgets.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:shared_preferences/shared_preferences.dart";

class LanguageCubit extends Cubit<MyAppLocalization> {
  LanguageCubit(MyAppLocalization initialLocale)
    : super(
        usedAppLanguageMap.firstOrNullWhere(
              (element) =>
                  element.locale.languageCode ==
                  initialLocale.locale.languageCode,
            ) ??
            _english,
      );

  static const String _selectedLanguageCodeKey = "selectedLanguageCode";

  static MyAppLocalization get _english => usedAppLanguageMap.firstWhere(
        (element) => element.locale.languageCode == "en",
      );

  Future<void> changeLanguage(MyAppLocalization localeInfo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _selectedLanguageCodeKey,
      localeInfo.locale.languageCode,
    );

    emit(localeInfo);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!isClosed) emit(localeInfo);
    });
  }

  static Future<MyAppLocalization> getInitialLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_selectedLanguageCodeKey);
    if (languageCode != null) {
      return usedAppLanguageMap.firstOrNullWhere(
            (element) => element.locale.languageCode == languageCode,
          ) ??
          _english;
    }

    // Imaanly is an English-first app. Users can still switch to Arabic or
    // another supported language from Settings; the device language should
    // not silently turn the whole UI into Arabic on first launch.
    return _english;
  }
}
