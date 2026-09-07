import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:imaanly/src/screen/qibla/qibla_direction.dart';
import '../../core/utils/prayer_names.dart';
import '../../notifications/data/prayer_notification_scheduler.dart';
import '../../notifications/domain/prayer_notification_preferences.dart';
import '../../notifications/services/local_notification_service.dart';
import '../widgets/prayer_times_app_bar.dart';
import '../widgets/next_prayer_hero_card.dart';
import '../widgets/prayer_time_list_item.dart';
import '../widgets/forbidden_times_section.dart';
import '../widgets/hijri_date_card.dart';
import '../widgets/quick_actions_section.dart';
import '../../core/theme/prayer_theme_colors.dart';
import '../../core/theme/prayer_text_styles.dart';
import '../../core/theme/prayer_dimensions.dart';

/// 🕌 شاشة مواقيت الصلاة الكاملة - Premium Redesign
class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen>
    with TickerProviderStateMixin {
  late Timer _timer;
  late AnimationController _pulseController;
  late ScrollController _scrollController;

  PrayerTimes? _prayerTimes;
  Prayer? _currentPrayer;
  Prayer? _nextPrayer;
  Duration _timeUntilNext = Duration.zero;

  String _locationName = 'القاهرة، مصر';
  bool _isLoadingLocation = false;
  bool _isScrolled = false;

  final CalculationParameters _calculationMethod = CalculationParameters(
    fajrAngle: 19.5,
    ishaAngle: 17.5,
    method: CalculationMethod.egyptian,
  );

  final PrayerNotificationScheduler _notificationScheduler =
      PrayerNotificationScheduler(
    notifications: LocalNotificationService.instance,
  );

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeScrollListener();
    _loadPrayerTimes();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  void _initializeScrollListener() {
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      final isScrolled = _scrollController.offset > 10;
      if (isScrolled != _isScrolled) {
        setState(() => _isScrolled = isScrolled);
      }
    });
  }

  Future<void> _loadPrayerTimes() async {
    if (!mounted) return;
    setState(() => _isLoadingLocation = true);

    try {
      Position? position;
      try {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          var permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }
          if (permission == LocationPermission.always ||
              permission == LocationPermission.whileInUse) {
            position = await Geolocator.getCurrentPosition();
          }
        }
      } catch (error) {
        debugPrint('Location lookup failed, using fallback: $error');
      }

      final latitude = position?.latitude ?? 30.0444;
      final longitude = position?.longitude ?? 31.2357;
      var resolvedLocation = 'الموقع الحالي';

      if (position != null) {
        try {
          final placemarks = await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          );
          if (placemarks.isNotEmpty) {
            final place = placemarks.first;
            resolvedLocation = [place.locality, place.country]
                .whereType<String>()
                .where((value) => value.trim().isNotEmpty)
                .join('، ');
            if (resolvedLocation.isEmpty) resolvedLocation = 'الموقع الحالي';
          }
        } catch (error) {
          debugPrint('Reverse geocoding failed: $error');
        }
      } else {
        resolvedLocation = 'القاهرة، مصر';
      }

      final now = DateTime.now();
      final prayerTimes = PrayerTimes(
        coordinates: Coordinates(latitude, longitude),
        date: now,
        calculationParameters: _calculationMethod,
        precision: true,
      );

      if (!mounted) return;
      setState(() {
        _prayerTimes = prayerTimes;
        _locationName = resolvedLocation;
        _updateCurrentAndNextPrayer();
        _isLoadingLocation = false;
      });

      await _synchronizePrayerNotifications(prayerTimes);
    } catch (e) {
      debugPrint('Error loading prayer times: $e');
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _synchronizePrayerNotifications(PrayerTimes prayerTimes) async {
    try {
      final schedule = <PrayerScheduleNotificationTime>[];
      for (final entry in const <MapEntry<String, Prayer>>[
        MapEntry('Fajr', Prayer.fajr),
        MapEntry('Dhuhr', Prayer.dhuhr),
        MapEntry('Asr', Prayer.asr),
        MapEntry('Maghrib', Prayer.maghrib),
        MapEntry('Isha', Prayer.isha),
      ]) {
        final time = prayerTimes.timeForPrayer(entry.value);
        schedule.add(
          PrayerScheduleNotificationTime(
            prayerName: entry.key,
            time: time,
          ),
        );
      }

      await _notificationScheduler.synchronize(
        schedule: schedule,
        preferences: const PrayerNotificationPreferences(),
      );
    } catch (error, stackTrace) {
      LocalNotificationService.instance.logError(error, stackTrace);
    }
  }

  void _updateCurrentAndNextPrayer() {
    if (_prayerTimes == null) return;

    final now = DateTime.now();
    _currentPrayer = _prayerTimes!.currentPrayer(date: now);
    _nextPrayer = _prayerTimes!.nextPrayer(date: now);

    if (_nextPrayer != null) {
      final nextPrayerTime = _prayerTimes!.timeForPrayer(_nextPrayer!);
      _timeUntilNext = nextPrayerTime.difference(now);
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(_updateCurrentAndNextPrayer);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: PrayerThemeColors.getBgColor(isDark),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          _buildBackgroundPattern(isDark),
          SafeArea(
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: PrayerTimesAppBar(
                    locationName: _locationName,
                    isLoading: _isLoadingLocation,
                    isScrolled: _isScrolled,
                    onLocationTap: _onLocationTap,
                    onRefresh: _onRefresh,
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: PrayerDimensions.pagePadding,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      SizedBox(height: PrayerDimensions.space16),
                      if (_nextPrayer != null && _prayerTimes != null)
                        NextPrayerHeroCard(
                          nextPrayer: _nextPrayer!,
                          prayerTime: _prayerTimes!.timeForPrayer(_nextPrayer!),
                          timeUntilNext: _timeUntilNext,
                          pulseAnimation: _pulseController,
                        ).animate().fadeIn(
                              duration: Duration(
                                milliseconds: PrayerDimensions.durationNormal,
                              ),
                              curve: Curves.easeOutCubic,
                            ).slideY(
                              begin: 0.04,
                              end: 0,
                              curve: Curves.easeOutCubic,
                            ),
                      SizedBox(height: PrayerDimensions.sectionSpacing),
                      _buildSectionHeader(
                        'مواقيت الصلاة',
                        Icons.access_time_rounded,
                        isDark,
                      ),
                      SizedBox(height: PrayerDimensions.space16),
                      if (_prayerTimes != null)
                        _buildPrayerTimesList().animate().fadeIn(
                              duration: Duration(
                                milliseconds: PrayerDimensions.durationNormal,
                              ),
                              delay: Duration(
                                milliseconds: PrayerDimensions.durationInstant,
                              ),
                            ).slideY(begin: 0.04, end: 0),
                      SizedBox(height: PrayerDimensions.sectionSpacing),
                      _buildSectionHeader(
                        'أوقات النهي عن الصلاة',
                        Icons.block_rounded,
                        isDark,
                      ),
                      SizedBox(height: PrayerDimensions.space16),
                      if (_prayerTimes != null)
                        ForbiddenTimesSection(prayerTimes: _prayerTimes!)
                            .animate()
                            .fadeIn(
                              duration: Duration(
                                milliseconds: PrayerDimensions.durationNormal,
                              ),
                              delay: Duration(
                                milliseconds: PrayerDimensions.durationFast,
                              ),
                            )
                            .slideY(begin: 0.04, end: 0),
                      SizedBox(height: PrayerDimensions.sectionSpacing),
                      HijriDateCard(onTap: _onCalendarTap)
                          .animate()
                          .fadeIn(
                            duration: Duration(
                              milliseconds: PrayerDimensions.durationNormal,
                            ),
                            delay: Duration(
                              milliseconds: PrayerDimensions.durationNormal,
                            ),
                          )
                          .slideY(begin: 0.04, end: 0),
                      SizedBox(height: PrayerDimensions.sectionSpacing),
                      _buildSectionHeader(
                        'إجراءات سريعة',
                        Icons.flash_on_rounded,
                        isDark,
                      ),
                      SizedBox(height: PrayerDimensions.space16),
                      QuickActionsSection(
                        onQiblaTap: _onQiblaTap,
                        onAdhanTap: _onAdhanTap,
                        onSettingsTap: _onSettingsTap,
                        onCalendarTap: _onCalendarTap,
                      ).animate().fadeIn(
                            duration: Duration(
                              milliseconds: PrayerDimensions.durationNormal,
                            ),
                            delay: Duration(
                              milliseconds: PrayerDimensions.durationSlow,
                            ),
                          ).slideY(begin: 0.04, end: 0),
                      SizedBox(height: PrayerDimensions.sectionSpacing),
                      _buildFooterInfo(isDark),
                      SizedBox(height: PrayerDimensions.space24),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundPattern(bool isDark) {
    return Positioned.fill(
      child: Opacity(
        opacity: PrayerDimensions.opacitySubtle,
        child: Image.asset(
          'assets/img/sajadah.png',
          repeat: ImageRepeat.repeat,
          color: PrayerThemeColors.getTextColor('primary', isDark),
          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Container(
          width: 32.w,
          height: 32.h,
          decoration: BoxDecoration(
            color: PrayerThemeColors.green.withValues(
              alpha: PrayerDimensions.opacityMedium,
            ),
            borderRadius: BorderRadius.circular(PrayerDimensions.radiusSmall),
          ),
          child: Icon(
            icon,
            size: PrayerDimensions.iconInline,
            color: PrayerThemeColors.green,
          ),
        ),
        SizedBox(width: PrayerDimensions.space12),
        Text(
          title,
          style: PrayerTextStyles.arabicHeadline(
            color: PrayerThemeColors.getTextColor('primary', isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerTimesList() {
    final prayers = [
      Prayer.fajr,
      Prayer.sunrise,
      Prayer.dhuhr,
      Prayer.asr,
      Prayer.maghrib,
      Prayer.isha,
    ];

    return Column(
      children: prayers.asMap().entries.map((entry) {
        final prayer = entry.value;
        final prayerTime = _prayerTimes!.timeForPrayer(prayer);
        final isPassed = DateTime.now().isAfter(prayerTime);
        final isCurrent = _currentPrayer == prayer;
        final isNext = _nextPrayer == prayer;

        return Padding(
          padding: EdgeInsets.only(bottom: PrayerDimensions.listItemSpacing),
          child: PrayerTimeListItem(
            prayer: prayer,
            prayerTime: prayerTime,
            isPassed: isPassed,
            isCurrent: isCurrent,
            isNext: isNext,
          ),
        );
      }).toList(),
    );
  }

  void _onLocationTap() => _loadPrayerTimes();
  void _onRefresh() => _loadPrayerTimes();
  void _onCalendarTap() {}
  void _onQiblaTap() => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const QiblaDirection()),
      );
  void _onAdhanTap() {}
  void _onSettingsTap() {}

  Widget _buildFooterInfo(bool isDark) => const SizedBox.shrink();
}
