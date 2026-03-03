import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/qibla_state.dart';

/// تعليمات واضحة للمستخدم حول كيفية استخدام البوصلة
class QiblaInstructions extends StatelessWidget {
  final QiblaUiState state;

  const QiblaInstructions({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final absDelta = state.delta.abs();
    final instructionData = _getInstructionData(absDelta, state.delta);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: instructionData.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: instructionData.color.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // أيقونة والنص الرئيسي في صف واحد
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                instructionData.icon,
                color: instructionData.color,
                size: 24,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  instructionData.mainText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          // النص التوضيحي
          if (instructionData.subText.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              instructionData.subText,
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: 13,
                color: Colors.white70,
                height: 1.4,
              ),
            ),
          ],

          // معلومات إضافية عن الموقع ودقة GPS
          if (state.locationName != null ||
              state.locationConfidence != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (state.locationName != null) ...[
                  const Icon(
                    Icons.location_on,
                    color: AppColors.qiblaGreen,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    state.locationName!,
                    style: GoogleFonts.tajawal(
                      fontSize: 11,
                      color: Colors.white60,
                    ),
                  ),
                ],
                if (state.locationName != null &&
                    state.locationConfidence != null)
                  const SizedBox(width: 12),
                if (state.locationConfidence != null)
                  _buildAccuracyIndicator(state.locationConfidence!),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// مؤشر دقة الموقع
  Widget _buildAccuracyIndicator(double confidence) {
    final accuracyData = _getAccuracyData(confidence);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.gps_fixed,
          color: accuracyData.color,
          size: 12,
        ),
        const SizedBox(width: 4),
        Text(
          accuracyData.label,
          style: GoogleFonts.tajawal(
            fontSize: 11,
            color: accuracyData.color,
          ),
        ),
      ],
    );
  }

  /// بيانات دقة الموقع
  ({Color color, String label}) _getAccuracyData(double confidence) {
    if (confidence >= 90) {
      return (color: AppColors.qiblaBrightGreen, label: 'ممتازة');
    } else if (confidence >= 75) {
      return (color: AppColors.qiblaGreen, label: 'جيدة جداً');
    } else if (confidence >= 50) {
      return (color: AppColors.qiblaWarning, label: 'جيدة');
    } else {
      return (color: AppColors.qiblaError, label: 'ضعيفة');
    }
  }

  /// الحصول على بيانات التعليمات بناءً على الانحراف
  ({
    Color color,
    IconData icon,
    String mainText,
    String subText,
  }) _getInstructionData(double absDelta, double delta) {
    if (absDelta < 3) {
      return (
        color: AppColors.qiblaBrightGreen,
        icon: Icons.check_circle,
        mainText: 'ممتاز! الاتجاه صحيح',
        subText: 'يمكنك الآن الصلاة في هذا الاتجاه بإذن الله',
      );
    } else if (absDelta < 10) {
      return (
        color: AppColors.qiblaGreen,
        icon: Icons.near_me,
        mainText: 'قريب جداً من الاتجاه الصحيح',
        subText: delta > 0
            ? 'حرّك الجوال قليلاً إلى اليمين'
            : 'حرّك الجوال قليلاً إلى اليسار',
      );
    } else if (absDelta < 30) {
      return (
        color: AppColors.qiblaWarning,
        icon: Icons.rotate_right,
        mainText: 'قريب من الاتجاه',
        subText: delta > 0
            ? 'استمر في تحريك الجوال إلى اليمين'
            : 'استمر في تحريك الجوال إلى اليسار',
      );
    } else if (absDelta < 90) {
      return (
        color: AppColors.qiblaError,
        icon: Icons.explore,
        mainText: 'ابحث عن الاتجاه',
        subText: delta > 0
            ? 'حرّك الجوال بشكل أكبر إلى اليمين'
            : 'حرّك الجوال بشكل أكبر إلى اليسار',
      );
    } else {
      return (
        color: Colors.white54,
        icon: Icons.refresh,
        mainText: 'استدر مع الجوال',
        subText: 'أمسك الجوال بشكل مستقيم ودر حول نفسك ببطء',
      );
    }
  }
}
