import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../../data/models/qibla_state.dart';

/// Simple and clear compass view for Qibla direction
/// Design: Fixed Kaaba at top, rotating arrow from center pointing to Qibla
class SimpleCompassView extends StatelessWidget {
  final QiblaUiState state;

  const SimpleCompassView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // تقليل حجم البوصلة لتناسب جميع الشاشات
    final compassSize = math.min(size.width * 0.65, 280.0);

    // تحديد اللون بناءً على الدقة
    final Color arrowColor = _getArrowColor(state.delta.abs());
    final bool isAligned = state.delta.abs() < 5.0;

    return SizedBox(
      width: compassSize,
      height: compassSize + 100, // مساحة إضافية للكعبة في الأعلى
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none, // للسماح للكعبة بالخروج من الحدود
        children: [
          // الكعبة الثابتة خارج الدائرة في الأعلى
          Positioned(
            top: 0,
            child: _buildFixedKaaba(isAligned, arrowColor),
          ),

          // الدائرة الخارجية (البوصلة) في المنتصف
          Positioned(
            top: 80, // بعد الكعبة
            child: _buildCompassCircle(compassSize, arrowColor),
          ),

          // السهم الدوار يشير للقبلة (فوق الدائرة)
          Positioned(
            top: 80,
            child: _buildRotatingArrow(compassSize, arrowColor, isAligned),
          ),

          // المركز (معلومات الاتجاه)
          Positioned(
            top: 80,
            child: _buildCenterInfo(arrowColor, compassSize),
          ),
        ],
      ),
    );
  }

  /// الدائرة الخارجية مع علامات الاتجاهات
  Widget _buildCompassCircle(double size, Color accentColor) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 3,
        ),
        gradient: RadialGradient(
          colors: [
            const Color(0xFF1A1A1A),
            const Color(0xFF0A0A0A),
          ],
          stops: const [0.7, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // علامات الاتجاهات الرئيسية (ش، ج، ق، غ)
          _buildDirectionMarker('ش', 0, size),      // شمال
          _buildDirectionMarker('ج', 90, size),     // جنوب
          _buildDirectionMarker('غ', 180, size),    // غرب
          _buildDirectionMarker('ق', 270, size),    // قبل

          // علامات فرعية كل 45 درجة
          ..._buildMinorTicks(size),
        ],
      ),
    );
  }

  /// علامات الاتجاهات الرئيسية
  Widget _buildDirectionMarker(String label, double angle, double size) {
    final double radians = angle * math.pi / 180;
    final double radius = size / 2 - 25;

    return Positioned(
      left: size / 2 + radius * math.cos(radians - math.pi / 2) - 15,
      top: size / 2 + radius * math.sin(radians - math.pi / 2) - 15,
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white60,
          ),
        ),
      ),
    );
  }

  /// علامات صغيرة كل 45 درجة
  List<Widget> _buildMinorTicks(double size) {
    final List<Widget> ticks = [];
    for (int i = 0; i < 8; i++) {
      final angle = i * 45.0;
      if (angle % 90 != 0) { // تجاهل الاتجاهات الرئيسية
        ticks.add(_buildTick(angle, size, isMinor: true));
      } else {
        ticks.add(_buildTick(angle, size, isMinor: false));
      }
    }
    return ticks;
  }

  /// علامة واحدة على محيط الدائرة
  Widget _buildTick(double angle, double size, {required bool isMinor}) {
    final double radians = angle * math.pi / 180;
    final double radius = size / 2;
    final double tickLength = isMinor ? 8 : 15;

    return Positioned(
      left: size / 2,
      top: size / 2,
      child: Transform.rotate(
        angle: radians,
        child: Transform.translate(
          offset: Offset(0, -radius + tickLength),
          child: Container(
            width: 2,
            height: tickLength,
            color: Colors.white30,
          ),
        ),
      ),
    );
  }

  /// السهم الدوار الذي يشير إلى القبلة
  Widget _buildRotatingArrow(double size, Color color, bool isAligned) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: state.delta),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (context, angle, child) {
        return Transform.rotate(
          angle: -angle * (math.pi / 180), // عكس الاتجاه لأن السهم يدور
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

  /// الكعبة الثابتة في الأعلى
  Widget _buildFixedKaaba(bool isAligned, Color accentColor) {
    return Positioned(
      top: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isAligned
              ? accentColor.withValues(alpha: 0.2)
              : const Color(0xFF1A1A1A),
          border: Border.all(
            color: accentColor,
            width: isAligned ? 3 : 2,
          ),
          boxShadow: isAligned
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.6),
                    blurRadius: 30,
                    spreadRadius: 10,
                  )
                ]
              : [],
        ),
        child: const Icon(
          Icons.place,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  /// المركز مع معلومات الاتجاه
  Widget _buildCenterInfo(Color accentColor, double compassSize) {
    final absDelta = state.delta.abs();
    final centerSize = compassSize * 0.35; // نسبة من حجم البوصلة

    return Container(
      width: centerSize,
      height: centerSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF0A0A0A),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // درجة الانحراف
          Text(
            '${absDelta.toInt()}°',
            style: GoogleFonts.tajawal(
              fontSize: centerSize * 0.24, // نسبة من حجم الدائرة
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          SizedBox(height: centerSize * 0.04),
          // اتجاه الدوران
          if (absDelta > 3)
            Icon(
              state.delta > 0 ? Icons.arrow_forward : Icons.arrow_back,
              size: centerSize * 0.20,
              color: accentColor.withValues(alpha: 0.7),
            ),
        ],
      ),
    );
  }

  /// تحديد لون السهم بناءً على الدقة
  Color _getArrowColor(double absDelta) {
    if (absDelta < 3) return const Color(0xFF00FF88); // أخضر فاتح - ممتاز
    if (absDelta < 10) return const Color(0xFF4AFFA3); // أخضر - جيد جداً
    if (absDelta < 30) return const Color(0xFFFFAA00); // برتقالي - جيد
    if (absDelta < 60) return const Color(0xFFFF6B6B); // أحمر فاتح - مقبول
    return Colors.white54; // أبيض باهت - بعيد
  }

  /// شدة التوهج بناءً على القرب من القبلة
  double _getGlowIntensity(double absDelta) {
    if (absDelta < 3) return 1.0;
    if (absDelta < 10) return 0.7;
    if (absDelta < 30) return 0.4;
    return 0.0;
  }
}

/// رسام مخصص للسهم - تصميم حديث وأنيق
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

    // توهج خارجي متعدد الطبقات للسهم
    if (glowIntensity > 0) {
      // طبقة توهج خارجية
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

      // طبقة توهج متوسطة
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

    // جسم السهم الرئيسي - تدرج في العرض
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

    // رأس السهم - تصميم حديث وأنيق
    final arrowTipY = center.dy - arrowLength;

    // رأس السهم الخارجي (محدد)
    final arrowHeadPath = Path()
      ..moveTo(center.dx, arrowTipY - 5) // نقطة السهم
      ..quadraticBezierTo(
        center.dx - 8, arrowTipY + 15, // نقطة التحكم اليسرى
        center.dx - 16, arrowTipY + 22, // النقطة اليسرى
      )
      ..lineTo(center.dx, arrowTipY + 12) // المركز السفلي
      ..lineTo(center.dx + 16, arrowTipY + 22) // النقطة اليمنى
      ..quadraticBezierTo(
        center.dx + 8, arrowTipY + 15, // نقطة التحكم اليمنى
        center.dx, arrowTipY - 5, // نقطة السهم
      )
      ..close();

    // توهج رأس السهم
    if (glowIntensity > 0) {
      canvas.drawPath(
        arrowHeadPath,
        Paint()
          ..color = color.withValues(alpha: glowIntensity * 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
      );
    }

    // تعبئة رأس السهم بتدرج
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

    // حدود رأس السهم
    final arrowHeadBorderPaint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawPath(arrowHeadPath, arrowHeadBorderPaint);

    // دائرة مركزية أنيقة
    // دائرة خارجية (توهج)
    if (glowIntensity > 0) {
      canvas.drawCircle(
        center,
        12,
        Paint()
          ..color = color.withValues(alpha: glowIntensity * 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }

    // دائرة خارجية (حدود)
    canvas.drawCircle(
      center,
      10,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // دائرة داخلية (تعبئة بتدرج)
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

    // نقطة مركزية صغيرة
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
