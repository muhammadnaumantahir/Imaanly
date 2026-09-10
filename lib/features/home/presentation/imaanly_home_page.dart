import 'dart:async';
import 'dart:ui';

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

import '../../fasting/presentation/fasting_launcher_screen.dart';
import '../../goals/presentation/daily_goals_screen.dart';
import '../../islamic_calendar/presentation/islamic_calendar_screen.dart';
import '../../worship_dashboard/presentation/worship_dashboard_screen.dart';
import '../../../src/features/islamic_knowledge/presentation/islamic_knowledge_screen.dart';
import '../../../src/features/quran/presentation/quran_reader_screen.dart';
import '../../../src/screen/azkar/azkar_categories_screen.dart';
import '../../../src/screen/location_handler/model/location_data_qibla_data_state.dart';
import '../../../src/screen/qibla/qibla_direction.dart';
import '../../../src/screen/settings/settings_page.dart';
import '../../../src/screen/prayer_time/prayer_time_page.dart';

class ImaanlyHomePage extends StatefulWidget {
  const ImaanlyHomePage({super.key});

  @override
  State<ImaanlyHomePage> createState() => _ImaanlyHomePageState();
}

class _ImaanlyHomePageState extends State<ImaanlyHomePage> {
  Timer? _timer;
  Timer? _splashTimer;
  bool _showBrandSplash = true;
  PrayerTimes? _prayerTimes;
  Prayer? _nextPrayer;
  Duration _timeUntilNext = Duration.zero;
  String _locationName = 'Your location';
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _refreshPrayerTimes();
    _resolveLocation();
    _splashTimer = Timer(const Duration(milliseconds: 1450), () {
      if (mounted) setState(() => _showBrandSplash = false);
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      _now = DateTime.now();
      _updateNextPrayer();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _splashTimer?.cancel();
    super.dispose();
  }

  void _refreshPrayerTimes() {
    final state = context.read<LocationQiblaPrayerDataCubit>().state;
    final latLon = state.latLon;
    final coordinates = latLon == null
        ? Coordinates(31.5204, 74.3587)
        : Coordinates(latLon.latitude, latLon.longitude);
    final params = state.calculationMethod ??
        CalculationParameters(
          fajrAngle: 18,
          ishaAngle: 18,
          method: CalculationMethod.karachi,
        );

    _prayerTimes = PrayerTimes(
      coordinates: coordinates,
      date: _now,
      calculationParameters: params,
      precision: true,
    );
    _updateNextPrayer();
  }

  void _updateNextPrayer() {
    final times = _prayerTimes;
    if (times == null) return;
    _nextPrayer = times.nextPrayer(date: _now);
    if (_nextPrayer == null) {
      _timeUntilNext = Duration.zero;
      return;
    }
    _timeUntilNext = times.timeForPrayer(_nextPrayer!).difference(_now);
    if (_timeUntilNext.isNegative) _timeUntilNext = Duration.zero;
  }

  Future<void> _resolveLocation() async {
    final state = context.read<LocationQiblaPrayerDataCubit>().state;
    final point = state.latLon;
    if (point == null) return;
    try {
      final places = await placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );
      if (!mounted || places.isEmpty) return;
      final place = places.first;
      final value = [
        place.locality,
        place.administrativeArea,
      ].where((item) => item != null && item!.trim().isNotEmpty).join(', ');
      if (value.isNotEmpty) setState(() => _locationName = value);
    } catch (_) {
      // Location is optional; prayer calculations continue with coordinates.
    }
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  String _formatCountdown(Duration value) {
    final hours = value.inHours.toString().padLeft(2, '0');
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  String _prayerName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'Fajr';
      case Prayer.dhuhr:
        return 'Dhuhr';
      case Prayer.asr:
        return 'Asr';
      case Prayer.maghrib:
        return 'Maghrib';
      case Prayer.isha:
        return 'Isha';
      default:
        return prayer.name;
    }
  }

  IconData _prayerIcon(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return Icons.wb_twilight_rounded;
      case Prayer.dhuhr:
        return Icons.wb_sunny_rounded;
      case Prayer.asr:
        return Icons.wb_cloudy_rounded;
      case Prayer.maghrib:
        return Icons.wb_twilight_rounded;
      case Prayer.isha:
        return Icons.nightlight_round;
      default:
        return Icons.access_time_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showBrandSplash) return const _BrandSplash();

    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final date = DateFormat('EEEE, d MMMM').format(_now);

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1180),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Header(
                          location: _locationName,
                          date: date,
                          onLocation: () => _open(
                            context,
                            const PrayerTimePage(),
                          ),
                          onSettings: () => _open(
                            context,
                            const SettingsPage(),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _NextPrayerCard(
                          prayerName: _nextPrayer == null
                              ? 'Prayer times'
                              : _prayerName(_nextPrayer!),
                          countdown: _nextPrayer == null
                              ? 'Open prayer times to set your location'
                              : _formatCountdown(_timeUntilNext),
                          prayerTime: _nextPrayer == null || _prayerTimes == null
                              ? null
                              : _prayerTimes!.timeForPrayer(_nextPrayer!),
                          onOpen: () => _open(
                            context,
                            const PrayerTimePage(),
                          ),
                        ),
                        const SizedBox(height: 22),
                        _SectionTitle(
                          title: 'Today’s prayers',
                          action: 'View all',
                          onAction: () => _open(
                            context,
                            const PrayerTimePage(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _PrayerStrip(
                          times: _prayerTimes,
                          nextPrayer: _nextPrayer,
                          prayerName: _prayerName,
                          prayerIcon: _prayerIcon,
                        ),
                        const SizedBox(height: 24),
                        _SectionTitle(
                          title: 'Quick access',
                          action: 'Customize',
                          onAction: () => _open(
                            context,
                            const SettingsPage(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _QuickGrid(
                          onQuran: () => _open(
                            context,
                            const QuranReaderScreen(),
                          ),
                          onQibla: () => _open(
                            context,
                            const QiblaDirection(),
                          ),
                          onDhikr: () => _open(
                            context,
                            const AzkarCategoriesScreen(),
                          ),
                          onDuas: () => _open(
                            context,
                            const IslamicKnowledgeScreen(),
                          ),
                          onCalendar: () => _open(
                            context,
                            const IslamicCalendarScreen(),
                          ),
                          onGoals: () => _open(
                            context,
                            const DailyGoalsScreen(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _DailyGoalsCard(
                          onOpen: () => _open(
                            context,
                            const DailyGoalsScreen(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _DiscoverCard(
                          isDark: isDark,
                          onOpen: () => _open(
                            context,
                            const QuranReaderScreen(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _ExploreCard(
                          onOpen: (page) => _open(context, page),
                        ),
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
        onDestinationSelected: (index) {
          switch (index) {
            case 1:
              _open(context, const QuranReaderScreen());
              break;
            case 2:
              _open(context, const PrayerTimePage());
              break;
            case 3:
              _open(context, const IslamicKnowledgeScreen());
              break;
          }
        },
      ),
    );
  }
}

class _BrandSplash extends StatelessWidget {
  const _BrandSplash();

  @override
  Widget build(BuildContext context) {
    const deepGreen = Color(0xFF0B3025);
    const green = Color(0xFF2E6B52);
    const gold = Color(0xFFD4B86A);
    const cream = Color(0xFFF7F1E2);

    return Scaffold(
      backgroundColor: deepGreen,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 154,
                height: 154,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF123D2F),
                  border: Border.all(color: gold, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x55204F3B),
                      blurRadius: 36,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.nightlight_round,
                      size: 82,
                      color: gold,
                    ),
                    Positioned(
                      top: 31,
                      right: 33,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: cream,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const Text(
                      'I',
                      style: TextStyle(
                        color: cream,
                        fontSize: 46,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Imaanly',
                style: TextStyle(
                  color: cream,
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(height: 9),
              const Text(
                'Your daily Islamic companion',
                style: TextStyle(
                  color: Color(0xFFB7CFC3),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  letterSpacing: .2,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: green,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.location,
    required this.date,
    required this.onLocation,
    required this.onSettings,
  });

  final String location;
  final String date;
  final VoidCallback onLocation;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assalamu Alaikum',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -.5,
                    ),
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: onLocation,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 2,
                    vertical: 3,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: scheme.primary,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 3),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 17,
                        color: scheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                date,
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Settings',
          onPressed: onSettings,
          icon: const Icon(Icons.settings_outlined),
        ),
        const SizedBox(width: 2),
        CircleAvatar(
          radius: 20,
          backgroundColor: scheme.primaryContainer,
          child: Icon(Icons.person_outline_rounded, color: scheme.primary),
        ),
      ],
    );
  }
}

class _NextPrayerCard extends StatelessWidget {
  const _NextPrayerCard({
    required this.prayerName,
    required this.countdown,
    required this.prayerTime,
    required this.onOpen,
  });

  final String prayerName;
  final String countdown;
  final DateTime? prayerTime;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final time = prayerTime == null
        ? null
        : DateFormat('h:mm a').format(prayerTime!);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors: [
            scheme.primary,
            Color.lerp(scheme.primary, scheme.secondary, .48) ?? scheme.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: .20),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NEXT PRAYER',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .76),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  prayerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (time != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    time,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .88),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  countdown,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: onOpen,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: scheme.primary,
                  ),
                  child: const Text('Open prayer times'),
                ),
              ],
            ),
          ),
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .12),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: .22),
              ),
            ),
            child: const Icon(
              Icons.mosque_rounded,
              color: Colors.white,
              size: 42,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerStrip extends StatelessWidget {
  const _PrayerStrip({
    required this.times,
    required this.nextPrayer,
    required this.prayerName,
    required this.prayerIcon,
  });

  final PrayerTimes? times;
  final Prayer? nextPrayer;
  final String Function(Prayer) prayerName;
  final IconData Function(Prayer) prayerIcon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const prayers = [
      Prayer.fajr,
      Prayer.dhuhr,
      Prayer.asr,
      Prayer.maghrib,
      Prayer.isha,
    ];

    return SizedBox(
      height: 106,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: prayers.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, index) {
          final prayer = prayers[index];
          final selected = nextPrayer == prayer;
          final time = times == null
              ? '--:--'
              : DateFormat('h:mm').format(times!.timeForPrayer(prayer));
          return Container(
            width: 112,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: selected ? scheme.primaryContainer : scheme.surfaceContainer,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected
                    ? scheme.primary.withValues(alpha: .38)
                    : scheme.outlineVariant.withValues(alpha: .55),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  prayerIcon(prayer),
                  size: 19,
                  color: selected ? scheme.primary : scheme.onSurfaceVariant,
                ),
                const Spacer(),
                Text(
                  prayerName(prayer),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  time,
                  style: TextStyle(
                    color: selected ? scheme.primary : scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _QuickGrid extends StatelessWidget {
  const _QuickGrid({
    required this.onQuran,
    required this.onQibla,
    required this.onDhikr,
    required this.onDuas,
    required this.onCalendar,
    required this.onGoals,
  });

  final VoidCallback onQuran;
  final VoidCallback onQibla;
  final VoidCallback onDhikr;
  final VoidCallback onDuas;
  final VoidCallback onCalendar;
  final VoidCallback onGoals;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Quran', 'Read & listen', Icons.menu_book_rounded, onQuran),
      ('Qibla', 'Find direction', Icons.explore_rounded, onQibla),
      ('Dhikr', 'Remember Allah', Icons.favorite_rounded, onDhikr),
      ('Duas', 'Daily supplications', Icons.volunteer_activism_rounded, onDuas),
      ('Calendar', 'Hijri dates', Icons.calendar_month_rounded, onCalendar),
      ('Goals', 'Build consistency', Icons.flag_rounded, onGoals),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 6
            : constraints.maxWidth >= 620
                ? 3
                : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 112,
          ),
          itemBuilder: (_, index) {
            final item = items[index];
            return Material(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                onTap: item.$4,
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.all(13),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        item.$3,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const Spacer(),
                      Text(
                        item.$1,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.$2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _DailyGoalsCard extends StatelessWidget {
  const _DailyGoalsCard({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.track_changes_rounded, color: scheme.primary),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily worship goals',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Track Salah, Quran, Dhikr and your daily consistency.',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            FilledButton(
              onPressed: onOpen,
              child: const Text('Open'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscoverCard extends StatelessWidget {
  const _DiscoverCard({
    required this.isDark,
    required this.onOpen,
  });

  final bool isDark;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? scheme.surfaceContainerHigh
            : scheme.primaryContainer.withValues(alpha: .62),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome_rounded, color: scheme.primary, size: 30),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Read, listen, reflect',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                ),
                SizedBox(height: 4),
                Text(
                  'Continue your Quran journey with translations, tafsir and audio.',
                  style: TextStyle(fontSize: 13, height: 1.35),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Open Quran',
            onPressed: onOpen,
            icon: const Icon(Icons.arrow_forward_rounded),
          ),
        ],
      ),
    );
  }
}

class _ExploreCard extends StatelessWidget {
  const _ExploreCard({required this.onOpen});

  final ValueChanged<Widget> onOpen;

  @override
  Widget build(BuildContext context) {
    final items = <_ExploreItem>[
      _ExploreItem(
        'Islamic knowledge',
        'Hadith, Sunnah and learning',
        Icons.auto_stories_rounded,
        () => onOpen(const IslamicKnowledgeScreen()),
      ),
      _ExploreItem(
        'Fasting',
        'Keep your fasting record',
        Icons.nightlight_rounded,
        () => onOpen(const FastingLauncherScreen()),
      ),
      _ExploreItem(
        'Calendar',
        'Islamic dates and occasions',
        Icons.calendar_month_rounded,
        () => onOpen(const IslamicCalendarScreen()),
      ),
      _ExploreItem(
        'Insights',
        'Review your worship',
        Icons.insights_rounded,
        () => onOpen(const WorshipDashboardScreen()),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Explore Imaanly',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 92,
          ),
          itemBuilder: (_, index) {
            final item = items[index];
            return Card(
              child: InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(13),
                  child: Row(
                    children: [
                      Icon(
                        item.icon,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, size: 19),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ExploreItem {
  const _ExploreItem(this.title, this.subtitle, this.icon, this.onTap);

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.action,
    required this.onAction,
  });

  final String title;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        TextButton(
          onPressed: onAction,
          child: Text(action),
        ),
      ],
    );
  }
}
