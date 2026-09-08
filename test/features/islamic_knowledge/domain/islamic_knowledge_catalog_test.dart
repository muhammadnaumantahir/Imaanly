import 'package:flutter_test/flutter_test.dart';
import 'package:imaanly/src/features/islamic_knowledge/domain/islamic_knowledge_catalog.dart';

void main() {
  test('catalog exposes knowledge sections in a stable order', () {
    expect(
      IslamicKnowledgeCatalog.sections.map((section) => section.id).toList(),
      ['tafsir', 'hadith', 'sunnah', 'quran_topics', 'worship', 'collections'],
    );
  });

  test('section search matches title and description case-insensitively', () {
    final results = IslamicKnowledgeCatalog.search('TAFSIR');
    expect(results.map((section) => section.id), contains('tafsir'));
  });

  test('empty search returns every section', () {
    expect(
      IslamicKnowledgeCatalog.search(''),
      IslamicKnowledgeCatalog.sections,
    );
  });
}
