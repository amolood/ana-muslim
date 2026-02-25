import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Overlay shown when magnetometer needs calibration
/// Guides user to move phone in figure-8 pattern
class CalibrationOverlay extends StatelessWidget {
  final VoidCallback? onDismiss;

  const CalibrationOverlay({super.key, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.85),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Figure-8 illustration
          const Figure8Animation(),
          const SizedBox(height: 32),

          // Title
          const Text(
            "تحسين دقة البوصلة",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(height: 16),

          // Instructions
          Text(
            "يرجى تحريك الهاتف بشكل رقم (8) في الهواء والابتعاد عن أي أجسام معدنية أو مغناطيسية.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
              height: 1.5,
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(height: 24),

          // Additional tips
          _buildTip("ابتعد عن الأجهزة الإلكترونية", Icons.devices_outlined),
          const SizedBox(height: 12),
          _buildTip("ابتعد عن الأسطح المعدنية", Icons.do_not_touch_outlined),
          const SizedBox(height: 12),
          _buildTip("تأكد من عدم وجود مغناطيس قريب", Icons.wifi_protected_setup_outlined),

          const SizedBox(height: 32),

          // Dismiss button
          if (onDismiss != null)
            OutlinedButton(
              onPressed: onDismiss,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white38),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                "فهمت",
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTip(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.amber, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
      ],
    );
  }
}

/// Animated figure-8 motion guide
class Figure8Animation extends StatefulWidget {
  const Figure8Animation({super.key});

  @override
  State<Figure8Animation> createState() => _Figure8AnimationState();
}

class _Figure8AnimationState extends State<Figure8Animation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 140,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: Figure8Painter(progress: _controller.value),
          );
        },
      ),
    );
  }
}

/// Custom painter for figure-8 animation
class Figure8Painter extends CustomPainter {
  final double progress;

  Figure8Painter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4AFFA3).withOpacity(0.3)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final activePaint = Paint()
      ..color = const Color(0xFF4AFFA3)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radiusX = size.width / 3;
    final radiusY = size.height / 2.5;

    // Draw figure-8 path (lemniscate)
    for (double t = 0; t <= 2 * math.pi; t += 0.01) {
      final x = centerX + radiusX * math.sin(t);
      final y = centerY + radiusY * math.sin(t) * math.cos(t);

      if (t == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Draw full path (faded)
    canvas.drawPath(path, paint);

    // Draw phone icon at current position
    final t = progress * 2 * math.pi;
    final phoneX = centerX + radiusX * math.sin(t);
    final phoneY = centerY + radiusY * math.sin(t) * math.cos(t);

    // Draw trailing line
    final trailPath = Path();
    bool started = false;
    for (double trailT = t - 0.5; trailT <= t; trailT += 0.01) {
      if (trailT < 0) continue;
      final x = centerX + radiusX * math.sin(trailT);
      final y = centerY + radiusY * math.sin(trailT) * math.cos(trailT);
      if (!started) {
        trailPath.moveTo(x, y);
        started = true;
      } else {
        trailPath.lineTo(x, y);
      }
    }
    canvas.drawPath(trailPath, activePaint);

    // Draw phone icon
    _drawPhoneIcon(canvas, Offset(phoneX, phoneY), t);
  }

  void _drawPhoneIcon(Canvas canvas, Offset position, double rotation) {
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(rotation + math.pi / 2);

    final phonePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final phoneRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-10, -15, 20, 30),
      const Radius.circular(3),
    );

    canvas.drawRRect(phoneRect, phonePaint);

    final screenPaint = Paint()
      ..color = const Color(0xFF4AFFA3)
      ..style = PaintingStyle.fill;

    final screenRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-7, -12, 14, 20),
      const Radius.circular(2),
    );

    canvas.drawRRect(screenRect, screenPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(Figure8Painter oldDelegate) =>
      progress != oldDelegate.progress;
}
