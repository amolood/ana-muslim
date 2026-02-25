import 'package:flutter/material.dart';
import '../../data/models/qibla_state.dart';

/// Header widget showing Qibla info and location
class QiblaHeader extends StatelessWidget {
  final QiblaUiState state;

  const QiblaHeader({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Title
          const Text(
            "القبلة",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(height: 8),

          // Qibla bearing and location
          Text(
            _getLocationText(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
              fontFamily: 'Tajawal',
            ),
          ),

          // Confidence indicator
          if (state.confidence > 0)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getConfidenceIcon(state.confidence),
                    color: _getConfidenceColor(state.confidence),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "دقة القياس: ${state.confidence.toInt()}%",
                    style: TextStyle(
                      color: _getConfidenceColor(state.confidence),
                      fontSize: 12,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _getLocationText() {
    if (state.qiblaBearing == null) {
      return "جارٍ تحديد الموقع...";
    }

    final bearing = state.qiblaBearing!.toStringAsFixed(0);
    final location = state.locationName ?? "موقعك الحالي";

    return "$bearing° من الشمال • $location";
  }

  IconData _getConfidenceIcon(double confidence) {
    if (confidence >= 80) return Icons.signal_cellular_alt;
    if (confidence >= 60) return Icons.signal_cellular_alt_2_bar;
    return Icons.signal_cellular_alt_1_bar;
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 80) return const Color(0xFF4AFFA3);
    if (confidence >= 60) return Colors.amberAccent;
    return Colors.redAccent;
  }
}
