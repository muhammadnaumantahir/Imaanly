import 'package:flutter/material.dart';

import '../../tafsir/presentation/tafsir_screen.dart';
import '../../../screen/azkar/azkar_categories_screen.dart';
import '../../../screen/collections/collection_page.dart';
import '../domain/islamic_knowledge_catalog.dart';

class IslamicKnowledgeScreen extends StatefulWidget {
  const IslamicKnowledgeScreen({super.key});

  @override
  State<IslamicKnowledgeScreen> createState() => _IslamicKnowledgeScreenState();
}

class _IslamicKnowledgeScreenState extends State<IslamicKnowledgeScreen> {
  final _searchController = TextEditingController();
  List<IslamicKnowledgeSection> _sections = IslamicKnowledgeCatalog.sections;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_search);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_search)
      ..dispose();
    super.dispose();
  }

  void _search() {
    setState(() {
      _sections = IslamicKnowledgeCatalog.search(_searchController.text);
    });
  }

  void _openSection(IslamicKnowledgeSection section) {
    Widget? page;
    switch (section.id) {
      case 'tafsir':
        page = const TafsirScreen();
      case 'quran_topics':
        page = const CollectionPage(collectionType: CollectionType.pinned);
      case 'worship':
        page = const AzkarCategoriesScreen();
      case 'collections':
        page = const CollectionPage(collectionType: CollectionType.notes);
    }
    if (page != null) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page!));
    }
  }

  IconData _iconFor(String icon) {
    switch (icon) {
      case 'topics':
        return Icons.auto_stories_rounded;
      case 'mosque':
        return Icons.mosque_outlined;
      case 'collections':
        return Icons.collections_bookmark_outlined;
      default:
        return Icons.menu_book_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Islamic Knowledge'),
        centerTitle: true,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [scheme.primaryContainer, scheme.surfaceContainerHighest],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.auto_awesome_rounded, color: scheme.primary, size: 30),
                        const SizedBox(height: 14),
                        Text(
                          'Learn with purpose',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Explore Quran commentary, saved ayahs and worship resources already available in Imaanly.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search knowledge',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: _searchController.clear,
                              icon: const Icon(Icons.clear_rounded),
                            ),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_sections.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('No knowledge sections found')),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverList.separated(
                itemCount: _sections.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final section = _sections[index];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => _openSection(section),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: scheme.primaryContainer,
                                borderRadius: BorderRadius.circular(17),
                              ),
                              child: Icon(_iconFor(section.icon), color: scheme.primary),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(section.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
                                  const SizedBox(height: 5),
                                  Text(section.subtitle, style: TextStyle(color: scheme.onSurfaceVariant, height: 1.3)),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 17),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
