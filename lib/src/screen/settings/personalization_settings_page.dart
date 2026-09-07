import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imaanly/features/personalization/domain/imaanly_personalization.dart';
import 'package:imaanly/features/personalization/presentation/personalization_cubit.dart';
import 'package:imaanly/src/core/di/service_locator.dart';
import 'package:imaanly/src/theme/controller/theme_cubit.dart';

class PersonalizationSettingsPage extends StatelessWidget {
  const PersonalizationSettingsPage({super.key});
  Future<void> _setTheme(BuildContext context, PersonalizationCubit cubit, String mode) async {
    context.read<ThemeCubit>().setTheme(switch (mode) { 'light' => ThemeMode.light, 'dark' => ThemeMode.dark, _ => ThemeMode.system });
    await cubit.update(cubit.state.copyWith(themeMode: mode));
  }
  @override Widget build(BuildContext context) {
    final cubit = getIt<PersonalizationCubit>();
    return BlocBuilder<PersonalizationCubit, ImaanlyPersonalization>(bloc: cubit, builder: (context, value) => Scaffold(
      appBar: AppBar(title: Text('التخصيص', style: GoogleFonts.cairo(fontWeight: FontWeight.w900))),
      body: SafeArea(child: ListView(padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 32.h), children: [
        _section(context, title: 'المظهر', icon: Icons.palette_rounded, child: SegmentedButton<String>(segments: const [ButtonSegment(value: 'system', label: Text('تلقائي'), icon: Icon(Icons.brightness_auto)), ButtonSegment(value: 'light', label: Text('فاتح'), icon: Icon(Icons.light_mode)), ButtonSegment(value: 'dark', label: Text('داكن'), icon: Icon(Icons.dark_mode))], selected: {value.themeMode}, onSelectionChanged: (m) => _setTheme(context, cubit, m.first))),
        SizedBox(height: 14.h),
        _section(context, title: 'القرآن', icon: Icons.menu_book_rounded, child: Column(children: [
          RadioListTile<String>(value: 'uthmanic', groupValue: value.quranScript, title: const Text('الرسم العثماني'), onChanged: (v) => cubit.update(value.copyWith(quranScript: v))),
          RadioListTile<String>(value: 'indopak', groupValue: value.quranScript, title: const Text('الإندوباك'), onChanged: (v) => cubit.update(value.copyWith(quranScript: v))),
          SwitchListTile.adaptive(title: const Text('إظهار الترجمة'), value: value.quranShowTranslation, onChanged: (v) => cubit.update(value.copyWith(quranShowTranslation: v))),
        ])),
        SizedBox(height: 14.h),
        _section(context, title: 'الذكر', icon: Icons.favorite_rounded, child: ListTile(title: const Text('الهدف اليومي'), subtitle: Text('${value.dhikrDailyGoal} ذكر'), trailing: SizedBox(width: 150.w, child: Slider(min: 0, max: 300, divisions: 30, value: value.dhikrDailyGoal.clamp(0, 300).toDouble(), onChanged: (v) => cubit.update(value.copyWith(dhikrDailyGoal: v.round()))))),
        SizedBox(height: 14.h),
        _section(context, title: 'الصفحة الرئيسية', icon: Icons.dashboard_customize_rounded, child: Column(children: [
          for (final item in const [('quran', 'القرآن', Icons.menu_book_rounded), ('dhikr', 'الذكر', Icons.favorite_rounded), ('qibla', 'القبلة', Icons.explore_rounded), ('salah', 'الصلاة', Icons.mosque_rounded), ('calendar', 'التقويم', Icons.calendar_month_rounded), ('knowledge', 'المعرفة', Icons.auto_stories_rounded)]) CheckboxListTile(value: value.homeShortcuts.contains(item.$1), title: Text(item.$2), secondary: Icon(item.$3), onChanged: (selected) { final shortcuts = [...value.homeShortcuts]; if (selected == true) { if (!shortcuts.contains(item.$1)) shortcuts.add(item.$1); } else { shortcuts.remove(item.$1); } if (shortcuts.isNotEmpty) cubit.update(value.copyWith(homeShortcuts: shortcuts)); }),
        ])),
        SizedBox(height: 14.h),
        _section(context, title: 'لوحة العبادة', icon: Icons.insights_rounded, child: SwitchListTile.adaptive(title: const Text('عرض مختصر'), subtitle: const Text('تقليل التفاصيل الثانوية في لوحة العبادة.'), value: value.dashboardCompact, onChanged: (v) => cubit.update(value.copyWith(dashboardCompact: v)))),
        SizedBox(height: 20.h),
        OutlinedButton.icon(onPressed: cubit.reset, icon: const Icon(Icons.restore_rounded), label: const Text('إعادة التخصيصات للوضع الافتراضي')),
      ])),
    ));
  }
  Widget _section(BuildContext context, {required String title, required IconData icon, required Widget child}) { final theme = Theme.of(context); return Container(padding: EdgeInsets.all(14.w), decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45), borderRadius: BorderRadius.circular(22), border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.12))), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Row(children: [Icon(icon, color: theme.colorScheme.primary), SizedBox(width: 10.w), Text(title, style: GoogleFonts.cairo(fontWeight: FontWeight.w900, fontSize: 16.sp))]), SizedBox(height: 8.h), child])); }
}
