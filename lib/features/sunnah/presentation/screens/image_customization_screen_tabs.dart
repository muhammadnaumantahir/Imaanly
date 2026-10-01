import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import '../../core/theme/sunnah_theme.dart';
import '../../models/image_customization_model.dart';
import '../widgets/customization_widgets.dart';

/// Extension للـ tabs
extension ImageCustomizationTabs on State {
  /// 📝 TEXT TAB
  Widget buildTextTab(
    ImageCustomizationSettings settings,
    Function(ImageCustomizationSettings) onUpdate,
    bool isDark,
  ) {
    return ListView(
      padding: const EdgeInsets.all(SunnahTheme.space24),
      children: [
        buildSectionTitle('Font type', Icons.font_download_rounded, isDark),
        const Gap(16),
        FontFamilySelector(
          selected: settings.fontFamily,
          onChanged: (font) => onUpdate(settings.copyWith(fontFamily: font)),
          isDark: isDark,
        ),
        
        const Gap(24),
        buildSectionTitle('Text sizes', Icons.format_size_rounded, isDark),
        const Gap(16),
        buildSlider(
          'Title size',
          settings.titleFontSize,
          20.0,
          60.0,
          (value) => onUpdate(settings.copyWith(titleFontSize: value)),
          isDark,
        ),
        const Gap(16),
        buildSlider(
          'Description size',
          settings.descriptionFontSize,
          14.0,
          32.0,
          (value) => onUpdate(settings.copyWith(descriptionFontSize: value)),
          isDark,
        ),
        const Gap(16),
        buildSlider(
          'Guide size',
          settings.evidenceFontSize,
          12.0,
          24.0,
          (value) => onUpdate(settings.copyWith(evidenceFontSize: value)),
          isDark,
        ),
        
        const Gap(24),
        buildSectionTitle('Text colors', Icons.palette_rounded, isDark),
        const Gap(16),
        ColorPickerTile(
          label: 'Title color',
          color: settings.titleColor,
          onChanged: (color) => onUpdate(settings.copyWith(titleColor: color)),
          isDark: isDark,
        ),
        const Gap(16),
        ColorPickerTile(
          label: 'Description color',
          color: settings.descriptionColor,
          onChanged: (color) => onUpdate(settings.copyWith(descriptionColor: color)),
          isDark: isDark,
        ),
        const Gap(16),
        ColorPickerTile(
          label: 'Guide color',
          color: settings.evidenceColor,
          onChanged: (color) => onUpdate(settings.copyWith(evidenceColor: color)),
          isDark: isDark,
        ),
        
        const Gap(24),
        buildSectionTitle('Text alignment', Icons.format_align_right_rounded, isDark),
        const Gap(16),
        buildTextAlignSelector(
          settings.textAlign,
          (align) => onUpdate(settings.copyWith(textAlign: align)),
          isDark,
        ),
        
        const Gap(24),
        buildSectionTitle('Line spacing', Icons.format_line_spacing_rounded, isDark),
        const Gap(16),
        buildSlider(
          'Line spacing',
          settings.lineHeight,
          1.0,
          2.5,
          (value) => onUpdate(settings.copyWith(lineHeight: value)),
          isDark,
        ),
      ],
    );
  }

  /// 🎯 ELEMENTS TAB
  Widget buildElementsTab(
    ImageCustomizationSettings settings,
    Function(ImageCustomizationSettings) onUpdate,
    bool isDark,
  ) {
    return ListView(
      padding: const EdgeInsets.all(SunnahTheme.space24),
      children: [
        buildSectionTitle('Header', Icons.title_rounded, isDark),
        const Gap(16),
        buildSwitch(
          'Show header',
          settings.showHeader,
          (value) => onUpdate(settings.copyWith(showHeader: value)),
          isDark,
        ),
        if (settings.showHeader) ...[
          const Gap(16),
          buildHeaderStyleSelector(
            settings.headerStyle,
            (style) => onUpdate(settings.copyWith(headerStyle: style)),
            isDark,
          ),
          const Gap(16),
          ColorPickerTile(
            label: 'Header color',
            color: settings.headerColor,
            onChanged: (color) => onUpdate(settings.copyWith(headerColor: color)),
            isDark: isDark,
          ),
        ],
        
        const Gap(24),
        buildSectionTitle('Icon', Icons.emoji_emotions_rounded, isDark),
        const Gap(16),
        buildSwitch(
          'Show icon',
          settings.showIcon,
          (value) => onUpdate(settings.copyWith(showIcon: value)),
          isDark,
        ),
        if (settings.showIcon) ...[
          const Gap(16),
          buildIconStyleSelector(
            settings.iconStyle,
            (style) => onUpdate(settings.copyWith(iconStyle: style)),
            isDark,
          ),
        ],
        
        const Gap(24),
        buildSectionTitle('Badge', Icons.label_rounded, isDark),
        const Gap(16),
        buildSwitch(
          'Show badge',
          settings.showBadge,
          (value) => onUpdate(settings.copyWith(showBadge: value)),
          isDark,
        ),
        if (settings.showBadge) ...[
          const Gap(16),
          buildBadgeStyleSelector(
            settings.badgeStyle,
            (style) => onUpdate(settings.copyWith(badgeStyle: style)),
            isDark,
          ),
          const Gap(16),
          ColorPickerTile(
            label: 'Badge color',
            color: settings.badgeColor,
            onChanged: (color) => onUpdate(settings.copyWith(badgeColor: color)),
            isDark: isDark,
          ),
        ],
        
        const Gap(24),
        buildSectionTitle('Footer', Icons.text_fields_rounded, isDark),
        const Gap(16),
        buildSwitch(
          'Show footer',
          settings.showFooter,
          (value) => onUpdate(settings.copyWith(showFooter: value)),
          isDark,
        ),
        if (settings.showFooter) ...[
          const Gap(16),
          buildTextField(
            'Footer text',
            settings.footerText,
            (text) => onUpdate(settings.copyWith(footerText: text)),
            isDark,
          ),
          const Gap(16),
          ColorPickerTile(
            label: 'Footer color',
            color: settings.footerColor,
            onChanged: (color) => onUpdate(settings.copyWith(footerColor: color)),
            isDark: isDark,
          ),
          const Gap(16),
          buildSlider(
            'Footer font size',
            settings.footerFontSize,
            10.0,
            20.0,
            (value) => onUpdate(settings.copyWith(footerFontSize: value)),
            isDark,
          ),
        ],
      ],
    );
  }

  /// ✨ DECORATIONS TAB
  Widget buildDecorationsTab(
    ImageCustomizationSettings settings,
    Function(ImageCustomizationSettings) onUpdate,
    bool isDark,
  ) {
    return ListView(
      padding: const EdgeInsets.all(SunnahTheme.space24),
      children: [
        buildSectionTitle('Top ornament', Icons.auto_awesome_rounded, isDark),
        const Gap(16),
        buildSwitch(
          'Show top ornament',
          settings.showTopDecoration,
          (value) => onUpdate(settings.copyWith(showTopDecoration: value)),
          isDark,
        ),
        
        const Gap(24),
        buildSectionTitle('Bottom ornament', Icons.auto_awesome_rounded, isDark),
        const Gap(16),
        buildSwitch(
          'Show bottom ornament',
          settings.showBottomDecoration,
          (value) => onUpdate(settings.copyWith(showBottomDecoration: value)),
          isDark,
        ),
        
        if (settings.showTopDecoration || settings.showBottomDecoration) ...[
          const Gap(24),
          buildSectionTitle('Ornament type', Icons.category_rounded, isDark),
          const Gap(16),
          buildDecorationTypeSelector(
            settings.decorationType,
            (type) => onUpdate(settings.copyWith(decorationType: type)),
            isDark,
          ),
          const Gap(16),
          ColorPickerTile(
            label: 'Ornament color',
            color: settings.decorationColor,
            onChanged: (color) => onUpdate(settings.copyWith(decorationColor: color)),
            isDark: isDark,
          ),
        ],
        
        const Gap(24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: SunnahTheme.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(SunnahTheme.radiusMedium),
            border: Border.all(
              color: SunnahTheme.green.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: SunnahTheme.green,
                size: 32,
              ),
              const Gap(12),
              Text(
                'Ornaments add an Islamic decorative touch to the image',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: SunnahTheme.green,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 📏 SIZE TAB
  Widget buildSizeTab(
    ImageCustomizationSettings settings,
    Function(ImageCustomizationSettings) onUpdate,
    bool isDark,
  ) {
    return ListView(
      padding: const EdgeInsets.all(SunnahTheme.space24),
      children: [
        buildSectionTitle('Image size', Icons.photo_size_select_large_rounded, isDark),
        const Gap(16),
        ImageSizeSelector(
          selected: settings.imageSize,
          onChanged: (size) => onUpdate(settings.copyWith(imageSize: size)),
          isDark: isDark,
        ),
        
        const Gap(24),
        buildSectionTitle('Image quality', Icons.high_quality_rounded, isDark),
        const Gap(16),
        buildQualitySelector(
          settings.imageQuality,
          (quality) => onUpdate(settings.copyWith(imageQuality: quality)),
          isDark,
        ),
        
        const Gap(24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                SunnahTheme.green.withValues(alpha: 0.1),
                SunnahTheme.gold.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(SunnahTheme.radiusMedium),
            border: Border.all(
              color: SunnahTheme.green.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.tips_and_updates_rounded,
                color: SunnahTheme.green,
                size: 32,
              ),
              const Gap(12),
              Text(
                'Tip',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: SunnahTheme.green,
                ),
              ),
              const Gap(8),
              Text(
                'Use the Instagram size for stories, and square for regular posts',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: SunnahTheme.getTextSecondaryColor(isDark),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // HELPER WIDGETS
  // ═══════════════════════════════════════════

  Widget buildSectionTitle(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, color: SunnahTheme.green, size: 24),
        const Gap(12),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: SunnahTheme.getTextPrimaryColor(isDark),
          ),
        ),
      ],
    );
  }

  Widget buildSlider(
    String label,
    double value,
    double min,
    double max,
    Function(double) onChanged,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: SunnahTheme.getTextSecondaryColor(isDark),
              ),
            ),
            Text(
              value.toStringAsFixed(1),
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: SunnahTheme.green,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: SunnahTheme.green,
          inactiveColor: SunnahTheme.green.withValues(alpha: 0.2),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget buildSwitch(
    String label,
    bool value,
    Function(bool) onChanged,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SunnahTheme.getSurfaceColor(isDark),
        borderRadius: BorderRadius.circular(SunnahTheme.radiusMedium),
        border: Border.all(
          color: SunnahTheme.getBorderColor(isDark),
          width: SunnahTheme.borderStandard,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: SunnahTheme.getTextPrimaryColor(isDark),
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: SunnahTheme.green,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget buildTextField(
    String label,
    String value,
    Function(String) onChanged,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: SunnahTheme.getTextSecondaryColor(isDark),
          ),
        ),
        const Gap(8),
        TextField(
          controller: TextEditingController(text: value),
          onChanged: onChanged,
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: SunnahTheme.getSurfaceColor(isDark),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SunnahTheme.radiusMedium),
              borderSide: BorderSide(
                color: SunnahTheme.getBorderColor(isDark),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SunnahTheme.radiusMedium),
              borderSide: BorderSide(
                color: SunnahTheme.getBorderColor(isDark),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SunnahTheme.radiusMedium),
              borderSide: const BorderSide(
                color: SunnahTheme.green,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildTextAlignSelector(
    TextAlign selected,
    Function(TextAlign) onChanged,
    bool isDark,
  ) {
    return Row(
      children: [
        _buildAlignButton(TextAlign.right, Icons.format_align_right_rounded, selected, onChanged, isDark),
        const Gap(12),
        _buildAlignButton(TextAlign.center, Icons.format_align_center_rounded, selected, onChanged, isDark),
        const Gap(12),
        _buildAlignButton(TextAlign.left, Icons.format_align_left_rounded, selected, onChanged, isDark),
      ],
    );
  }

  Widget _buildAlignButton(
    TextAlign align,
    IconData icon,
    TextAlign selected,
    Function(TextAlign) onChanged,
    bool isDark,
  ) {
    final isSelected = align == selected;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(align),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? SunnahTheme.green.withValues(alpha: 0.15)
                : SunnahTheme.getSurfaceColor(isDark),
            borderRadius: BorderRadius.circular(SunnahTheme.radiusMedium),
            border: Border.all(
              color: isSelected
                  ? SunnahTheme.green
                  : SunnahTheme.getBorderColor(isDark),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Icon(
            icon,
            color: isSelected
                ? SunnahTheme.green
                : SunnahTheme.getTextSecondaryColor(isDark),
          ),
        ),
      ),
    );
  }

  Widget buildHeaderStyleSelector(
    HeaderStyle selected,
    Function(HeaderStyle) onChanged,
    bool isDark,
  ) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: HeaderStyle.values.map((style) {
        final isSelected = style == selected;
        return GestureDetector(
          onTap: () => onChanged(style),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? SunnahTheme.green.withValues(alpha: 0.15)
                  : SunnahTheme.getSurfaceColor(isDark),
              borderRadius: BorderRadius.circular(SunnahTheme.radiusMedium),
              border: Border.all(
                color: isSelected
                    ? SunnahTheme.green
                    : SunnahTheme.getBorderColor(isDark),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(
              _getHeaderStyleLabel(style),
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: isSelected
                    ? SunnahTheme.green
                    : SunnahTheme.getTextSecondaryColor(isDark),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget buildIconStyleSelector(
    IconStyle selected,
    Function(IconStyle) onChanged,
    bool isDark,
  ) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: IconStyle.values.map((style) {
        final isSelected = style == selected;
        return GestureDetector(
          onTap: () => onChanged(style),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? SunnahTheme.green.withValues(alpha: 0.15)
                  : SunnahTheme.getSurfaceColor(isDark),
              borderRadius: BorderRadius.circular(SunnahTheme.radiusMedium),
              border: Border.all(
                color: isSelected
                    ? SunnahTheme.green
                    : SunnahTheme.getBorderColor(isDark),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(
              _getIconStyleLabel(style),
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: isSelected
                    ? SunnahTheme.green
                    : SunnahTheme.getTextSecondaryColor(isDark),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget buildBadgeStyleSelector(
    BadgeStyle selected,
    Function(BadgeStyle) onChanged,
    bool isDark,
  ) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: BadgeStyle.values.map((style) {
        final isSelected = style == selected;
        return GestureDetector(
          onTap: () => onChanged(style),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? SunnahTheme.green.withValues(alpha: 0.15)
                  : SunnahTheme.getSurfaceColor(isDark),
              borderRadius: BorderRadius.circular(SunnahTheme.radiusMedium),
              border: Border.all(
                color: isSelected
                    ? SunnahTheme.green
                    : SunnahTheme.getBorderColor(isDark),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(
              _getBadgeStyleLabel(style),
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: isSelected
                    ? SunnahTheme.green
                    : SunnahTheme.getTextSecondaryColor(isDark),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget buildDecorationTypeSelector(
    DecorationType selected,
    Function(DecorationType) onChanged,
    bool isDark,
  ) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: DecorationType.values.map((type) {
        final isSelected = type == selected;
        return GestureDetector(
          onTap: () => onChanged(type),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? SunnahTheme.green.withValues(alpha: 0.15)
                  : SunnahTheme.getSurfaceColor(isDark),
              borderRadius: BorderRadius.circular(SunnahTheme.radiusMedium),
              border: Border.all(
                color: isSelected
                    ? SunnahTheme.green
                    : SunnahTheme.getBorderColor(isDark),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(
              _getDecorationTypeLabel(type),
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: isSelected
                    ? SunnahTheme.green
                    : SunnahTheme.getTextSecondaryColor(isDark),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget buildQualitySelector(
    ImageQuality selected,
    Function(ImageQuality) onChanged,
    bool isDark,
  ) {
    return Column(
      children: ImageQuality.values.map((quality) {
        final isSelected = quality == selected;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => onChanged(quality),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? SunnahTheme.green.withValues(alpha: 0.15)
                    : SunnahTheme.getSurfaceColor(isDark),
                borderRadius: BorderRadius.circular(SunnahTheme.radiusMedium),
                border: Border.all(
                  color: isSelected
                      ? SunnahTheme.green
                      : SunnahTheme.getBorderColor(isDark),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _getQualityLabel(quality),
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                        color: isSelected
                            ? SunnahTheme.green
                            : SunnahTheme.getTextPrimaryColor(isDark),
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: SunnahTheme.green,
                      size: 24,
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Label helpers
  String _getHeaderStyleLabel(HeaderStyle style) {
    switch (style) {
      case HeaderStyle.simple:
        return 'Simple';
      case HeaderStyle.gradient:
        return 'Gradient';
      case HeaderStyle.outlined:
        return 'Selected';
      case HeaderStyle.filled:
        return 'Full';
    }
  }

  String _getIconStyleLabel(IconStyle style) {
    switch (style) {
      case IconStyle.filled:
        return 'Full';
      case IconStyle.outlined:
        return 'Selected';
      case IconStyle.gradient:
        return 'Gradient';
      case IconStyle.none:
        return 'None';
    }
  }

  String _getBadgeStyleLabel(BadgeStyle style) {
    switch (style) {
      case BadgeStyle.rounded:
        return 'Circular';
      case BadgeStyle.square:
        return 'Square';
      case BadgeStyle.pill:
        return 'Grain';
      case BadgeStyle.minimal:
        return 'Simple';
    }
  }

  String _getDecorationTypeLabel(DecorationType type) {
    switch (type) {
      case DecorationType.none:
        return 'None';
      case DecorationType.islamic:
        return 'Islamic';
      case DecorationType.floral:
        return 'Pink';
      case DecorationType.geometric:
        return 'Geometric';
      case DecorationType.simple:
        return 'Simple';
    }
  }

  String _getQualityLabel(ImageQuality quality) {
    switch (quality) {
      case ImageQuality.low:
        return 'Low (fast)';
      case ImageQuality.medium:
        return 'Medium';
      case ImageQuality.high:
        return 'High (recommended)';
      case ImageQuality.ultra:
        return 'Ultra quality';
    }
  }
}
