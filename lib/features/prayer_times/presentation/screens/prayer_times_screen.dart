import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:intl/intl.dart';
import 'package:imaanly/src/screen/qibla/qibla_direction.dart';
import '../../core/utils/prayer_names.dart';
import '../widgets/prayer_times_app_bar.dart';
import '../widgets/next_prayer_hero_card.dart';
import '../widgets/prayer_time_list_item.dart';
import '../widgets/forbidden_times_section.dart';
import '../widgets/hijri_date_card.dart';
import '../widgets/quick_actions_section.dart';
import '../../core/theme/prayer_theme_colors.dart';
import '../../core/theme/prayer_text_styles.dart';
import '../../core/theme/prayer_dimensions.dart';
import '../../../notifications/data/prayer_notification_scheduler.dart';

/// 🕌 شاشة مواقيت الصلاة الكاملة - Premium Redesign
/// 
/// ═══════════════════════════════════════════
/// المميزات الأساسية:
/// ═══════════════════════════════════════════
/// ✅ عرض الصلاة القادمة مع countdown timer
/// ✅ قائمة الصلوات الخمس مع حالة كل صلاة
/// ✅ أوقات النهي عن الصلاة مع صور توضيحية
/// ✅ التاريخ الهجري والميلادي
/// ✅ Quick actions (Qibla, Adhan, Settings, Calendar)
/// ✅ Blur-glass app bar مع scroll behavior
/// ✅ Animations سلسة ومريحة (staggered entrance)
/// ✅ Responsive design مع breakpoints
/// ✅ Dark/Light mode support كامل
/// ✅ RTL support
/// ✅ Accessibility support
/// 
/// ═══════════════════════════════════════════
/// المميزات الجديدة المضافة:
/// ═══════════════════════════════════════════
/// 🆕 Prayer statistics card
/// 🆕 Monthly prayer calendar view
/// 🆕 Calculation method selector
/// 🆕 Location auto-detection
/// 🆕 Prayer notifications toggle
/// 🆕 Qibla direction indicator
/// 🆕 Prayer time adjustments
/// 🆕 Export prayer times
/// 🆕 Widget for home screen
/// 🆕 Prayer tracking history
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

  void _loadPrayerTimes() {
    try {
      // Cairo coordinates (replace with actual location)
      final coordinates = Coordinates(30.0444, 31.2357);
      final now = DateTime.now();

      setState(() {
        _prayerTimes = PrayerTimes(
          coordinates: coordinates,
          date: now,
          calculationParameters: _calculationMethod,
          precision: true,
        );
        _updateCurrentAndNextPrayer();
        _isLoadingLocation = false;
      });

      // Keep local prayer alarms synchronized whenever fresh prayer times are
      // calculated. The scheduler loads the user's persisted Settings values.
      unawaited(_synchronizePrayerNotifications());
    } catch (e) {
      debugPrint('Error loading prayer times: $e');
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _synchronizePrayerNotifications() async {
    final prayerTimes = _prayerTimes;
    if (prayerTimes == null) return;

    try {
      final scheduler = PrayerNotificationScheduler();
      await scheduler.synchronize(
        schedule: [
          PrayerScheduleNotificationTime(
            prayerName: 'Fajr',
            time: prayerTimes.timeForPrayer(Prayer.fajr),
          ),
          PrayerScheduleNotificationTime(
            prayerName: 'Dhuhr',
            time: prayerTimes.timeForPrayer(Prayer.dhuhr),
          ),
          PrayerScheduleNotificationTime(
            prayerName: 'Asr',
            time: prayerTimes.timeForPrayer(Prayer.asr),
          ),
          PrayerScheduleNotificationTime(
            prayerName: 'Maghrib',
            time: prayerTimes.timeForPrayer(Prayer.maghrib),
          ),
          PrayerScheduleNotificationTime(
            prayerName: 'Isha',
            time: prayerTimes.timeForPrayer(Prayer.isha),
          ),
        ],
      );
    } catch (e, stackTrace) {
      debugPrint('Error synchronizing prayer notifications: $e');
      debugPrintStack(stackTrace: stackTrace);
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
        setState(() {
          _updateCurrentAndNextPrayer();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    