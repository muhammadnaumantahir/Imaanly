import 'package:adhan_dart/adhan_dart.dart';
import 'package:al_furkan/features/home/domain/next_prayer.dart';
import 'package:al_furkan/src/screen/azkar/azkar_categories_screen.dart';
import 'package:al_furkan/src/screen/location_handler/cubit/location_data_qibla_data_cubit.dart';
import 'package:al_furkan/src/screen/location_handler/model/location_data_qibla_data_state.dart';
import 'package:al_furkan/src/screen/mushaf/mushaf_screen.dart';
import 'package:al_furkan/src/screen/prayer_time/prayer_time_page.dart';
import 'package:al_furkan/src/screen/quran_script_view/quran_script_view.dart';
import 'package:al_furkan/src/utils/quran_ayahs_function/gen_ayahs_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Imaanly's balanced-companion Home experience.
///
/// This screen composes existing stable features and keeps business logic in
/// small feature/domain classes so the Home can grow without becoming a
/// monolithic dashboard.
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
                tooltip: 'Qibla',
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Qibla experience is coming in the next phase.')),
                ),
                icon: const Icon(Icons.explore_outlined),
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
                    QuranScriptView(
                      startKey: '1:1',
                      endKey: getEndAyahKeyFromSurahNumber(1),
                      toScrollKey: '1:1',
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const _SectionHeader(title: 'Quick actions'),
                const SizedBox(height: 10),
                _QuickActions(
                  onQuran: () => _open(context, const MushafScreen()),
                  onDhikr: () => _open(context, const AzkarCategoriesScreen()),
                  onPrayer: () => _open(context, const PrayerTimePage()),
                  onQibla: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Qibla experience is coming in the next phase.')),
                  ),
                ),
                const SizedBox(height: 24),
                const _SectionHeader(title: 'Today\'s reflection'),
                const SizedBox(height: 10),
                const _ReflectionCard(),
                const SizedBox(height: 24),
                const _SectionHeader(title: 'Worship progress'),
                const SizedBox(height: 10),
                const _ProgressCard(),
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primaryContainer, scheme.surface],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 76, 20, 18),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assalamu Alaikum',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              dateLabel,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextPrayerCard extends StatefulWidget {
  const _NextPrayerCard({required this.onOpen});

  final VoidCallback onOpen;

  @override
  State<_NextPrayerCard> createState() => _NextPrayerCardState();
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

  Widget _buildCard(
    BuildContext context,
    LocationQiblaPrayerDataState location,
    DateTime now,
  ) {
    final scheme = Theme.of(context).colorScheme;

    if (location.latLon == null) {
      return Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onOpen,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                _PrayerIcon(color: scheme.primaryContainer, iconColor: scheme.primary),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Prayer times', style: TextStyle(fontWeight: FontWeight.w800)),
                      SizedBox(height: 4),
                      Text('Set your location to see the live next-prayer countdown.'),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      );
    }

    final params = location.calculationMethod ?? CalculationMethodParameters.karachi();
    params.madhab = location.madhab ?? Madhab.hanafi;

    final coordinates = Coordinates(location.latLon!.latitude, location.latLon!.longitude);
    final prayerTimes = PrayerTimes(
      coordinates: coordinates,
      date: now,
      calculationParameters: params,
      precision: true,
    );
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _PrayerIcon(color: scheme.primaryContainer, iconColor: scheme.primary),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Next prayer', style: Theme.of(context).textTheme.labelLarge),
                        const SizedBox(height: 2),
                        Text(nextLabel, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                  Text(timeLabel, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Starts in', style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 2),
                        Text(_formatCountdown(next.remaining), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                  Text('Current: $currentLabel', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
                ],
              ),
              const SizedBox(height: 14),
              LinearProgressIndicator(value: _progress(prayerTimes, now, next.time), minHeight: 6),
              const SizedBox(height: 10),
              Text(
                'Live calculation • ${location.latLon!.latitude.toStringAsFixed(2)}, ${location.latLon!.longitude.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _progress(PrayerTimes times, DateTime now, DateTime nextTime) {
    final nextPrayer = const NextPrayerCalculator().calculate(times, now);
    if (nextPrayer == null) return 0;
    final previous = <DateTime>[
      times.fajr.toLocal(),
      times.dhuhr.toLocal(),
      times.asr.toLocal(),
      times.maghrib.toLocal(),
      times.isha.toLocal(),
    ].where((time) => time.isBefore(nextTime)).fold<DateTime?>(null, (latest, time) {
      if (latest == null || time.isAfter(latest)) return time;
      return latest;
    });
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

class _PrayerIcon extends StatelessWidget {
  const _PrayerIcon({required this.color, required this.iconColor});

  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
      child: Icon(Icons.mosque_outlined, color: iconColor),
    );
  }
}

class _QuranCard extends StatelessWidget {
  const _QuranCard({required this.onOpen});
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: scheme.secondaryContainer, borderRadius: BorderRadius.circular(18)),
                child: Icon(Icons.menu_book_rounded, color: scheme.secondary),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Continue Quran', style: TextStyle(fontWeight: FontWeight.w800)),
                    SizedBox(height: 4),
                    Text('Return to your reading and keep the habit going.'),
                  ],
                ),
              ),
              FilledButton.tonal(onPressed: onOpen, child: const Text('Read')),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.onQuran, required this.onDhikr, required this.onPrayer, required this.onQibla});
  final VoidCallback onQuran;
  final VoidCallback onDhikr;
  final VoidCallback onPrayer;
  final VoidCallback onQibla;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _ActionTile(icon: Icons.menu_book_rounded, label: 'Quran', onTap: onQuran)),
        const SizedBox(width: 10),
        Expanded(child: _ActionTile(icon: Icons.favorite_outline_rounded, label: 'Dhikr', onTap: onDhikr)),
        const SizedBox(width: 10),
        Expanded(child: _ActionTile(icon: Icons.access_time_rounded, label: 'Prayer', onTap: onPrayer)),
        const SizedBox(width: 10),
        Expanded(child: _ActionTile(icon: Icons.explore_outlined, label: 'Qibla', onTap: onQibla)),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
          child: Column(
            children: [
              Icon(icon),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReflectionCard extends StatelessWidget {
  const _ReflectionCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.auto_awesome_rounded, color: scheme.primary),
            const SizedBox(height: 14),
            const Text('A little consistency can transform an ordinary day into a meaningful one.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, height: 1.35)),
            const SizedBox(height: 8),
            Text('Your daily reflection area will connect to verified Quran and Islamic content in the content phase.', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationQiblaPrayerDataCubit, LocationQiblaPrayerDataState>(
      builder: (context, location) {
        final locationReady = location.latLon != null;
        final scheme = Theme.of(context).colorScheme;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(child: Text('Daily foundation', style: TextStyle(fontWeight: FontWeight.w800))),
                    Text(
                      locationReady ? 'Location ready' : 'Location not set',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: locationReady ? scheme.primary : scheme.onSurfaceVariant, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(borderRadius: BorderRadius.circular(20), child: const LinearProgressIndicator(value: 0.0, minHeight: 8)),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Prayer, Quran and Dhikr tracking will become live as their phases are completed.', style: Theme.of(context).textTheme.bodySmall),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))),
        if (action != null && onAction != null) TextButton(onPressed: onAction, child: Text(action!)),
      ],
    );
  }
}
