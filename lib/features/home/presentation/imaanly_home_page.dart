import 'dart:async';
import 'dart:ui' show FontFeature;

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../../ath_an/presentation/athan_feature_center.dart';
import '../../goals/presentation/daily_goals_screen.dart';
import '../../islamic_calendar/presentation/islamic_calendar_screen.dart';
import '../../tasbih/presentation/tasbih_screen.dart';
import 'widgets/next_islamic_event_card.dart';
import '../../../src/features/quran/presentation/quran_reader_screen.dart';
import '../../../src/screen/azkar/azkar_categories_screen.dart';
import '../../../src/screen/location_handler/model/location_data_qibla_data_state.dart';
import '../../../src/screen/prayer_time/prayer_time_page.dart';
import '../../../src/screen/qibla/qibla_direction.dart';
import '../../../src/screen/settings/settings_page.dart';
import '../../../src/theme/app_colors.dart';
import '../../../src/theme/app_widgets.dart';

/// Imaanly home: a gradient "next prayer" hero, today's prayer timeline and
/// quick access tiles.
class ImaanlyHomePage extends StatefulWidget {
  const ImaanlyHomePage({super.key});

  @override
  State<ImaanlyHomePage> createState() => _ImaanlyHomePageState();
}

class _ImaanlyHomePageState extends State<ImaanlyHomePage> {
  static const List<Prayer> _prayers = [
    Prayer.fajr,
    Prayer.dhuhr,
    Prayer.asr,
    Prayer.maghrib,
    Prayer.isha,
  ];
  static const List<Prayer> _timeline = [
    Prayer.fajr,
    Prayer.sunrise,
    Prayer.dhuhr,
    Prayer.asr,
    Prayer.maghrib,
    Prayer.isha,
  ];

  final CalculationParameters _fallbackParams = CalculationParameters(
    fajrAngle: 18,
    ishaAngle: 18,
    method: CalculationMethod.karachi,
  );

  Timer? _timer;
  DateTime _now = DateTime.now();
  PrayerTimes? _times;
  Prayer? _next;
  String _location = 'Lahore';
  String? _resolvedLocationKey;
  CalculationParameters? _computedParams;
  String? _computedPointKey;
  DateTime? _computedDay;

  @override
  void initState() {
    super.initState();
    _refresh();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
        _refresh();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _refresh() {
    final state = context.read<LocationQiblaPrayerDataCubit>().state;
    final point = state.latLon;
    final coordinates = point == null
        ? Coordinates(31.5204, 74.3587)
        : Coordinates(point.latitude, point.longitude);
    final params = state.calculationMethod ?? _fallbackParams;
    final pointKey = point == null
        ? 'default'
        : '${point.latitude.toStringAsFixed(4)}:${point.longitude.toStringAsFixed(4)}';
    final today = DateUtils.dateOnly(_now);

    final needsRecompute = _times == null ||
        _computedDay != today ||
        _computedPointKey != pointKey ||
        !identical(_computedParams, params);
    if (needsRecompute) {
      _times = PrayerTimes(
        coordinates: coordinates,
        date: _now,
        calculationParameters: params,
        precision: true,
      );
      _computedDay = today;
      _computedPointKey = pointKey;
      _computedParams = params;
    }
    _next = _times!.nextPrayer(date: _now);

    if (point != null && _resolvedLocationKey != pointKey) {
      _resolvedLocationKey = pointKey;
      _resolveLocation(point.latitude, point.longitude);
    }
  }

  Future<void> _resolveLocation(double lat, double lon) async {
    try {
      final places = await placemarkFromCoordinates(lat, lon);
      if (!mounted || places.isEmpty) return;
      final p = places.first;
      final value = [p.locality, p.administrativeArea]
          .whereType<String>()
          .where((v) => v.trim().isNotEmpty)
          .join(', ');
      if (value.isNotEmpty && value != _location) {
        setState(() => _location = value);
      }
    } catch (_) {}
  }

  /// Sky colours (top, bottom) for the hero, based on the upcoming prayer.
  (Color, Color) _skyColors(Prayer? p, bool isDark) => switch (p) {
        Prayer.fajr => (const Color(0xFF1F2A6B), const Color(0xFF8E4A8F)),
        Prayer.sunrise => (const Color(0xFF2F5FA8), const Color(0xFFD98A4E)),
        Prayer.dhuhr => (const Color(0xFF1B78B8), const Color(0xFF14806A)),
        Prayer.asr => (const Color(0xFF0E6E55), const Color(0xFFB9822B)),
        Prayer.maghrib => (const Color(0xFF5B2A86), const Color(0xFFD9573A)),
        Prayer.isha => (const Color(0xFF0B1B3D), const Color(0xFF24457E)),
        _ => isDark
            ? (AppColors.gradientTopDark, AppColors.gradientBottomDark)
            : (AppColors.gradientTop, AppColors.gradientBottom),
      };

  void _open(Widget page) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  String _name(Prayer? p) => switch (p) {
        Prayer.fajr => 'Fajr',
        Prayer.sunrise => 'Sunrise',
        Prayer.dhuhr => 'Dhuhr',
        Prayer.asr => 'Asr',
        Prayer.maghrib => 'Maghrib',
        Prayer.isha => 'Isha',
        _ => 'Fajr',
      };

  IconData _icon(Prayer? p) => switch (p) {
        Prayer.fajr => Icons.wb_twilight_rounded,
        Prayer.sunrise => Icons.wb_sunny_outlined,
        Prayer.dhuhr => Icons.wb_sunny_rounded,
        Prayer.asr => Icons.wb_cloudy_rounded,
        Prayer.maghrib => Icons.nights_stay_outlined,
        Prayer.isha => Icons.nightlight_round,
        _ => Icons.wb_twilight_rounded,
      };

  DateTime? _timeOf(Prayer? p) {
    if (p == null || _times == null) return null;
    try {
      return _times!.timeForPrayer(p);
    } catch (_) {
      return null;
    }
  }

  String _clock(Prayer? p) {
    final t = _timeOf(p);
    return t == null ? '--:--' : DateFormat('h:mm a').format(t.toLocal());
  }

  Duration get _remaining {
    final t = _timeOf(_next);
    if (t == null) return Duration.zero;
    final d = t.difference(_now);
    return d.isNegative ? Duration.zero : d;
  }

  double get _progress {
    final next = _timeOf(_next);
    if (next == null) return 0;
    DateTime? previous;
    for (final p in _timeline) {
      final t = _timeOf(p);
      if (t != null && !t.isAfter(_now)) previous = t;
    }
    if (previous == null) return 0;
    final total = next.difference(previous).inSeconds;
    if (total <= 0) return 0;
    return (_now.difference(previous).inSeconds / total).clamp(0.0, 1.0).toDouble();
  }

  String _countdown(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _header(cs).animate().fadeIn(duration: 400.ms).slideY(begin: -0.08, curve: Curves.easeOutCubic),
                        const SizedBox(height: 18),
                        _hero(cs, isDark).animate().fadeIn(duration: 550.ms, delay: 100.ms).slideY(begin: 0.06, curve: Curves.easeOutCubic),
                        const SizedBox(height: 26),
                        _SectionTitle(
                          title: "Today's prayers",
                          action: 'View all',
                          onTap: () => _open(const PrayerTimePage()),
                        ),
                        const SizedBox(height: 10),
                        _prayerList(cs).animate().fadeIn(duration: 500.ms, delay: 250.ms).slideY(begin: 0.06, curve: Curves.easeOutCubic),
                        const SizedBox(height: 26),
                        _SectionTitle(
                          title: 'Quick access',
                          action: 'Explore',
                          onTap: () => _open(const AthanFeatureCenter()),
                        ),
                        const SizedBox(height: 12),
                        _quickAccess().animate().fadeIn(duration: 500.ms, delay: 400.ms).slideY(begin: 0.06, curve: Curves.easeOutCubic),
                        const SizedBox(height: 26),
                        _SectionTitle(
                          title: 'Coming up',
                          action: 'Calendar',
                          onTap: () => _open(const IslamicCalendarScreen()),
                        ),
                        const SizedBox(height: 10),
                        NextIslamicEventCard(
                          now: _now,
                          onTap: () => _open(const IslamicCalendarScreen()),
                        ).animate().fadeIn(duration: 500.ms, delay: 500.ms).slideY(begin: 0.06, curve: Curves.easeOutCubic),
                        const SizedBox(height: 26),
                        _SectionTitle(
                          title: 'More for your journey',
                          action: 'Open Explore',
                          onTap: () => _open(const AthanFeatureCenter()),
                        ),
                        const SizedBox(height: 10),
                        _moreCard(cs).animate().fadeIn(duration: 500.ms, delay: 550.ms).slideY(begin: 0.06, curve: Curves.easeOutCubic),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Quran',
          ),
          NavigationDestination(
            icon: Icon(Icons.mosque_outlined),
            selectedIcon: Icon(Icons.mosque_rounded),
            label: 'Prayer',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'Explore',
          ),
        ],
        onDestinationSelected: (i) {
          if (i == 1) _open(const QuranReaderScreen());
          if (i == 2) _open(const PrayerTimePage());
          if (i == 3) _open(const AthanFeatureCenter());
        },
      ),
    );
  }

  Widget _header(ColorScheme cs) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.asset(
            'assets/img/Quran_Logo_v3.png',
            width: 46,
            height: 46,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Assalamu Alaikum',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.location_on_rounded, size: 15, color: cs.primary),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      _location,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: () => _open(const SettingsPage()),
          tooltip: 'Settings',
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    );
  }

  Widget _hero(ColorScheme cs, bool isDark) {
    final hasNext = _next != null && _times != null;
    final hijri = HijriCalendar.fromDate(_now).toFormat('dd MMMM yyyy');
    const onHero = Colors.white;

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_skyColors(_next, isDark).$1, _skyColors(_next, isDark).$2],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: StarPatternPainter(Colors.white.withValues(alpha: 0.05)),
              ),
            ),
            if (_next == null || _next == Prayer.fajr || _next == Prayer.isha)
              const Positioned.fill(
                child: CustomPaint(painter: StarFieldPainter()),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 96,
              child: CustomPaint(
                painter: MosqueSkylinePainter(Colors.black.withValues(alpha: 0.24)),
              ),
            ),
            Positioned(
              right: -50,
              top: -50,
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.gold.withValues(alpha: 0.30),
                      AppColors.gold.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              hasNext ? _icon(_next) : Icons.mosque_rounded,
                              size: 16,
                              color: AppColors.gold,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'NEXT PRAYER',
                              style: TextStyle(
                                color: onHero,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$hijri AH',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(
                    hasNext ? _name(_next) : 'Prayer times',
                    style: const TextStyle(
                      color: onHero,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasNext ? _countdown(_remaining) : 'Set your location',
                    style: const TextStyle(
                      color: onHero,
                      fontSize: 54,
                      fontWeight: FontWeight.w300,
                      height: 1.1,
                      letterSpacing: 1,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (hasNext) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: _progress,
                        minHeight: 8,
                        backgroundColor: Colors.white.withValues(alpha: 0.18),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          hasNext
                              ? 'at ${_clock(_next)}  •  ${DateFormat('EEE, d MMM').format(_now)}'
                              : 'Open Prayer Times to configure Salah.',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ),
                      FilledButton.tonal(
                        onPressed: () => _open(const PrayerTimePage()),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.gradientBottom,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: const Text(
                          'Details',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _prayerList(ColorScheme cs) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Column(
        children: [
          for (final p in _prayers) _prayerRow(cs, p),
        ],
      ),
    );
  }

  Widget _prayerRow(ColorScheme cs, Prayer p) {
    final time = _timeOf(p);
    final isNext = p == _next;
    final passed = time != null && time.isBefore(_now) && !isNext;
    final fg = isNext ? cs.primary : (passed ? cs.onSurfaceVariant : cs.onSurface);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: isNext ? cs.primaryContainer.withValues(alpha: 0.55) : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        boxShadow: isNext
            ? [
                BoxShadow(
                  color: _skyColors(p, false).$1.withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isNext ? _skyColors(p, false).$1 : cs.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _icon(p),
              size: 20,
              color: isNext ? Colors.white : cs.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              _name(p),
              style: TextStyle(
                fontSize: 16,
                fontWeight: isNext ? FontWeight.w800 : FontWeight.w600,
                color: fg,
              ),
            ),
          ),
          if (isNext)
            Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'NEXT',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: cs.onPrimary,
                ),
              ),
            ),
          if (passed)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(Icons.check_circle_rounded, size: 16, color: cs.primary.withValues(alpha: 0.6)),
            ),
          Text(
            _clock(p),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: fg,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickAccess() {
    final items = <_QuickItem>[
      _QuickItem('Quran', Icons.menu_book_rounded, () => _open(const QuranReaderScreen())),
      _QuickItem('Qibla', Icons.explore_rounded, () => _open(const QiblaDirection())),
      _QuickItem('Tasbih', Icons.fingerprint_rounded, () => _open(const TasbihScreen())),
      _QuickItem('Azkar', Icons.auto_stories_rounded, () => _open(const AzkarCategoriesScreen())),
    ];
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(child: _QuickTile(item: items[i])),
        ],
      ],
    );
  }

  Widget _moreCard(ColorScheme cs) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _MoreRow(
            Icons.calendar_month_rounded,
            'Islamic calendar',
            'Hijri dates and events',
            () => _open(const IslamicCalendarScreen()),
          ),
          const Divider(height: 22),
          _MoreRow(
            Icons.flag_rounded,
            'Daily goals',
            'Set small, steady worship targets',
            () => _open(const DailyGoalsScreen()),
          ),
          const Divider(height: 22),
          _MoreRow(
            Icons.grid_view_rounded,
            'Zakat, mosques & more',
            'Everything in Explore',
            () => _open(const AthanFeatureCenter()),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.action, required this.onTap});

  final String title;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ),
        TextButton(onPressed: onTap, child: Text(action)),
      ],
    );
  }
}

class _QuickItem {
  const _QuickItem(this.title, this.icon, this.onTap);
  final String title;
  final IconData icon;
  final VoidCallback onTap;
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({required this.item});

  final _QuickItem item;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainer,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: item.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(item.icon, color: cs.primary, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                item.title,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreRow extends StatelessWidget {
  const _MoreRow(this.icon, this.title, this.subtitle, this.onTap);

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: cs.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
        ],
      ),
    );
  }
}
