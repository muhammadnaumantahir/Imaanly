/// Metadata for Quranic Transliteration (النطق بالحروف اللاتينية) resources
/// All data is downloaded from the internet — nothing is bundled in the app.
Map<String, List<Map<String, dynamic>>> transliterationResources = {
  "ayah": [
    {
      "language": "Arabic",
      "name": "Latin pronunciation of ayahs",
      "description": "Full Latin-letter pronunciation of each ayah",
      "totalEntries": 6236,
      "score": 100,
      "full_path":
          "quranic_universal_library/transliteration/ayah_transliteration.json.txt",
    },
  ],
  "word": [
    {
      "language": "Arabic",
      "name": "Latin word pronunciation",
      "description": "Word-by-word Latin-letter pronunciation",
      "totalEntries": 77429,
      "score": 100,
      "full_path":
          "quranic_universal_library/transliteration/word_transliteration.json.txt",
    },
  ],
};
