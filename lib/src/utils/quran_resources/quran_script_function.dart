import "dart:convert";

import "package:imaanly/src/utils/tajweed_rules.dart";
import "package:imaanly/src/widget/quran_script/model/script_info.dart";
import "package:flutter/services.dart";
import "package:hive_ce/hive.dart";

class QuranScriptFunction {
  static String quranScriptVersion = "1";
  static Box? quranBox;
  static final Map<QuranScriptType, Box> _scriptBoxes = {};

  static Future<void> writeQuranScript({
    Function(int progress)? onProgress,
  }) async {
    int progress = 0;
    int processed = 0;
    final userBox = Hive.box("user");
    for (QuranScriptType scriptType in QuranScriptType.values) {
      Map quranScriptMap = {};
      switch (scriptType) {
        case QuranScriptType.tajweed:
          quranScriptMap = jsonDecode(
            await rootBundle.loadString(
              "assets/quran_script/QPC_Hafs_Tajweed_Compress.json",
            ),
          );
        case QuranScriptType.uthmani:
          quranScriptMap = jsonDecode(
            await rootBundle.loadString("assets/quran_script/Uthmani.json"),
          );
        case QuranScriptType.indopak:
          quranScriptMap = jsonDecode(
            await rootBundle.loadString("assets/quran_script/Indopak.json"),
          );
      }
      final quranBox = await Hive.openBox("script_${scriptType.name}");
      for (String surahKey in quranScriptMap.keys) {
        final Map surahMap = quranScriptMap[surahKey] as Map;
        final entries = <String, dynamic>{};
        for (final ayahKey in surahMap.keys) {
          entries["$surahKey:$ayahKey"] = surahMap[ayahKey];
          processed++;
        }
        // One batched write per surah is far faster (especially on web) than 18k single writes.
        await quranBox.putAll(entries);
        if (onProgress != null) {
          final double temProgress = (processed / 18708) * 100;
          if (temProgress.toInt() != progress) {
            progress = temProgress.toInt();
            onProgress(progress);
          }
        }
      }

      quranScriptMap.clear();
      await quranBox.close();
    }
    await userBox.put("writeQuranScriptVersion", quranScriptVersion);
    await userBox.put("writeQuranScript", true);
  }

  /// Imports the bundled Quran script into local storage the first time it is needed.
  static Future<void> ensureQuranScriptWritten({
    Function(int progress)? onProgress,
  }) async {
    final userBox = Hive.box("user");
    final written = userBox.get("writeQuranScript", defaultValue: false) == true &&
        userBox.get("writeQuranScriptVersion") == quranScriptVersion;
    if (written) return;
    await writeQuranScript(onProgress: onProgress);
  }

  static Future<void> initQuranScript(QuranScriptType type) async {
    for (final scriptType in QuranScriptType.values) {
      final boxName = "script_${scriptType.name}";
      if (Hive.isBoxOpen(boxName)) {
        _scriptBoxes[scriptType] = Hive.box(boxName);
      } else {
        _scriptBoxes[scriptType] = await Hive.openBox(boxName);
      }
    }
    quranBox = _scriptBoxes[type];
  }

  static Map cacheOfAyah = {};

  static List<String> getWordListOfAyah(
    QuranScriptType type,
    String surah,
    String ayah,
  ) {
    final String ayahKey = "$surah:$ayah";
    final fromCache = cacheOfAyah[ayahKey + type.name];
    if (fromCache != null) return fromCache;

    final Box? sourceBox = _scriptBoxes[type];

    // Guard: box might not be initialized yet
    if (sourceBox == null || !sourceBox.isOpen) return [];

    final rawData = sourceBox.get(ayahKey);
    if (rawData == null) return [];

    switch (type) {
      case QuranScriptType.tajweed:
        final List<String> compressed = List<String>.from(rawData);
        for (int i = 0; i < compressed.length; i++) {
          for (int j = tajweedRulesList.length - 1; 0 <= j; j--) {
            compressed[i] = compressed[i].replaceAll(
              "r$j",
              tajweedRulesList[j],
            );
          }
        }
        cacheOfAyah[ayahKey + type.name] = compressed;
        return compressed;

      default:
        final toReturn = List<String>.from(rawData);
        cacheOfAyah[ayahKey + type.name] = toReturn;
        return toReturn;
    }
  }
}
