import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/utils/arabic_utils.dart';

// ── Islamic palette constants ────────────────────────────────────────────────
const _deepGreen = Color(0xFF0B3D23);
const _midGreen = Color(0xFF1A6B42);
const _goldAccent = Color(0xFFD4A537);

class SebhaStatsCard extends StatelessWidget {
  const SebhaStatsCard({required this.state, super.key});

  final SebhaState state;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = [
      (
        Icons.all_inclusive_rounded,
        context.l10n.totalCountLabel,
        ArabicUtils.toArabicDigits(state.totalCount),
      ),
      (
        Icons.today_rounded,
        context.l10n.todayTotalLabel,
        ArabicUtils.toArabicDigits(state.todayTotalCount),
      ),
      (
        Icons.emoji_events_rounded,
        context.l10n.completedGoalsLabel,
        ArabicUtils.toArabicDigits(state.completedGoalsCount),
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: isDark
              ? [const Color(0xFF0E2A1A), const Color(0xFF091A10)]
              : [const Color(0xFFF0FDF4), const Color(0xFFDCFCE7)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? _goldAccent.withValues(alpha: 0.2)
              : _midGreen.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Row(
        children: List.generate(items.length * 2 - 1, (i) {
          if (i.isOdd) {
            return Container(
              width: 1,
              height: 64,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : _midGreen.withValues(alpha: 0.15),
            );
          }
          final item = items[i ~/ 2];
          return Expanded(
            child: _StatTile(
              icon: item.$1,
              label: item.$2,
              value: item.$3,
              isDark: isDark,
            ),
          );
        }),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final accent = isDark ? _goldAccent : _midGreen;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent.withValues(alpha: 0.13),
          ),
          child: Icon(icon, size: 20, color: accent),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.tajawal(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : _deepGreen,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.tajawal(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark
                ? Colors.white.withValues(alpha: 0.55)
                : _midGreen.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
