import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../../data/models/qibla_state.dart';

/// Immersive Qibla compass — large ring with Kaaba badge on the edge,
/// rotating arrow, and integrated status text below.
class SimpleCompassView extends StatelessWidget {
  final QiblaUiState state;

  const SimpleCompassView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compassSize = math.min(width * 0.80, 340.0);
    final absDelta = state.delta.abs();
    final Color accentColor = _getArrowColor(absDelta);
    final bool isAligned = absDelta < 3.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Compass with Kaaba on ring ──
        SizedBox(
          width: compassSize + 40, // extra room for Kaaba badge overhang
          height: compassSize + 40,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Ring + tick marks (CustomPainter)
              CustomPaint(
                size: Size(compassSize, compassSize),
                painter: CompassRingPainter(accentColor: accentColor),
              ),

              // Cardinal labels (skip North — Kaaba sits there)
              _buildCardinalLabels(compassSize),

              // Rotating arrow
              _buildRotatingArrow(compassSize, accentColor, isAligned),

              // Center hub
              _buildCenterHub(compassSize, accentColor, absDelta, isAligned),

              // Kaaba badge sitting ON the ring at 12 o'clock
              Positioned(
                top: 20 - 22, // half of badge height above ring top
                child: _buildKaabaBadge(isAligned, accentColor),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── Status text ──
        _buildStatusText(absDelta, state.delta, accentColor),
      ],
    );
  }

  /// Cardinal labels: ق (East), ج (South), غ (West) — skip North (Kaaba is there)
  Widget _buildCardinalLabels(double size) {
    final double radius = size / 2 - 28;
    final center = size / 2;

    // Angles: East=90°, South=180°, West=270° (measured clockwise from North)
    const cardinals = [
      (label: 'ق', angleDeg: 90.0),  // شرق (East) — right
      (label: 'ج', angleDeg: 180.0), // جنوب (South) — bottom
      (label: 'غ', angleDeg: 270.0), // غرب (West) — left
    ];

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: cardinals.map((c) {
          final rad = c.angleDeg * math.pi / 180;
          final dx = center + radius * math.sin(rad) - 12;
          final dy = center - radius * math.cos(rad) - 12;
          return Positioned(
            left: dx,
            top: dy,
            child: SizedBox(
              width: 24,
              height: 24,
              child: Center(
                child: Text(
                  c.label,
                  style: GoogleFonts.tajawal(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Rotating Qibla arrow (kept exactly as original)
  Widget _buildRotatingArrow(double size, Color color, bool isAligned) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: state.delta),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (context, angle, child) {
        return Transform.rotate(
          angle: -angle * (math.pi / 180),
          child: child,
        );
      },
      child: CustomPaint(
        size: Size(size, size),
        painter: QiblaArrowPainter(
          color: color,
          isAligned: isAligned,
          glowIntensity: _getGlowIntensity(state.delta.abs()),
        ),
      ),
    );
  }

  /// Center hub — small circle showing ✓ when aligned, degree otherwise
  Widget _buildCenterHub(
    double compassSize,
    Color accentColor,
    double absDelta,
    bool isAligned,
  ) {
    final hubSize = compassSize * 0.28;

    return Container(
      width: hubSize,
      height: hubSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.qiblaDark,
        border: Border.all(
          color: accentColor.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Center(
        child: isAligned
            ? Icon(
                Icons.check_rounded,
                size: hubSize * 0.45,
                color: accentColor,
              )
            : Text(
                '${absDelta.toInt()}°',
                style: GoogleFonts.tajawal(
                  fontSize: hubSize * 0.28,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
      ),
    );
  }

  /// Kaaba badge — sits ON the ring at 12 o'clock, half in / half out
  Widget _buildKaabaBadge(bool isAligned, Color accentColor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isAligned
            ? accentColor.withValues(alpha: 0.25)
            : const Color(0xFF1A1A1A),
        border: Border.all(
          color: accentColor,
          width: isAligned ? 2.5 : 1.5,
        ),
        boxShadow: isAligned
            ? [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.5),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ]
            : [],
      ),
      child: const Center(
        child: Text('🕋', style: TextStyle(fontSize: 20)),
      ),
    );
  }

  /// Status text — single bold line + optional subtitle
  Widget _buildStatusText(double absDelta, double delta, Color accentColor) {
    final String mainText;
    final String? subText;

    if (absDelta < 3) {
      mainText = 'اتجاه القبلة صحيح ✓';
      subText = null;
    } else if (absDelta < 45) {
      mainText = delta > 0 ? 'استدر يميناً' : 'استدر يساراً';
      subText = absDelta > 3 && absDelta < 45
          ? 'ضمن النطاق المقبول للصلاة'
          : null;
    } else {
      mainText = delta > 0 ? 'استدر يميناً' : 'استدر يساراً';
      subText = null;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          mainText,
          style: GoogleFonts.tajawal(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: accentColor,
          ),
        ),
        if (subText != null) ...[
          const SizedBox(height: 4),
          Text(
            subText,
            style: GoogleFonts.tajawal(
              fontSize: 13,
              color: Colors.white54,
            ),
          ),
        ],
      ],
    );
  }

  Color _getArrowColor(double absDelta) {
    if (absDelta < 3) return AppColors.qiblaBrightGreen;
    if (absDelta < 10) return AppColors.qiblaGreen;
    if (absDelta < 30) return const Color(0xFFFFAA00);
    if (absDelta < 60) return const Color(0xFFFF6B6B);
    return Colors.white54;
  }

  double _getGlowIntensity(double absDelta) {
    if (absDelta < 3) return 1.0;
    if (absDelta < 10) return 0.7;
    if (absDelta < 30) return 0.4;
    return 0.0;
  }
}

/// Draws the compass ring + 36 tick marks efficiently in a single paint call.
class CompassRingPainter extends CustomPainter {
  final Color accentColor;

  CompassRingPainter({required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // ── Outer ring ──
    final ringPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, ringPaint);

    // ── Background fill ──
    final bgGradient = RadialGradient(
      colors: [
        const Color(0xFF1A1A1A),
        AppColors.qiblaDark,
      ],
      stops: const [0.7, 1.0],
    );
    final bgPaint = Paint()
      ..shader = bgGradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      )
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 1.5, bgPaint);

    // ── 36 tick marks (every 10°) ──
    final majorTickPaint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final minorTickPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 36; i++) {
      final angleDeg = i * 10.0;
      final rad = angleDeg * math.pi / 180;
      final isMajor = angleDeg % 90 == 0; // N, E, S, W
      final tickLength = isMajor ? 14.0 : 8.0;
      final paint = isMajor ? majorTickPaint : minorTickPaint;

      final outerX = center.dx + radius * math.sin(rad);
      final outerY = center.dy - radius * math.cos(rad);
      final innerX = center.dx + (radius - tickLength) * math.sin(rad);
      final innerY = center.dy - (radius - tickLength) * math.cos(rad);

      canvas.drawLine(
        Offset(outerX, outerY),
        Offset(innerX, innerY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CompassRingPainter oldDelegate) {
    return oldDelegate.accentColor != accentColor;
  }
}

/// Arrow painter — kept exactly as original design
class QiblaArrowPainter extends CustomPainter {
  final Color color;
  final bool isAligned;
  final double glowIntensity;

  QiblaArrowPainter({
    required this.color,
    required this.isAligned,
    required this.glowIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final arrowLength = radius - 20;

    // Multi-layer outer glow
    if (glowIntensity > 0) {
      final outerGlowPaint = Paint()
        ..color = color.withValues(alpha: glowIntensity * 0.15)
        ..strokeWidth = 20
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25)
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        center,
        Offset(center.dx, center.dy - arrowLength),
        outerGlowPaint,
      );

      final midGlowPaint = Paint()
        ..color = color.withValues(alpha: glowIntensity * 0.3)
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15)
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        center,
        Offset(center.dx, center.dy - arrowLength),
        midGlowPaint,
      );
    }

    // Arrow body with gradient
    final gradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        color.withValues(alpha: 0.7),
        color,
      ],
    );

    final arrowBodyPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromPoints(
          center,
          Offset(center.dx, center.dy - arrowLength),
        ),
      )
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(center.dx, center.dy - 15),
      Offset(center.dx, center.dy - arrowLength + 25),
      arrowBodyPaint,
    );

    // Arrow head
    final arrowTipY = center.dy - arrowLength;

    final arrowHeadPath = Path()
      ..moveTo(center.dx, arrowTipY - 5)
      ..quadraticBezierTo(
        center.dx - 8, arrowTipY + 15,
        center.dx - 16, arrowTipY + 22,
      )
      ..lineTo(center.dx, arrowTipY + 12)
      ..lineTo(center.dx + 16, arrowTipY + 22)
      ..quadraticBezierTo(
        center.dx + 8, arrowTipY + 15,
        center.dx, arrowTipY - 5,
      )
      ..close();

    if (glowIntensity > 0) {
      canvas.drawPath(
        arrowHeadPath,
        Paint()
          ..color = color.withValues(alpha: glowIntensity * 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
      );
    }

    final arrowHeadGradient = RadialGradient(
      center: Alignment.topCenter,
      radius: 1.5,
      colors: [
        color,
        color.withValues(alpha: 0.8),
      ],
    );

    final arrowHeadPaint = Paint()
      ..shader = arrowHeadGradient.createShader(
        Rect.fromLTRB(
          center.dx - 20,
          arrowTipY - 10,
          center.dx + 20,
          arrowTipY + 30,
        ),
      )
      ..style = PaintingStyle.fill;

    canvas.drawPath(arrowHeadPath, arrowHeadPaint);

    final arrowHeadBorderPaint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawPath(arrowHeadPath, arrowHeadBorderPaint);

    // Center dot
    if (glowIntensity > 0) {
      canvas.drawCircle(
        center,
        12,
        Paint()
          ..color = color.withValues(alpha: glowIntensity * 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }

    canvas.drawCircle(
      center,
      10,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final centerGradient = RadialGradient(
      colors: [
        color,
        color.withValues(alpha: 0.6),
      ],
    );

    canvas.drawCircle(
      center,
      8,
      Paint()
        ..shader = centerGradient.createShader(
          Rect.fromCircle(center: center, radius: 8),
        )
        ..style = PaintingStyle.fill,
    );

    canvas.drawCircle(
      center,
      3,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(QiblaArrowPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.isAligned != isAligned ||
        oldDelegate.glowIntensity != glowIntensity;
  }
}
