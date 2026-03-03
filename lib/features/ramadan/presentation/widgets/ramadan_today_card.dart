import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/arabic_utils.dart';
import '../../data/models/ramadan_model.dart';

/// Converts "X hours Y minutes" (English) → "X ساعة و Y دقيقة" (Arabic digits)
/// when [isArabic] is true. Falls back to the raw string for other formats/locales.
String _formatFastingDuration(String? duration, bool isArabic) {
  if (duration == null || duration.isEmpty) return '—';
  if (!isArabic) return duration;

  // Match patterns like "15 hours 30 minutes", "1 hour 5 minutes", etc.
  final match = RegExp(
    r'(\d+)\s*hours?\s*(\d+)\s*min(?:utes?)?',
    caseSensitive: false,
  ).firstMatch(duration);

  if (match != null) {
    final h = int.parse(match.group(1)!);
    final m = int.parse(match.group(2)!);
    return '${ArabicUtils.toArabicDigits(h)} ساعة و ${ArabicUtils.toArabicDigits(m)} دقيقة';
  }

  // Fallback: return as-is (server may already send Arabic or different format)
  return duration;
}

String _formatTo12h(String? time, bool isArabic) {
  if (time == null || time.isEmpty) return '—';
  try {
    final parts = time.split(':');
    if (parts.length != 2) return time;
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final dt = DateTime(2026, 1, 1, hour, minute);
    if (isArabic) {
      return ArabicUtils.ensureLatinDigits(DateFormat.jm('ar').format(dt));
    }
    return DateFormat.jm('en_US').format(dt);
  } catch (_) {
    return time;
  }
}

/// Card showing today's Ramadan day with sahur/iftar times and fasting duration.
class RamadanTodayCard extends StatelessWidget {
  const RamadanTodayCard({
    super.key,
    required this.today,
    required this.strings,
    required this.isArabic,
  });

  final RamadanDay today;
  final Map<String, String> strings;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF065F46),
                  const Color(0xFF047857),
                  const Color(0xFF059669),
                ]
              : [
                  const Color(0xFF10B981).withValues(alpha: 0.2),
                  const Color(0xFF059669).withValues(alpha: 0.15),
                  AppColors.surfaceLight,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? const Color(0xFF10B981).withValues(alpha: 0.3)
              : const Color(0xFF059669).withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? const Color(0xFF10B981).withValues(alpha: 0.4)
                : const Color(0xFF059669).withValues(alpha: 0.2),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: isDark
                ? const Color(0xFF34D399).withValues(alpha: 0.2)
                : const Color(0xFF10B981).withValues(alpha: 0.1),
            blurRadius: 40,
            spreadRadius: 0,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings['today_label']!,
                        style: GoogleFonts.tajawal(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFF6EE7B7)
                              : const Color(0xFF047857),
                          letterSpacing: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        ArabicUtils.ensureLatinDigits(today.hijriArabic ?? ''),
                        style: GoogleFonts.tajawal(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF065F46),
                          shadows: isDark
                              ? [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (today.isWhiteDay) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFBBF24).withValues(
                              alpha: 0.4,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              strings['white_days_label']!,
                              style: GoogleFonts.tajawal(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildTimeItem(
                    context,
                    Icons.wb_twilight_rounded,
                    strings['sahur']!,
                    _formatTo12h(today.sahurTime, isArabic),
                  ),
                ),
                Container(
                  width: 1,
                  height: 48,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                Expanded(
                  child: _buildTimeItem(
                    context,
                    Icons.wb_sunny_rounded,
                    strings['iftar']!,
                    _formatTo12h(today.iftarTime, isArabic),
                  ),
                ),
              ],
            ),
            if (today.fastingDuration != null) ...[
              const SizedBox(height: 14),
              Center(
                child: Text(
                  '${strings['fasting_duration']!}: ${_formatFastingDuration(today.fastingDuration, isArabic)}',
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFF95D5B2)
                        : const Color(0xFF059669),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeItem(
    BuildContext context,
    IconData icon,
    String label,
    String time,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF6EE7B7).withValues(alpha: 0.15)
                : const Color(0xFF047857).withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark
                  ? const Color(0xFF6EE7B7).withValues(alpha: 0.3)
                  : const Color(0xFF047857).withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            color: isDark
                ? const Color(0xFF6EE7B7)
                : const Color(0xFF047857),
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark
                ? const Color(0xFF6EE7B7)
                : const Color(0xFF047857),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: GoogleFonts.manrope(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF065F46),
            letterSpacing: 0.5,
            shadows: isDark
                ? [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
