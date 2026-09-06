import "package:imaanly/src/utils/basic_functions.dart";
import "package:imaanly/src/resources/quran_resources/quran_pages_info.dart";

int? getPageNumber(String ayahKey) {
  final int? ayahID = convertKeyToAyahNumber(ayahKey);
  if (ayahID == null) {
    return null;
  }
  for (Map info in quranPagesInfo) {
    if (info["s"] <= ayahID && info["e"] >= ayahID) {
      return info["i"] + 1;
    }
  }
  return null;
}
