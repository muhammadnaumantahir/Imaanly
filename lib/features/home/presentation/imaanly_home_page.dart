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

  void _open(BuildContext context, Widget page) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    final shortcuts = context.select<PersonalizationCubit, List<String>>((c) => c.state.homeShortcuts).toSet();
    final scheme = Theme.of(context).colorScheme;
    final date = DateFormat('EEEE, d MMMM').format(DateTime.now());
    return Scaffold(
      backgroundColor: scheme.surface,
      body: LayoutBuilder(builder: (context, size) {
        final desktop = size.maxWidth >= 1050;
        return Row(children: [
          if (desktop) _Rail(onOpen: (page) => _open(context, page)),
          Expanded(child: SafeArea(child: CustomScrollView(slivers: [
            SliverPadding(padding: EdgeInsets.fromLTRB(desktop ? 38 : 18, 22, desktop ? 38 : 18, 36), sliver: SliverToBoxAdapter(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1380), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _Header(date: date, onKnowledge: () => _open(context, const IslamicKnowledgeScreen()), onSettings: () => _open(context, const SettingsPage())),
              const SizedBox(height: 24),
              _Hero(onQuran: () => _open(context, const QuranReaderScreen()), onPrayer: () => _open(context, const PrayerTimePage())),
              const SizedBox(height: 28),
              const _SectionTitle('Daily essentials', 'Your most important worship tools, one tap away.'),
              const SizedBox(height: 14),
              _Essentials(shortcuts: shortcuts, onQuran: () => _open(context, const QuranReaderScreen()), onDhikr: () => _open(context, const AzkarCategoriesScreen()), onPrayer: () => _open(context, const PrayerTimePage()), onQibla: () => _open(context, const QiblaDirection())),
              const SizedBox(height: 28),
              const _SectionTitle('Explore Imaanly', 'Go deeper with tools designed for everyday consistency.'),
              const SizedBox(height: 14),
              _Explore(onOpen: (page) => _open(context, page)),
              const SizedBox(height: 28),
              _Journey(onGoals: () => _open(context, const DailyGoalsScreen())),
            ])))),),
          ]))),
        ]);
      }),
      bottomNavigationBar: LayoutBuilder(builder: (context, size) => size.maxWidth < 1050 ? NavigationBar(selectedIndex: 0, onDestinationSelected: (index) {
        switch (index) {
          case 0: break;
          case 1: _open(context, const QuranReaderScreen()); break;
          case 2: _open(context, const PrayerTimePage()); break;
          case 3: _open(context, const IslamicKnowledgeScreen()); break;
        }
      }, destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book_rounded), label: 'Quran'),
        NavigationDestination(icon: Icon(Icons.mosque_outlined), selectedIcon: Icon(Icons.mosque_rounded), label: 'Prayer'),
        NavigationDestination(icon: Icon(Icons.auto_stories_outlined), selectedIcon: Icon(Icons.auto_stories_rounded), label: 'Explore'),
      ]) : const SizedBox.shrink()),
    );
  }
}

class _Rail extends StatelessWidget {
  const _Rail({required this.onOpen});
  final ValueChanged<Widget> onOpen;
  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Container(width: 252, color: s.surfaceContainerLow, child: SafeArea(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Container(width: 44, height: 44, decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: LinearGradient(colors: [s.primary, s.secondary])), child: const Icon(Icons.auto_awesome_rounded, color: Colors.white)), const SizedBox(width: 12), Text('Imaanly', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900))]),
      const SizedBox(height: 34),
      _RailItem('Home', Icons.home_rounded, true, () {}),
      _RailItem('Quran', Icons.menu_book_rounded, false, () => onOpen(const QuranReaderScreen())),
      _RailItem('Prayer', Icons.mosque_rounded, false, () => onOpen(const PrayerTimePage())),
      _RailItem('Qibla', Icons.explore_rounded, false, () => onOpen(const QiblaDirection())),
      _RailItem('Dhikr', Icons.favorite_rounded, false, () => onOpen(const AzkarCategoriesScreen())),
      const Spacer(),
      _RailItem('Knowledge', Icons.auto_stories_rounded, false, () => onOpen(const IslamicKnowledgeScreen())),
      _RailItem('Settings', Icons.settings_rounded, false, () => onOpen(const SettingsPage())),
    ]))));
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem(this.label, this.icon, this.selected, this.onTap);
  final String label; final IconData icon; final bool selected; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Padding(padding: const EdgeInsets.only(bottom: 6), child: Material(color: selected ? s.primaryContainer : Colors.transparent, borderRadius: BorderRadius.circular(16), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13), child: Row(children: [Icon(icon, size: 21, color: selected ? s.primary : s.onSurfaceVariant), const SizedBox(width: 13), Text(label, style: TextStyle(fontWeight: selected ? FontWeight.w800 : FontWeight.w600))])))));
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.date, required this.onKnowledge, required this.onSettings});
  final String date; final VoidCallback onKnowledge; final VoidCallback onSettings;
  @override
  Widget build(BuildContext context) => Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Assalamu Alaikum', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -.8)), const SizedBox(height: 4), Text(date, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))])), _IconButton(Icons.auto_stories_outlined, onKnowledge), const SizedBox(width: 8), _IconButton(Icons.settings_outlined, onSettings), const SizedBox(width: 8), CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primaryContainer, child: Icon(Icons.person_rounded, color: Theme.of(context).colorScheme.primary))]);
}

class _IconButton extends StatelessWidget {
  const _IconButton(this.icon, this.onTap); final IconData icon; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(color: Theme.of(context).colorScheme.surfaceContainerHigh, shape: const CircleBorder(), child: InkWell(onTap: onTap, customBorder: const CircleBorder(), child: Padding(padding: const EdgeInsets.all(11), child: Icon(icon, size: 20))));
}

class _Hero extends StatelessWidget {
  const _Hero({required this.onQuran, required this.onPrayer}); final VoidCallback onQuran; final VoidCallback onPrayer;
  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Container(padding: const EdgeInsets.all(28), decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), gradient: LinearGradient(colors: [s.primary, s.secondary], begin: Alignment.topLeft, end: Alignment.bottomRight), boxShadow: [BoxShadow(color: s.primary.withValues(alpha: .22), blurRadius: 30, offset: const Offset(0, 14))]), child: LayoutBuilder(builder: (context, c) {
      final copy = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .15), borderRadius: BorderRadius.circular(99)), child: const Text('SMART WORSHIP COMPANION', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1))), const SizedBox(height: 16), const Text('Make space for what matters.', style: TextStyle(color: Colors.white, fontSize: 30, height: 1.08, fontWeight: FontWeight.w900, letterSpacing: -.7)), const SizedBox(height: 10), Text('Read, reflect, remember and build a beautiful worship routine — one moment at a time.', style: TextStyle(color: Colors.white.withValues(alpha: .88), height: 1.5, fontSize: 15)), const SizedBox(height: 20), Wrap(spacing: 10, runSpacing: 10, children: [FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: s.primary), onPressed: onQuran, icon: const Icon(Icons.menu_book_rounded), label: const Text('Open Quran')), OutlinedButton.icon(style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: BorderSide(color: Colors.white.withValues(alpha: .55))), onPressed: onPrayer, icon: const Icon(Icons.mosque_outlined), label: const Text('Prayer times'))])]);
      if (c.maxWidth < 650) return copy;
      return Row(children: [Expanded(flex: 3, child: copy), const SizedBox(width: 28), const Expanded(flex: 2, child: Center(child: Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 120)))]);
    }));
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, this.subtitle); final String title; final String subtitle;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))]);
}

class _Essentials extends StatelessWidget {
  const _Essentials({required this.shortcuts, required this.onQuran, required this.onDhikr, required this.onPrayer, required this.onQibla});
  final Set<String> shortcuts; final VoidCallback onQuran, onDhikr, onPrayer, onQibla;
  @override
  Widget build(BuildContext context) {
    final data = <_Tile>[
      if (shortcuts.contains('quran')) _Tile('Quran', 'Read & reflect', Icons.menu_book_rounded, onQuran),
      if (shortcuts.contains('dhikr')) _Tile('Dhikr', 'Remember Allah', Icons.favorite_rounded, onDhikr),
      if (shortcuts.contains('salah')) _Tile('Prayer', 'Today’s schedule', Icons.mosque_rounded, onPrayer),
      if (shortcuts.contains('qibla')) _Tile('Qibla', 'Find direction', Icons.explore_rounded, onQibla),
    ];
    return LayoutBuilder(builder: (context, c) { final cols = c.maxWidth >= 900 ? 4 : c.maxWidth >= 600 ? 2 : 1; return GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: data.length, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols, crossAxisSpacing: 14, mainAxisSpacing: 14, mainAxisExtent: 126), itemBuilder: (_, i) => _TileCard(data[i])); });
  }
}

class _Tile { const _Tile(this.title, this.subtitle, this.icon, this.onTap); final String title, subtitle; final IconData icon; final VoidCallback onTap; }

class _TileCard extends StatefulWidget { const _TileCard(this.data); final _Tile data; @override State<_TileCard> createState() => _TileCardState(); }
class _TileCardState extends State<_TileCard> {
  bool hover = false;
  @override
  Widget build(BuildContext context) { final s = Theme.of(context).colorScheme; return MouseRegion(onEnter: (_) => setState(() => hover = true), onExit: (_) => setState(() => hover = false), child: AnimatedContainer(duration: const Duration(milliseconds: 160), transform: Matrix4.translationValues(0, hover ? -3 : 0, 0), child: Material(color: s.surfaceContainer, borderRadius: BorderRadius.circular(22), child: InkWell(onTap: widget.data.onTap, borderRadius: BorderRadius.circular(22), child: Padding(padding: const EdgeInsets.all(17), child: Row(children: [Container(width: 50, height: 50, decoration: BoxDecoration(color: s.primaryContainer, borderRadius: BorderRadius.circular(16)), child: Icon(widget.data.icon, color: s.primary, size: 25)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(widget.data.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)), const SizedBox(height: 4), Text(widget.data.subtitle, style: TextStyle(color: s.onSurfaceVariant, fontSize: 12))])), Icon(Icons.arrow_forward_ios_rounded, size: 14, color: s.onSurfaceVariant)]))))); }
}

class _Explore extends StatelessWidget {
  const _Explore({required this.onOpen}); final ValueChanged<Widget> onOpen;
  @override
  Widget build(BuildContext context) {
    final items = <_Tile>[
      _Tile('Knowledge', 'Hadith, Sunnah & learning', Icons.auto_stories_rounded, () => onOpen(const IslamicKnowledgeScreen())),
      _Tile('Insights', 'Review your worship', Icons.insights_rounded, () => onOpen(const WorshipDashboardScreen())),
      _Tile('Calendar', 'Hijri dates & occasions', Icons.calendar_month_rounded, () => onOpen(const IslamicCalendarScreen())),
      _Tile('Fasting', 'Keep your private record', Icons.nightlight_rounded, () => onOpen(const FastingLauncherScreen())),
      _Tile('Goals', 'Build daily consistency', Icons.flag_rounded, () => onOpen(const DailyGoalsScreen())),
    ];
    return LayoutBuilder(builder: (context, c) { final cols = c.maxWidth >= 1050 ? 5 : c.maxWidth >= 650 ? 3 : 2; return GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: items.length, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols, crossAxisSpacing: 12, mainAxisSpacing: 12, mainAxisExtent: 122), itemBuilder: (_, i) => Card(child: InkWell(onTap: items[i].onTap, borderRadius: BorderRadius.circular(16), child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(items[i].icon, color: Theme.of(context).colorScheme.secondary), const Spacer(), Text(items[i].title, style: const TextStyle(fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text(items[i].subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant))]))))); });
  }
}

class _Journey extends StatelessWidget {
  const _Journey({required this.onGoals}); final VoidCallback onGoals;
  @override
  Widget build(BuildContext context) { final s = Theme.of(context).colorScheme; return Card(child: Padding(padding: const EdgeInsets.all(22), child: LayoutBuilder(builder: (context, c) { final compact = c.maxWidth < 650; final content = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: s.primaryContainer, shape: BoxShape.circle), child: Icon(Icons.spa_rounded, color: s.primary)), const SizedBox(width: 14), const Expanded(child: Text('Your worship journey', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)))]), const SizedBox(height: 10), Text('Choose a goal, build gently, and let consistency become part of your day.', style: TextStyle(color: s.onSurfaceVariant, height: 1.5)), const SizedBox(height: 15), FilledButton.icon(onPressed: onGoals, icon: const Icon(Icons.flag_outlined), label: const Text('Set daily goals'))]); if (compact) return content; return Row(children: [Expanded(child: content), const SizedBox(width: 28), Icon(Icons.spa_rounded, size: 100, color: s.primaryContainer)]); })))); }
}
