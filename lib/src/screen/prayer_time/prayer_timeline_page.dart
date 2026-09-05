import "package:adhan_dart/adhan_dart.dart" hide Prayer;
import "package:al_furkan/src/screen/location_handler/cubit/location_data_qibla_data_cubit.dart";
import "package:al_furkan/src/screen/location_handler/location_aquire.dart";
import "package:al_furkan/src/screen/location_handler/model/location_data_qibla_data_state.dart";
import "package:al_furkan/src/screen/prayer_time/models/prayer_enum.dart";
import "package:al_furkan/src/screen/prayer_time/prayer_time_extensions.dart";
import "package:al_furkan/src/screen/prayer_time/prayer_time_functions/prayer_time_helper.dart";
import "package:al_furkan/src/utils/format_time_of_day.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:google_fonts/google_fonts.dart";
import "package:imaanly/features/prayer/domain/prayer_schedule.dart";

/// A focused visual timeline for the five daily prayers.
///
/// This is intentionally separate from the mature TimeListOfPrayers screen so
/// the existing notification, Iqamah, adjustment and settings flows remain
/// untouched while the Imaanly prayer experience evolves incrementally.
class PrayerTimelinePage extends StatefulWidget {
  const PrayerTimelinePage({super.key});

  @override
  State<PrayerTimelinePage> createState() => _PrayerTimelinePageState();
}

class _PrayerTimelinePageState extends State<PrayerTimelinePage> {
  static const _prayers = <Prayer>[
    Prayer.fajr,
    Prayer.dhuhr,
    Prayer.asr,
    Prayer.maghrib,
    Prayer.isha,
  ];

  DateTime _now = DateTime.now();

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
    Stream.periodic(const Duration(seconds: 1)).listen((_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  PrayerTimes _times(LocationQiblaPrayerDataState state) {
    final parameters = CalculationMethodParameters.karachi()
      ..madhab = state.madhab ?? Madhab.hanafi;
    return PrayerTimes(
      coordinates: Coordinates(state.latLon!.latitude, state.latLon!.longitude),
      date: _now,
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
          final times = _times(state);
          final schedule = const PrayerScheduleCalculator().calculate(times);
          final current = const PrayerScheduleCalculator().current(schedule, _now);
          final next = const PrayerScheduleCalculator().next(schedule, _now);
          final sunrise = const PrayerScheduleCalculator().sunrise(times);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
            children: [
              _buildHero(context, current, next, cs),
              const SizedBox(height: 20),
              Text(
                "Today's Salah",
                style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              for (final entry in schedule) ...[
                _buildPrayerCard(context, entry.prayer, entry.time, entry.prayer == current?.prayer, entry.prayer == next?.prayer, cs),
                const SizedBox(height: 10),
              ],
              _buildSunrise(context, sunrise.time, cs),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHero(BuildContext context, PrayerScheduleEntry? current, PrayerScheduleEntry? next, ColorScheme cs) {
    final target = next?.time;
    final remaining = target == null ? Duration.zero : target.difference(_now);
    final hours = remaining.inHours.clamp(0, 99).toString().padLeft(2, "0");
    final minutes = (remaining.inMinutes % 60).clamp(0, 59).toString().padLeft(2, "0");
    final seconds = (remaining.inSeconds % 60).clamp(0, 59).toString().padLeft(2, "0");

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.primary.withValues(alpha: 0.78)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("NEXT PRAYER", style: GoogleFonts.dmMono(fontSize: 12, fontWeight: FontWeight.w700, color: cs.onPrimary.withValues(alpha: 0.78))),
          const SizedBox(height: 8),
          Text(
            next == null ? "Fajr tomorrow" : (PrayerTimeHelper.localizedPrayerName(context, next.prayer) ?? next.prayer.name),
            style: GoogleFonts.cairo(fontSize: 28, fontWeight: FontWeight.w900, color: cs.onPrimary),
          ),
          const SizedBox(height: 12),
          Text("$hours:$minutes:$seconds", style: GoogleFonts.dmMono(fontSize: 34, fontWeight: FontWeight.w900, color: cs.onPrimary)),
          if (current != null) ...[
            const SizedBox(height: 8),
            Text(
              "Current: ${PrayerTimeHelper.localizedPrayerName(context, current.prayer) ?? current.prayer.name}",
              style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700, color: cs.onPrimary.withValues(alpha: 0.82)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPrayerCard(BuildContext context, Prayer prayer, DateTime time, bool isCurrent, bool isNext, ColorScheme cs) {
    final accent = isCurrent ? cs.primary : isNext ? cs.secondary : cs.outline;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrent ? cs.primary.withValues(alpha: 0.10) : cs.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isCurrent ? cs.primary.withValues(alpha: 0.45) : cs.outlineVariant, width: isCurrent ? 2 : 1),
      ),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: accent.withValues(alpha: 0.14), shape: BoxShape.circle), child: Icon(_icon(prayer), color: accent)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(PrayerTimeHelper.localizedPrayerName(context, prayer) ?? prayer.name, style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w900)),
                if (isCurrent || isNext) ...[
                  const SizedBox(width: 8),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(8)), child: Text(isCurrent ? "NOW" : "NEXT", style: GoogleFonts.dmMono(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white))),
                ],
              ),
              const SizedBox(height: 3),
              Text(isCurrent ? "Prayer time is in progress" : isNext ? "Prepare for Salah" : "Daily prayer", style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
            ]),
          ),
          Text(formatTimeOfDay(context, TimeOfDay.fromDateTime(time)), style: GoogleFonts.dmMono(fontSize: 20, fontWeight: FontWeight.w900)),
        ],
      ),
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
