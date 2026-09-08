class HadithItem {
  const HadithItem({
    required this.id,
    required this.title,
    required this.text,
    required this.source,
  });

  final String id;
  final String title;
  final String text;
  final String source;
}

class HadithCatalog {
  HadithCatalog._();

  // Short paraphrases are used in-app; references identify the source
  // collection and hadith number for verification.
  static const items = <HadithItem>[
    HadithItem(
      id: 'intentions',
      title: 'Intentions',
      text: 'The reward of deeds depends upon intentions, and each person receives according to what they intended.',
      source: 'Sahih al-Bukhari 1',
    ),
    HadithItem(
      id: 'mercy',
      title: 'Mercy',
      text: 'The merciful are shown mercy by the Most Merciful; be merciful to those on earth.',
      source: 'Jami at-Tirmidhi 1924',
    ),
    HadithItem(
      id: 'good_character',
      title: 'Good character',
      text: 'The best among you are those who are best in character and manners.',
      source: 'Sahih al-Bukhari 6035',
    ),
    HadithItem(
      id: 'brotherhood',
      title: 'Brotherhood',
      text: 'Faith is not complete until a person loves for their brother what they love for themselves.',
      source: 'Sahih al-Bukhari; Sahih Muslim',
    ),
    HadithItem(
      id: 'ease',
      title: 'Ease',
      text: 'Make matters easy for people, do not make them difficult, and give them glad tidings.',
      source: 'Sahih al-Bukhari 69',
    ),
    HadithItem(
      id: 'spread_salam',
      title: 'Spread salam',
      text: 'Spread the greeting of salam among one another as a means of fostering love and brotherhood.',
      source: 'Sahih Muslim 54a',
    ),
    HadithItem(
      id: 'cleanliness',
      title: 'Purification',
      text: 'Purification is described as half of faith, alongside remembrance, prayer, charity, patience, and the Quran.',
      source: 'Sahih Muslim 223',
    ),
    HadithItem(
      id: 'right_hand',
      title: 'Eating and drinking',
      text: 'When eating or drinking, use the right hand.',
      source: 'Sahih Muslim 2020a',
    ),
    HadithItem(
      id: 'kind_word',
      title: 'A kind word',
      text: 'A good and pleasant word can itself be an act of charity.',
      source: 'Sahih al-Bukhari 6023',
    ),
  ];

  static List<HadithItem> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return items;
    return items
        .where(
          (item) =>
              item.title.toLowerCase().contains(q) ||
              item.text.toLowerCase().contains(q) ||
              item.source.toLowerCase().contains(q),
        )
        .toList(growable: false);
  }
}
