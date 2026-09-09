import 'package:flutter/material.dart';
import 'package:qcf_quran/qcf_quran.dart';

/// Double-page (side-by-side) Mushaf layout.
///
/// Displays two Quran pages next to each other in a horizontal [PageView],
/// similar to reading a physical Mushaf. Each "spread" shows pages
/// (right = odd, left = even) in RTL order.
class DoublePageMushaf extends StatefulWidget {
  final PageController controller;
  final int initialPageNumber;
  final double sp;
  final double h;
  final double? fontSize;
  final QcfThemeData theme;
  final Color? Function(int surah, int verse)? verseBackgroundColor;
  final List<HighlightRange> Function(int surah, int verse)? highlightsBuilder;
  final void Function(int surah, int verse, TapDownDetails details)? onTapDown;
  final void Function(int surah, int verse)? onTap;
  final void Function(int surah, int verse, LongPressStartDetails details)? onLongPressDown;
  final void Function(int surah, int verse)? onLongPress;
  final void Function(int surah, int verse)? onLongPressUp;
  final void Function(int surah, int verse)? onLongPressCancel;
  final void Function(int surah, int verse)? onDoubleTap;
  final ValueChanged<int>? onPageChanged;
  final bool pageBgIsDark;

  const DoublePageMushaf({super.key,
    required this.controller,
    required this.initialPageNumber,
    required this.sp,
    required this.h,
    this.fontSize,
    required this.theme,
    this.verseBackgroundColor,
    this.highlightsBuilder,
    this.onTapDown,
    this.onTap,
    this.onLongPressDown,
    this.onLongPress,
    this.onLongPressUp,
    this.onLongPressCancel,
    this.onDoubleTap,
    this.onPageChanged,
    required this.pageBgIsDark,
  });

  @override
  State<DoublePageMushaf> createState() => _DoublePageMushafState();
}

class _DoublePageMushafState extends State<DoublePageMushaf> {
  static const int _totalSpreads = 303;

  static int pageToSpread(int pageNumber) {
    if (pageNumber <= 1) return 0;
    return 1 + ((pageNumber - 2) ~/ 2);
  }

  static (int, int?) spreadToPages(int spreadIndex) {
    if (spreadIndex == 0) return (1, null);
    final rightPage = 2 + (spreadIndex - 1) * 2;
    final leftPage = rightPage + 1;
    return (rightPage, leftPage > 604 ? null : leftPage);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: PageView.builder(
        controller: PageController(initialPage: pageToSpread(widget.initialPageNumber)),
        physics: const ClampingScrollPhysics(),
        itemCount: _totalSpreads,
        onPageChanged: (spreadIndex) {
          final (rightPage, _) = spreadToPages(spreadIndex);
          widget.onPageChanged?.call(rightPage);
        },
        itemBuilder: (context, spreadIndex) {
          final (rightPage, leftPage) = spreadToPages(spreadIndex);
          return Row(
            children: [
              Expanded(child: RepaintBoundary(child: QcfPage(
                pageNumber: rightPage, sp: widget.sp, h: widget.h, fontSize: widget.fontSize,
                theme: widget.theme, verseBackgroundColor: widget.verseBackgroundColor,
                highlightsBuilder: widget.highlightsBuilder, onTapDown: widget.onTapDown,
                onTap: widget.onTap, onLongPressDown: widget.onLongPressDown,
                onLongPress: widget.onLongPress, onLongPressUp: widget.onLongPressUp,
                onLongPressCancel: widget.onLongPressCancel, onDoubleTap: widget.onDoubleTap,
              ))),
              Container(width: 1, color: widget.theme.verseTextColor.withValues(alpha: 0.08)),
              Expanded(child: leftPage != null ? RepaintBoundary(child: QcfPage(
                pageNumber: leftPage, sp: widget.sp, h: widget.h, fontSize: widget.fontSize,
                theme: widget.theme, verseBackgroundColor: widget.verseBackgroundColor,
                highlightsBuilder: widget.highlightsBuilder, onTapDown: widget.onTapDown,
                onTap: widget.onTap, onLongPressDown: widget.onLongPressDown,
                onLongPress: widget.onLongPress, onLongPressUp: widget.onLongPressUp,
                onLongPressCancel: widget.onLongPressCancel, onDoubleTap: widget.onDoubleTap,
              )) : const SizedBox.expand()),
            ],
          );
        },
      ),
    );
  }
}

class ContinuousScrollMushaf extends StatefulWidget {
  final PageController controller;
  final int initialPageNumber;
  final double sp;
  final double h;
  final double? fontSize;
  final QcfThemeData theme;
  final Color? Function(int surah, int verse)? verseBackgroundColor;
  final List<HighlightRange> Function(int surah, int verse)? highlightsBuilder;
  final void Function(int surah, int verse, TapDownDetails details)? onTapDown;
  final void Function(int surah, int verse)? onTap;
  final void Function(int surah, int verse, LongPressStartDetails details)? onLongPressDown;
  final void Function(int surah, int verse)? onLongPress;
  final void Function(int surah, int verse)? onLongPressUp;
  final void Function(int surah, int verse)? onLongPressCancel;
  final void Function(int surah, int verse)? onDoubleTap;
  final ValueChanged<int>? onPageChanged;
  final bool pageBgIsDark;

  const ContinuousScrollMushaf({super.key,
    required this.controller, required this.initialPageNumber, required this.sp, required this.h,
    this.fontSize, required this.theme, this.verseBackgroundColor, this.highlightsBuilder,
    this.onTapDown, this.onTap, this.onLongPressDown, this.onLongPress, this.onLongPressUp,
    this.onLongPressCancel, this.onDoubleTap, this.onPageChanged, required this.pageBgIsDark,
  });

  @override
  State<ContinuousScrollMushaf> createState() => _ContinuousScrollMushafState();
}

class _ContinuousScrollMushafState extends State<ContinuousScrollMushaf> {
  late final ScrollController _scrollController;
  int _lastReportedPage = 1;
  static const double _estimatedPageHeight = 680.0;

  @override
  void initState() {
    super.initState();
    _lastReportedPage = widget.initialPageNumber;
    _scrollController = ScrollController(initialScrollOffset: (widget.initialPageNumber - 1) * 680.0);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final offset = _scrollController.offset;
    final estimatedPage = (offset / _estimatedPageHeight).floor() + 1;
    final currentPage = estimatedPage.clamp(1, 604);
    if (currentPage != _lastReportedPage) {
      _lastReportedPage = currentPage;
      widget.onPageChanged?.call(currentPage);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const pageH = _estimatedPageHeight;
    const separatorHeight = 24.0;
    return ListView.builder(
      controller: _scrollController,
      physics: const ClampingScrollPhysics(),
      scrollCacheExtent: ScrollCacheExtent.pixels(pageH * 2),
      itemCount: 604,
      itemBuilder: (context, index) {
        final pageNumber = index + 1;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: pageH, child: RepaintBoundary(child: QcfPage(
              pageNumber: pageNumber, sp: widget.sp, h: widget.h, fontSize: widget.fontSize,
              theme: widget.theme, verseBackgroundColor: widget.verseBackgroundColor,
              highlightsBuilder: widget.highlightsBuilder, onTapDown: widget.onTapDown,
              onTap: widget.onTap, onLongPressDown: widget.onLongPressDown,
              onLongPress: widget.onLongPress, onLongPressUp: widget.onLongPressUp,
              onLongPressCancel: widget.onLongPressCancel, onDoubleTap: widget.onDoubleTap,
            ))),
            if (pageNumber < 604) Container(
              height: separatorHeight, color: widget.theme.pageBackgroundColor, alignment: Alignment.center,
              child: Container(width: 40, height: 1, color: widget.theme.verseTextColor.withValues(alpha: 0.12)),
            ),
          ],
        );
      },
    );
  }
}
