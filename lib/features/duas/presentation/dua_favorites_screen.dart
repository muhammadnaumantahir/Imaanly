import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// Local-first collection of saved Duas/Adhkar.
///
/// Entries are stored as plain maps in the existing `user` Hive box so this
/// feature does not duplicate or alter the mature Adhkar content source.
class DuaFavoritesScreen extends StatefulWidget {
  const DuaFavoritesScreen({super.key});

  @override
  State<DuaFavoritesScreen> createState() => _DuaFavoritesScreenState();
}

class _DuaFavoritesScreenState extends State<DuaFavoritesScreen> {
  static const _key = 'dua_favorites_v1';

  Box get _box => Hive.box('user');

  List<Map<String, dynamic>> get _favorites {
    final raw = _box.get(_key, defaultValue: <dynamic>[]);
    if (raw is! List) return <Map<String, dynamic>>[];
    return raw
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  void _remove(int index) {
    final items = _favorites;
    if (index < 0 || index >= items.length) return;
    items.removeAt(index);
    _box.put(_key, items);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final favorites = _favorites;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Favorites', style: TextStyle(fontWeight: FontWeight.w900)),
          centerTitle: true,
        ),
        body: favorites.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_border_rounded, size: 72, color: primary.withValues(alpha: .45)),
                      const SizedBox(height: 16),
                      const Text('No saved adhkar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the memorization star inside a dhikr to add it to favorites.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: favorites.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = favorites[index];
                  final text = item['zekr']?.toString() ?? '';
                  final category = item['category']?.toString() ?? 'Dua';
                  final reference = item['reference']?.toString() ?? '';
                  return Card(
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(category, style: TextStyle(color: primary, fontWeight: FontWeight.w900)),
                              ),
                              IconButton(
                                tooltip: 'Remove from favorites',
                                onPressed: () => _remove(index),
                                icon: Icon(Icons.star_rounded, color: primary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(text, textAlign: TextAlign.right, style: const TextStyle(fontSize: 21, height: 1.8, fontWeight: FontWeight.w700)),
                          if (reference.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(reference, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
