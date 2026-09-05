import "dart:async";
import "dart:developer";
import "dart:io";
import "dart:ui";

import "package:al_furkan/l10n/app_localizations.dart";
import "package:al_furkan/src/core/audio/cubit/audio_ui_cubit.dart";
import "package:al_furkan/src/core/audio/cubit/ayah_key_cubit.dart";
import "package:al_furkan/src/core/audio/cubit/player_position_cubit.dart";
import "package:al_furkan/src/core/audio/cubit/player_state_cubit.dart";
import "package:al_furkan/src/core/audio/cubit/segmented_quran_reciter_cubit.dart";
import "package:al_furkan/src/core/audio/cubit/offline_download_cubit.dart";
import "package:al_furkan/src/core/audio/cubit/sleep_timer_cubit.dart";
import "package:al_furkan/src/core/audio/cubit/ayah_repeat_cubit.dart";
import "package:al_furkan/src/core/reading_stats/reading_stats_cubit.dart";
import "package:al_furkan/src/core/hifz/hifz_cubit.dart";
import "package:al_furkan/src/core/night_mode/night_reading_cubit.dart";
import "package:al_furkan/src/core/audio/cubit/custom_playlist_cubit.dart";
import "package:al_furkan/src/core/audio/player/audio_player_manager.dart";
import "package:al_furkan/src/core/audio/services/audio_player_ui_bridge.dart";
import "package:al_furkan/src/core/bootstrap/app_bootstrap_coordinator.dart";
import "package:al_furkan/src/core/di/service_locator.dart";
import "package:al_furkan/src/core/reader_session/reader_session_repository.dart";
import "package:al_furkan/src/core/settings/settings_repository.dart";
import "package:al_furkan/src/core/storage/app_boxes.dart";
import "package:al_furkan/src/core/unified_quran_settings/cubit/quran_settings_cubit.dart";
import "package:al_furkan/src/core/error/release_error_handler.dart";
import "package:al_furkan/src/core/services/ayah_of_the_day_service.dart";
import "package:al_furkan/src/platform_services.dart" as platform_services;
import "package:al_furkan/src/resources/translation/language_cubit.dart";
import "package:al_furkan/src/resources/translation/languages.dart";
import "package:al_furkan/src/screen/location_handler/cubit/location_data_qibla_data_cubit.dart";
import "package:al_furkan/src/screen/location_handler/model/location_data_qibla_data_state.dart";
import "package:al_furkan/src/screen/mushaf/mushaf_screen.dart";
import "package:al_furkan/src/screen/prayer_time/cubit/prayer_time_cubit.dart";
import "package:al_furkan/src/screen/prayer_time/prayer_time_page.dart";
import "package:al_furkan/src/screen/azkar/azkar_categories_screen.dart";
import "package:al_furkan/src/screen/quran_script_view/quran_script_view.dart";
import "package:al_furkan/src/utils/quran_ayahs_function/gen_ayahs_key.dart";
import "package:al_furkan/src/screen/quran_reader/cubit/reader_ui_cubit.dart";
import "package:al_furkan/src/screen/quran_script_view/cubit/ayah_by_ayah_in_scroll_info_cubit.dart";
import "package:al_furkan/src/screen/quran_script_view/cubit/ayah_to_highlight.dart";
import "package:al_furkan/src/screen/quran_script_view/cubit/landscape_scroll_effect.dart";
import "package:al_furkan/src/screen/settings/cubit/quran_script_view_cubit.dart";
import "package:al_furkan/src/screen/setup/cubit/resources_progress_cubit_cubit.dart";
import "package:al_furkan/core/auth/auth_cubit.dart";
import "package:al_furkan/src/theme/app_theme.dart";
import "package:al_furkan/src/theme/controller/theme_cubit.dart";
import "package:al_furkan/src/theme/controller/theme_state.dart";
import "package:al_furkan/src/core/audio/services/idrisium_audio_tracker.dart";
import "package:al_furkan/src/widget/history/cubit/quran_history_cubit.dart";
import "package:al_furkan/src/widget/quran_script_words/cubit/word_playing_state_cubit.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:flutter_native_splash/flutter_native_splash.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:google_fonts/google_fonts.dart";
import "package:hive_ce_flutter/hive_flutter.dart";
import "package:home_widget/home_widget.dart";
import "package:just_audio_background/just_audio_background.dart";
import "package:just_audio_media_kit/just_audio_media_kit.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:al_furkan/src/screen/prayer_time/sunnah_prayer_page.dart";
import "package:al_furkan/src/screen/prayer_time/sunnah_wudu_page.dart";
import "package:al_furkan/core/services/firebase_service.dart";
import "package:al_furkan/features/analytics/services/analytics_tracker.dart";
import "package:al_furkan/features/home/presentation/imaanly_home_page.dart";

String? applicationDataPath;
platform_services.PlatformOwn platformOwn = platform_services.getPlatform();

Future<void> _safeOpenBox(String name, {Duration timeout = const Duration(seconds: 8)}) async {
  try {
    if (Hive.isBoxOpen(name)) return;
    await Hive.openBox(name).timeout(timeout);
  } catch (e) {
    log("⚠️ Failed to open box '$name': $e — attempting recovery", name: "HiveSafeOpen");
    try {
      if (Hive.isBoxOpen(name)) await Hive.box(name).close().timeout(const Duration(seconds: 3));
      await Hive.deleteBoxFromDisk(name).timeout(const Duration(seconds: 5));
      await Hive.openBox(name).timeout(timeout);
      log("✅ Box '$name' recovered successfully", name: "HiveSafeOpen");
    } catch (e2) {
      log("❌ CRITICAL: Box '$name' recovery also failed: $e2 — nuclear reset", name: "HiveSafeOpen");
      try {
        await Hive.deleteBoxFromDisk(name).timeout(const Duration(seconds: 5));
        await Hive.openBox(name).timeout(timeout);
        log("✅ Box '$name' opened after nuclear reset", name: "HiveSafeOpen");
      } catch (e3) {
        log("💥 UNRECOVERABLE: Box '$name' cannot be opened: $e3", name: "HiveSafeOpen");
        rethrow;
      }
    }
  }
}

Future<void> main() async {
  ReleaseErrorHandler.initialize();
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  Future.delayed(const Duration(seconds: 10), () { try { FlutterNativeSplash.remove(); } catch (_) {} });
  try {
    await platform_services.initializePlatform();
    await FirebaseService.instance.init();
    GoogleFonts.config.allowRuntimeFetching = false;
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    applicationDataPath = await platform_services.getApplicationDataPath();
    if (platformOwn == platform_services.PlatformOwn.isWindows || platformOwn == platform_services.PlatformOwn.isLinux) {
      Hive.init("${applicationDataPath!}/db");
    } else {
      await Hive.initFlutter();
    }
    await _safeOpenBox(AppBoxes.user);
    await _safeOpenBox(AppBoxes.pinned);
    await _safeOpenBox(AppBoxes.notes);
    await _safeOpenBox(AppBoxes.readingStats);
    if (platformOwn != platform_services.PlatformOwn.isLinux && platformOwn != platform_services.PlatformOwn.isWindows) {
      await JustAudioBackground.init(
        androidNotificationChannelId: "com.ryanheise.bg_demo.channel.audio",
        androidNotificationChannelName: "Audio playback",
        androidNotificationOngoing: true,
      );
    } else {
      try {
        JustAudioMediaKit.ensureInitialized();
        JustAudioMediaKit.bufferSize = 8 * 1024 * 1024;
        JustAudioMediaKit.title = "Al Quran Audio";
      } catch (e) {
        log("Unable To Config JustAudioMediaKit with error: $e");
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await configureDependencies(preferences: prefs);
    final bootstrapCoordinator = getIt<AppBootstrapCoordinator>();
    final bootstrapSnapshot = await bootstrapCoordinator.prepareApp(
      loadLocationState: LocationQiblaPrayerDataCubit.getSavedState,
    );
    await bootstrapCoordinator.prepareLaunch();
    log(bootstrapSnapshot.locationState.madhab.toString(), name: "Madhab");
    await AnalyticsTracker.instance.init();
    runApp(MyApp(
      initialLocale: bootstrapSnapshot.initialLocale,
      locationQiblaPrayerDataState: bootstrapSnapshot.locationState,
    ));
    unawaited(bootstrapCoordinator.runDeferredWarmup().catchError((error, stackTrace) {
      log("Deferred warmup failed after app launch: $error\n$stackTrace", name: "AppBootstrapWarmup");
    }));
    unawaited(AyahOfTheDayService.updateWidget(forceRefresh: true).catchError((_) {}));
    platform_services.hideLoadingIndicator();
  } catch (e, stackTrace) {
    log("Fatal error during app initialization: $e\n$stackTrace", name: "AppInit");
    try { FlutterNativeSplash.remove(); } catch (_) {}
    runApp(MaterialApp(home: _FatalErrorScreen(error: e)));
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

TextTheme getTextTheme(Locale locale, bool isDarkMode) {
  final textTheme = isDarkMode ? ThemeData.dark().textTheme : ThemeData.light().textTheme;
  return textTheme.apply(fontFamily: "NotoSans");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.initialLocale, required this.locationQiblaPrayerDataState});
  final MyAppLocalization initialLocale;
  final LocationQiblaPrayerDataState locationQiblaPrayerDataState;

  @override
  Widget build(BuildContext context) {
    try { FlutterNativeSplash.remove(); } catch (e) { log("Failed to remove splash: $e", name: "SplashRemoval"); }
    const pageTransitionsTheme = PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
      },
    );
    return _UsageTimeTracker(
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthCubit()),
          BlocProvider(create: (_) => ResourcesProgressCubit()),
          BlocProvider(create: (_) => ThemeCubit()),
          BlocProvider(create: (_) => AudioUiCubit()),
          BlocProvider(create: (_) => PlayerPositionCubit()),
          BlocProvider(create: (_) => AyahKeyCubit()),
          BlocProvider(create: (_) => AyahByAyahInScrollInfoCubit()),
          BlocProvider(create: (_) => LocationQiblaPrayerDataCubit(initState: locationQiblaPrayerDataState)),
          BlocProvider(create: (_) => SegmentedQuranReciterCubit()),
          BlocProvider(create: (_) => OfflineDownloadCubit()),
          BlocProvider(create: (_) => PlayerStateCubit(PlayerState())),
          BlocProvider(create: (_) => WordPlayingStateCubit()),
          BlocProvider(create: (_) => AudioAyahHighlightCubit()),
          BlocProvider(create: (_) => SleepTimerCubit()),
          BlocProvider(create: (_) => AyahRepeatCubit()),
          BlocProvider(create: (_) => ReadingStatsCubit()),
          BlocProvider(create: (_) => HifzCubit()),
          BlocProvider(create: (_) => NightReadingCubit()),
          BlocProvider(create: (_) => CustomPlaylistCubit()),
          BlocProvider(create: (_) => QuranViewCubit(getIt<SettingsRepository>())),
          BlocProvider(create: (_) => PrayerReminderCubit(getIt<SettingsRepository>())),
          BlocProvider(create: (_) => LanguageCubit(initialLocale)),
          BlocProvider(create: (_) => LandscapeScrollEffect()),
          BlocProvider(create: (_) => QuranHistoryCubit()),
          BlocProvider(create: (_) => AyahToHighlight(null)),
          BlocProvider(create: (_) => ReaderUICubit(getIt<ReaderSessionRepository>())),
          BlocProvider(create: (_) => QuranSettingsCubit()),
        ],
        child: BlocBuilder<LanguageCubit, MyAppLocalization>(
          builder: (context, languageState) => BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, themeState) => ScreenUtilInit(
              designSize: const Size(360, 690),
              minTextAdapt: true,
              splitScreenMode: true,
              builder: (_, child) => MaterialApp(
                navigatorKey: navigatorKey,
                debugShowCheckedModeBanner: false,
                locale: languageState.locale,
                localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
                supportedLocales: AppLocalizations.supportedLocales,
                onGenerateTitle: (_) => "Imaanly",
                theme: AppTheme.lightTheme().copyWith(pageTransitionsTheme: pageTransitionsTheme, textTheme: getTextTheme(languageState.locale, false)),
                darkTheme: AppTheme.darkTheme().copyWith(pageTransitionsTheme: pageTransitionsTheme, textTheme: getTextTheme(languageState.locale, true)),
                themeMode: themeState.themeMode,
                builder: (context, child) => _FullscreenEnforcer(child: _AudioPlayerBridgeBinder(child: child ?? const SizedBox.shrink())),
                scrollBehavior: AppScrollBehavior(),
                home: const ImaanlyHomePage(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UsageTimeTracker extends StatefulWidget {
  const _UsageTimeTracker({required this.child});
  final Widget child;
  @override State<_UsageTimeTracker> createState() => _UsageTimeTrackerState();
}

class _UsageTimeTrackerState extends State<_UsageTimeTracker> with WidgetsBindingObserver {
  static const _kUsageSeconds = "usage_time_seconds";
  DateTime? _sessionStart;
  @override void initState() { super.initState(); WidgetsBinding.instance.addObserver(this); _sessionStart = DateTime.now(); WidgetsBinding.instance.addPostFrameCallback((_) => _checkPendingSunnahPage()); }
  @override void dispose() { WidgetsBinding.instance.removeObserver(this); _saveSession(); super.dispose(); }
  @override void didChangeAppLifecycleState(AppLifecycleState state) { if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) _saveSession(); if (state == AppLifecycleState.resumed) _sessionStart = DateTime.now(); }
  Future<void> _saveSession() async { final start = _sessionStart; if (start == null) return; final elapsed = DateTime.now().difference(start).inSeconds; if (elapsed <= 0) return; _sessionStart = DateTime.now(); final prefs = await SharedPreferences.getInstance(); await prefs.setInt(_kUsageSeconds, (prefs.getInt(_kUsageSeconds) ?? 0) + elapsed); }
  Future<void> _checkPendingSunnahPage() async {}
  @override Widget build(BuildContext context) => widget.child;
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override Set<PointerDeviceKind> get dragDevices => {PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.trackpad, PointerDeviceKind.stylus};
}

class _AudioPlayerBridgeBinder extends StatefulWidget {
  const _AudioPlayerBridgeBinder({required this.child});
  final Widget child;
  @override State<_AudioPlayerBridgeBinder> createState() => _AudioPlayerBridgeBinderState();
}
class _AudioPlayerBridgeBinderState extends State<_AudioPlayerBridgeBinder> {
  @override void initState() { super.initState(); AudioPlayerUIBridge.instance.bindToNavigator(navigatorKey); }
  @override Widget build(BuildContext context) => widget.child;
}

class _FullscreenEnforcer extends StatelessWidget {
  const _FullscreenEnforcer({required this.child});
  final Widget child;
  @override Widget build(BuildContext context) { SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky); return child; }
}

class _FatalErrorScreen extends StatelessWidget {
  const _FatalErrorScreen({required this.error});
  final Object error;
  @override Widget build(BuildContext context) => Scaffold(body: Center(child: Padding(padding: const EdgeInsets.all(24), child: Text("Imaanly could not start.\n\n$error", textAlign: TextAlign.center))));
}
