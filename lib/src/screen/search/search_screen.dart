import "dart:async";

import "package:imaanly/src/core/audio/cubit/ayah_key_cubit.dart";
import "package:imaanly/src/screen/quran_script_view/cubit/ayah_to_highlight.dart";
import "package:imaanly/src/core/audio/services/idrisium_audio_tracker.dart";
import "package:imaanly/src/theme/controller/theme_cubit.dart";
import "package:imaanly/src/theme/controller/theme_state.dart";
import "package:imaanly/src/utils/number_localization.dart";
import "package:imaanly/src/utils/quran_search_engine.dart";
import "package:fluentui_system_icons/fluentui_system_icons.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:gap/gap.dart";
import "package:hive_ce_flutter/hive_flutter.dart";
import "package:qcf_quran/qcf_quran.dart" as qcf;
import "package:imaanly/src/widget/share/unified_share_bottom_sheet.dart";

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final ValueNotifier<List<Map<String, dynamic>>> _resultsVN =
      ValueNotifier<List<Map<String, dynamic>>>(const []);
  final ValueNotifier<bool> _hasSearchedVN = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isSearchingVN = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isExactSearchVN = ValueNotifier<bool>(true);
  final ValueNotifier<int?> _filterSurahIdVN = ValueNotifier<int?>(null);

  Timer? _debounce;
  List<String> _searchHistory = <String>[];

  static const String _kHistoryKey = "search_history";
  static const int _maxHistory = 8;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _pageBg =>
      _isDark ? const Color(0xFF071E18) : const Color(0xFFF3F8F5);
  Color get _cardBg =>
      _isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFFFFFFF);
  Color get _cardBorder => _isDark
      ? Colors.white.withValues(alpha: 0.08)
      : Colors.black.withValues(alpha: 0.06);
  Color get _textPrimary => _isDark ? Colors.white : const Color(0xFF0C281F);

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    _resultsVN.dispose();
    _hasSearchedVN.dispose();
    _isSearchingVN.dispose();
    _isExactSearchVN.dispose();
    _filterSurahIdVN.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    final rawQuery = query.trim();
    final normalizedQuery = normalizeQuranSearchQuery(rawQuery);

    if (rawQuery.isEmpty || normalizedQuery.length < 2) {
      if (!mounted) return;
      _resultsVN.value = const <Map<String, dynamic>>[];
      _hasSearchedVN.value = false;
      _isSearchingVN.value = false;
      return;
    }

    _isSearchingVN.value = true;
    final results = await searchQuranAyahs(rawQuery, exactPhrase: _isExactSearchVN.value, surahId: _filterSurahIdVN.value, limit: 150);
    if (!mounted) return;

    _resultsVN.value = results;
    _hasSearchedVN.value = true;
    _isSearchingVN.value = false;

    if (results.isNotEmpty) {
      _saveToHistory(rawQuery);
    }
  }

  void _queueSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 180),
      () => _performSearch(value),
    );
  }

  void _loadHistory() {
    final box = Hive.box("user");
    final raw = box.get(_kHistoryKey);
    if (raw is List) {
      _searchHistory = raw.cast<String>().toList();
    }
  }

  void _saveToHistory(String query) {
    _searchHistory.remove(query);
    _searchHistory.insert(0, query);
    if (_searchHistory.length > _maxHistory) {
      _searchHistory = _searchHistory.sublist(0, _maxHistory);
    }
    Hive.box("user").put(_kHistoryKey, _searchHistory);
    if (mounted) {
      setState(() {});
    }
  }

  void _applySuggestion(String value) {
    _searchController.text = value;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: value.length),
    );
    _performSearch(value);
  }

  void _removeFromHistory(String query) {
    _searchHistory.remove(query);
    Hive.box("user").put(_kHistoryKey, _searchHistory);
    if (mounted) setState(() {});
  }

  void _toggleExactSearch() {
    _isExactSearchVN.value = !_isExactSearchVN.value;
    _performSearch(_searchController.text);
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
            height: MediaQuery.of(ctx).size.height * 0.7,
            decoration: const BoxDecoration(
              color: Color(0xFFF3F8F5),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(4)),
                ),
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Customize search scope",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: 115,
                    itemBuilder: (context, i) {
                      final isAll = i == 0;
                      final surahId = isAll ? null : i;
                      final surahName = isAll ? "The entire Holy Quran" : "${qcf.getSurahNameArabic(surahId!)} ($surahId)";
                      final isSelected = _filterSurahIdVN.value == surahId;
                      return ListTile(
                        leading: isAll ? const Icon(Icons.menu_book) : null,
                        title: Text(
                          surahName,
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF0F7A5C) : Colors.black,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                            fontFamily: "QPC_Hafs",
                          ),
                        ),
                        trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF0F7A5C)) : null,
                        onTap: () {
                          _filterSurahIdVN.value = surahId;
                          _performSearch(_searchController.text);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToAyah(BuildContext context, int surah, int ayah) {
    HapticFeedback.lightImpact();
    final key = "$surah:$ayah";
    final page = qcf.getPageNumber(surah, ayah);

    context.read<AyahKeyCubit>().changeLastScrolledPage(page);
    final isAudioPlaying = context.read<AudioAyahHighlightCubit>().state.activeAyahKey != null;
    if (!isAudioPlaying) {
      context.read<AyahKeyCubit>().changeCurrentAyahKey(key);
      context.read<AyahToHighlight>().changeAyah(key);
    }

    Future<void>.delayed(const Duration(seconds: 2), () {
      if (!context.mounted) return;
      if (!isAudioPlaying && context.read<AyahToHighlight>().state == key) {
        context.read<AyahToHighlight>().changeAyah(null);
      }
    });

    Navigator.of(context).pop(<String, dynamic>{"page": page, "key": key});
  }

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeCubit>().state;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
              child: Container(
                clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: _pageBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  _buildSearchBarRow(themeState),
                  Divider(color: _cardBorder, height: 1, thickness: 1),
                  Expanded(
                    child: _buildBody(themeState),
                  ),
                ],
              ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBarRow(ThemeState themeState) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Color(0xFF4B6B5E), size: 28),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const Gap(16),
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: _cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _cardBorder, width: 1.5),
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    textAlign: TextAlign.center,
                    textInputAction: TextInputAction.search,
                    enableSuggestions: false,
                    autocorrect: false,
                    style: TextStyle(
                      color: _textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      prefixIcon: ValueListenableBuilder<bool>(
                        valueListenable: _isSearchingVN,
                        builder: (context, isSearching, _) {
                          if (isSearching) {
                            return const Padding(
                              padding: EdgeInsets.all(14),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1FA37A)),
                              ),
                            );
                          }
                          return const Icon(FluentIcons.search_24_regular, color: Color(0xFF1FA37A), size: 24);
                        },
                      ),
                      suffixIcon: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _searchController,
                        builder: (context, value, _) {
                          if (value.text.isEmpty) return const SizedBox.shrink();
                          return IconButton(
                            icon: const Icon(Icons.close, color: Color(0xFF86A094), size: 22),
                            onPressed: () {
                              _searchController.clear();
                              _performSearch("");
                            },
                          );
                        },
                      ),
                    ),
                    onChanged: _queueSearch,
                    onSubmitted: _performSearch,
                  ),
                ),
              ),
              const Gap(16),
              ValueListenableBuilder<int?>(
                valueListenable: _filterSurahIdVN,
                builder: (context, surahId, _) {
                  return IconButton(
                    onPressed: _showFilterSheet,
                    icon: Icon(
                      surahId == null ? Icons.tune : Icons.filter_alt_off_rounded,
                      size: 28,
                      color: surahId == null ? const Color(0xFF4B6B5E) : const Color(0xFF0F7A5C),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpiderWebHistory() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FluentIcons.search_24_regular, size: 56, color: const Color(0xFF4B6B5E).withValues(alpha: 0.4)),
              const Gap(16),
              const Text("Search the ayahs of the Holy Quran", style: TextStyle(color: Color(0xFF4B6B5E), fontSize: 17, fontWeight: FontWeight.w800)),
              const Gap(8),
              const Text(
                "You can search by any word or phrase",
                style: TextStyle(color: Color(0xFF86A094), fontSize: 13),
              ),
              if (_searchHistory.isNotEmpty) ...[
                const Gap(28),
                const Text(
                  "Recent searches",
                  style: TextStyle(color: Color(0xFF4B6B5E), fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 12,
                  children: _searchHistory.map((query) {
                    return InputChip(
                      onPressed: () => _applySuggestion(query),
                      onDeleted: () => _removeFromHistory(query),
                      deleteIcon: const Icon(Icons.close, size: 16, color: Color(0xFF86A094)),
                      label: Text(
                        query,
                        style: const TextStyle(color: Color(0xFF0E1F1A), fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      backgroundColor: const Color(0xFFE3EEE8),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    );
                  }).toList(),
                ),
              ],
              const Gap(28),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3EEE8).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: const [
                    Text("💡 Tips", style: TextStyle(color: Color(0xFF4B6B5E), fontSize: 14, fontWeight: FontWeight.w800)),
                    Gap(8),
                    Text(
                      "• Turn on \"Exact match\" to search for an exact phrase\n• Long-press a result to copy or share it\n• Use the filter icon to limit the search to a specific surah",
                      style: TextStyle(color: Color(0xFF6B7F77), fontSize: 12, height: 1.8),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(ThemeState themeState, List<Map<String, dynamic>> results) {
    int surahsCount = 0;
    int ayahsCount = 0;
    int occurrences = 0;

    final query = _searchController.text.trim();
    final normQ = normalizeQuranSearchQuery(query);

    if (results.isNotEmpty && normQ.isNotEmpty) {
      surahsCount = results.map((e) => e["surah_number"]).toSet().length;
      ayahsCount = results.length;
      for (var res in results) {
        final text = normalizeQuranSearchQuery(res["content"] ?? "");
        int matched = 0;
        int idx = -1;
        while ((idx = text.indexOf(normQ, idx + 1)) != -1) {
          matched++;
        }
        occurrences += matched;
      }
    }

    return ValueListenableBuilder<bool>(
      valueListenable: _isExactSearchVN,
      builder: (context, isExactSearch, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (results.isNotEmpty)
                Text(
                  "Surahs: $surahsCount, Ayahs: $ayahsCount (word repeats: $occurrences)",
                  style: const TextStyle(color: Color(0xFF3C524A), fontSize: 11, fontWeight: FontWeight.w700),
                )
              else
                const SizedBox.shrink(),
              GestureDetector(
                onTap: _toggleExactSearch,
                child: Row(
                  children: [
                    Icon(
                      isExactSearch ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: isExactSearch ? const Color(0xFF0F7A5C) : const Color(0xFF4B6B5E),
                      size: 18,
                    ),
                    const Gap(6),
                    Text(
                      "Exact match",
                      style: TextStyle(
                        color: isExactSearch ? Colors.black : const Color(0xFF3C524A),
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(ThemeState themeState) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _searchController,
      builder: (context, val, _) {
        final isTyping = val.text.isNotEmpty;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              fit: StackFit.expand,
              children: <Widget>[
                ...previousChildren,
                ?currentChild,
              ],
            );
          },
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.96, end: 1.0).animate(animation),
                child: child,
              ),
            );
          },
          child: isTyping ? _buildActiveSearchState(themeState, key: const ValueKey("active")) : _buildSpiderWebHistory(),
        );
      },
    );
  }

  Widget _buildActiveSearchState(ThemeState themeState, {Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: _resultsVN,
          builder: (context, results, _) => _buildStatsRow(themeState, results),
        ),
        Expanded(
          child: ValueListenableBuilder<bool>(
            valueListenable: _hasSearchedVN,
            builder: (context, hasSearched, _) {
              return ValueListenableBuilder<bool>(
                valueListenable: _isSearchingVN,
                builder: (context, isSearching, _) {
                  return ValueListenableBuilder<List<Map<String, dynamic>>>(
                    valueListenable: _resultsVN,
                    builder: (context, results, _) {
                      final query = _searchController.text.trim();

                      Widget child;
                      if (query.isNotEmpty && normalizeQuranSearchQuery(query).length < 2) {
                        child = const SizedBox.shrink();
                      } else if (isSearching) {
                        child = const Center(
                          child: CircularProgressIndicator(color: Color(0xFF1FA37A)),
                        );
                      } else if (hasSearched && results.isEmpty) {
                        child = Center(
                          child: Text(
                            "No results",
                            style: TextStyle(color: Color(0xFF4B6B5E), fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                        );
                      } else if (hasSearched && results.isNotEmpty) {
                        child = _buildResultsState(themeState, results, query);
                      } else {
                        child = const SizedBox.shrink();
                      }

                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: child,
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResultsState(
    ThemeState themeState,
    List<Map<String, dynamic>> results,
    String query,
  ) {
    final normQ = normalizeQuranSearchQuery(query);
    int? matchedSurahId;

    for (int i = 1; i <= 114; i++) {
      if (normalizeQuranSearchQuery(qcf.getSurahNameArabic(i)) == normQ) {
        matchedSurahId = i;
        break;
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 40),
      itemCount: results.length + (matchedSurahId != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (matchedSurahId != null && index == 0) {
          return _buildSurahInfoCard(matchedSurahId);
        }

        final result = results[matchedSurahId != null ? index - 1 : index];
        final surahNumber = (result["surah_number"] as num?)?.toInt() ?? 1;
        final ayahNumber = (result["verse_number"] as num?)?.toInt() ?? 1;
        final surahName = qcf.getSurahNameArabic(surahNumber);
        final content = (result["content"] as String?) ?? "";
        final pageNumber = qcf.getPageNumber(surahNumber, ayahNumber);

        return ValueListenableBuilder<bool>(
          valueListenable: _isExactSearchVN,
          builder: (context, isExactSearch, _) {
            return _VerseResultCard(
              surahName: surahName,
              surahNumber: surahNumber,
              ayahNumber: ayahNumber,
              pageNumber: pageNumber,
              content: content,
              query: query,
              isExactSearch: isExactSearch,
              onTap: () => _navigateToAyah(context, surahNumber, ayahNumber),
            );
          },
        );
      },
    );
  }

  Widget _buildSurahInfoCard(int surahNum) {
    final verseCount = qcf.quranText.where((e) => (e['surah_number'] as num).toInt() == surahNum).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _IslamicStar(number: surahNum, color: const Color(0xFF1FA37A)),
              const Gap(16),
              Text(
                qcf.getSurahNameArabic(surahNum),
                style: TextStyle(
                  fontFamily: "QPC_Hafs",
                  fontSize: 26,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "${localizedNumber(context, verseCount)} ayahs",
                style: const TextStyle(color: Color(0xFF86A094), fontSize: 13, fontWeight: FontWeight.w800),
              ),
              const Gap(6),
              Text(
                "Page ${localizedNumber(context, qcf.getPageNumber(surahNum, 1))}",
                style: const TextStyle(color: Color(0xFF86A094), fontSize: 13, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: Color(0xFFE3EEE8), shape: BoxShape.circle),
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationZ(3.1415),
                  child: const Icon(Icons.send_rounded, color: Color(0xFF1FA37A), size: 16),
                ),
              ),
              const Gap(12),
              Icon(FluentIcons.building_mosque_24_filled, color: _textPrimary, size: 28),
            ],
          ),
        ],
      ),
    );
  }
}

class _VerseResultCard extends StatelessWidget {
  final String surahName;
  final int surahNumber;
  final int ayahNumber;
  final int pageNumber;
  final String content;
  final String query;
  final bool isExactSearch;
  final VoidCallback onTap;

  const _VerseResultCard({
    required this.surahName,
    required this.surahNumber,
    required this.ayahNumber,
    required this.pageNumber,
    required this.content,
    required this.query,
    required this.isExactSearch,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white;
    final cardBorder = isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFD3E2DA);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0E1F1A);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: () => _showActionsMenu(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SearchHighlightedText(
                        text: content,
                        searchQuery: query,
                        isExactSearch: isExactSearch,
                        textStyle: TextStyle(
                          fontFamily: "QPC_Hafs",
                          fontSize: 22,
                          height: 1.7,
                          color: textPrimary,
                        ),
                        highlightColor: const Color(0xFF2F9BB5),
                      ),
                    ),
                    const Gap(16),
                    Column(
                      children: [
                        _IslamicStar(number: ayahNumber, color: const Color(0xFF1FA37A)),
                        const Gap(6),
                        Text(
                          "$surahNumber. $surahName",
                          style: const TextStyle(
                            color: Color(0xFF6B7F77),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Gap(8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Page $pageNumber",
                      style: const TextStyle(color: Color(0xFF86A094), fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () => _copyAyah(context),
                          child: const Icon(Icons.copy_rounded, size: 18, color: Color(0xFF86A094)),
                        ),
                        const Gap(16),
                        GestureDetector(
                          onTap: () => _shareAyah(context),
                          child: const Icon(Icons.share_outlined, size: 18, color: Color(0xFF86A094)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _copyAyah(BuildContext context) {
    final ayahText = "$content\n\n— $surahName: $ayahNumber";
    Clipboard.setData(ClipboardData(text: ayahText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Ayah copied ✓", style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: const Color(0xFF0F7A5C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareAyah(BuildContext context) {
    UnifiedShareBottomSheet.show(
      context: context,
      surahNumber: surahNumber,
      verseNumber: ayahNumber,
      getAyahText: (surah, verse) => content,
    );
  }

  void _showActionsMenu(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF3F8F5),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(4)),
                ),
                const Gap(16),
                Text(
                  "$surahName — Ayah $ayahNumber",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0E1F1A)),
                ),
                const Gap(16),
                ListTile(
                  leading: const Icon(Icons.copy_rounded, color: Color(0xFF0F7A5C)),
                  title: const Text("Copy ayah", style: TextStyle(fontWeight: FontWeight.w700)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _copyAyah(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.share_outlined, color: Color(0xFF2F9BB5)),
                  title: const Text("Share ayah", style: TextStyle(fontWeight: FontWeight.w700)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _shareAyah(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF1FA37A)),
                  title: const Text("Go to ayah in Mushaf", style: TextStyle(fontWeight: FontWeight.w700)),
                  onTap: () {
                    Navigator.pop(ctx);
                    onTap();
                  },
                ),
                const Gap(8),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _IslamicStar extends StatelessWidget {
  final int number;
  final Color color;

  const _IslamicStar({required this.number, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: 0,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Transform.rotate(
            angle: 3.14159 / 4,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Text(
            "$number",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              fontFamily: "Roboto",
            ),
          ),
        ],
      ),
    );
  }
}

class SearchHighlightedText extends StatelessWidget {
  final String text;
  final String searchQuery;
  final bool isExactSearch;
  final TextStyle textStyle;
  final Color highlightColor;

  const SearchHighlightedText({
    super.key,
    required this.text,
    required this.searchQuery,
    required this.isExactSearch,
    required this.textStyle,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    if (searchQuery.trim().isEmpty) {
      return Text(text, style: textStyle, textAlign: TextAlign.right);
    }

    final queryTokens = normalizeQuranSearchQuery(searchQuery)
        .split(' ')
        .where((t) => t.isNotEmpty)
        .toList();

    if (queryTokens.isEmpty) {
      return Text(text, style: textStyle, textAlign: TextAlign.right);
    }

    final originalWords = text.split(' ');
    final normWords = originalWords.map(normalizeQuranSearchQuery).toList();
    final highlightIndices = <int>{};

    if (isExactSearch) {
      for (int i = 0; i <= normWords.length - queryTokens.length; i++) {
        bool match = true;
        for (int j = 0; j < queryTokens.length; j++) {
          if (normWords[i + j] != queryTokens[j]) {
            match = false;
            break;
          }
        }
        if (match) {
          for (int j = 0; j < queryTokens.length; j++) {
            highlightIndices.add(i + j);
          }
        }
      }
    } else {
      for (int i = 0; i < normWords.length; i++) {
        final w = normWords[i];
        for (final t in queryTokens) {
          if (w.contains(t)) {
            highlightIndices.add(i);
            break;
          }
        }
      }
    }

    final spans = <TextSpan>[];
    for (int i = 0; i < originalWords.length; i++) {
      final shouldHighlight = highlightIndices.contains(i);

      spans.add(
        TextSpan(
          text: originalWords[i] + (i == originalWords.length - 1 ? "" : " "),
          style: shouldHighlight
              ? textStyle.copyWith(
                  backgroundColor: highlightColor.withValues(alpha: 0.15),
                  color: highlightColor,
                  fontWeight: FontWeight.w900,
                )
              : textStyle,
        ),
      );
    }

    return Text.rich(
      TextSpan(children: spans),
      textAlign: TextAlign.right,
    );
  }
}

