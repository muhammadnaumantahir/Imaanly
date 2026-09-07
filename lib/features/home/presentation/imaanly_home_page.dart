import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../fasting/presentation/fasting_launcher_screen.dart';
import '../../goals/presentation/daily_goals_screen.dart';
import '../../islamic_calendar/presentation/islamic_calendar_screen.dart';
import '../../personalization/presentation/personalization_cubit.dart';
import '../../worship_dashboard/presentation/worship_dashboard_screen.dart';
import '../../../src/features/islamic_knowledge/presentation/islamic_knowledge_screen.dart';
import '../../../src/features/quran/presentation/quran_reader_screen.dart';
import '../../../src/screen/azkar/azkar_categories_screen.dart';
import '../../../src/screen/prayer_time/prayer_time_page.dart';
import '../../../src/screen/qibla/qibla_direction.dart';
import '../../../src/screen/settings/settings_page.dart';

class ImaanlyHomePage extends StatelessWidget {
  const ImaanlyHomePage({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final shortcuts = context.select<PersonalizationCubit, List<String>>((cubit) => cubit.state.homeShortcuts).toSet();
    final date = DateFormat('EEEE, d MMMM').format(DateTime.now());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Imaanly', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(onPressed: () => _open(context, const IslamicKnowledgeScreen()), icon: const Icon(Icons.auto_stories_outlined), tooltip: 'Knowledge'),
          IconButton(onPressed: () => _open(context, const SettingsPage()), icon: const Icon(Icons.settings_outlined), tooltip: 'Settings'),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Assalamu Alaikum', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text(date),
            const SizedBox(height: 14),
            const Text('Build a little consistency into your day, one act of worship at a time.'),
          ]))),
          const SizedBox(height: 18),
          _Section(title: 'Quick actions', child: Wrap(spacing: 10, runSpacing: 10, children: [
            if (shortcuts.contains('quran')) _Action(label: 'Quran', icon: Icons.menu_book_outlined, onTap: () => _open(context, const QuranReaderScreen())),
            if (shortcuts.contains('dhikr')) _Action(label: 'Dhikr', icon: Icons.favorite_outline, onTap: () => _open(context, const AzkarCategoriesScreen())),
            if (shortcuts.contains('salah')) _Action(label: 'Prayer', icon: Icons.mosque_outlined, onTap: () => _open(context, const PrayerTimePage())),
            if (shortcuts.contains('qibla')) _Action(label: 'Qibla', icon: Icons.explore_outlined, onTap: () => _open(context, const QiblaDirection())),
          ])),
          const SizedBox(height: 18),
          _Section(title: 'Explore', child: Column(children: [
            _ExploreTile(title: 'Islamic Knowledge', subtitle: 'Hadith, Sunnah, Tafsir and resources', icon: Icons.auto_stories_outlined, onTap: () => _open(context, const IslamicKnowledgeScreen())),
            _ExploreTile(title: 'Worship Dashboard', subtitle: 'Review your recent worship activity', icon: Icons.insights_outlined, onTap: () => _open(context, const WorshipDashboardScreen())),
            _ExploreTile(title: 'Islamic Calendar', subtitle: 'Browse Hijri dates and occasions', icon: Icons.calendar_month_outlined, onTap: () => _open(context, const IslamicCalendarScreen())),
            _ExploreTile(title: 'Fasting Tracker', subtitle: 'Keep your private fasting record', icon: Icons.nightlight_outlined, onTap: () => _open(context, const FastingLauncherScreen())),
            _ExploreTile(title: 'Daily Goals', subtitle: 'Set and review worship targets', icon: Icons.flag_outlined, onTap: () => _open(context, const DailyGoalsScreen())),
          ])),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)), const SizedBox(height: 10), child]);
}

class _Action extends StatelessWidget {
  const _Action({required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(width: 105, child: Card(child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(14), child: Padding(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8), child: Column(children: [Icon(icon), const SizedBox(height: 8), Text(label, style: const TextStyle(fontWeight: FontWeight.w700))])))));
}

class _ExploreTile extends StatelessWidget {
  const _ExploreTile({required this.title, required this.subtitle, required this.icon, required this.onTap});
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(child: ListTile(onTap: onTap, leading: Icon(icon, color: Theme.of(context).colorScheme.primary), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(subtitle), trailing: const Icon(Icons.chevron_right_rounded)));
}
