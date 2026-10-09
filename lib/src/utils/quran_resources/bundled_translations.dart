import "dart:convert";

import "package:archive/archive.dart";
import "package:flutter/services.dart";
import "package:hive_ce_flutter/hive_flutter.dart";

import "../../resources/quran_resources/models/translation_book_model.dart";
import "quran_translation_function.dart";

/// Translations that ship inside the app, so ayat show a translation right away
/// and without internet: English (Saheeh International) first, with Urdu as an option.
class BundledTranslations {
  static const String _installedKey = "bundled_translations_installed_v1";

  static final TranslationBookModel english = TranslationBookModel(
    language: "English",
    name: "Saheeh International",
    fileName: "saheeh_international.json",
    score: 100,
    type: TranslationResourcesType.withFootnoteTags,
    fullPath: "bundled/English/saheeh_international.json",
  );

  static final TranslationBookModel urdu = TranslationBookModel(
    language: "Urdu",
    name: "Fateh Muhammad Jalandhry",
    fileName: "fateh_muhammad_jalandhry.json",
    score: 100,
    type: TranslationResourcesType.simple,
    fullPath: "bundled/Urdu/fateh_muhammad_jalandhry.json",
  );

  static Future<void> ensureInstalled() async {
    if (!Hive.isBoxOpen("user")) {
      await Hive.openBox("user");
    }
    final userBox = Hive.box("user");

    await _install(english, "assets/wahy/en.json.gz");
    await _install(urdu, "assets/translations/ur_fateh_muhammad_jalandhry.json.gz");

    // First run only: English is shown by default; Urdu can be switched on in
    // Resources > Translations.
    if (userBox.get(_installedKey, defaultValue: false) != true) {
      final selections = await QuranTranslationFunction.getTranslationSelections() ?? [];
      if (selections.isEmpty) {
        await QuranTranslationFunction.setTranslationSelection(english);
      }
      await userBox.put(_installedKey, true);
    }
  }

  static Future<void> _install(TranslationBookModel book, String assetPath) async {
    final boxName = QuranTranslationFunction.getTranslationBoxName(translationBook: book);
    final LazyBox box = Hive.isBoxOpen(boxName)
        ? Hive.lazyBox(boxName)
        : await Hive.openLazyBox(boxName);

    if (box.length < 6000) {
      final bytes = (await rootBundle.load(assetPath)).buffer.asUint8List();
      final text = utf8.decode(GZipDecoder().decodeBytes(bytes));
      final Map data = jsonDecode(text) as Map;
      await box.putAll(data.cast<String, dynamic>());
      await box.put("meta_data", book.toMap());
    }
    await QuranTranslationFunction.setToListAlreadyDownloaded(book);
  }
}
