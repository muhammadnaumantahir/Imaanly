import 'dart:convert';

import 'package:imaanly/src/core/constants/wahy_assets.dart';
import 'package:imaanly/src/screen/azkar/azkar_detail_screen.dart';
import 'package:imaanly/src/theme/controller/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'azkar_category_names.dart';
import 'azkar_meanings.dart';
import 'azkar_translations.dart';

class AzkarCategoriesScreen extends StatefulWidget {
  final String? initialCategory;

  const AzkarCategoriesScreen({super.key, this.initialCategory});

  @override
  State<AzkarCategoriesScreen> createState() => _AzkarCategoriesScreenState();
}

class _AzkarCategoriesScreenState extends State<AzkarCategoriesScreen> {
  bool _isLoading = true;
  bool _hasAutoOpened = false;
  List<Map<String, dynamic>> _allAzkar = const [];
  List<String> _categories = const [];
  String? _errorMessage;
  String _query = '';
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadAzkarData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAzkarData() async {
    try {
      final raw = await rootBundle.loadString(WahyAssets.jsonAzkar);
      final decoded = json.decode(raw);
      final list = List<Map<String, dynamic>>.from(decoded['data']);
      // The stored explanations and sources are Arabic; show their English translations.
      for (final item in list) {
        item['description'] = azkarDescriptionText(item['description']?.toString());
        item['reference'] = azkarReferenceText(item['reference']?.toString());
        item['meaning'] = azkarMeaningText(item['zekr']?.toString());
      }
      final categories = <String>[];

      for (final item in list) {
        final category = item['category']?.toString().trim();
        if (category != null && category.isNotEmpty && !categories.contains(category)) {
          categories.add(category);
        }
      }

      if (!mounted) return;
      setState(() {
        _allAzkar = list;
        _categories = categories;
        _isLoading = false;
        _errorMessage = categories.isEmpty ? 'No adhkar available right now' : null;
      });

      final target = widget.initialCategory;
      if (target != null && !_hasAutoOpened && categories.contains(target)) {
        _hasAutoOpened = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _openCategory(target);
        });
      }
    } catch (e) {
      debugPrint('Error loading azkar: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred while loading adhkar';
      });
    }
  }

  List<String> get _filteredCategories {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _categories;
    return _categories.where((category) => category.toLowerCase().contains(query) || azkarCategoryTitle(category).toLowerCase().contains(query)).toList();
  }

  int _countFor(String category) =>
      _allAzkar.where((item) => item['category']?.toString() == category).length;

  void _openCategory(String category) {
    final filtered = _allAzkar
        .where((item) => item['category']?.toString() == category)
        .toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AzkarDetailScreen(
          categoryName: category,
          azkarList: filtered,
          primary: context.read<ThemeCubit>().state.primary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = context.read<ThemeCubit>().state.primary;
    final isDark = theme.brightness == Brightness.dark;
    final background = isDark ? const Color(0xFF071E18) : const Color(0xFFF3F8F5);
    final surface = isDark ? const Color(0xFF0E2E25) : Colors.white;
    final text = isDark ? Colors.white : const Color(0xFF0E1F1A);
    final muted = isDark ? Colors.white60 : const Color(0xFF6B7F77);
    final filtered = _filteredCategories;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: background,
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: primary))
            : _errorMessage != null
                ? _buildError(primary, text)
                : RefreshIndicator(
                    color: primary,
                    onRefresh: _loadAzkarData,
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      slivers: [
                        SliverToBoxAdapter(child: _buildHero(primary, text, muted, isDark)),
                        SliverToBoxAdapter(child: _buildSearch(primary, surface, text, muted)),
                        if (_query.trim().isEmpty && _categories.isNotEmpty)
                          SliverToBoxAdapter(
                            child: _buildFeatured(primary, surface, text, muted),
                          ),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 18, 16, 40),
                          sliver: SliverToBoxAdapter(
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _query.isEmpty ? 'All adhkar' : 'Search results',
                                  style: TextStyle(
                                    color: text,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${filtered.length} groups',
                                  style: TextStyle(color: muted, fontSize: 12, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (filtered.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Text(
                                'No adhkar found with that name',
                                style: TextStyle(color: muted, fontWeight: FontWeight.w700),
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                            sliver: SliverGrid(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => _buildCategoryCard(
                                  category: filtered[index],
                                  count: _countFor(filtered[index]),
                                  primary: primary,
                                  surface: surface,
                                  text: text,
                                  muted: muted,
                                  index: index,
                                  onTap: () => _openCategory(filtered[index]),
                                ),
                                childCount: filtered.length,
                              ),
                              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 260,
                                mainAxisExtent: 142,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildHero(Color primary, Color text, Color muted, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 52, 16, 14),
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: isDark
              ? const [Color(0xFF14604A), Color(0xFF082B22)]
              : const [Color(0xFF0F7A5C), Color(0xFF063D2E)],
        ),
        boxShadow: [
          BoxShadow(color: const Color(0xFF063D2E).withValues(alpha: 0.28), blurRadius: 28, offset: const Offset(0, 12)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: -30,
            bottom: -55,
            child: Icon(Icons.auto_awesome_rounded, size: 150, color: Colors.white.withValues(alpha: 0.06)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  ),
                  const Spacer(),
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFFE2BC6B), size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Muslim Adhkar',
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 5),
              Text(
                'Remember Allah with a present heart, at all times.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.82), fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _heroStat(Icons.menu_book_rounded, '${_allAzkar.length}', 'Adhkar'),
                  const SizedBox(width: 22),
                  _heroStat(Icons.category_rounded, '${_categories.length}', 'Groups'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStat(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 18),
        const SizedBox(width: 6),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.72), fontSize: 12, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildSearch(Color primary, Color surface, Color text, Color muted) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _query = value),
        style: TextStyle(color: text, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: 'Search adhkar groups...',
          hintStyle: TextStyle(color: muted, fontSize: 13),
          prefixIcon: Icon(Icons.search_rounded, color: primary),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                  icon: Icon(Icons.close_rounded, color: muted),
                ),
          filled: true,
          fillColor: surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: primary.withValues(alpha: 0.45), width: 1.3),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildFeatured(Color primary, Color surface, Color text, Color muted) {
    final morning = _categories.cast<String?>().firstWhere(
      (category) => category?.contains('الصباح') ?? false,
      orElse: () => null,
    );
    final evening = _categories.cast<String?>().firstWhere(
      (category) => category?.contains('المساء') ?? false,
      orElse: () => null,
    );
    final featured = [?morning, ?evening];
    if (featured.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 132,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: featured.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, index) {
          final category = featured[index];
          final isMorning = category.contains('الصباح');
          return _buildFeaturedCard(category, isMorning, primary, surface, text, muted);
        },
      ),
    );
  }

  Widget _buildFeaturedCard(String category, bool isMorning, Color primary, Color surface, Color text, Color muted) {
    final accent = isMorning ? const Color(0xFFE6A23C) : primary;
    return SizedBox(
      width: 245,
      child: Material(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () => _openCategory(category),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(color: accent.withValues(alpha: 0.12), shape: BoxShape.circle),
                  child: Icon(isMorning ? Icons.wb_sunny_rounded : Icons.nightlight_round, color: accent, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(azkarCategoryTitle(category), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: text, fontWeight: FontWeight.w900, fontSize: 15)),
                      const SizedBox(height: 5),
                      Text(adhkarCountLabel(_countFor(category)), style: TextStyle(color: muted, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 15, color: muted),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required String category,
    required int count,
    required Color primary,
    required Color surface,
    required Color text,
    required Color muted,
    required int index,
    required VoidCallback onTap,
  }) {
    final icon = _iconFor(category);
    final tint = _accentFor(index, primary);
    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: tint.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: tint, size: 25),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_back_rounded, color: muted, size: 18),
                ],
              ),
              const Spacer(),
              Text(
                azkarCategoryTitle(category),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: text, fontSize: 15, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(adhkarCountLabel(count), style: TextStyle(color: tint, fontSize: 11, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(String category) {
    if (category.contains('الصباح')) return Icons.wb_sunny_rounded;
    if (category.contains('المساء')) return Icons.nightlight_round;
    if (category.contains('النوم')) return Icons.bedtime_rounded;
    if (category.contains('الصلاة')) return Icons.mosque_rounded;
    if (category.contains('الأذان')) return Icons.notifications_active_rounded;
    if (category.contains('الوضوء') || category.contains('الطهارة')) return Icons.water_drop_rounded;
    if (category.contains('المنزل') || category.contains('البيت')) return Icons.home_rounded;
    if (category.contains('الخروج') || category.contains('السفر')) return Icons.luggage_rounded;
    if (category.contains('الطعام') || category.contains('الأكل')) return Icons.restaurant_rounded;
    if (category.contains('الحزن') || category.contains('الهم')) return Icons.favorite_rounded;
    return Icons.auto_awesome_rounded;
  }

  Color _accentFor(int index, Color primary) {
    const accents = [
      Color(0xFF0F7A5C),
      Color(0xFFC9A24B),
      Color(0xFF4C5FD5),
      Color(0xFF8A5A9E),
      Color(0xFF2F9BB5),
      Color(0xFFB07A4A),
    ];
    return index < accents.length ? accents[index] : primary;
  }

  Widget _buildError(Color primary, Color text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_rounded, color: primary, size: 58),
            const SizedBox(height: 16),
            Text(_errorMessage ?? 'Couldn\'t load adhkar', textAlign: TextAlign.center, style: TextStyle(color: text, fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () {
                setState(() => _isLoading = true);
                _loadAzkarData();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: FilledButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
