import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:imaanly/features/personalization/domain/imaanly_personalization.dart';
import 'package:imaanly/features/personalization/presentation/personalization_cubit.dart';
import 'package:imaanly/src/core/di/service_locator.dart';
import 'package:imaanly/src/theme/controller/theme_cubit.dart';

class PersonalizationSettingsPage extends StatelessWidget {
  const PersonalizationSettingsPage({super.key});

  Future<void> _setTheme(BuildContext context, PersonalizationCubit cubit, String mode) async {
    final theme = mode == 'light' ? ThemeMode.light : mode == 'dark' ? ThemeMode.dark : ThemeMode.system;
    context.read<ThemeCubit>().setTheme(theme);
    await cubit.update(cubit.state.copyWith(themeMode: mode));
  }

  @override
  Widget build(BuildContext context) {
    final cubit = getIt<PersonalizationCubit>();
    return BlocBuilder<PersonalizationCubit, ImaanlyPersonalization>(
      bloc: cubit,
      builder: (context, value) {
        return Scaffold(
          appBar: AppBar(title: const Text('Personalization')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Section(title: 'Appearance', icon: Icons.palette_outlined, child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'system', label: Text('System'), icon: Icon(Icons.brightness_auto)),
                  ButtonSegment(value: 'light', label: Text('Light'), icon: Icon(Icons.light_mode)),
                  ButtonSegment(value: 'dark', label: Text('Dark'), icon: Icon(Icons.dark_mode)),
                ],
                selected: {value.themeMode},
                onSelectionChanged: (selection) => _setTheme(context, cubit, selection.first),
              )),
              const SizedBox(height: 14),
              _Section(title: 'Quran', icon: Icons.menu_book_outlined, child: RadioGroup<String>(
                groupValue: value.quranScript,
                onChanged: (v) { if (v != null) cubit.update(value.copyWith(quranScript: v)); },
                child: Column(children: [
                  const RadioListTile<String>(value: 'uthmanic', title: Text('Uthmanic')),
                  const RadioListTile<String>(value: 'indopak', title: Text('Indo-Pak')),
                  SwitchListTile.adaptive(title: const Text('Show translation'), value: value.quranShowTranslation, onChanged: (v) => cubit.update(value.copyWith(quranShowTranslation: v))),
                ]),
              )),
              const SizedBox(height: 14),
              _Section(title: 'Dhikr', icon: Icons.favorite_outline, child: ListTile(
                title: const Text('Daily goal'),
                subtitle: Text('${value.dhikrDailyGoal} repetitions'),
                trailing: SizedBox(width: 170, child: Slider(min: 1, max: 300, divisions: 30, value: value.dhikrDailyGoal.clamp(1, 300).toDouble(), onChanged: (v) => cubit.update(value.copyWith(dhikrDailyGoal: v.round())))),
              )),
              const SizedBox(height: 14),
              _Section(title: 'Home shortcuts', icon: Icons.dashboard_customize_outlined, child: Column(children: [
                _shortcut(context, cubit, value, 'quran', 'Quran', Icons.menu_book_outlined),
                _shortcut(context, cubit, value, 'dhikr', 'Dhikr', Icons.favorite_outline),
                _shortcut(context, cubit, value, 'qibla', 'Qibla', Icons.explore_outlined),
                _shortcut(context, cubit, value, 'salah', 'Prayer', Icons.mosque_outlined),
                _shortcut(context, cubit, value, 'calendar', 'Calendar', Icons.calendar_month_outlined),
                _shortcut(context, cubit, value, 'knowledge', 'Knowledge', Icons.auto_stories_outlined),
              ])),
              const SizedBox(height: 14),
              _Section(title: 'Worship dashboard', icon: Icons.insights_outlined, child: SwitchListTile.adaptive(title: const Text('Compact view'), value: value.dashboardCompact, onChanged: (v) => cubit.update(value.copyWith(dashboardCompact: v)))),
              const SizedBox(height: 20),
              OutlinedButton.icon(onPressed: cubit.reset, icon: const Icon(Icons.restore), label: const Text('Reset personalization')),
            ],
          ),
        );
      },
    );
  }

  Widget _shortcut(BuildContext context, PersonalizationCubit cubit, ImaanlyPersonalization value, String id, String label, IconData icon) {
    return CheckboxListTile(
      value: value.homeShortcuts.contains(id),
      title: Text(label),
      secondary: Icon(icon),
      onChanged: (selected) {
        final shortcuts = List<String>.from(value.homeShortcuts);
        if (selected == true && !shortcuts.contains(id)) shortcuts.add(id);
        if (selected == false) shortcuts.remove(id);
        if (shortcuts.isNotEmpty) cubit.update(value.copyWith(homeShortcuts: shortcuts));
      },
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.icon, required this.child});
  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [Icon(icon, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 10), Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))]),
          const SizedBox(height: 8),
          child,
        ]),
      ),
    );
  }
}
