class SunnahItem {
  const SunnahItem({
    required this.id,
    required this.title,
    required this.practice,
    required this.source,
  });

  final String id;
  final String title;
  final String practice;
  final String source;
}

/// A small offline starter set of broadly established Sunnah/adab practices.
/// References are included so the content can be audited and expanded later.
class SunnahCatalog {
  SunnahCatalog._();

  static const items = <SunnahItem>[
    SunnahItem(
      id: 'salam',
      title: 'Spread salam',
      practice: 'Greet fellow Muslims with peace and return the greeting warmly.',
      source: 'Sahih Muslim 54',
    ),
    SunnahItem(
      id: 'right_hand_food',
      title: 'Eat with the right hand',
      practice: 'When eating or drinking, use the right hand.',
      source: 'Sahih Muslim 2020',
    ),
    SunnahItem(
      id: 'kind_word',
      title: 'Speak a kind word',
      practice: 'A good and kind word is an act of charity.',
      source: 'Sahih al-Bukhari 2989; Sahih Muslim 1009',
    ),
    SunnahItem(
      id: 'smile',
      title: 'Smile and be welcoming',
      practice: 'A sincere smile toward your fellow Muslim is counted as charity.',
      source: 'Jami at-Tirmidhi 1956',
    ),
    SunnahItem(
      id: 'cleanliness',
      title: 'Maintain cleanliness',
      practice: 'Keep yourself and your surroundings clean as part of a mindful Muslim life.',
      source: 'Sahih Muslim 223',
    ),
    SunnahItem(
      id: 'bismillah_food',
      title: 'Remember Allah before eating',
      practice: 'Mention Allah’s name before eating; if you forget, remember Allah when you recall it.',
      source: 'Sunan Abi Dawud 3767; Jami at-Tirmidhi 1859',
    ),
  ];

  static List<SunnahItem> search(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return items;
    return items
        .where((item) =>
            item.title.toLowerCase().contains(normalized) ||
            item.practice.toLowerCase().contains(normalized) ||
            item.source.toLowerCase().contains(normalized))
        .toList(growable: false);
  }
}
