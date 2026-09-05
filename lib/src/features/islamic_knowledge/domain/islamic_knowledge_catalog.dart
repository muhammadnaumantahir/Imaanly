class IslamicKnowledgeSection {
  const IslamicKnowledgeSection({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String id;
  final String title;
  final String subtitle;
  final String icon;
}

/// Offline-first entry points for learning inside Imaanly.
///
/// The catalog deliberately points to content already shipped by the app;
/// it does not invent religious content or require a network service.
class IslamicKnowledgeCatalog {
  IslamicKnowledgeCatalog._();

  static const sections = <IslamicKnowledgeSection>[
    IslamicKnowledgeSection(
      id: 'tafsir',
      title: 'Tafsir',
      subtitle: 'Explore Quran commentary and understand ayahs in context.',
      icon: 'book',
    ),
    IslamicKnowledgeSection(
      id: 'quran_topics',
      title: 'Quran topics',
      subtitle: 'Return to your saved Quran collections and reflections.',
      icon: 'topics',
    ),
    IslamicKnowledgeSection(
      id: 'worship',
      title: 'Worship & adab',
      subtitle: 'Build knowledge around prayer, remembrance and daily worship.',
      icon: 'mosque',
    ),
    IslamicKnowledgeSection(
      id: 'collections',
      title: 'My collections',
      subtitle: 'Review ayahs and notes you have saved while learning.',
      icon: 'collections',
    ),
  ];

  static List<IslamicKnowledgeSection> search(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return sections;
    return sections.where((section) {
      return section.title.toLowerCase().contains(normalized) ||
          section.subtitle.toLowerCase().contains(normalized);
    }).toList(growable: false);
  }
}
