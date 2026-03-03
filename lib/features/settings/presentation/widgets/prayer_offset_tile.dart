import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../core/theme/app_colors.dart';

class PrayerOffsetTile extends StatelessWidget {
  final Prayer prayer;
  final String name;
  final IconData icon;
  final int offset;
  final DateTime? adjustedTime;
  final ValueChanged<double> onChanged;

  const PrayerOffsetTile({
    super.key,
    required this.prayer,
    required this.name,
    required this.icon,
    required this.offset,
    required this.adjustedTime,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isModified = offset != 0;
    final timeStr = adjustedTime != null
        ? DateFormat(
            'hh:mm a',
          ).format(adjustedTime!).replaceAll('AM', 'ص').replaceAll('PM', 'م')
        : '--:--';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isModified
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.borderTeal,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(icon, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.tajawal(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      timeStr,
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        color: isModified
                            ? AppColors.primary
                            : AppColors.textSecondaryDark,
                        fontWeight: isModified
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              // Offset badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isModified
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isModified
                        ? AppColors.primary.withValues(alpha: 0.4)
                        : Colors.white12,
                  ),
                ),
                child: Text(
                  offset == 0 ? '٠ د' : '${offset > 0 ? '+' : ''}$offset د',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isModified ? AppColors.primary : Colors.white54,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: Colors.white10,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.1),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: offset.toDouble(),
              min: -60,
              max: 60,
              divisions: 120,
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '−٦٠ د',
                style: GoogleFonts.tajawal(fontSize: 10, color: Colors.white24),
              ),
              Text(
                '+٦٠ د',
                style: GoogleFonts.tajawal(fontSize: 10, color: Colors.white24),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
