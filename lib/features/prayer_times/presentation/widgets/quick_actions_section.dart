import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/athan_audio_service.dart';
import '../../core/theme/prayer_theme_colors.dart';
import '../../core/theme/prayer_dimensions.dart';
import '../../core/theme/prayer_text_styles.dart';

/// Quick actions for the prayer screen.
///
/// The Athan action opens a real audio picker/preview. Playback is explicitly
/// user initiated so it works with browser autoplay policies as well as
/// Android audio playback.
class QuickActionsSection extends StatelessWidget {
  final VoidCallback? onQiblaTap;
  final VoidCallback? onAdhanTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onCalendarTap;

  const QuickActionsSection({
    super.key,
    this.onQiblaTap,
    this.onAdhanTap,
    this.onSettingsTap,
    this.onCalendarTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: PrayerDimensions.space12,
      crossAxisSpacing: PrayerDimensions.space12,
      childAspectRatio: 1.5,
      children: [
        _QuickActionButton(
          icon: Icons.explore_rounded,
          label: 'اتجاه القبلة',
          color: PrayerThemeColors.green,
          onTap: onQiblaTap,
          isDark: isDark,
        ),
        _QuickActionButton(
          icon: Icons.volume_up_rounded,
          label: 'الأذان',
          color: PrayerThemeColors.gold,
          onTap: onAdhanTap,
          isDark: isDark,
          isAthan: true,
        ),
        _QuickActionButton(
          icon: Icons.calendar_month_rounded,
          label: 'التقويم الإسلامي',
          color: PrayerThemeColors.info,
          onTap: onCalendarTap,
          isDark: isDark,
        ),
        _QuickActionButton(
          icon: Icons.settings_rounded,
          label: 'إعدادات الصلاة',
          color: PrayerThemeColors.getTextColor('secondary', isDark),
          onTap: onSettingsTap,
          isDark: isDark,
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool isDark;
  final bool isAthan;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    this.onTap,
    this.isAthan = false,
  });

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: PrayerDimensions.durationInstant),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (widget.isAthan) {
      await _showAthanPicker(context);
      return;
    }
    widget.onTap?.call();
  }

  Future<void> _showAthanPicker(BuildContext context) async {
    final service = AthanAudioService();
    var selected = AthanAudio.dohaFajr;

    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) {
          final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
          return StatefulBuilder(
            builder: (context, setState) {
              return Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.72,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? PrayerThemeColors.bgDark
                      : PrayerThemeColors.surface,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(PrayerDimensions.radiusXLarge),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: PrayerDimensions.dragHandleTop),
                    Container(
                      width: PrayerDimensions.dragHandleWidth,
                      height: PrayerDimensions.dragHandleHeight,
                      decoration: BoxDecoration(
                        color: PrayerThemeColors.textMuted,
                        borderRadius: BorderRadius.circular(
                          PrayerDimensions.radiusPill,
                        ),
                      ),
                    ),
                    SizedBox(height: PrayerDimensions.space20),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: PrayerDimensions.pagePadding,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.volume_up_rounded,
                            color: PrayerThemeColors.gold,
                            size: PrayerDimensions.iconInline,
                          ),
                          SizedBox(width: PrayerDimensions.space12),
                          Expanded(
                            child: Text(
                              'اختيار صوت الأذان',
                              style: PrayerTextStyles.arabicHeadline(
                                color: PrayerThemeColors.getTextColor(
                                  'primary',
                                  isDark,
                                ),
                              ),
                            ),
                          ),
                          StreamBuilder<bool>(
                            stream: service.playingStream,
                            initialData: false,
                            builder: (context, snapshot) {
                              if (snapshot.data != true) {
                                return const SizedBox.shrink();
                              }
                              return IconButton(
                                tooltip: 'إيقاف',
                                onPressed: service.stop,
                                icon: const Icon(Icons.stop_circle_outlined),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: PrayerDimensions.pagePadding,
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'اضغط على أي خيار لتشغيل التسجيل مباشرة',
                          style: PrayerTextStyles.arabicCaption(
                            color: PrayerThemeColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: PrayerDimensions.space12),
                    Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(
                          horizontal: PrayerDimensions.pagePadding,
                        ),
                        itemCount: AthanAudio.values.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: PrayerDimensions.space8),
                        itemBuilder: (context, index) {
                          final athan = AthanAudio.values[index];
                          final isSelected = selected == athan;
                          return ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                PrayerDimensions.radiusMedium,
                              ),
                            ),
                            tileColor: isSelected
                                ? PrayerThemeColors.greenLight
                                : PrayerThemeColors.surfaceVariant,
                            leading: Icon(
                              isSelected
                                  ? Icons.graphic_eq_rounded
                                  : Icons.play_circle_outline_rounded,
                              color: isSelected
                                  ? PrayerThemeColors.green
                                  : PrayerThemeColors.textMuted,
                            ),
                            title: Text(
                              athan.label,
                              textAlign: TextAlign.right,
                              style: PrayerTextStyles.arabicBody(
                                color: PrayerThemeColors.getTextColor(
                                  'primary',
                                  isDark,
                                ),
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(
                                    Icons.check_circle_rounded,
                                    color: PrayerThemeColors.green,
                                  )
                                : null,
                            onTap: () async {
                              setState(() => selected = athan);
                              try {
                                await service.play(athan);
                              } catch (error) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('تعذر تشغيل الأذان: $error'),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(PrayerDimensions.pagePadding),
                      child: SizedBox(
                        width: double.infinity,
                        height: PrayerDimensions.buttonHeight,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            backgroundColor: PrayerThemeColors.greenLight,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                PrayerDimensions.radiusMedium,
                              ),
                            ),
                          ),
                          child: Text(
                            'إغلاق',
                            style: PrayerTextStyles.arabicLabel(
                              color: PrayerThemeColors.green,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    } finally {
      await service.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _scaleController.forward(),
        onTapUp: (_) {
          _scaleController.reverse();
          _handleTap();
        },
        onTapCancel: () => _scaleController.reverse(),
        child: Container(
          decoration: BoxDecoration(
            color: PrayerThemeColors.surfaceVariant,
            borderRadius: BorderRadius.circular(PrayerDimensions.radiusMedium),
            border: Border.all(
              color: PrayerThemeColors.getBorderColor(widget.isDark),
              width: PrayerDimensions.borderStandard,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: widget.color.withValues(
                    alpha: PrayerDimensions.opacityLight,
                  ),
                  borderRadius: BorderRadius.circular(
                    PrayerDimensions.radiusMedium,
                  ),
                ),
                child: Icon(
                  widget.icon,
                  size: PrayerDimensions.iconNav,
                  color: widget.color,
                ),
              ),
              SizedBox(height: PrayerDimensions.space12),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: PrayerDimensions.space12,
                ),
                child: Text(
                  widget.label,
                  style: PrayerTextStyles.arabicBody(
                    color: PrayerThemeColors.getTextColor(
                      'primary',
                      widget.isDark,
                    ),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
