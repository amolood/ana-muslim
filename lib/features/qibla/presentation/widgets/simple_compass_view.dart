import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../../data/models/qibla_state.dart';

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
    final heading = state.smoothedHeading ?? state.rawHeading ?? 0.0;

    const ringPadding = 20.0;
    const indicatorGap = 30.0;
    final stackSize = compassSize + (ringPadding * 2);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Compass: rotating dial + fixed HUD ──
        SizedBox(
          width: stackSize,
          height: stackSize,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              _buildRotatingDial(
                compassSize,
                accentColor,
                heading,
                state.qiblaBearing,
                isAligned,
              ),

              // Fixed top indicator (phone top reference)
              Positioned(
                top: ringPadding + indicatorGap,
                child: _buildFixedTopIndicator(accentColor),
              ),

              // Fixed center readout
              _buildCenterHub(
                compassSize,
                accentColor,
                isAligned,
                heading,
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

  // ... (Cardinals and Labels remain the same) ...
  Widget _buildCardinalLabels(double size) {
    final double radius = size / 2 - 28;
    final center = size / 2;
    const cardinals = [
      (label: 'ق', angleDeg: 90.0),
      (label: 'ج', angleDeg: 180.0),
      (label: 'غ', angleDeg: 270.0),
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

  // 🔥 UPDATED: Passes the current rotation angle to the badge
  Widget _buildRotatingDial(
    double size,
    Color accentColor,
    double heading,
    double? qiblaBearing,
    bool isAligned,
  ) {
    const kaabaBadgeSize = 56.0;
    const kaabaTrackInset = 6.0;
    final center = size / 2;
    final radius = size / 2;

    double? kaabaLeft;
    double? kaabaTop;
    if (qiblaBearing != null) {
      final normalizedBearing = ((qiblaBearing % 360) + 360) % 360;
      final bearingRad = normalizedBearing * math.pi / 180;
      final markerRadius = radius - kaabaTrackInset;
      kaabaLeft =
          center + markerRadius * math.sin(bearingRad) - (kaabaBadgeSize / 2);
      kaabaTop =
          center - markerRadius * math.cos(bearingRad) - (kaabaBadgeSize / 2);
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: heading),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (context, angle, child) {
        // We capture 'angle' here to pass it down
        return Transform.rotate(
          angle: -angle * (math.pi / 180),
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                CustomPaint(
                  size: Size(size, size),
                  painter: CompassRingPainter(accentColor: accentColor),
                ),
                _buildCardinalLabels(size),
                if (kaabaLeft != null && kaabaTop != null)
                  Positioned(
                    left: kaabaLeft,
                    top: kaabaTop,
                    // 🔥 Passing 'angle' to counter-rotate the icon
                    child: _buildKaabaBadge(isAligned, accentColor, angle),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFixedTopIndicator(Color accentColor) {
    return Icon(
      Icons.navigation_rounded,
      size: 38,
      color: accentColor,
    );
  }

  Widget _buildCenterHub(
    double compassSize,
    Color accentColor,
    bool isAligned,
    double heading,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${heading.toStringAsFixed(0)}°',
            style: GoogleFonts.tajawal(
              fontSize: hubSize * 0.28,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'اتجاهك',
            style: GoogleFonts.tajawal(
              fontSize: hubSize * 0.12,
              color: Colors.white54,
            ),
          ),
          if (isAligned) ...[
            const SizedBox(height: 2),
            Icon(
              Icons.check_rounded,
              size: hubSize * 0.2,
              color: accentColor,
            ),
          ],
        ],
      ),
    );
  }

  // 🔥 UPDATED: Counter-rotates the badge using rotationAngle
  Widget _buildKaabaBadge(bool isAligned, Color accentColor, double rotationAngle) {
    return Transform.rotate(
      // Counter-rotation: Positive angle cancels out the parent's Negative angle
      angle: rotationAngle * (math.pi / 180), 
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 56,
        height: 56,
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
          child: Text(
            '🕋',
            style: TextStyle(
              fontSize: 30,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }

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
}

// ... (CompassRingPainter remains the same) ...
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