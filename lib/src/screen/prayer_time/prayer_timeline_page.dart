import "dart:async";

import "package:adhan_dart/adhan_dart.dart" hide Prayer;
import "package:imaanly/features/worship/data/worship_activity_repository.dart";
import "package:imaanly/features/worship/domain/worship_activity.dart";
import "package:imaanly/src/core/storage/app_boxes.dart";
import "package:imaanly/src/screen/location_handler/cubit/location_data_qibla_data_cubit.dart";
import "package:imaanly/src/screen/location_handler/location_aquire.dart";
import "package:imaanly/src/screen/location_handler/model/location_data_qibla_data_state.dart";
import "package:imaanly/src/screen/prayer_time/models/calculation_method_enum.dart";
import "package:imaanly/src/screen/prayer_time/models/prayer_enum.dart";
import "package:imaanly/src/screen/prayer_time/prayer_time_functions/prayer_time_helper.dart";
import "package:imaanly/src/utils/format_time_of_day.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:google_fonts/google_fonts.dart";
import "package:hive_ce_flutter/hive_flutter.dart";

/// A focused visual timeline for the five daily prayers.
///
/// Prayer completion is an explicit user action. Passing the prayer time never
/// marks a Salah as completed automatically.
class PrayerTimelinePage extends StatefulWidget {
  const PrayerTimelinePage({super.key});

  @override
  State<PrayerTimelinePage> createState() => _PrayerTimelinePageState();
}

class _PrayerTimelinePageState extends State<PrayerTimelinePage> {
  DateTime _now = DateTime.now();
  Timer? _ticker;
  Set<String> _completedPrayers = <String>{};
  WorshipActivityRepository? _worshipRepository;

  IconData _icon(Prayer prayer) {
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
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    _loadWorshipState();
  }

  Future<void> _loadWorshipState() async {
    try {
      final box = Hive.isBoxOpen(AppBoxes.worshipActivity)
          ? Hive.box<Map>(AppBoxes.worshipActivity)
          : await Hive.openBox<Map>(AppBoxes.worshipActivity);
      final repository = WorshipActivityRepository(HiveWorshipActivityBackend(box));
      final summary = await repository.getDailySummary(DateTime.now());
      final activities = await repository.getAll();
      if (!mounted) return;
      setState(() {
        _worshipRepository = repository;
        _completedPrayers = activities
            .where((activity) =>
                activity.type == WorshipActivityType.salah &&
                activity.dateKey == summary.dateKey &&
                activity.reference != null)
            .map((activity) => activity.reference!)
            .toSet();
      });
    } catch (_) {
      // Prayer times remain fully usable if local activity storage fails.
    }
  }

  Future<void> _markPrayerCompleted(Prayer prayer) async {
    final repository = _worshipRepository;
    if (repository == null || _completedPrayers.contains(prayer.name)) return;

    await repository.record(
      WorshipActivity.salah(
        prayer: prayer.name,
        completedAt: DateTime.now(),
      ),
    );
    if (!mounted) return;
    setState(() => _completedPrayers = {..._completedPrayers, prayer.name});
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  PrayerTimes _times(LocationQiblaPrayerDataState state, DateTime date) {
    final method = state.calculationMethod?.method ?? CalculationMethod.egyptian;
    final parameters = getCalculationParameters(fromLibraryEnum(method));
    parameters.madhab = state.madhab ?? Madhab.shafi;

    return PrayerTimes(
      coordinates: Coordinates(state.latLon!.latitude, state.latLon!.longitude),
      date: date,
      calculationParameters: parameters,
      precision: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text("Prayer Timeline"),
        centerTitle: true,
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: BlocBuilder<LocationQiblaPrayerDataCubit, LocationQiblaPrayerDataState>(
        builder: (context, state) {
          if (state.latLon == null) return const LocationAcquire();
          final today = _times(state, _now);
          final tomorrow = _times(state, _now.add(const Duration(days: 1)));
          final calculator = const PrayerScheduleCalculator();
          final schedule = calculator.calculate(today);
          final current = calculator.current(schedule, _now);
          final next = calculator.next(schedule, _now);
          final nextEntry = next ?? calculator.nextDayFajr(tomorrow);
          final sunrise = calculator.sunrise(today);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
            children: [
              _buildHero(context, current, nextEntry, cs),
              const SizedBox(height: 20),
              Text("Today's Salah", style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              for (final entry in schedule) ...[
                _buildPrayerCard(
                  context,
                  entry.prayer,
                  entry.time,
                  entry.prayer == current?.prayer,
                  entry.prayer == next?.prayer,
                  _completedPrayers.contains(entry.prayer.name),
                  cs,
                ),
                const SizedBox(height: 10),
              ],
              _buildSunrise(context, sunrise.time, cs),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHero(BuildContext context, PrayerScheduleEntry? current, PrayerScheduleEntry next, ColorScheme cs) {
    final remaining = next.time.difference(_now);
    final hours = remaining.inHours.clamp(0, 99).toString().padLeft(2, "0");
    final minutes = (remaining.inMinutes % 60).clamp(0, 59).toString().padLeft(2, "0");
    final seconds = (remaining.inSeconds % 60).clamp(0, 59).toString().padLeft(2, "0");

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [cs.primary, cs.primary.withValues(alpha: 0.78)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("NEXT PRAYER", style: GoogleFonts.dmMono(fontSize: 12, fontWeight: FontWeight.w700, color: cs.onPrimary.withValues(alpha: 0.78))),
        const SizedBox(height: 8),
        Text(PrayerTimeHelper.localizedPrayerName(context, next.prayer) ?? next.prayer.name, style: GoogleFonts.cairo(fontSize: 28, fontWeight: FontWeight.w900, color: cs.onPrimary)),
        const SizedBox(height: 12),
        Text("$hours:$minutes:$seconds", style: GoogleFonts.dmMono(fontSize: 34, fontWeight: FontWeight.w900, color: cs.onPrimary)),
        if (current != null) ...[
          const SizedBox(height: 8),
          Text("Current: ${PrayerTimeHelper.localizedPrayerName(context, current.prayer) ?? current.prayer.name}", style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700, color: cs.onPrimary.withValues(alpha: 0.82))),
        ],
      ]),
    );
  }

  Widget _buildPrayerCard(
    BuildContext context,
    Prayer prayer,
    DateTime time,
    bool isCurrent,
    bool isNext,
    bool isCompleted,
    ColorScheme cs,
  ) {
    final accent = isCompleted ? cs.primary : isCurrent ? cs.primary : isNext ? cs.secondary : cs.outline;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted
            ? cs.primary.withValues(alpha: 0.12)
            : isCurrent
                ? cs.primary.withValues(alpha: 0.10)
                : cs.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted || isCurrent ? cs.primary.withValues(alpha: 0.45) : cs.outlineVariant,
          width: isCompleted || isCurrent ? 2 : 1,
        ),
      ),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: accent.withValues(alpha: 0.14), shape: BoxShape.circle), child: Icon(isCompleted ? Icons.check_rounded : _icon(prayer), color: accent)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Flexible(child: Text(PrayerTimeHelper.localizedPrayerName(context, prayer) ?? prayer.name, style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w900))),
            if (isCurrent || isNext || isCompleted) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(8)),
                child: Text(isCompleted ? "DONE" : isCurrent ? "NOW" : "NEXT", style: GoogleFonts.dmMono(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(isCompleted ? "Salah recorded today" : isCurrent ? "Prayer time is in progress" : isNext ? "Prepare for Salah" : "Daily prayer", style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
        ])),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(formatTimeOfDay(context, TimeOfDay.fromDateTime(time)), style: GoogleFonts.dmMono(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          if (isCompleted)
            Icon(Icons.verified_rounded, size: 20, color: cs.primary)
          else
            TextButton(
              onPressed: _worshipRepository == null ? null : () => _markPrayerCompleted(prayer),
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact, padding: const EdgeInsets.symmetric(horizontal: 8)),
              child: const Text("Mark done"),
            ),
        ]),
      ]),
    );
  }

  Widget _buildSunrise(BuildContext context, DateTime time, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: cs.surfaceContainerHighest.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(18), border: Border.all(color: cs.outlineVariant)),
      child: Row(children: [
        Icon(Icons.wb_sunny_outlined, color: cs.secondary),
        const SizedBox(width: 12),
        Expanded(child: Text("Sunrise", style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w800))),
        Text(formatTimeOfDay(context, TimeOfDay.fromDateTime(time)), style: GoogleFonts.dmMono(fontSize: 16, fontWeight: FontWeight.w800)),
      ]),
    );
  }
}
