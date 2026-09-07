import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:imaanly/features/personalization/data/imaanly_personalization_repository.dart';
import 'package:imaanly/features/personalization/domain/imaanly_personalization.dart';
import 'package:imaanly/src/theme/controller/theme_cubit.dart';

class PersonalizationSettingsPage extends StatefulWidget {
  const PersonalizationSettingsPage({super.key});

  @override
  State<PersonalizationSettingsPage> createState() =>
      _PersonalizationSettingsPageState();
}

class _PersonalizationSettingsPageState
    extends State<PersonalizationSettingsPage> {
  ImaanlyPersonalization _value = const ImaanlyPersonalization();
  ImaanlyPersonalizationRepository? _repository;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final repository = ImaanlyPersonalizationRepository(prefs);
    if (!mounted) return;
    setState(() {
      _repository = repository;
      _value = repository.load();
      _loading = false;
    });
  }

  Future<void> _save(ImaanlyPersonalization next) async {
    final repository = _repository;
    if (repository == null) return;
    setState(() => _value = next);
    await repository.save(next);
  }

  Future<void> _setTheme(String mode) async {
    final themeMode = switch (mode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    context.read<ThemeCubit>().setTheme(themeMode);
    await _save(_value.copyWith(themeMode: mode));
  }

  Future<void> _reset() async {
    final repository = _repository;
    if (repository == null) return;
    await repository.reset();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'التخصيص',
          style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 32.h),
          children: [
            _section(
              context,
              title: 'المظهر',
              icon: Icons.palette_rounded,
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'system', label: Text('تلقائي'), icon: Icon(Icons.brightness_auto)),
                  ButtonSegment(value: 'light', label: Text('فاتح'), icon: Icon(Icons.light_mode)),
                  ButtonSegment(value: 'dark', label: Text('داكن'), icon: Icon(Icons.dark_mode)),
                ],
                selected: {_value.themeMode},
                onSelectionChanged: (value) => _setTheme(value.first),
              ),
            ),
            SizedBox(height: 14.h),
            _section(
              context,
              title: 'القرآن',
              icon: Icons.menu_book_rounded,
              child: Column(
                children: [
                  RadioListTile<String>(
                    value: 'uthmanic',
                    groupValue: _value.quranScript,
                    title: const Text('الرسم العثماني'),
                    onChanged: (value) => _save(_value.copyWith(quranScript: value)),
                  ),
                  RadioListTile<String>(
                    value: 'indopak',
                    groupValue: _value.quranScript,
                    title: const Text('الإندوباك'),
                    onChanged: (value) => _save(_value.copyWith(quranScript: value)),
                  ),
                  SwitchListTile.adaptive(
                    title: const Text('إظهار الترجمة'),
                    value: _value.quranShowTranslation,
                    onChanged: (value) =>
                        _save(_value.copyWith(quranShowTranslation: value)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            _section(
              context,
              title: 'الذكر',
              icon: Icons.favorite_rounded,
              child: ListTile(
                title: const Text('الهدف اليومي'),
                subtitle: Text('${_value.dhikrDailyGoal} ذكر'),
                trailing: SizedBox(
                  width: 150.w,
                  child: Slider(
                    min: 0,
                    max: 300,
                    divisions: 30,
                    value: _value.dhikrDailyGoal.clamp(0, 300).toDouble(),
                    onChanged: (value) =>
                        _save(_value.copyWith(dhikrDailyGoal: value.round())),
                  ),
                ),
              ),
            ),
            SizedBox(height: 14.h),
            _section(
              context,
              title: 'الصفحة الرئيسية',
              icon: Icons.dashboard_customize_rounded,
              child: Column(
                children: [
                  for (final item in const [
                    ('quran', 'القرآن', Icons.menu_book_rounded),
                    ('dhikr', 'الذكر', Icons.favorite_rounded),
                    ('qibla', 'القبلة', Icons.explore_rounded),
                    ('salah', 'الصلاة', Icons.mosque_rounded),
                    ('calendar', 'التقويم', Icons.calendar_month_rounded),
                    ('knowledge', 'المعرفة', Icons.auto_stories_rounded),
                  ])
                    CheckboxListTile(
                      value: _value.homeShortcuts.contains(item.$1),
                      title: Text(item.$2),
                      secondary: Icon(item.$3),
                      onChanged: (selected) {
                        final shortcuts = [..._value.homeShortcuts];
                        if (selected == true) {
                          if (!shortcuts.contains(item.$1)) shortcuts.add(item.$1);
                        } else {
                          shortcuts.remove(item.$1);
                        }
                        if (shortcuts.isEmpty) return;
                        _save(_value.copyWith(homeShortcuts: shortcuts));
                      },
                    ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            _section(
              context,
              title: 'لوحة العبادة',
              icon: Icons.insights_rounded,
              child: SwitchListTile.adaptive(
                title: const Text('عرض مختصر'),
                subtitle: const Text('تقليل التفاصيل الثانوية في لوحة العبادة.'),
                value: _value.dashboardCompact,
                onChanged: (value) =>
                    _save(_value.copyWith(dashboardCompact: value)),
              ),
            ),
            SizedBox(height: 20.h),
            OutlinedButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.restore_rounded),
              label: const Text('إعادة التخصيصات للوضع الافتراضي'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              SizedBox(width: 10.w),
              Text(title, style: GoogleFonts.cairo(fontWeight: FontWeight.w900, fontSize: 16.sp)),
            ],
          ),
          SizedBox(height: 8.h),
          child,
        ],
      ),
    );
  }
}
