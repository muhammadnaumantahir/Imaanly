import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Gradient "hero" card used at the top of Imaanly screens.
///
/// Anything placed inside automatically picks up light-on-dark styling:
/// text from the theme turns white, icons turn white, and `colorScheme.primary`
/// (progress bars, switches, etc.) becomes gold.
class HeroCard extends StatelessWidget {
  const HeroCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(22),
    this.radius = 28,
    this.showPattern = true,
    this.showSkyline = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool showPattern;
  final bool showSkyline;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final isDark = base.brightness == Brightness.dark;
    final onHero = base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      primaryTextTheme: base.primaryTextTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.gold,
        onSurface: Colors.white,
        onSurfaceVariant: Colors.white70,
        outline: Colors.white38,
        surfaceContainerHighest: Colors.white24,
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(gradient: AppColors.heroGradient(isDark)),
        child: Stack(
          children: [
            if (showPattern)
              Positioned.fill(
                child: CustomPaint(
                  painter: StarPatternPainter(Colors.white.withValues(alpha: 0.07)),
                ),
              ),
            if (showSkyline)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 96,
                child: CustomPaint(
                  painter: MosqueSkylinePainter(Colors.black.withValues(alpha: 0.22)),
                ),
              ),
            Positioned(
              right: -50,
              top: -50,
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.gold.withValues(alpha: 0.28),
                      AppColors.gold.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Theme(
              data: onHero,
              child: DefaultTextStyle.merge(
                style: const TextStyle(color: Colors.white),
                child: IconTheme.merge(
                  data: const IconThemeData(color: Colors.white),
                  child: Padding(padding: padding, child: child),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A rounded section card with a soft border, matching the home screen style.
class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 24,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainer,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// A rounded icon "badge" in the brand mint tone.
class IconBadge extends StatelessWidget {
  const IconBadge({super.key, required this.icon, this.size = 46});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(icon, color: cs.primary, size: size * 0.52),
    );
  }
}

/// Faint tiled eight-pointed stars (rub el hizb) used as a hero texture.
class StarPatternPainter extends CustomPainter {
  const StarPatternPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    const step = 56.0;
    var row = 0;
    for (double y = 0; y < size.height + step; y += step) {
      final offsetX = row.isEven ? 0.0 : step / 2;
      for (double x = offsetX; x < size.width + step; x += step) {
        canvas.drawPath(_octagram(Offset(x, y), 18), paint);
      }
      row++;
    }
  }

  Path _octagram(Offset c, double r) {
    final path = Path();
    for (var i = 0; i < 16; i++) {
      final angle = -math.pi / 2 + i * math.pi / 8;
      final radius = i.isEven ? r : r * 0.7654;
      final x = c.dx + radius * math.cos(angle);
      final y = c.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant StarPatternPainter oldDelegate) =>
      oldDelegate.color != color;
}


/// A simple mosque silhouette (domes and minarets) drawn along the bottom edge.
class MosqueSkylinePainter extends CustomPainter {
  const MosqueSkylinePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final ground = h * 0.80;
    final path = Path()
      ..moveTo(0, h)
      ..lineTo(0, ground);

    void minaret(double cx, double halfWidth, double height) {
      final top = ground - height;
      path
        ..lineTo(cx - halfWidth, ground)
        ..lineTo(cx - halfWidth, top)
        ..lineTo(cx, top - h * 0.16)
        ..lineTo(cx + halfWidth, top)
        ..lineTo(cx + halfWidth, ground);
    }

    void dome(double cx, double radius, double drum) {
      final base = ground - drum;
      path
        ..lineTo(cx - radius, ground)
        ..lineTo(cx - radius, base)
        ..arcToPoint(
          Offset(cx + radius, base),
          radius: Radius.circular(radius),
          clockwise: true,
        )
        ..lineTo(cx + radius, ground);
    }

    minaret(w * 0.08, w * 0.012, h * 0.30);
    dome(w * 0.24, w * 0.05, h * 0.06);
    dome(w * 0.50, w * 0.11, h * 0.08);
    dome(w * 0.76, w * 0.05, h * 0.06);
    minaret(w * 0.92, w * 0.012, h * 0.30);

    path
      ..lineTo(w, ground)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant MosqueSkylinePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Deterministic scatter of small stars for night-time skies.
class StarFieldPainter extends CustomPainter {
  const StarFieldPainter({this.count = 30});

  final int count;

  @override
  void paint(Canvas canvas, Size size) {
    var seed = 7;
    double next() {
      seed = (seed * 48271) % 2147483647;
      return seed / 2147483647;
    }

    for (var i = 0; i < count; i++) {
      final x = next() * size.width;
      final y = next() * size.height * 0.6;
      final radius = 0.6 + next() * 1.2;
      final alpha = 0.35 + next() * 0.55;
      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()..color = Colors.white.withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(covariant StarFieldPainter oldDelegate) => false;
}
