import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../data/models/qibla_state.dart';
import '../../core/constants.dart';

/// Main compass hero widget with fixed Kaaba and rotating compass disk
class CompassHero extends StatelessWidget {
  final QiblaUiState state;

  const CompassHero({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final double absDelta = state.delta.abs();
    final bool isNear = absDelta < kNearThreshold;
    final Color accentColor = _getAccentColor(state.alignmentStatus);

    return SizedBox(
      width: MediaQuery.sizeOf(context).width * 0.85,
      height: MediaQuery.sizeOf(context).width * 0.85,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Rotating Compass Disk (background)
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: state.delta),
            duration: const Duration(milliseconds: kAnimationDurationMs),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * (math.pi / 180) * -1,
                child: child,
              );
            },
            child: CompassDisk(accentColor: accentColor),
          ),

          // 2. Fixed Kaaba Badge at top
          Positioned(
            top: 10,
            child: _buildKaabaBadge(accentColor, isNear),
          ),

          // 3. Center Hub (shows phone heading)
          CenterHub(state: state, accentColor: accentColor),
        ],
      ),
    );
  }

  Color _getAccentColor(AlignmentStatus status) {
    switch (status) {
      case AlignmentStatus.perfect:
        return const Color(0xFF4AFFA3);
      case AlignmentStatus.excellent:
        return const Color(0xFF4AFFA3);
      case AlignmentStatus.good:
        return Colors.amberAccent;
      case AlignmentStatus.acceptable:
        return Colors.white60;
      case AlignmentStatus.off:
        return Colors.white30;
    }
  }

  Widget _buildKaabaBadge(Color accentColor, bool isNear) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: state.isFullyAligned
                ? accentColor.withValues(alpha:0.3)
                : Colors.black87,
            border: Border.all(
              color: accentColor,
              width: state.isFullyAligned ? 3 : 2,
            ),
            boxShadow: [
              if (isNear)
                BoxShadow(
                  color: accentColor.withValues(alpha:0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                )
            ],
          ),
          child: const Text(
            "🕋",
            style: TextStyle(fontSize: 28),
          ),
        ),
        const SizedBox(height: 6),
        // Indicator line
        Container(
          width: 3,
          height: 20,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              if (isNear)
                BoxShadow(
                  color: accentColor.withValues(alpha:0.6),
                  blurRadius: 8,
                )
            ],
          ),
        ),
      ],
    );
  }
}

/// Rotating compass disk with tick marks and direction arrow
class CompassDisk extends StatelessWidget {
  final Color accentColor;

  const CompassDisk({super.key, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withValues(alpha:0.3),
        border: Border.all(
          color: Colors.white.withValues(alpha:0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Compass ticks and cardinal directions
          CustomPaint(
            painter: CompassTicksPainter(
              tickColor: Colors.white.withValues(alpha:0.3),
              accentColor: accentColor,
            ),
          ),

          // Direction arrow (phone direction) - points up
          Positioned(
            top: 30,
            left: 0,
            right: 0,
            child: Center(
              child: CustomPaint(
                size: const Size(30, 50),
                painter: DirectionArrowPainter(
                  color: accentColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Center hub showing phone heading and delta
class CenterHub extends StatelessWidget {
  final QiblaUiState state;
  final Color accentColor;

  const CenterHub({super.key, required this.state, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        shape: BoxShape.circle,
        border: Border.all(
          color: accentColor.withValues(alpha:0.6),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha:0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Phone heading
          Text(
            "${state.smoothedHeading?.toStringAsFixed(0) ?? '---'}°",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "اتجاهك",
            style: TextStyle(
              color: Colors.white.withValues(alpha:0.5),
              fontSize: 10,
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(height: 8),
          // Delta
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "${state.delta.abs().toStringAsFixed(0)}°",
              style: TextStyle(
                color: accentColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for compass tick marks and cardinal directions
class CompassTicksPainter extends CustomPainter {
  final Color tickColor;
  final Color accentColor;

  CompassTicksPainter({
    required this.tickColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw cardinal directions (N, E, S, W)
    _drawCardinalDirections(canvas, center, radius);

    // Draw tick marks every 30 degrees (12 marks)
    final tickPaint = Paint()
      ..color = tickColor
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 12; i++) {
      final angle = (i * 30) * (math.pi / 180) - math.pi / 2;
      final isMajor = i % 3 == 0; // Major tick every 90 degrees
      final tickLength = isMajor ? 20.0 : 12.0;
      final tickWidth = isMajor ? 3.0 : 2.0;

      tickPaint.strokeWidth = tickWidth;
      if (isMajor) {
        tickPaint.color = accentColor.withValues(alpha:0.6);
      } else {
        tickPaint.color = tickColor;
      }

      final start = Offset(
        center.dx + (radius - tickLength - 5) * math.cos(angle),
        center.dy + (radius - tickLength - 5) * math.sin(angle),
      );
      final end = Offset(
        center.dx + (radius - 5) * math.cos(angle),
        center.dy + (radius - 5) * math.sin(angle),
      );

      canvas.drawLine(start, end, tickPaint);
    }
  }

  void _drawCardinalDirections(Canvas canvas, Offset center, double radius) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    final cardinals = [
      {'label': 'ش', 'angle': 0},    // North
      {'label': 'ج', 'angle': 90},   // East
      {'label': 'ق', 'angle': 180},  // South
      {'label': 'غ', 'angle': 270},  // West
    ];

    for (var cardinal in cardinals) {
      final label = cardinal['label'] as String;
      final angleDeg = cardinal['angle'] as int;

      textPainter.text = TextSpan(
        text: label,
        style: TextStyle(
          color: angleDeg == 0 ? accentColor : Colors.white.withValues(alpha:0.7),
          fontSize: angleDeg == 0 ? 18 : 16,
          fontWeight: angleDeg == 0 ? FontWeight.bold : FontWeight.normal,
          fontFamily: 'Tajawal',
        ),
      );
      textPainter.layout();

      final angle = angleDeg * (math.pi / 180) - math.pi / 2;
      final offset = Offset(
        center.dx + (radius - 45) * math.cos(angle) - textPainter.width / 2,
        center.dy + (radius - 45) * math.sin(angle) - textPainter.height / 2,
      );

      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(CompassTicksPainter oldDelegate) =>
      tickColor != oldDelegate.tickColor || accentColor != oldDelegate.accentColor;
}

/// Custom painter for direction arrow (points to Kaaba direction)
class DirectionArrowPainter extends CustomPainter {
  final Color color;

  DirectionArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final centerX = size.width / 2;

    // Draw arrow pointing up
    path.moveTo(centerX, 0); // Tip
    path.lineTo(centerX - 12, 20); // Left wing
    path.lineTo(centerX - 5, 20); // Left inner
    path.lineTo(centerX - 5, size.height); // Left shaft
    path.lineTo(centerX + 5, size.height); // Right shaft
    path.lineTo(centerX + 5, 20); // Right inner
    path.lineTo(centerX + 12, 20); // Right wing
    path.close();

    // Draw shadow
    canvas.drawShadow(path, Colors.black, 6.0, true);

    // Draw arrow
    canvas.drawPath(path, paint);

    // Draw outline
    final outlinePaint = Paint()
      ..color = Colors.white.withValues(alpha:0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, outlinePaint);
  }

  @override
  bool shouldRepaint(DirectionArrowPainter oldDelegate) =>
      color != oldDelegate.color;
}
