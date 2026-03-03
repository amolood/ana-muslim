import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/utils/arabic_utils.dart';
import '../../data/models/ramadan_model.dart';

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

/// A single row in the Ramadan schedule list showing date badge,
/// Hijri date, day of week, and compact sahur/iftar times.
class RamadanDayRow extends StatelessWidget {
  const RamadanDayRow({
    super.key,
    required this.day,
    required this.strings,
    required this.isArabic,
    this.isFirst = false,
    this.isLast = false,
  });

  final RamadanDay day;
  final Map<String, String> strings;
  final bool isArabic;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isToday = day.isToday;
    final locale = Localizations.localeOf(context).toString();
    final date = DateFormat('dd MMM', locale).format(
      DateTime.tryParse(day.date) ?? DateTime.now(),
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = context.colors;

    return Container(
      margin: EdgeInsets.fromLTRB(20, isFirst ? 0 : 6, 20, isLast ? 0 : 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isToday
              ? isDark
                  ? [
                      const Color(0xFF059669).withValues(alpha: 0.4),
                      const Color(0xFF047857).withValues(alpha: 0.3),
                    ]
                  : [
                      const Color(0xFF10B981).withValues(alpha: 0.2),
                      const Color(0xFF059669).withValues(alpha: 0.1),
                    ]
              : day.isWhiteDay
                  ? isDark
                      ? [
                          const Color(0xFFFBBF24).withValues(alpha: 0.15),
                          const Color(0xFFF59E0B).withValues(alpha: 0.1),
                        ]
                      : [
                          const Color(0xFFFBBF24).withValues(alpha: 0.1),
                          const Color(0xFFF59E0B).withValues(alpha: 0.05),
                        ]
                  : [colors.surfaceCard, colors.surfaceCard],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isToday
              ? const Color(0xFF10B981).withValues(alpha: 0.4)
              : day.isWhiteDay
                  ? const Color(0xFFFBBF24).withValues(alpha: 0.3)
                  : colors.borderSubtle,
          width: isToday || day.isWhiteDay ? 1.5 : 1,
        ),
        boxShadow: isToday
            ? [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : day.isWhiteDay
                ? [
                    BoxShadow(
                      color: const Color(0xFFFBBF24).withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
      ),
      child: Row(
        children: [
          // ─── Day number badge ────────────────────────────────
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: isToday
                  ? const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : day.isWhiteDay
                      ? const LinearGradient(
                          colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
              color: isToday || day.isWhiteDay
                  ? null
                  : colors.surfaceVariant,
              shape: BoxShape.circle,
              boxShadow: isToday || day.isWhiteDay
                  ? [
                      BoxShadow(
                        color: (isToday
                                ? const Color(0xFF10B981)
                                : const Color(0xFFFBBF24))
                            .withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: Text(
                date,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: isToday || day.isWhiteDay
                      ? Colors.white
                      : colors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // ─── Hijri date + day name ───────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ArabicUtils.ensureLatinDigits(day.hijriArabic ?? ''),
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                    color: isToday
                        ? isDark
                            ? Colors.white
                            : const Color(0xFF065F46)
                        : colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  DateFormat('EEEE', locale).format(
                    DateTime.tryParse(day.date) ?? DateTime.now(),
                  ),
                  style: GoogleFonts.tajawal(
                    fontSize: 11,
                    color: colors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // ─── Compact times ───────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildMiniTime(
                context,
                Icons.nightlight_round,
                _formatTo12h(day.sahurTime, isArabic),
              ),
              const SizedBox(height: 2),
              _buildMiniTime(
                context,
                Icons.wb_sunny_rounded,
                _formatTo12h(day.iftarTime, isArabic),
              ),
            ],
          ),
          if (day.isWhiteDay) ...[
            const SizedBox(width: 8),
            const Icon(Icons.star_rounded, color: Color(0xFFFACC15), size: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniTime(BuildContext context, IconData icon, String? time) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: colors.textSecondary,
          size: 12,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            time ?? '—',
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
