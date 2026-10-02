import "package:imaanly/l10n/app_localizations.dart";
import "package:imaanly/src/resources/translation/language_cubit.dart";
import "package:imaanly/src/resources/translation/languages.dart";
import "package:imaanly/src/screen/settings/app_language_settings.dart";
import "package:imaanly/src/screen/settings/notification_settings_page_enhanced.dart";
import "package:imaanly/src/screen/settings/personalization_settings_page.dart";
import "package:imaanly/src/screen/settings/widgets/home_widget_studio_screen.dart";
import "package:imaanly/src/widget/theme/theme_icon_button.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:gap/gap.dart";
import "package:imaanly/src/core/hifz/hifz_cubit.dart";
import "package:imaanly/src/core/night_mode/night_reading_cubit.dart";
import 'package:imaanly/src/theme/app_fonts.dart';
import "../../theme/controller/theme_cubit.dart";
import "../../theme/controller/theme_state.dart";

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool _autoScrollEnabled = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return BlocBuilder<LanguageCubit, MyAppLocalization>(
          builder: (context, languageState) {
            final isArabic = languageState.locale.languageCode == 'ar';
            
            return Scaffold(
              extendBodyBehindAppBar: true,
              backgroundColor: isDark ? Theme.of(context).colorScheme.surface : const Color(0xFFF3F8F5),
              appBar: AppBar(
                title: Text(
                  l10n.settings,
                  style: AppFonts.body(fontWeight: FontWeight.w900),
                ),
                actions: [themeIconButton(context)],
                backgroundColor: Colors.transparent,
              ),
              body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.surface]
                        : [const Color(0xFFF3F8F5), const Color(0xFFF8FBF9)],
                  ),
                ),
                child: SafeArea(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 32.h),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      if (!isArabic)
                        _buildLanguageSuggestionBanner(
                          context,
                          themeState,
                          isDark,
                          languageState,
                        ),
                      if (!isArabic) Gap(14.h),
                      _SettingsSectionCard(
                        title: "Appearance",
                        icon: Icons.palette_rounded,
                        themeState: themeState,
                        isDark: isDark,
                        child: Column(
                          children: [
                            _buildThemeModeSelector(context, themeState, isDark),
                          ],
                        ),
                      ),
                      Gap(14.h),
                      _SettingsSectionCard(
                        title: "Personalization",
                        icon: Icons.tune_rounded,
                        themeState: themeState,
                        isDark: isDark,
                        child: _SettingsShortcutTile(
                          icon: Icons.tune_rounded,
                          title: "Customize your Imaanly experience",
                          subtitle: "Home page, appearance, Quran, dhikr, and worship dashboard.",
                          themeState: themeState,
                          isDark: isDark,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PersonalizationSettingsPage(),
                            ),
                          ),
                        ),
                      ),
                      Gap(14.h),
                      _SettingsSectionCard(
                        title: "Auto-scroll",
                        icon: Icons.auto_mode_rounded,
                        themeState: themeState,
                        isDark: isDark,
                        child: _buildAutoScrollSettings(themeState, isDark),
                      ),
                      Gap(14.h),
                      _SettingsSectionCard(
                        title: "Quick shortcuts",
                        icon: Icons.dashboard_customize_rounded,
                        themeState: themeState,
                        isDark: isDark,
                        child: Column(
                          children: [
                            _SettingsShortcutTile(
                              icon: Icons.widgets_rounded,
                              title: "Ayah of the Day widget",
                              subtitle: "Live design, themes, auto-refresh, and a custom ayah or category.",
                              themeState: themeState,
                              isDark: isDark,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HomeWidgetStudioScreen(),
                                ),
                              ),
                            ),
                            Gap(10.h),
                            _SettingsShortcutTile(
                              icon: Icons.language_rounded,
                              title: "App language",
                              subtitle: "Choose the primary language for the experience and supported content.",
                              themeState: themeState,
                              isDark: isDark,
                              trailing: _buildLanguageFlag(languageState),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AppLanguageSettings(),
                                ),
                              ),
                            ),
                            Gap(10.h),
                            _SettingsShortcutTile(
                              icon: Icons.notifications_active_rounded,
                              title: "Notifications",
                              subtitle: "Full control over all types of notifications and alerts.",
                              themeState: themeState,
                              isDark: isDark,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const NotificationSettingsPageEnhanced(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Gap(14.h),
                      _SettingsSectionCard(
                        title: "Reading modes",
                        icon: Icons.auto_stories_rounded,
                        themeState: themeState,
                        isDark: isDark,
                        child: Column(
                          children: [
                            BlocBuilder<HifzCubit, HifzState>(
                              builder: (context, hifzState) {
                                return _SettingsShortcutTile(
                                  icon: Icons.visibility_off_rounded,
                                  title: "Memorization mode",
                                  subtitle: hifzState.isActive
                                      ? "Active — ${hifzState.hideLevel == HifzHideLevel.blurred ? 'Blurred' : hifzState.hideLevel == HifzHideLevel.hidden ? 'Hidden' : 'Visible'}"
                                      : "Gradually hide ayahs and test your memorization",
                                  themeState: themeState,
                                  isDark: isDark,
                                  trailing: Switch(
                                    value: hifzState.isActive,
                                    activeThumbColor: themeState.primary,
                                    onChanged: (_) => context.read<HifzCubit>().toggleHifz(),
                                  ),
                                  onTap: () => _showHifzSettings(context, themeState, isDark),
                                );
                              },
                            ),
                            Gap(10.h),
                            BlocBuilder<NightReadingCubit, NightReadingState>(
                              builder: (context, nightState) {
                                return _SettingsShortcutTile(
                                  icon: Icons.bedtime_rounded,
                                  title: "Night reading mode",
                                  subtitle: nightState.isActive
                                      ? "Active — warm colors to protect your eyes"
                                      : "Warm amber tones and reduced brightness",
                                  themeState: themeState,
                                  isDark: isDark,
                                  trailing: Switch(
                                    value: nightState.isActive,
                                    activeThumbColor: themeState.primary,
                                    onChanged: (_) => context.read<NightReadingCubit>().toggle(),
                                  ),
                                  onTap: () => _showNightSettings(context, themeState, isDark),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLanguageSuggestionBanner(
    BuildContext context,
    ThemeState themeState,
    bool isDark,
    MyAppLocalization currentLang,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2F9BB5).withValues(alpha: 0.15),
            const Color(0xFF6A4FC4).withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2F9BB5).withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFF2F9BB5).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.translate_rounded,
              color: Color(0xFF2F9BB5),
              size: 28,
            ),
          ),
          Gap(14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "💡 Suggestion",
                  style: AppFonts.body(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF2F9BB5),
                  ),
                ),
                Gap(4.h),
                Text(
                  "It looks like you're using ${currentLang.native}. Do you want to enable the library for this language?",
                  style: AppFonts.body(
                    fontSize: 12.sp,
                    height: 1.6,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, color: const Color(0xFF2F9BB5), size: 18),
        ],
      ),
    );
  }

  Widget _buildLanguageFlag(MyAppLocalization lang) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFF2F9BB5).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        lang.native,
        style: AppFonts.body(
          fontSize: 11.sp,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF2F9BB5),
        ),
      ),
    );
  }

  Widget _buildThemeModeSelector(
    BuildContext context,
    ThemeState themeState,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildThemeModeButton(
              context,
              icon: Icons.light_mode_rounded,
              label: "Light",
              isSelected: themeState.themeMode == ThemeMode.light,
              themeState: themeState,
              isDark: isDark,
              onTap: () => context.read<ThemeCubit>().setTheme(ThemeMode.light),
            ),
          ),
          Gap(4.w),
          Expanded(
            child: _buildThemeModeButton(
              context,
              icon: Icons.dark_mode_rounded,
              label: "Dark",
              isSelected: themeState.themeMode == ThemeMode.dark,
              themeState: themeState,
              isDark: isDark,
              onTap: () => context.read<ThemeCubit>().setTheme(ThemeMode.dark),
            ),
          ),
          Gap(4.w),
          Expanded(
            child: _buildThemeModeButton(
              context,
              icon: Icons.brightness_auto_rounded,
              label: "Auto",
              isSelected: themeState.themeMode == ThemeMode.system,
              themeState: themeState,
              isDark: isDark,
              onTap: () => context.read<ThemeCubit>().setTheme(ThemeMode.system),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeModeButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required ThemeState themeState,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? themeState.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : (isDark ? Colors.white60 : Colors.black54),
              size: 22,
            ),
            Gap(4.h),
            Text(
              label,
              style: AppFonts.body(
                fontSize: 11.sp,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : (isDark ? Colors.white60 : Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoScrollSettings(ThemeState themeState, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Enable auto-scroll",
                    style: AppFonts.body(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Gap(4.h),
                  Text(
                    "Auto-scroll while reading is always on",
                    style: AppFonts.body(
                      fontSize: 11.sp,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: _autoScrollEnabled,
              onChanged: (v) => setState(() => _autoScrollEnabled = v),
              activeThumbColor: themeState.primary,
            ),
          ],
        ),
        if (_autoScrollEnabled) ...[
          Gap(12.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: themeState.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: themeState.primary, size: 20),
                Gap(10.w),
                Expanded(
                  child: Text(
                    "Auto-scroll is on and running smoothly",
                    style: AppFonts.body(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: themeState.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _showHifzSettings(BuildContext context, ThemeState themeState, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
          padding: const EdgeInsets.all(20),
          child: Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(2))),
              ),
              const Gap(16),
              Text("Memorization mode settings", style: TextStyle(color: isDark ? const Color(0xFFF3F8F5) : const Color(0xFF0E1F1A), fontWeight: FontWeight.w800, fontSize: 18)),
              const Gap(16),
              Text("Hiding level:", style: TextStyle(color: isDark ? const Color(0xFF86A094) : const Color(0xFF3C524A), fontWeight: FontWeight.w600)),
              const Gap(8),
              BlocBuilder<HifzCubit, HifzState>(
                builder: (context, state) => Wrap(
                  spacing: 8,
                  children: HifzHideLevel.values.map((level) {
                    final labels = {HifzHideLevel.visible: "Visible", HifzHideLevel.blurred: "Blurred", HifzHideLevel.hidden: "Hidden"};
                    final isSelected = state.hideLevel == level;
                    return ChoiceChip(
                      label: Text(labels[level]!),
                      selected: isSelected,
                      selectedColor: themeState.primary.withValues(alpha: 0.2),
                      side: BorderSide(color: isSelected ? themeState.primary : Colors.grey),
                      onSelected: (_) => context.read<HifzCubit>().setHideLevel(level),
                    );
                  }).toList(),
                ),
              ),
              const Gap(16),
              BlocBuilder<HifzCubit, HifzState>(
                builder: (context, state) => SwitchListTile(
                  title: Text("Test mode", style: TextStyle(color: isDark ? const Color(0xFFF3F8F5) : const Color(0xFF0E1F1A), fontWeight: FontWeight.w600)),
                  subtitle: Text("Tap the ayah to reveal it", style: TextStyle(color: isDark ? const Color(0xFF86A094) : const Color(0xFF3C524A), fontSize: 12)),
                  value: state.isTestMode,
                  activeThumbColor: themeState.primary,
                  onChanged: (_) => context.read<HifzCubit>().toggleTestMode(),
                ),
              ),
              const Gap(20),
            ],
          ),
        ),
      ),
    );
  }

  void _showNightSettings(BuildContext context, ThemeState themeState, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
          padding: const EdgeInsets.all(20),
          child: Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(2))),
              ),
              const Gap(16),
              Text("Night mode settings", style: TextStyle(color: isDark ? const Color(0xFFF3F8F5) : const Color(0xFF0E1F1A), fontWeight: FontWeight.w800, fontSize: 18)),
              const Gap(16),
              BlocBuilder<NightReadingCubit, NightReadingState>(
                builder: (context, state) => Column(
                  children: [
                    Text("Warmth: ${(state.warmth * 100).round()}%", style: TextStyle(color: isDark ? const Color(0xFF86A094) : const Color(0xFF3C524A), fontWeight: FontWeight.w600)),
                    Slider(
                      value: state.warmth,
                      activeColor: themeState.primary,
                      onChanged: (v) => context.read<NightReadingCubit>().setWarmth(v),
                    ),
                    const Gap(8),
                    Text("Dimming: ${(state.dimLevel * 100).round()}%", style: TextStyle(color: isDark ? const Color(0xFF86A094) : const Color(0xFF3C524A), fontWeight: FontWeight.w600)),
                    Slider(
                      value: state.dimLevel,
                      activeColor: themeState.primary,
                      onChanged: (v) => context.read<NightReadingCubit>().setDimLevel(v),
                    ),
                    const Gap(8),
                    SwitchListTile(
                      title: Text("Auto-enable at sunset", style: TextStyle(color: isDark ? const Color(0xFFF3F8F5) : const Color(0xFF0E1F1A), fontWeight: FontWeight.w600)),
                      value: state.autoAtSunset,
                      activeThumbColor: themeState.primary,
                      onChanged: (_) => context.read<NightReadingCubit>().setAutoAtSunset(!state.autoAtSunset),
                    ),
                  ],
                ),
              ),
              const Gap(20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final ThemeState themeState;
  final bool isDark;
  final Widget child;

  const _SettingsSectionCard({
    required this.title,
    required this.icon,
    required this.themeState,
    required this.isDark,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: isDark ? const Color(0xFF11332A) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: isDark ? const Color(0xFF1F4538) : const Color(0xFFD3E2DA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      themeState.primary.withValues(alpha: 0.15),
                      themeState.primary.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: themeState.primary, size: 22),
              ),
              Gap(12.w),
              Text(
                title,
                style: AppFonts.body(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          Gap(16.h),
          child,
        ],
      ),
    );
  }
}

class _SettingsShortcutTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final ThemeState themeState;
  final bool isDark;
  final VoidCallback onTap;
  final Widget? trailing;

  const _SettingsShortcutTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.themeState,
    required this.isDark,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [Colors.white.withValues(alpha: 0.05), Colors.white.withValues(alpha: 0.02)]
                : [themeState.primary.withValues(alpha: 0.05), themeState.primary.withValues(alpha: 0.02)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : themeState.primary.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [themeState.primary, themeState.primary.withValues(alpha: 0.8)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: themeState.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            Gap(14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppFonts.body(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap(6.h),
                  Text(
                    subtitle,
                    style: AppFonts.body(
                      fontSize: 12.sp,
                      height: 1.6,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Gap(10.w),
            trailing ??
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: themeState.primary,
                  size: 18,
                ),
          ],
        ),
      ),
    );
  }
}
