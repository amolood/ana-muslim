import 'package:flutter/material.dart';
import '../../data/models/qibla_state.dart';
import '../../core/constants.dart';

/// Footer widget showing alignment status and guidance
class StatusFooter extends StatelessWidget {
  final QiblaUiState state;

  const StatusFooter({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final message = _getMessage();
    final statusColor = _getStatusColor();
    final icon = _getIcon();

    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        children: [
          // Status icon
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor.withOpacity(0.15),
            ),
            child: Icon(
              icon,
              color: statusColor,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),

          // Status message
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: statusColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),

          // Delta display
          if (state.smoothedHeading != null)
            Text(
              "انحراف: ${state.delta.abs().toStringAsFixed(1)}°",
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 12,
                fontFamily: 'Tajawal',
              ),
            ),

          // Tolerance indicator
          if (!state.isFullyAligned && state.delta.abs() < kToleranceThreshold)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_outline, size: 14, color: Colors.green),
                    const SizedBox(width: 6),
                    Text(
                      "ضمن النطاق المقبول للصلاة",
                      style: TextStyle(
                        color: Colors.green.shade200,
                        fontSize: 11,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getMessage() {
    if (state.smoothedHeading == null) {
      return "جارٍ تحديد الاتجاه...";
    }

    switch (state.alignmentStatus) {
      case AlignmentStatus.perfect:
        return "✓ اتجاه القبلة مضبوط";
      case AlignmentStatus.excellent:
        return "ممتاز! ثبّت لثانية";
      case AlignmentStatus.good:
        return "قريب جداً";
      case AlignmentStatus.acceptable:
        if (state.delta > 0) {
          return "استدر يميناً قليلاً";
        } else {
          return "استدر يساراً قليلاً";
        }
      case AlignmentStatus.off:
        if (state.delta > 0) {
          return "استدر نحو اليمين";
        } else {
          return "استدر نحو اليسار";
        }
    }
  }

  Color _getStatusColor() {
    switch (state.alignmentStatus) {
      case AlignmentStatus.perfect:
      case AlignmentStatus.excellent:
        return const Color(0xFF4AFFA3);
      case AlignmentStatus.good:
        return Colors.amberAccent;
      case AlignmentStatus.acceptable:
        return Colors.white70;
      case AlignmentStatus.off:
        return Colors.white38;
    }
  }

  IconData _getIcon() {
    switch (state.alignmentStatus) {
      case AlignmentStatus.perfect:
        return Icons.check_circle;
      case AlignmentStatus.excellent:
        return Icons.adjust;
      case AlignmentStatus.good:
        return Icons.near_me;
      case AlignmentStatus.acceptable:
        return state.delta > 0 ? Icons.arrow_back : Icons.arrow_forward;
      case AlignmentStatus.off:
        return Icons.explore;
    }
  }
}
