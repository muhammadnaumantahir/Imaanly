import 'package:flutter/material.dart';
import '../domain/hadith_catalog.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});
  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  final _search = TextEditingController();
  List<HadithItem> _items = HadithCatalog.items;

  @override
  void initState() { super.initState(); _search.addListener(_filter); }
  @override
  void dispose() { _search.removeListener(_filter); _search.dispose(); super.dispose(); }
  void _filter() => setState(() => _items = HadithCatalog.search(_search.text));

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Hadith'), centerTitle: true),
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(16), child: TextField(controller: _search, decoration: InputDecoration(hintText: 'Search hadith', prefixIcon: const Icon(Icons.search_rounded), suffixIcon: _search.text.isEmpty ? null : IconButton(onPressed: _search.clear, icon: const Icon(Icons.clear_rounded)), filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none))))),
        if (_items.isEmpty) const SliverFillRemaining(hasScrollBody: false, child: Center(child: Text('No hadith found')))
        else SliverPadding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 32), sliver: SliverList.separated(itemCount: _items.length, separatorBuilder: (_, _) => const SizedBox(height: 12), itemBuilder: (_, i) {
          final item = _items[i];
          return Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Expanded(child: Text(item.title, style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w900, fontSize: 17))), Icon(Icons.format_quote_rounded, color: scheme.primary)]),
            const SizedBox(height: 14), Text(item.text, style: const TextStyle(fontSize: 18, height: 1.65, fontWeight: FontWeight.w600)),
            const SizedBox(height: 14), Text(item.source, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w700)),
          ])));
        }))
      ]),
    );
  }
}
