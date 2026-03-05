import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_semantic_colors.dart';

/// A consistent surface card used throughout the app.
///
/// Supports optional tap ripple, custom padding/margin, and border override.
/// All colors come from the semantic color extension — never hardcoded.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.cardPadding,
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.borderRadius = AppSpacing.radiusCard,
    this.showBorder = true,
    this.showShadow = true,
    this.accentBorderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final double borderRadius;
  final bool showBorder;
  final bool showShadow;

  /// When set, the border uses this color instead of the default semantic border.
  final Color? accentBorderColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final border = showBorder
        ? Border.all(
            color: accentBorderColor ?? colors.borderSubtle,
            width: 1.5,
          )
        : null;

    final shadow = (showShadow && !isDark)
        ? [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ]
        : null;

    final decoration = BoxDecoration(
      color: colors.surfaceCard,
      borderRadius: BorderRadius.circular(borderRadius),
      border: border,
      boxShadow: shadow,
    );

    final content = Padding(padding: padding, child: child);

    if (onTap == null) {
      return Padding(
        padding: margin,
        child: DecoratedBox(decoration: decoration, child: content),
      );
    }

    return Padding(
      padding: margin,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Ink(decoration: decoration, child: content),
        ),
      ),
    );
  }
}
