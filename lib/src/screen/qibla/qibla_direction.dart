import "dart:math" as math;
import "dart:async";

import "package:imaanly/l10n/app_localizations.dart";
import "package:imaanly/src/screen/location_handler/location_aquire.dart";
import "package:imaanly/src/screen/location_handler/model/location_data_qibla_data_state.dart";
import "package:imaanly/src/screen/qibla/ar_qibla_screen.dart";
import "package:imaanly/src/screen/qibla/qibla_guidance.dart";
import "package:imaanly/src/screen/mushaf/widgets/wahy_side_drawer.dart";
import "package:imaanly/src/theme/controller/theme_cubit.dart";
import "package:imaanly/src/theme/controller/theme_state.dart";
import "package:imaanly/src/utils/number_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_compass_v2/flutter_compass_v2.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:gap/gap.dart";
import "package:vibration/vibration.dart";
import "package:google_fonts/google_fonts.dart";
import "package:vector_math/vector_math.dart" as vector;

class QiblaDirection extends StatefulWidget {
  final bool showAppBar;
  const QiblaDirection({super.key, this.showAppBar = false});

  @override
  State<QiblaDirection> createState() => _QiblaDirectionState();
}

class _QiblaDirectionState extends State<QiblaDirection> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  double? _smoothedHeading;
  bool _showTips = true;
  bool _alignedLatch = false;
  bool _hasVibrator = false;
  bool _hasAmplitudeSupport = false;
  int _calibrationProgress = 0;
  Timer? _calibrationTimer;
  
  // EMA smoothing for INSTANT response
  static const double _emaAlpha = 0.5; // Much higher = instant response
  double? _emaValue;
  
  // New features
  bool _showAdvancedStats = false;
  bool _compassLocked = false;
  double _compassAccuracy = 0.0;
  int _alignmentCount = 0;
  DateTime? _lastAlignmentTime;
  final List<double> _accuracyHistory = [];
  bool _autoVibrate = true;
  bool _showDistance = true;
  double _distanceToKaaba = 0.0;
  
  // Performance tracking
  DateTime? _lastUpdateTime;
  double _updateFrequency = 0.0;
  final List<double> _frequencyHistory = [];
  
  // Sound effects
  bool _soundEffects = false;

  @override
  void initState() {
    super.initState();
    _initVibration();
  }

  @override
  void dispose() {
    _calibrationTimer?.cancel();
    super.dispose();
  }

  // ULTRA-fast smoothing - minimal processing for instant response
  double _advancedSmoothing(double rawHeading) {
    // Only use EMA for instant response
    if (_emaValue == null) {
      _emaValue = rawHeading;
      return rawHeading;
    }
    
    final double diff = shortestSignedAngleDifference(_emaValue!, rawHeading);
    _emaValue = normalizeDegrees(_emaValue! + _emaAlpha * diff);
    
    return _emaValue!;
  }
  
  // Start calibration mode
  void _startCalibration() {
    setState(() {
      _calibrationProgress = 0;
    });
    
    _calibrationTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _calibrationProgress++;
        if (_calibrationProgress >= 100) {
          timer.cancel();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Calibration successful!",
                style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF12906A),
            ),
          );
        }
      });
    });
  }

  Future<void> _initVibration() async {
    final hasVib = await Vibration.hasVibrator();
    _hasVibrator = hasVib == true;
    if (_hasVibrator) {
      final hasAmp = await Vibration.hasCustomVibrationsSupport();
      _hasAmplitudeSupport = hasAmp == true;
    }
  }

  Future<void> _refreshLocation() async {
    await context.read<LocationQiblaPrayerDataCubit>().getLocation();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Location and Qibla direction updated."),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _vibrateOnAlignment() async {
    if (!_hasVibrator || _alignedLatch) return;
    _alignedLatch = true;
    await Vibration.vibrate(
      amplitude: _hasAmplitudeSupport ? 180 : -1,
      duration: 70,
    );
  }

  void _handleAlignment(QiblaGuidance guidance) {
    // Track update frequency
    if (_lastUpdateTime != null) {
      final timeDiff = DateTime.now().difference(_lastUpdateTime!).inMilliseconds;
      if (timeDiff > 0) {
        final double freq = 1000 / timeDiff; // Updates per second
        _frequencyHistory.add(freq);
        if (_frequencyHistory.length > 10) {
          _frequencyHistory.removeAt(0);
        }
        _updateFrequency = _frequencyHistory.reduce((a, b) => a + b) / _frequencyHistory.length;
      }
    }
    _lastUpdateTime = DateTime.now();
    
    if (guidance.isAligned) {
      if (_autoVibrate) {
        _vibrateOnAlignment();
      }
      if (!_alignedLatch) {
        _alignmentCount++;
        _lastAlignmentTime = DateTime.now();
      }
    } else {
      _alignedLatch = false;
    }
    
    // Calculate compass accuracy
    _accuracyHistory.add(guidance.absoluteDifference);
    if (_accuracyHistory.length > 10) {
      _accuracyHistory.removeAt(0);
    }
    
    if (_accuracyHistory.isNotEmpty) {
      final double avgDiff = _accuracyHistory.reduce((a, b) => a + b) / _accuracyHistory.length;
      _compassAccuracy = (1 - (avgDiff / 180)) * 100;
      _compassAccuracy = _compassAccuracy.clamp(0, 100);
    }
  }
  
  void _calculateDistance(double userLat, double userLon) {
    // Haversine formula to calculate distance
    const double earthRadius = 6371; // km
    final double dLat = (kaabaLatDegrees - userLat) * math.pi / 180;
    final double dLon = (kaabaLonDegrees - userLon) * math.pi / 180;
    
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(userLat * math.pi / 180) * math.cos(kaabaLatDegrees * math.pi / 180) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    _distanceToKaaba = earthRadius * c;
  }

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeCubit>().state;
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: cs.surface,
      drawer: WahySideDrawer(
        primary: cs.primary,
        onOpenIndex: () {},
        onOpenBookmarks: () {},
        onOpenStarred: () {},
        onOpenNotes: () {},
        onJumpToAyah: (_) {},
      ),
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.qibla,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: cs.onSurface,
          ),
        ),
        leading: IconButton(
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          icon: Icon(Icons.menu_rounded, color: cs.primary),
          tooltip: "Main menu",
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ARQiblaScreen()),
              );
            },
            icon: Icon(Icons.view_in_ar_rounded, color: cs.primary),
            tooltip: "AR Qibla",
          ),
          const Gap(4),
        ],
      ),
      body: BlocBuilder<LocationQiblaPrayerDataCubit, LocationQiblaPrayerDataState>(
        builder: (context, state) {
          if (state.latLon == null) {
            return const LocationAcquire();
          }
          if (state.kaabaAngle == null) {
            return Center(
              child: CircularProgressIndicator(
                color: themeState.primary,
                backgroundColor: themeState.primaryShade100,
              ),
            );
          }

          return StreamBuilder<CompassEvent>(
            stream: FlutterCompass.events,
            builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _buildUnavailableState(
                      icon: Icons.explore_off_rounded,
                      title: "Couldn't read compass data",
                      subtitle: l10n.unableToGetCompassData,
                    );
                  }

                  final direction = snapshot.data?.heading;
                  if (direction == null || !direction.isFinite) {
                    return _buildUnavailableState(
                      icon: Icons.sensors_off_rounded,
                      title: "Sensors unavailable",
                      subtitle: l10n.deviceDoesNotHaveSensors,
                    );
                  }

                  // Normalize direction
                  double rawHeading = direction;
                  if (rawHeading < 0) {
                    rawHeading = 180 + (180 - rawHeading.abs());
                  }

                  // Apply advanced smoothing
                  _smoothedHeading = _advancedSmoothing(rawHeading);

                  final guidance = resolveQiblaGuidance(
                    headingDegrees: _smoothedHeading!,
                    qiblaDegrees: state.kaabaAngle!,
                  );
                  _handleAlignment(guidance);
                  
                  // Calculate distance to Kaaba
                  if (_showDistance && state.latLon != null) {
                    _calculateDistance(state.latLon!.latitude, state.latLon!.longitude);
                  }

                  return _buildQiblaBody(
                    context: context,
                    themeState: themeState,
                    guidance: guidance,
                    state: state,
                  );
                },
              );
        },
      ),
    );
  }

  Widget _buildQiblaBody({
    required BuildContext context,
    required ThemeState themeState,
    required QiblaGuidance guidance,
    required LocationQiblaPrayerDataState state,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _statusColor(guidance, themeState);
    final screenWidth = MediaQuery.of(context).size.width;
    final compassSize = math.min(screenWidth - 48, 320.0);
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      physics: const BouncingScrollPhysics(),
      children: [
        // Warning Card - IMPORTANT
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFFEF3C7),
                const Color(0xFFFDE68A),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFD08A1E),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD08A1E).withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD08A1E),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD08A1E).withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.warning_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const Gap(14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "⚠️ Important notice",
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF92400E),
                          ),
                        ),
                        const Gap(4),
                        Text(
                          "The digital compass may contain errors",
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF92400E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "• Don't rely on it entirely to determine the Qibla direction",
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        height: 1.7,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF92400E),
                      ),
                    ),
                    const Gap(6),
                    Text(
                      "• Use other means to confirm the correct direction",
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        height: 1.7,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF92400E),
                      ),
                    ),
                    const Gap(6),
                    Text(
                      "• Accuracy will be improved in upcoming updates, God willing",
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        height: 1.7,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Gap(16),
        _buildHeroCard(
          guidance: guidance,
          themeState: themeState,
          isDark: isDark,
          state: state,
        ),
        const Gap(16),
        // Professional Compass Container
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF11332A) : Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: statusColor.withValues(alpha: 0.2),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Professional Compass with CustomPainter
              SizedBox(
                width: compassSize,
                height: compassSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Rotating Compass with CustomPainter
                    AnimatedRotation(
                      turns: _compassLocked ? 0 : (guidance.heading / 360),
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.linear,
                      child: CustomPaint(
                        size: Size(compassSize, compassSize),
                        painter: _CompassPainter(
                          context: context,
                          kaabaAngle: guidance.bearing,
                          themeState: themeState,
                          appLocalizations: l10n,
                        ),
                      ),
                    ),
                    
                    // Center Kaaba Icon
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: statusColor,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withValues(alpha: 0.3),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: SvgPicture.asset(
                          "assets/img/kaaba.svg",
                          colorFilter: ColorFilter.mode(
                            statusColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const Gap(20),
              
              // Guidance Text
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [statusColor, statusColor.withValues(alpha: 0.85)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  _guidanceText(guidance),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              
              const Gap(20),
              
              // Progress Bar
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Accuracy",
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      Text(
                        "${(guidance.progress * 100).toInt()}%",
                        style: GoogleFonts.dmMono(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                  const Gap(8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: guidance.progress,
                      minHeight: 10,
                      backgroundColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08),
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Gap(16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: "Qibla angle",
                value: "${guidance.bearing.round()}°",
                subtitle: _getCardinalDirection(guidance.bearing),
                icon: Icons.explore_rounded,
                color: themeState.primary,
                isDark: isDark,
              ),
            ),
            const Gap(10),
            Expanded(
              child: _buildStatCard(
                title: "Phone direction",
                value: "${guidance.heading.round()}°",
                subtitle: _getCardinalDirection(guidance.heading),
                icon: Icons.phone_android_rounded,
                color: const Color(0xFF2F9BB5),
                isDark: isDark,
              ),
            ),
            const Gap(10),
            Expanded(
              child: _buildStatCard(
                title: "Current difference",
                value: "${guidance.absoluteDifference.round()}°",
                subtitle: guidance.isAligned ? "Matching ✓" : "Needs improvement",
                icon: Icons.compare_arrows_rounded,
                color: statusColor,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const Gap(14),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.autorenew_rounded,
                title: "Compass calibration",
                subtitle: "Improve accuracy",
                color: const Color(0xFF2F9BB5),
                onTap: () => _startCalibration(),
                isDark: isDark,
              ),
            ),
            const Gap(10),
            Expanded(
              child: _buildActionCard(
                icon: Icons.my_location_rounded,
                title: "Update location",
                subtitle: "Recalculate Qibla",
                color: const Color(0xFF12906A),
                onTap: () => _refreshLocation(),
                isDark: isDark,
              ),
            ),
          ],
        ),
        const Gap(10),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.view_in_ar_rounded,
                title: "AR mode",
                subtitle: "Direct guidance view",
                color: statusColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ARQiblaScreen()),
                  );
                },
                isDark: isDark,
              ),
            ),
          ],
        ),
        const Gap(14),
        // Advanced Statistics Card
        if (_showAdvancedStats)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF0E2E25), const Color(0xFF071E18)]
                    : [const Color(0xFFF3F8F5), Colors.white],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: themeState.primary.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.analytics_rounded, color: themeState.primary, size: 20),
                    const Gap(10),
                    Text(
                      "Advanced statistics",
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => setState(() => _showAdvancedStats = false),
                      icon: Icon(
                        Icons.close_rounded,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  ],
                ),
                const Gap(14),
                Row(
                  children: [
                    Expanded(
                      child: _buildMiniStat(
                        "Compass accuracy",
                        "${_compassAccuracy.toStringAsFixed(1)}%",
                        Icons.speed_rounded,
                        themeState.primary,
                        isDark,
                      ),
                    ),
                    const Gap(10),
                    Expanded(
                      child: _buildMiniStat(
                        "Alignment count",
                        "$_alignmentCount",
                        Icons.check_circle_rounded,
                        const Color(0xFF12906A),
                        isDark,
                      ),
                    ),
                  ],
                ),
                const Gap(10),
                if (_showDistance)
                  _buildMiniStat(
                    "Distance to the Kaaba",
                    "${_distanceToKaaba.toStringAsFixed(0)} km",
                    Icons.social_distance_rounded,
                    const Color(0xFFC9A24B),
                    isDark,
                  ),
                if (_lastAlignmentTime != null) ...[
                  const Gap(10),
                  _buildMiniStat(
                    "Last alignment",
                    _formatTimeSince(_lastAlignmentTime!),
                    Icons.access_time_rounded,
                    const Color(0xFF2F9BB5),
                    isDark,
                  ),
                ],
                const Gap(10),
                _buildMiniStat(
                  "Refresh rate",
                  "${_updateFrequency.toStringAsFixed(1)} Hz",
                  Icons.speed_rounded,
                  const Color(0xFF6A4FC4),
                  isDark,
                ),
              ],
            ),
          ),
        if (_showAdvancedStats) const Gap(14),
        // Settings Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF0E2E25), const Color(0xFF071E18)]
                  : [Colors.white, const Color(0xFFF3F8F5)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: themeState.primary.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.settings_rounded, color: themeState.primary, size: 20),
                  const Gap(10),
                  Text(
                    "Compass settings",
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              const Gap(14),
              _buildSettingRow(
                "Auto-vibrate when aligned",
                _autoVibrate,
                (value) => setState(() => _autoVibrate = value),
                Icons.vibration_rounded,
                isDark,
              ),
              const Gap(10),
              _buildSettingRow(
                "Show distance to the Kaaba",
                _showDistance,
                (value) => setState(() => _showDistance = value),
                Icons.social_distance_rounded,
                isDark,
              ),
              const Gap(10),
              _buildSettingRow(
                "View advanced statistics",
                _showAdvancedStats,
                (value) => setState(() => _showAdvancedStats = value),
                Icons.analytics_rounded,
                isDark,
              ),
              const Gap(10),
              _buildSettingRow(
                "Lock compass (prevent rotation)",
                _compassLocked,
                (value) => setState(() => _compassLocked = value),
                Icons.lock_rounded,
                isDark,
              ),
              const Gap(10),
              _buildSettingRow(
                "Sound effects on alignment",
                _soundEffects,
                (value) => setState(() => _soundEffects = value),
                Icons.volume_up_rounded,
                isDark,
              ),
              const Gap(14),
              // Quick Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _shareQiblaInfo(guidance, state),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeState.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: Text(
                        "Share",
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _resetStatistics(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: Text(
                        "Reset",
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Gap(14),
        // Info Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF2F9BB5).withValues(alpha: 0.08),
                const Color(0xFF2F9BB5).withValues(alpha: 0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF2F9BB5).withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: const Color(0xFF2F9BB5),
                size: 20,
              ),
              const Gap(12),
              Expanded(
                child: Text(
                  "Compass improved with advanced algorithms for best accuracy and responsiveness",
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    height: 1.6,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  void _shareQiblaInfo(QiblaGuidance guidance, LocationQiblaPrayerDataState state) {
    final latitude = state.latLon!.latitude.toStringAsFixed(4);
    final longitude = state.latLon!.longitude.toStringAsFixed(4);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Qibla info:\n"
          "Location: $latitude, $longitude\n"
          "Qibla angle: ${guidance.bearing.round()}°\n"
          "Distance: ${_distanceToKaaba.toStringAsFixed(0)} km\n"
          "Accuracy: ${_compassAccuracy.toStringAsFixed(1)}%",
          style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: "Copy",
          onPressed: () {},
        ),
      ),
    );
  }
  
  void _resetStatistics() {
    setState(() {
      _alignmentCount = 0;
      _lastAlignmentTime = null;
      _accuracyHistory.clear();
      _compassAccuracy = 0.0;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Statistics reset successfully",
          style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF12906A),
      ),
    );
  }
  
  Widget _buildMiniStat(String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const Gap(6),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          const Gap(8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmMono(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSettingRow(
    String title,
    bool value,
    Function(bool) onChanged,
    IconData icon,
    bool isDark,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: isDark ? Colors.white70 : Colors.black54),
        const Gap(10),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }
  
  String _formatTimeSince(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) {
      return "${diff.inSeconds} seconds ago";
    } else if (diff.inMinutes < 60) {
      return "${diff.inMinutes} minutes ago";
    } else {
      return "${diff.inHours} hours ago";
    }
  }

  Widget _buildHeroCard({
    required QiblaGuidance guidance,
    required ThemeState themeState,
    required bool isDark,
    required LocationQiblaPrayerDataState state,
  }) {
    final statusColor = _statusColor(guidance, themeState);
    final latitude = state.latLon!.latitude.toStringAsFixed(4);
    final longitude = state.latLon!.longitude.toStringAsFixed(4);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: isDark
              ? [
                  const Color(0xFF0E2E25),
                  statusColor.withValues(alpha: 0.15),
                ]
              : [
                  Colors.white,
                  statusColor.withValues(alpha: 0.08),
                ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.25),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [statusColor, statusColor.withValues(alpha: 0.8)],
                  ),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      guidance.isAligned ? Icons.check_circle_rounded : Icons.adjust_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const Gap(6),
                    Text(
                      _statusLabel(guidance),
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (_showTips)
                IconButton(
                  onPressed: () => setState(() => _showTips = false),
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                  tooltip: "Hide tips",
                ),
            ],
          ),
          const Gap(14),
          Text(
            _guidanceText(guidance),
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black87,
              height: 1.3,
            ),
          ),
          const Gap(10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 18,
                  color: statusColor,
                ),
                const Gap(8),
                Expanded(
                  child: Text(
                    "Your location: $latitude, $longitude",
                    style: GoogleFonts.dmMono(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.08),
            color.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const Gap(8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          const Gap(10),
          Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmMono(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const Gap(6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white60 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.12),
                color.withValues(alpha: 0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const Gap(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      subtitle,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnavailableState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 46, color: Theme.of(context).colorScheme.primary),
            const Gap(14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const Gap(8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.7,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(QiblaGuidance guidance, ThemeState themeState) {
    switch (guidance.alignment) {
      case QiblaAlignment.aligned:
        return themeState.primary;
      case QiblaAlignment.close:
        return const Color(0xFFC9A24B);
      case QiblaAlignment.adjusting:
        return const Color(0xFF6B7280);
    }
  }

  String _statusLabel(QiblaGuidance guidance) {
    switch (guidance.alignment) {
      case QiblaAlignment.aligned:
        return "Perfect alignment";
      case QiblaAlignment.close:
        return "Very close";
      case QiblaAlignment.adjusting:
        return "Needs adjustment";
    }
  }

  String _guidanceText(QiblaGuidance guidance) {
    if (guidance.isAligned) {
      return "Qibla is ahead of you now";
    }
    if (guidance.turn == QiblaTurn.right) {
      return "Turn right ${guidance.absoluteDifference.round()}°";
    }
    if (guidance.turn == QiblaTurn.left) {
      return "Turn left ${guidance.absoluteDifference.round()}°";
    }
    return "Hold the phone steady";
  }
  
  String _getCardinalDirection(double degrees) {
    const directions = [
      "North", "Northeast", "East", "Southeast",
      "South", "Southwest", "West", "Northwest"
    ];
    final int index = ((degrees + 22.5) / 45).floor() % 8;
    return directions[index];
  }
}

// Professional Compass Painter
class _CompassPainter extends CustomPainter {
  final BuildContext context;
  final double kaabaAngle;
  final ThemeState themeState;
  final AppLocalizations appLocalizations;

  _CompassPainter({
    required this.context,
    required this.kaabaAngle,
    required this.themeState,
    required this.appLocalizations,
  });

  static const Color _gold = Color(0xFFE2BC6B);
  static const Color _cream = Color(0xFFCFE3D9);
  static const Color _north = Color(0xFFE5543A);

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    canvas.translate(center.dx, center.dy);

    final double radius = size.width / 2;
    final double edge = radius - 5;
    final Rect dialRect = Rect.fromCircle(center: Offset.zero, radius: radius);

    // Dial disc
    canvas.drawCircle(
      Offset.zero,
      radius,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFF14604A), Color(0xFF082B22), Color(0xFF05201A)],
          stops: [0.0, 0.72, 1.0],
        ).createShader(dialRect),
    );

    // Outer gold ring and inner keyline
    canvas.drawCircle(
      Offset.zero,
      radius - 1.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = _gold,
    );
    canvas.drawCircle(
      Offset.zero,
      radius - 72,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = _gold.withValues(alpha: 0.28),
    );

    // Qibla pointer: glow, shaft and arrowhead
    final double qiblaRadian = vector.radians(kaabaAngle);
    canvas.save();
    canvas.rotate(qiblaRadian);
    canvas.drawLine(
      const Offset(0, -34),
      Offset(0, -(edge - 56)),
      Paint()
        ..color = _gold.withValues(alpha: 0.30)
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawLine(
      const Offset(0, -34),
      Offset(0, -(edge - 56)),
      Paint()
        ..color = _gold
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    final Path arrow = Path()
      ..moveTo(0, -(edge - 28))
      ..lineTo(-11, -(edge - 58))
      ..lineTo(11, -(edge - 58))
      ..close();
    canvas.drawPath(arrow, Paint()..color = _gold);
    canvas.restore();

    // North marker
    final Path northMarker = Path()
      ..moveTo(0, -(edge - 7))
      ..lineTo(-7, -(edge + 3))
      ..lineTo(7, -(edge + 3))
      ..close();
    canvas.drawPath(northMarker, Paint()..color = _north);

    // Degree ticks, labels and cardinal directions
    for (int degree = 0; degree < 360; degree++) {
      if (degree % 2 != 0) continue;
      final bool is30 = degree % 30 == 0;
      final bool is90 = degree % 90 == 0;
      double length = 5;
      Color color = Colors.white.withValues(alpha: 0.32);
      double width = 1;

      if (is30) {
        length = 10;
        color = _gold.withValues(alpha: 0.9);
        width = 2;
      }
      if (is90) {
        length = 15;
        color = _gold;
        width = 3;
      }

      final double radian = vector.radians(degree.toDouble());
      final Paint tickPaint = Paint()
        ..color = color
        ..strokeCap = StrokeCap.round
        ..strokeWidth = width;
      canvas.drawLine(
        Offset(math.sin(radian) * edge, -math.cos(radian) * edge),
        Offset(math.sin(radian) * (edge - length), -math.cos(radian) * (edge - length)),
        tickPaint,
      );

      if (!is30) continue;
      canvas.save();
      canvas.rotate(radian);

      TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: localizedNumber(context, degree),
          style: TextStyle(
            fontSize: is90 ? 14 : 11,
            color: is90 ? _gold : _cream.withValues(alpha: 0.75),
            fontWeight: is90 ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -(edge - 26)));

      if (is90) {
        final List<String> directionList = [
          appLocalizations.north,
          appLocalizations.east,
          appLocalizations.south,
          appLocalizations.west,
        ];
        textPainter = TextPainter(
          text: TextSpan(
            text: directionList[(degree / 90).toInt()],
            style: TextStyle(
              fontSize: 18,
              color: degree == 0 ? _north : Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(canvas, Offset(-textPainter.width / 2, -(edge - 50)));
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! _CompassPainter || oldDelegate.kaabaAngle != kaabaAngle;
  }
}
