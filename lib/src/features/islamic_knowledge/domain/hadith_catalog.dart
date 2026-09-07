class HadithItem {
  const HadithItem({required this.id, required this.title, required this.text, required this.source});
  final String id;
  final String title;
  final String text;
  final String source;
}

class HadithCatalog {
  HadithCatalog._();

  static const items = <HadithItem>[
    HadithItem(id: 'intentions', title: 'Intentions', text: 'Actions are judged by intentions, and every person will have what they intended.', source: 'Sahih al-Bukhari; Sahih Muslim'),
    HadithItem(id: 'mercy', title: 'Mercy', text: 'Those who are merciful will be shown mercy by the Most Merciful.', source: 'Jami at-Tirmidhi'),
    HadithItem(id: 'good_character', title: 'Good character', text: 'The best of you are those who are best in character.', source: 'Sahih al-Bukhari'),
    HadithItem(id: 'brotherhood', title: 'Brotherhood', text: 'None of you truly believes until he loves for his brother what he loves for himself.', source: 'Sahih al-Bukhari; Sahih Muslim'),
    HadithItem(id: 'ease', title: 'Ease', text: 'Make things easy and do not make things difficult; give glad tidings and do not repel people.', source: 'Sahih al-Bukhari; Sahih Muslim'),
  ];

  static List<HadithItem> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return items;
    return items.where((item) => item.title.toLowerCase().contains(q) || item.text.toLowerCase().contains(q) || item.source.toLowerCase().contains(q)).toList(growable: false);
  }
}
