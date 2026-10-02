import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../goals/presentation/daily_goals_screen.dart';
import '../../islamic_calendar/presentation/islamic_calendar_screen.dart';
import '../../fasting/presentation/fasting_launcher_screen.dart';
import '../../../src/screen/prayer_time/prayer_time_page.dart';
import '../../../src/features/quran/presentation/quran_reader_screen.dart';
import '../../../src/screen/azkar/azkar_categories_screen.dart';
import '../../../src/screen/qibla/qibla_direction.dart';
import '../../../src/theme/app_colors.dart';
import '../../../src/theme/app_widgets.dart';

class AthanFeatureCenter extends StatelessWidget {
  const AthanFeatureCenter({super.key});

  @override
  Widget build(BuildContext context) {
    final groups = <_FeatureGroup>[
      _FeatureGroup('Prayer & Qibla', Icons.mosque_rounded, [
        _Feature('Prayer times', 'Live Salah schedule and settings', Icons.access_time_rounded, const PrayerTimePage()),
        _Feature('Prayer tracker', 'Track your five daily prayers', Icons.check_circle_outline_rounded, const PrayerTrackerScreen()),
        _Feature('Qibla', 'Find the direction of the Kaaba', Icons.explore_rounded, const QiblaDirection()),
        _Feature('Nearby mosques', 'Open a nearby Masjid search', Icons.location_city_rounded, null, _openMosques),
      ]),
      _FeatureGroup('Quran & remembrance', Icons.auto_stories_rounded, [
        _Feature('Holy Quran', 'Read, listen, bookmark and study', Icons.menu_book_rounded, const QuranReaderScreen()),
        _Feature('Dhikr & Tasbih', 'Daily remembrance and counter', Icons.fingerprint_rounded, const AzkarCategoriesScreen()),
        _Feature('99 Names of Allah', 'Learn and reflect on the Names', Icons.favorite_outline_rounded, const NamesOfAllahScreen()),
        _Feature('Daily goals', 'Build a consistent worship routine', Icons.flag_outlined, const DailyGoalsScreen()),
      ]),
      _FeatureGroup('Calendar & fasting', Icons.calendar_month_rounded, [
        _Feature('Islamic calendar', 'Hijri dates and Islamic events', Icons.calendar_month_outlined, const IslamicCalendarScreen()),
        _Feature('Fasting', 'Ramadan and fasting tools', Icons.nightlight_outlined, const FastingLauncherScreen()),
        _Feature('Zakat calculator', 'Estimate your annual Zakat', Icons.calculate_outlined, const ZakatCalculatorScreen()),
        _Feature('Hajj & Umrah', 'Step-by-step worship guides', Icons.flight_takeoff_rounded, const HajjUmrahGuideScreen()),
      ]),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Explore Imaanly')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
        children: [
          const HeroCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.auto_awesome_rounded, color: AppColors.gold, size: 30),
              SizedBox(height: 14),
              Text('Your complete Islamic companion', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
              SizedBox(height: 7),
              Text('Prayer, Quran, Qibla, Dhikr, fasting, Zakat and more — designed around your daily worship.', style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.45)),
            ]),
          ),
          const SizedBox(height: 22),
          for (final group in groups) ...[
            _GroupHeader(group: group),
            const SizedBox(height: 10),
            ...group.features.map((feature) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _FeatureTile(feature: feature))),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  static Future<void> _openMosques(BuildContext context) => _openSearch('mosques near me');
  static Future<void> _openSearch(String query) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _FeatureGroup { const _FeatureGroup(this.title, this.icon, this.features); final String title; final IconData icon; final List<_Feature> features; }
class _Feature { const _Feature(this.title, this.subtitle, this.icon, this.page, [this.action]); final String title; final String subtitle; final IconData icon; final Widget? page; final Future<void> Function(BuildContext)? action; }
class _GroupHeader extends StatelessWidget { const _GroupHeader({required this.group}); final _FeatureGroup group; @override Widget build(BuildContext context) => Row(children: [Icon(group.icon, size: 19, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 8), Text(group.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))]); }
class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.feature}); final _Feature feature;
  @override Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SoftCard(
      onTap: () { if (feature.page != null) { Navigator.of(context).push(MaterialPageRoute(builder: (_) => feature.page!)); } else if (feature.action != null) { feature.action!(context); } },
      child: Row(children: [
        IconBadge(icon: feature.icon),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(feature.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)), const SizedBox(height: 4), Text(feature.subtitle, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12.5, height: 1.3))])),
        Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
      ]),
    );
  }
}

class PrayerTrackerScreen extends StatefulWidget { const PrayerTrackerScreen({super.key}); @override State<PrayerTrackerScreen> createState() => _PrayerTrackerScreenState(); }
class _PrayerTrackerScreenState extends State<PrayerTrackerScreen> {
  final _names = const ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']; final _done = <bool>[false, false, false, false, false];
  @override Widget build(BuildContext context) { final completed = _done.where((e) => e).length; return Scaffold(appBar: AppBar(title: const Text('Prayer tracker')), body: ListView(padding: const EdgeInsets.all(16), children: [Card(child: Padding(padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('$completed of 5 prayers completed', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)), const SizedBox(height: 12), LinearProgressIndicator(value: completed / 5), const SizedBox(height: 8), Text('Keep your daily Salah streak going.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))]))), const SizedBox(height: 12), for (var i = 0; i < _names.length; i++) Card(child: CheckboxListTile(value: _done[i], onChanged: (v) => setState(() => _done[i] = v ?? false), title: Text(_names[i], style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: const Text('Today'), secondary: Icon(_done[i] ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded))) ])); }
}

class ZakatCalculatorScreen extends StatefulWidget { const ZakatCalculatorScreen({super.key}); @override State<ZakatCalculatorScreen> createState() => _ZakatCalculatorScreenState(); }
class _ZakatCalculatorScreenState extends State<ZakatCalculatorScreen> {
  final _cash = TextEditingController(), _gold = TextEditingController(), _silver = TextEditingController(), _investments = TextEditingController(), _debts = TextEditingController();
  double get _assets => [_cash, _gold, _silver, _investments].map((c) => double.tryParse(c.text) ?? 0).fold(0, (a, b) => a + b);
  double get _net => (_assets - (double.tryParse(_debts.text) ?? 0)).clamp(0, double.infinity);
  @override void dispose() { for (final c in [_cash, _gold, _silver, _investments, _debts]) c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) { final zakat = _net * .025; final fields = [('Cash & bank', _cash), ('Gold value', _gold), ('Silver value', _silver), ('Investments', _investments), ('Short-term debts', _debts)]; return Scaffold(appBar: AppBar(title: const Text('Zakat calculator')), body: ListView(padding: const EdgeInsets.all(16), children: [const Text('Enter approximate values in your currency.'), const SizedBox(height: 16), for (final item in fields) Padding(padding: const EdgeInsets.only(bottom: 10), child: TextField(controller: item.$2, keyboardType: const TextInputType.numberWithOptions(decimal: true), onChanged: (_) => setState(() {}), decoration: InputDecoration(labelText: item.$1, prefixIcon: const Icon(Icons.payments_outlined)))), Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Estimated Zakat', style: TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 5), Text(zakat.toStringAsFixed(2), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)), const SizedBox(height: 6), const Text('Estimate only: confirm Nisab, liabilities and asset eligibility with a qualified scholar.')]))) ])); }
}

class NamesOfAllahScreen extends StatelessWidget {
  const NamesOfAllahScreen({super.key});
  static const _names = [('Ar-Rahman', 'The Most Merciful'), ('Ar-Raheem', 'The Especially Merciful'), ('Al-Malik', 'The King'), ('Al-Quddus', 'The Holy'), ('As-Salam', 'The Source of Peace'), ('Al-Mu’min', 'The Giver of Security'), ('Al-Aziz', 'The Almighty'), ('Al-Hakim', 'The All-Wise'), ('Al-Ghaffar', 'The Constant Forgiver'), ('Al-Wadud', 'The Most Loving'), ('Al-Alim', 'The All-Knowing'), ('Al-Latif', 'The Subtle and Kind')];
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('99 Names of Allah')), body: ListView.separated(padding: const EdgeInsets.all(16), itemCount: _names.length, separatorBuilder: (_, __) => const SizedBox(height: 8), itemBuilder: (_, i) => Card(child: ListTile(leading: CircleAvatar(child: Text('${i + 1}')), title: Text(_names[i].$1, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(_names[i].$2)))));
}

class HajjUmrahGuideScreen extends StatelessWidget {
  const HajjUmrahGuideScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Hajj & Umrah guide')), body: ListView(padding: const EdgeInsets.all(16), children: const [_GuideCard('Before the journey', 'Learn the rites, prepare Ihram, understand your route, arrange documents and consult a qualified scholar for questions specific to your situation.'), _GuideCard('Ihram & intention', 'Enter Ihram at the appropriate Miqat, make the intention and recite the Talbiyah.'), _GuideCard('Tawaf', 'Circumambulate the Kaaba seven times, following the established Sunnah and avoiding harm or crowding.'), _GuideCard('Sa’i', 'Walk between Safa and Marwah seven circuits, remembering Allah and following the established rites.'), _GuideCard('Completion', 'Follow the required shaving or trimming and other rites for the pilgrimage type you are performing.')]));
}
class _GuideCard extends StatelessWidget { const _GuideCard(this.title, this.body); final String title, body; @override Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 10), child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)), const SizedBox(height: 7), Text(body, style: const TextStyle(height: 1.5))]))); }
