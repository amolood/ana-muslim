import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_semantic_colors.dart';

/// Consistent section header with icon pill + title + optional trailing widget.
///
/// Used in: HomeScreen quick-actions, WorshipStatsScreen sections, etc.
class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.iconColor,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.sm,
      0,
      AppSpacing.sm,
      AppSpacing.md,
    ),
  });

  final IconData icon;
  final String title;

  /// Icon background + icon color. Defaults to [AppColors.primary].
  final Color? iconColor;

  /// Optional widget rendered at the trailing end of the row.
  final Widget? trailing;

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = iconColor ?? AppColors.primary;

    return Padding(
      padding: padding,
      child: Row(
        children: [
          Container(
            width: AppSpacing.iconXl,
            height: AppSpacing.iconXl,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm + 1),
            ),
            child: Icon(icon, color: accent, size: AppSpacing.iconSm + 1),
          ),
          const SizedBox(width: AppSpacing.sm + 2),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.tajawal(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
