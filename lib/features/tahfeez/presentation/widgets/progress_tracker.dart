import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/utils/arabic_utils.dart';

/// متتبع تقدم جلسة الحفظ
class ProgressTracker extends StatelessWidget {
  final int currentAyah;
  final int startAyah;
  final int totalAyahs;
  final int currentAyahInRange;
  final Duration sessionTime;
  final int repeatsDone;

  const ProgressTracker({
    super.key,
    required this.currentAyah,
    required this.startAyah,
    required this.totalAyahs,
    required this.currentAyahInRange,
    required this.sessionTime,
    required this.repeatsDone,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final calculatedRangeIndex = currentAyah > 0
        ? (currentAyah - startAyah + 1).clamp(0, totalAyahs)
        : 0;
    final displayedRangeIndex = currentAyahInRange > 0
        ? currentAyahInRange.clamp(0, totalAyahs)
        : calculatedRangeIndex;

    final progress = totalAyahs > 0
        ? (displayedRangeIndex / totalAyahs).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: colors.surfaceCard,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.trending_up,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'تقدم الجلسة',
                  style: GoogleFonts.tajawal(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // شريط التقدم
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'التقدم',
                      style: GoogleFonts.tajawal(
                        fontSize: 14,
                        color: colors.textSecondary,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: GoogleFonts.tajawal(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 12,
                    backgroundColor: colors.borderSubtle,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // الإحصائيات
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatCard(
                  icon: Icons.timer_outlined,
                  label: 'الوقت',
                  value: ArabicUtils.formatDuration(sessionTime),
                ),
                _StatCard(
                  icon: Icons.repeat,
                  label: 'التكرارات',
                  value: '$repeatsDone',
                ),
                _StatCard(
                  icon: Icons.menu_book,
                  label: 'الآيات',
                  value: '$displayedRangeIndex/$totalAyahs',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.tajawal(
              fontSize: 12,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
