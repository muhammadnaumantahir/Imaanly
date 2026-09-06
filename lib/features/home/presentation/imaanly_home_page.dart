import 'package:adhan_dart/adhan_dart.dart';
import 'package:imaanly/features/home/domain/next_prayer.dart';
import 'package:imaanly/features/islamic_calendar/presentation/islamic_calendar_screen.dart';
import 'package:imaanly/features/worship_dashboard/presentation/worship_dashboard_screen.dart';
import 'package:imaanly/src/features/islamic_knowledge/presentation/islamic_knowledge_screen.dart';
import 'package:imaanly/src/screen/azkar/azkar_categories_screen.dart';
import 'package:imaanly/src/screen/location_handler/cubit/location_data_qibla_data_cubit.dart';
import 'package:imaanly/src/screen/location_handler/model/location_data_qibla_data_state.dart';
import 'package:imaanly/src/screen/mushaf/mushaf_screen.dart';
import 'package:imaanly/src/screen/prayer_time/prayer_time_page.dart';
import 'package:imaanly/src/screen/quran_script_view/quran_script_view.dart';
import 'package:imaanly/src/utils/quran_ayahs_function/gen_ayahs_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Imaanly's balanced-companion Home experience.
class ImaanlyHomePage extends StatelessWidget {
  const ImaanlyHomePage({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final dateLabel = DateFormat('EEEE, d MMMM').format(now);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 178,
            backgroundColor: theme.colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            title: const Text('Imaanly', style: TextStyle(fontWeight: FontWeight.w800)),
            actions: [
              IconButton(
                tooltip: 'Islamic knowledge',
                onPressed: () => _open(context, const IslamicKnowledgeScreen()),
                icon: const Icon(Icons.auto_stories_rounded),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(background: _HeroHeader(dateLabel: dateLabel)),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _SectionHeader(
                  title: 'Your day',
                  action: 'Prayer times',
                  onAction: () => _open(context, const PrayerTimePage()),
                ),
                const SizedBox(height: 10),
                _NextPrayerCard(onOpen: () => _open(context, const PrayerTimePage())),
                const SizedBox(height: 24),
                const _SectionHeader(title: 'Continue your journey'),
                const SizedBox(height: 10),
                _QuranCard(
                  onOpen: () => _open(
                    context,
                    QuranScriptView(startKey: '1:1', endKey: getEndAyahKeyFromSurahNumber(1), toScrollKey: '1:1'),
                  ),
                ),
                const SizedBox(height: 24),
                const _SectionHeader(title: 'Quick actions'),
                const SizedBox(height: 10),
                _QuickActions(
                  onQuran: () => _open(context, const MushafScreen()),
                  onDhikr: () => _open(context, const AzkarCategoriesScreen()),
                  onPrayer: () => _open(context, const PrayerTimePage()),
                  onQibla: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Open Qibla from the Prayer tools when needed.'))),
                ),
                const SizedBox(height: 24),
                const _SectionHeader(title: 'Explore'),
                const SizedBox(height: 10),
                _ExploreGrid(
                  onKnowledge: () => _open(context, const IslamicKnowledgeScreen()),
                  onDashboard: () => _open(context, const WorshipDashboardScreen()),
                  onCalendar: () => _open(context, const IslamicCalendarScreen()),
                ),
                const SizedBox(height: 24),
                const _SectionHeader(title: 'Today\'s reflection'),
                const SizedBox(height: 10),
                const _ReflectionCard(),
                const SizedBox(height: 24),
                const _SectionHeader(title: 'Worship progress'),
                const SizedBox(height: 10),
                _DashboardTeaser(onOpen: () => _open(context, const WorshipDashboardScreen())),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.dateLabel});
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [scheme.primaryContainer, scheme.surface])),
      padding: const EdgeInsets.fromLTRB(20, 76, 20, 18),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assalamu Alaikum', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(dateLabel, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _NextPrayerCard extends StatefulWidget {
  const _NextPrayerCard({required this.onOpen});
  final VoidCallback onOpen;
  @override State<_NextPrayerCard> createState() => _NextPrayerCardState();
}

class _NextPrayerCardState extends State<_NextPrayerCard> {
  DateTime _now = DateTime.now();
  late final Stream<DateTime> _clock;

  @override
  void initState() {
    super.initState();
    _clock = Stream<DateTime>.periodic(const Duration(seconds: 1), (_) => DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: _clock,
      initialData: _now,
      builder: (context, snapshot) {
        _now = snapshot.data ?? DateTime.now();
        return BlocBuilder<LocationQiblaPrayerDataCubit, LocationQiblaPrayerDataState>(
          builder: (context, location) => _buildCard(context, location, _now),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, LocationQiblaPrayerDataState location, DateTime now) {
    final scheme = Theme.of(context).colorScheme;
    if (location.latLon == null) {
      return Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onOpen,
          child: const Padding(
            padding: EdgeInsets.all(18),
            child: Row(children: [
              Icon(Icons.mosque_outlined, size: 32),
              SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Prayer times', style: TextStyle(fontWeight: FontWeight.w800)),
                SizedBox(height: 4),
                Text('Set your location to see the live next-prayer countdown.'),
              ])),
              Icon(Icons.chevron_right_rounded),
            ]),
          ),
        ),
      );
    }

    final params = location.calculationMethod ?? CalculationMethodParameters.karachi();
    params.madhab = location.madhab ?? Madhab.hanafi;
    final coordinates = Coordinates(location.latLon!.latitude, location.latLon!.longitude);
    final prayerTimes = PrayerTimes(coordinates: coordinates, date: now, calculationParameters: params, precision: true);
    final next = const NextPrayerCalculator().calculate(prayerTimes, now);
    final current = prayerTimes.currentPrayer(date: now);
    if (next == null) return const SizedBox.shrink();

    final timeLabel = DateFormat.jm().format(next.time);
    final currentLabel = _prayerLabel(current);
    final nextLabel = _prayerLabel(next.prayer);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onOpen,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 52, height: 52, decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(16)), child: Icon(Icons.mosque_outlined, color: scheme.primary)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Next prayer', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 2),
                Text(nextLabel, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
              ])),
              Text(timeLabel, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 18),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Starts in', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(_formatCountdown(next.remaining), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              ])),
              Text('Current: $currentLabel', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
            ]),
            const SizedBox(height: 14),
            LinearProgressIndicator(value: _progress(prayerTimes, now, next.time), minHeight: 6),
          ]),
        ),
      ),
    );
  }

  double _progress(PrayerTimes times, DateTime now, DateTime nextTime) {
    final previous = <DateTime>[times.fajr.toLocal(), times.dhuhr.toLocal(), times.asr.toLocal(), times.maghrib.toLocal(), times.isha.toLocal()]
        .where((time) => time.isBefore(nextTime))
        .fold<DateTime?>(null, (latest, time) => latest == null || time.isAfter(latest) ? time : latest);
    if (previous == null) return 0;
    final total = nextTime.difference(previous).inSeconds;
    if (total <= 0) return 0;
    return (1 - nextTime.difference(now).inSeconds / total).clamp(0.0, 1.0);
  }

  String _formatCountdown(Duration duration) {
    final safe = duration.isNegative ? Duration.zero : duration;
    final hours = safe.inHours;
    final minutes = safe.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = safe.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
  }

  String _prayerLabel(Prayer prayer) {
    switch (prayer.name) {
      case 'fajr': return 'Fajr';
      case 'dhuhr': return 'Dhuhr';
      case 'asr': return 'Asr';
      case 'maghrib': return 'Maghrib';
      case 'isha': return 'Isha';
      case 'sunrise': return 'Sunrise';
      default: return prayer.name;
    }
  }
}

class _QuranCard extends StatelessWidget {
  const _QuranCard({required this.onOpen});
  final VoidCallback onOpen;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(clipBehavior: Clip.antiAlias, child: InkWell(onTap: onOpen, child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [
      Container(width: 56, height: 56, decoration: BoxDecoration(color: scheme.secondaryContainer, borderRadius: BorderRadius.circular(18)), child: Icon(Icons.menu_book_rounded, color: scheme.secondary)),
      const SizedBox(width: 14),
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Continue Quran', style: TextStyle(fontWeight: FontWeight.w800)), SizedBox(height: 4), Text('Return to your reading and keep the habit going.')])),
      FilledButton.tonal(onPressed: onOpen, child: const Text('Read')),
    ]))));
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.onQuran, required this.onDhikr, required this.onPrayer, required this.onQibla});
  final VoidCallback onQuran, onDhikr, onPrayer, onQibla;
  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: _ActionTile(icon: Icons.menu_book_rounded, label: 'Quran', onTap: onQuran)),
    const SizedBox(width: 10),
    Expanded(child: _ActionTile(icon: Icons.favorite_outline_rounded, label: 'Dhikr', onTap: onDhikr)),
    const SizedBox(width: 10),
    Expanded(child: _ActionTile(icon: Icons.access_time_rounded, label: 'Prayer', onTap: onPrayer)),
    const SizedBox(width: 10),
    Expanded(child: _ActionTile(icon: Icons.explore_outlined, label: 'Qibla', onTap: onQibla)),
  ]);
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.label, required this.onTap});
  final IconData icon; final String label; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(child: InkWell(borderRadius: BorderRadius.circular(12), onTap: onTap, child: Padding(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6), child: Column(children: [Icon(icon), const SizedBox(height: 8), Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))]))));
}

class _ExploreGrid extends StatelessWidget {
  const _ExploreGrid({required this.onKnowledge, required this.onDashboard, required this.onCalendar});
  final VoidCallback onKnowledge, onDashboard, onCalendar;
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
    final width = constraints.maxWidth;
    final columns = width >= 700 ? 3 : 1;
    return GridView.count(
      crossAxisCount: columns,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: width >= 700 ? 2.5 : 3.5,
      children: [
        _ExploreTile(icon: Icons.auto_stories_rounded, title: 'Islamic Knowledge', subtitle: 'Learn from existing resources', onTap: onKnowledge),
        _ExploreTile(icon: Icons.insights_rounded, title: 'Worship Dashboard', subtitle: 'See your daily progress', onTap: onDashboard),
        _ExploreTile(icon: Icons.calendar_month_rounded, title: 'Islamic Calendar', subtitle: 'Today\'s Hijri date', onTap: onCalendar),
      ],
    );
  });
}

class _ExploreTile extends StatelessWidget {
  const _ExploreTile({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon; final String title; final String subtitle; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [Icon(icon), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(subtitle, style: Theme.of(context).textTheme.bodySmall)])), const Icon(Icons.chevron_right_rounded)]))));
}

class _ReflectionCard extends StatelessWidget {
  const _ReflectionCard();
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.auto_awesome_rounded, color: Theme.of(context).colorScheme.primary), const SizedBox(height: 14), const Text('A little consistency can transform an ordinary day into a meaningful one.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, height: 1.35)), const SizedBox(height: 8), Text('Use Islamic Knowledge for verified, contextual resources instead of relying on an unverified daily quote.', style: Theme.of(context).textTheme.bodySmall)])));
}

class _DashboardTeaser extends StatelessWidget {
  const _DashboardTeaser({required this.onOpen});
  final VoidCallback onOpen;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(child: InkWell(onTap: onOpen, borderRadius: BorderRadius.circular(16), child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [Container(width: 52, height: 52, decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(16)), child: Icon(Icons.insights_rounded, color: scheme.primary)), const SizedBox(width: 14), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Your worship overview', style: TextStyle(fontWeight: FontWeight.w800)), SizedBox(height: 4), Text('Open the dashboard for Quran reading, Dhikr and daily habit progress.')])) , const Icon(Icons.chevron_right_rounded)]))));
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action, this.onAction});
  final String title; final String? action; final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Row(children: [Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))), if (action != null && onAction != null) TextButton(onPressed: onAction, child: Text(action!))]);
}
