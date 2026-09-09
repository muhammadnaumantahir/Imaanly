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
import '../../../src/theme/app_colors.dart';

class ImaanlyHomePage extends StatelessWidget {
  const ImaanlyHomePage({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final shortcuts = context
        .select<PersonalizationCubit, List<String>>(
          (cubit) => cubit.state.homeShortcuts,
        )
        .toSet();
    final date = DateFormat('EEEE, d MMMM').format(DateTime.now());
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final desktop = constraints.maxWidth >= 1050;
          return Row(
            children: [
              if (desktop) _DesktopRail(onOpen: (page) => _open(context, page)),
              Expanded(
                child: SafeArea(
                  bottom: false,
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          desktop ? 36 : 18,
                          18,
                          desktop ? 36 : 18,
                          32,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1380),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _TopBar(
                                    date: date,
                                    onSettings: () => _open(context, const SettingsPage()),
                                    onKnowledge: () => _open(context, const IslamicKnowledgeScreen()),
                                  ),
                                  const SizedBox(height: 24),
                                  _WelcomeHero(
                                    onQuran: () => _open(context, const QuranReaderScreen()),
                                    onPrayer: () => _open(context, const PrayerTimePage()),
                                  ),
                                  const SizedBox(height: 28),
                                  _SectionHeader(
                                    title: 'Your daily essentials',
                                    subtitle: 'Everything you need for a more intentional day.',
                                  ),
                                  const SizedBox(height: 14),
                                  _EssentialsGrid(
                                    shortcuts: shortcuts,
                                    onQuran: () => _open(context, const QuranReaderScreen()),
                                    onDhikr: () => _open(context, const AzkarCategoriesScreen()),
                                    onPrayer: () => _open(context, const PrayerTimePage()),
                                    onQibla: () => _open(context, const QiblaDirection()),
                                  ),
                                  const SizedBox(height: 28),
                                  _ResponsiveFeatureRow(
                                    onKnowledge: () => _open(context, const IslamicKnowledgeScreen()),
                                    onWorship: () => _open(context, const WorshipDashboardScreen()),
                                    onCalendar: () => _open(context, const IslamicCalendarScreen()),
                                    onFasting: () => _open(context, const FastingLauncherScreen()),
                                    onGoals: () => _open(context, const DailyGoalsScreen()),
                                  ),
                                  const SizedBox(height: 28),
                                  _SectionHeader(
                                    title: 'A calmer way to grow',
                                    subtitle: 'Small, consistent moments can become a meaningful routine.',
                                  ),
                                  const SizedBox(height: 14),
                                  _JourneyCard(onOpenGoals: () => _open(context, const DailyGoalsScreen())),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) => constraints.maxWidth < 1050
            ? _MobileNav(
                onHome: () {},
                onQuran: () => _open(context, const QuranReaderScreen()),
                onPrayer: () => _open(context, const PrayerTimePage()),
                onExplore: () => _open(context, const IslamicKnowledgeScreen()),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}

class _DesktopRail extends StatelessWidget {
  const _DesktopRail({required this.onOpen});
  final ValueChanged<Widget> onOpen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border(right: BorderSide(color: scheme.outlineVariant.withValues(alpha: .45))),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _BrandLockup(),
              const SizedBox(height: 34),
              _RailItem(icon: Icons.home_rounded, label: 'Home', selected: true, onTap: () {}),
              _RailItem(icon: Icons.menu_book_rounded, label: 'Quran', onTap: () => onOpen(const QuranReaderScreen())),
              _RailItem(icon: Icons.mosque_rounded, label: 'Prayer', onTap: () => onOpen(const PrayerTimePage())),
              _RailItem(icon: Icons.explore_rounded, label: 'Qibla', onTap: () => onOpen(const QiblaDirection())),
              _RailItem(icon: Icons.favorite_rounded, label: 'Dhikr', onTap: () => onOpen(const AzkarCategoriesScreen())),
              const Spacer(),
              _RailItem(icon: Icons.auto_stories_rounded, label: 'Knowledge', onTap: () => onOpen(const IslamicKnowledgeScreen())),
              _RailItem(icon: Icons.settings_rounded, label: 'Settings', onTap: () => onOpen(const SettingsPage())),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandLockup extends StatelessWidget {
  const _BrandLockup();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: [scheme.primary, scheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Text('Imaanly', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
      ],
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({required this.icon, required this.label, required this.onTap, this.selected = false});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: selected ? scheme.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Icon(icon, size: 21, color: selected ? scheme.primary : scheme.onSurfaceVariant),
                const SizedBox(width: 13),
                Text(label, style: TextStyle(fontWeight: selected ? FontWeight.w800 : FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.date, required this.onSettings, required this.onKnowledge});
  final String date;
  final VoidCallback onSettings;
  final VoidCallback onKnowledge;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Assalamu Alaikum', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -.8)),
              const SizedBox(height: 5),
              Text(date, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
        _CircleButton(icon: Icons.auto_stories_outlined, tooltip: 'Knowledge', onTap: onKnowledge),
        const SizedBox(width: 8),
        _CircleButton(icon: Icons.settings_outlined, tooltip: 'Settings', onTap: onSettings),
        const SizedBox(width: 8),
        CircleAvatar(
          radius: 20,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(Icons.person_rounded, color: Theme.of(context).colorScheme.primary),
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.tooltip, required this.onTap});
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        shape: const CircleBorder(),
        child: InkWell(onTap: onTap, customBorder: const CircleBorder(), child: Padding(padding: const EdgeInsets.all(11), child: Icon(icon, size: 21))),
      ),
    );
  }
}

class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero({required this.onQuran, required this.onPrayer});
  final VoidCallback onQuran;
  final VoidCallback onPrayer;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [BoxShadow(color: scheme.primary.withValues(alpha: .20), blurRadius: 30, offset: const Offset(0, 14))],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 650;
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: .15), borderRadius: BorderRadius.circular(99)),
                child: const Text('SMART WORSHIP COMPANION', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
              ),
              const SizedBox(height: 16),
              const Text('Make space for what matters.', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, height: 1.08, letterSpacing: -.7)),
              const SizedBox(height: 10),
              Text('Read, reflect, remember and build a beautiful worship routine — one moment at a time.', style: TextStyle(color: Colors.white.withValues(alpha: .88), fontSize: 15, height: 1.5)),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: scheme.primary, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13)), onPressed: onQuran, icon: const Icon(Icons.menu_book_rounded), label: const Text('Open Quran')),
                  OutlinedButton.icon(style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: BorderSide(color: Colors.white.withValues(alpha: .55)), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13)), onPressed: onPrayer, icon: const Icon(Icons.mosque_outlined), label: const Text('Prayer times')),
                ],
              ),
            ],
          );

          if (compact) return copy;
          return Row(children: [Expanded(flex: 3, child: copy), const SizedBox(width: 28), const Expanded(flex: 2, child: _HeroOrb())]);
        },
      ),
    );
  }
}

class _HeroOrb extends StatelessWidget {
  const _HeroOrb();
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: .08),
        border: Border.all(color: Colors.white.withValues(alpha: .18), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .08), blurRadius: 40, spreadRadius: 5)],
      ),
      child: Center(child: Container(width: 118, height: 118, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: .12)), child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 58))),
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant))]);
}

class _EssentialsGrid extends StatelessWidget {
  const _EssentialsGrid({required this.shortcuts, required this.onQuran, required this.onDhikr, required this.onPrayer, required this.onQibla});
  final Set<String> shortcuts;
  final VoidCallback onQuran;
  final VoidCallback onDhikr;
  final VoidCallback onPrayer;
  final VoidCallback onQibla;

  @override
  Widget build(BuildContext context) {
    final items = <_EssentialData>[
      if (shortcuts.contains('quran')) _EssentialData('Quran', 'Read & reflect', Icons.menu_book_rounded, onQuran),
      if (shortcuts.contains('dhikr')) _EssentialData('Dhikr', 'Remember Allah', Icons.favorite_rounded, onDhikr),
      if (shortcuts.contains('salah')) _EssentialData('Prayer', 'Today’s schedule', Icons.mosque_rounded, onPrayer),
      if (shortcuts.contains('qibla')) _EssentialData('Qibla', 'Find direction', Icons.explore_rounded, onQibla),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900 ? 4 : constraints.maxWidth >= 600 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 14, mainAxisSpacing: 14, mainAxisExtent: 132),
          itemBuilder: (_, index) => _EssentialCard(data: items[index]),
        );
      },
    );
  }
}

class _EssentialData {
  const _EssentialData(this.title, this.subtitle, this.icon, this.onTap);
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
}

class _EssentialCard extends StatefulWidget {
  const _EssentialCard({required this.data});
  final _EssentialData data;
  @override State<_EssentialCard> createState() => _EssentialCardState();
}

class _EssentialCardState extends State<_EssentialCard> {
  bool hover = false;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.translationValues(0, hover ? -3 : 0, 0),
        child: Material(
          color: scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            onTap: widget.data.onTap,
            borderRadius: BorderRadius.circular(22),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(children: [
                Container(width: 52, height: 52, decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(17)), child: Icon(widget.data.icon, color: scheme.primary, size: 26)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(widget.data.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text(widget.data.subtitle, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12.5))])),
                Icon(Icons.arrow_forward_ios_rounded, size: 15, color: scheme.onSurfaceVariant),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResponsiveFeatureRow extends StatelessWidget {
  const _ResponsiveFeatureRow({required this.onKnowledge, required this.onWorship, required this.onCalendar, required this.onFasting, required this.onGoals});
  final VoidCallback onKnowledge;
  final VoidCallback onWorship;
  final VoidCallback onCalendar;
  final VoidCallback onFasting;
  final VoidCallback onGoals;

  @override
  Widget build(BuildContext context) {
    final features = [
      _FeatureData('Knowledge', 'Learn with purpose', Icons.auto_stories_rounded, onKnowledge),
      _FeatureData('Insights', 'Review your journey', Icons.insights_rounded, onWorship),
      _FeatureData('Calendar', 'Hijri dates & events', Icons.calendar_month_rounded, onCalendar),
      _FeatureData('Fasting', 'Keep your record', Icons.nightlight_round, onFasting),
      _FeatureData('Goals', 'Build consistency', Icons.flag_rounded, onGoals),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1050 ? 5 : constraints.maxWidth >= 650 ? 3 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: features.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 12, mainAxisSpacing: 12, mainAxisExtent: 128),
          itemBuilder: (_, index) => _FeatureCard(data: features[index]),
        );
      },
    );
  }
}

class _FeatureData {
  const _FeatureData(this.title, this.subtitle, this.icon, this.onTap);
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.data});
  final _FeatureData data;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 42, height: 42, decoration: BoxDecoration(color: scheme.secondaryContainer, borderRadius: BorderRadius.circular(14)), child: Icon(data.icon, color: scheme.secondary)),
            const Spacer(),
            Text(data.title, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            Text(data.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant)),
          ]),
        ),
      ),
    );
  }
}

class _JourneyCard extends StatelessWidget {
  const _JourneyCard({required this.onOpenGoals});
  final VoidCallback onOpenGoals;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 650;
            final content = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Container(width: 44, height: 44, decoration: BoxDecoration(color: scheme.primaryContainer, shape: BoxShape.circle), child: Icon(Icons.spa_rounded, color: scheme.primary)), const SizedBox(width: 13), const Expanded(child: Text('Your worship journey', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)))]),
              const SizedBox(height: 12),
              Text('Use Imaanly at your own pace. Explore what helps you most, then make it part of your everyday rhythm.', style: TextStyle(color: scheme.onSurfaceVariant, height: 1.5)),
              const SizedBox(height: 16),
              FilledButton.icon(onPressed: onOpenGoals, icon: const Icon(Icons.flag_outlined), label: const Text('Set daily goals')),
            ]);
            if (compact) return content;
            return Row(children: [Expanded(child: content), const SizedBox(width: 30), SizedBox(width: 150, height: 130, child: CustomPaint(painter: _JourneyPainter(scheme.primaryContainer))) ]);
          },
        ),
      ),
    );
  }
}

class _JourneyPainter extends CustomPainter {
  const _JourneyPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: .55)..style = PaintingStyle.stroke..strokeWidth = 7..strokeCap = StrokeCap.round;
    final path = Path()..moveTo(8, size.height * .72)..cubicTo(size.width * .25, size.height * .15, size.width * .52, size.height * .92, size.width - 8, size.height * .25);
    canvas.drawPath(path, paint);
  }
  @override bool shouldRepaint(covariant _JourneyPainter oldDelegate) => oldDelegate.color != color;
}

class _MobileNav extends StatelessWidget {
  const _MobileNav({required this.onHome, required this.onQuran, required this.onPrayer, required this.onExplore});
  final VoidCallback onHome;
  final VoidCallback onQuran;
  final VoidCallback onPrayer;
  final VoidCallback onExplore;
  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: 0,
    onDestinationSelected: (index) {
      switch (index) {
        case 0: onHome();
        case 1: onQuran();
        case 2: onPrayer();
        case 3: onExplore();
      }
    },
    destinations: const [
      NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
      NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book_rounded), label: 'Quran'),
      NavigationDestination(icon: Icon(Icons.mosque_outlined), selectedIcon: Icon(Icons.mosque_rounded), label: 'Prayer'),
      NavigationDestination(icon: Icon(Icons.auto_stories_outlined), selectedIcon: Icon(Icons.auto_stories_rounded), label: 'Explore'),
    ],
  );
}
