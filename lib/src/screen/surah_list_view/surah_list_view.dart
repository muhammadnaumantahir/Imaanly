import "dart:async";

import "package:imaanly/l10n/app_localizations.dart";

import "package:imaanly/src/screen/quran_script_view/quran_script_view.dart";
import "package:imaanly/src/utils/filter/filter_surah.dart";
import "package:imaanly/src/utils/number_localization.dart";
import "package:imaanly/src/resources/quran_resources/meaning_of_surah.dart";
import "package:imaanly/src/screen/surah_list_view/model/surah_info_model.dart";
import "package:imaanly/src/theme/values/values.dart";
import "package:imaanly/src/widget/components/get_surah_index_widget.dart";

import "package:fluentui_system_icons/fluentui_system_icons.dart";
import "package:flutter/material.dart";
import "package:imaanly/src/core/navigation/wahy_page_route.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:gap/gap.dart";
import "package:qcf_quran/qcf_quran.dart" as qcf;

import "../../theme/controller/theme_cubit.dart";

class SurahListView extends StatefulWidget {
  final List<SurahInfoModel> surahInfoList;
  final void Function(int page, String ayahKey)? onOpenLocation;

  const SurahListView({
    super.key,
    required this.surahInfoList,
    this.onOpenLocation,
  });

  @override
  State<SurahListView> createState() => _SurahListViewState();
}

class _SurahListViewState extends State<SurahListView> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    if (surahNameLocalization.isEmpty || surahMeaningLocalization.isEmpty) {
      loadMetaSurah().then((value) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Brightness brightness = Theme.of(context).brightness;
    final Color textColor =
        brightness == Brightness.light ? Colors.black : Colors.white;
    final Color secondaryTextColor =
        brightness == Brightness.light ? Colors.grey.shade600 : Colors.grey.shade400;
    final Color cardColor = brightness == Brightness.dark
        ? const Color(0xFF11332A)
        : const Color(0xFFF3F8F5);
    final Color borderColor =
        context.read<ThemeCubit>().state.primaryShade200.withValues(alpha: 0.65);
    final List<SurahInfoModel> filteredSurah = getFilteredSurah(
      context,
      searchController.text.trim(),
    );

    return (surahNameLocalization.isEmpty || surahMeaningLocalization.isEmpty)
        ? const Center(child: CircularProgressIndicator())
        : Scrollbar(
            controller: scrollController,
            radius: Radius.circular(roundedRadius),
            thickness: 8,
            interactive: true,
            child: ListView.builder(
              padding: EdgeInsets.only(
                bottom: 120,
                top: MediaQuery.of(context).padding.top + 3 + 40,
              ),
              itemCount: filteredSurah.length + 1,
              controller: scrollController,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(8, 5, 8, 8),
                    child: SearchBar(
                      elevation: WidgetStateProperty.all<double?>(0),
                      hintText: l10n.searchForASurah,
                      controller: searchController,
                      backgroundColor: WidgetStateProperty.all<Color?>(cardColor),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: borderColor),
                        ),
                      ),
                      leading: const Icon(FluentIcons.search_24_filled),
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onChanged: (value) {
                        _debounce?.cancel();
                        _debounce = Timer(
                          const Duration(milliseconds: 250),
                          () {
                            if (mounted) setState(() {});
                          },
                        );
                      },
                    ),
                  );
                }

                final surahIndex = index - 1;
                final surah = filteredSurah[surahIndex];
                final isMakkah = surah.revelationPlace == "makkah";
                final hasSajda = qcf.isSajdaVerse(surah.id, 1) ||
                    qcf.allSajdaVerses.any((s) => s.surah == surah.id);

                return Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        final onOpen = widget.onOpenLocation;
                        if (onOpen != null) {
                          onOpen(qcf.getPageNumber(surah.id, 1), "${surah.id}:1");
                          return;
                        }
                        Navigator.push(
                          context,
                          WahyPageRoute(
                            page: QuranScriptView(
                              startKey: "${surah.id}:1",
                              endKey: "${surah.id}:${surah.versesCount}",
                            ),
                          ),
                        );
                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                          child: Row(
                            children: [
                              getIndexNumberWidget(
                                context,
                                surah.id,
                                textColor: textColor,
                                height: 42,
                                width: 42,
                              ),
                              const Gap(12),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: Image.asset(
                                            isMakkah
                                                ? "assets/img/kaaba_10171102.png"
                                                : "assets/img/masjid-al-nabawi_16183907.png",
                                          ),
                                        ),
                                        const Gap(5),
                                        Flexible(
                                          child: Text(
                                            getSurahName(context, surah.id),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: textColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Gap(4),
                                    Text(
                                      getSurahMeaning(context, surah.id),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: secondaryTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Gap(8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "surah${surah.id.toString().padLeft(3, '0')}",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: textColor,
                                          fontFamily: "surah-name-v1",
                                        ),
                                      ),
                                      if (hasSajda)
                                        Padding(
                                          padding: const EdgeInsets.only(right: 4),
                                          child: Text(
                                            '۩',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: context.read<ThemeCubit>().state.primary,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const Gap(2),
                                  Text(
                                    l10n.ayahsCount(
                                      localizedNumber(context, surah.versesCount),
                                    ),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
  }
}
