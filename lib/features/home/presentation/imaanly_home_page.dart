import 'dart:async';

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

import '../../ath_an/presentation/athan_feature_center.dart';
import '../../goals/presentation/daily_goals_screen.dart';
import '../../../src/features/quran/presentation/quran_reader_screen.dart';
import '../../../src/screen/azkar/azkar_categories_screen.dart';
import '../../../src/screen/location_handler/model/location_data_qibla_data_state.dart';
import '../../../src/screen/prayer_time/prayer_time_page.dart';
import '../../../src/screen/qibla/qibla_direction.dart';
import '../../../src/screen/settings/settings_page.dart';

class ImaanlyHomePage extends StatefulWidget {
  const ImaanlyHomePage({super.key});
  @override State<ImaanlyHomePage> createState() => _ImaanlyHomePageState();
}

class _ImaanlyHomePageState extends State<ImaanlyHomePage> {
  Timer? _timer;
  DateTime _now = DateTime.now();
  PrayerTimes? _times;
  Prayer? _next;
  String _location = 'Lahore';

  @override void initState() { super.initState(); _refresh(); _timer = Timer.periodic(const Duration(seconds: 1), (_) { if (!mounted) return; setState(() { _now = DateTime.now(); _refresh(); }); }); }
  @override void dispose() { _timer?.cancel(); super.dispose(); }

  void _refresh() {
    final state = context.read<LocationQiblaPrayerDataCubit>().state;
    final point = state.latLon;
    final coordinates = point == null ? Coordinates(31.5204, 74.3587) : Coordinates(point.latitude, point.longitude);
    final params = state.calculationMethod ?? CalculationParameters(fajrAngle: 18, ishaAngle: 18, method: CalculationMethod.karachi);
    _times = PrayerTimes(coordinates: coordinates, date: _now, calculationParameters: params, precision: true);
    _next = _times!.nextPrayer(date: _now);
    if (point != null) _resolveLocation(point.latitude, point.longitude);
  }

  Future<void> _resolveLocation(double lat, double lon) async {
    try {
      final places = await placemarkFromCoordinates(lat, lon);
      if (!mounted || places.isEmpty) return;
      final p = places.first;
      final value = [p.locality, p.administrativeArea].whereType<String>().where((v) => v.trim().isNotEmpty).join(', ');
      if (value.isNotEmpty && value != _location) setState(() => _location = value);
    } catch (_) {}
  }

  void _open(Widget page) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  String _name(Prayer? p) => switch (p) { Prayer.fajr => 'Fajr', Prayer.dhuhr => 'Dhuhr', Prayer.asr => 'Asr', Prayer.maghrib => 'Maghrib', Prayer.isha => 'Isha', _ => 'Prayer' };
  String _time(Prayer? p) => p == null || _times == null ? '--:--' : DateFormat('h:mm a').format(_times!.timeForPrayer(p));
  Duration get _remaining { if (_next == null || _times == null) return Duration.zero; final d = _times!.timeForPrayer(_next!).difference(_now); return d.isNegative ? Duration.zero : d; }
  String _countdown(Duration d) => '${d.inHours.toString().padLeft(2, '0')}:${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  IconData _icon(Prayer p) => switch (p) { Prayer.fajr => Icons.wb_twilight_rounded, Prayer.dhuhr => Icons.wb_sunny_rounded, Prayer.asr => Icons.wb_cloudy_rounded, Prayer.maghrib => Icons.wb_twilight_rounded, Prayer.isha => Icons.nightlight_round, _ => Icons.access_time_rounded };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final prayers = const [Prayer.fajr, Prayer.dhuhr, Prayer.asr, Prayer.maghrib, Prayer.isha];
    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(child: CustomScrollView(slivers: [
        SliverPadding(padding: const EdgeInsets.fromLTRB(18, 16, 18, 34), sliver: SliverToBoxAdapter(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1120), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Assalamu Alaikum', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)), const SizedBox(height: 4), Row(children: [Icon(Icons.location_on_outlined, size: 16, color: cs.primary), const SizedBox(width: 5), Flexible(child: Text(_location, style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600)))])])), IconButton(onPressed: () => _open(const SettingsPage()), icon: const Icon(Icons.settings_outlined)), const CircleAvatar(radius: 20, child: Icon(Icons.person_outline_rounded))]),
          const SizedBox(height: 8), Text(DateFormat('EEEE, d MMMM yyyy').format(_now), style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
          const SizedBox(height: 18),
          Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [cs.primary, cs.primaryContainer])), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Container(width: 44, height: 44, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .14), borderRadius: BorderRadius.circular(14)), child: Icon(_next == null ? Icons.mosque_rounded : _icon(_next!), color: Colors.white)), const SizedBox(width: 12), Expanded(child: Text(_next == null ? 'Prayer times' : 'Next prayer • ${_name(_next)}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)))]),
            const SizedBox(height: 22), Text(_next == null ? 'Set your location' : _countdown(_remaining), style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: -1)),
            const SizedBox(height: 5), Text(_next == null ? 'Open Prayer Times to configure Salah.' : '${_time(_next)} • ${_location}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 18), SizedBox(height: 46, child: FilledButton.tonal(onPressed: () => _open(const PrayerTimePage()), style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: cs.primary), child: const Text('Open prayer times'))),
          ])),
          const SizedBox(height: 24), _Section(title: 'Today’s prayers', action: 'View all', onTap: () => _open(const PrayerTimePage())), const SizedBox(height: 10),
          SizedBox(height: 112, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: prayers.length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, i) { final p = prayers[i]; final active = p == _next; return SizedBox(width: 118, child: Card(color: active ? cs.primaryContainer : null, child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(_icon(p), size: 20, color: active ? cs.primary : cs.onSurfaceVariant), const Spacer(), Text(_name(p), style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 2), Text(_time(p), style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant))])))); })),
          const SizedBox(height: 24), _Section(title: 'Quick access', action: 'Explore all', onTap: () => _open(const AthanFeatureCenter())), const SizedBox(height: 10),
          GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 4, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.05, children: [
            _Quick('Quran', Icons.menu_book_rounded, () => _open(const QuranReaderScreen())), _Quick('Qibla', Icons.explore_rounded, () => _open(const QiblaDirection())), _Quick('Dhikr', Icons.fingerprint_rounded, () => _open(const AzkarCategoriesScreen())), _Quick('Goals', Icons.flag_outlined, () => _open(const DailyGoalsScreen())),
          ]),
          const SizedBox(height: 24),
          _Section(title: 'More for your journey', action: 'Open Explore', onTap: () => _open(const AthanFeatureCenter())), const SizedBox(height: 10),
          Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(children: [
            _MoreRow(Icons.calendar_month_outlined, 'Islamic calendar', 'Hijri dates and events', () => _open(const AthanFeatureCenter())),
            const Divider(height: 24), _MoreRow(Icons.calculate_outlined, 'Zakat calculator', 'Estimate your annual Zakat', () => _open(const AthanFeatureCenter())),
            const Divider(height: 24), _MoreRow(Icons.mosque_outlined, 'Mosque & Halal finder', 'Find nearby places', () => _open(const AthanFeatureCenter())),
          ]))),
        ]))))
      ])),
      bottomNavigationBar: NavigationBar(selectedIndex: 0, destinations: const [NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'), NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book_rounded), label: 'Quran'), NavigationDestination(icon: Icon(Icons.mosque_outlined), selectedIcon: Icon(Icons.mosque_rounded), label: 'Prayer'), NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore_rounded), label: 'Explore')], onDestinationSelected: (i) { if (i == 1) _open(const QuranReaderScreen()); if (i == 2) _open(const PrayerTimePage()); if (i == 3) _open(const AthanFeatureCenter()); }),
      floatingActionButton: FloatingActionButton.small(onPressed: () => _open(const AthanFeatureCenter()), tooltip: 'Explore Imaanly', child: const Icon(Icons.auto_awesome_rounded)),
    );
  }
}

class _Section extends StatelessWidget { const _Section({required this.title, required this.action, required this.onTap}); final String title, action; final VoidCallback onTap; @override Widget build(BuildContext context) => Row(children: [Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))), TextButton(onPressed: onTap, child: Text(action))]); }
class _Quick extends StatelessWidget { const _Quick(this.title, this.icon, this.onTap); final String title; final IconData icon; final VoidCallback onTap; @override Widget build(BuildContext context) { final cs = Theme.of(context).colorScheme; return Card(elevation: 0, child: InkWell(borderRadius: BorderRadius.circular(16), onTap: onTap, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: cs.primary, size: 25), const SizedBox(height: 7), Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))])); } }
class _MoreRow extends StatelessWidget { const _MoreRow(this.icon, this.title, this.subtitle, this.onTap); final IconData icon; final String title, subtitle; final VoidCallback onTap; @override Widget build(BuildContext context) { final cs = Theme.of(context).colorScheme; return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: cs.primary)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text(subtitle, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12))])), Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant)])); } }
