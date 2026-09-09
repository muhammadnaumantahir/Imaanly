import 'package:flutter/material.dart';
import '../domain/sunnah_catalog.dart';

class SunnahScreen extends StatefulWidget {
  const SunnahScreen({super.key});

  @override
  State<SunnahScreen> createState() => _SunnahScreenState();
}

class _SunnahScreenState extends State<SunnahScreen> {
  final _searchController = TextEditingController();
  List<SunnahItem> _items = SunnahCatalog.items;

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
    setState(() => _items = SunnahCatalog.search(_searchController.text));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Sunnah & Adab'), centerTitle: true),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                children: [
                  Text('Simple daily practices with references for further reading.', textAlign: TextAlign.center, style: TextStyle(color: scheme.onSurfaceVariant, height: 1.4)),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search Sunnah & adab',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isEmpty ? null : IconButton(onPressed: _searchController.clear, icon: const Icon(Icons.clear_rounded)),
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_items.isEmpty)
            const SliverFillRemaining(hasScrollBody: false, child: Center(child: Text('No practices found')))
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverList.separated(
                itemCount: _items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Card(
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Container(width: 42, height: 42, decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(14)), child: Icon(Icons.auto_awesome_rounded, color: scheme.primary)),
                            const SizedBox(width: 12),
                            Expanded(child: Text(item.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900))),
                          ]),
                          const SizedBox(height: 14),
                          Text(item.practice, style: const TextStyle(fontSize: 16, height: 1.55)),
                          const SizedBox(height: 12),
                          Text(item.source, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: scheme.primary)),
                        ],
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
