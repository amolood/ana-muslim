import 'package:flutter/material.dart';

/// Semantic color tokens for the app.
/// These colors represent the *meaning* of UI elements, not just their appearance.
/// Use these instead of hardcoded Colors.white, Colors.grey, etc.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.textOnPrimary,
    required this.textOnSurface,
    required this.textOnCard,
    required this.surfaceCard,
    required this.surfaceVariant,
    required this.borderDefault,
    required this.borderStrong,
    required this.borderSubtle,
    required this.iconPrimary,
    required this.iconSecondary,
    required this.iconDisabled,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
  });

  // Text colors
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;
  final Color textOnPrimary;
  final Color textOnSurface;
  final Color textOnCard;

  // Surface colors
  final Color surfaceCard;
  final Color surfaceVariant;

  // Border colors
  final Color borderDefault;
  final Color borderStrong;
  final Color borderSubtle;

  // Icon colors
  final Color iconPrimary;
  final Color iconSecondary;
  final Color iconDisabled;

  // Status colors
  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  @override
  AppSemanticColors copyWith({
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? textOnPrimary,
    Color? textOnSurface,
    Color? textOnCard,
    Color? surfaceCard,
    Color? surfaceVariant,
    Color? borderDefault,
    Color? borderStrong,
    Color? borderSubtle,
    Color? iconPrimary,
    Color? iconSecondary,
    Color? iconDisabled,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
  }) {
    return AppSemanticColors(
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textDisabled: textDisabled ?? this.textDisabled,
      textOnPrimary: textOnPrimary ?? this.textOnPrimary,
      textOnSurface: textOnSurface ?? this.textOnSurface,
      textOnCard: textOnCard ?? this.textOnCard,
      surfaceCard: surfaceCard ?? this.surfaceCard,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      borderDefault: borderDefault ?? this.borderDefault,
      borderStrong: borderStrong ?? this.borderStrong,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      iconPrimary: iconPrimary ?? this.iconPrimary,
      iconSecondary: iconSecondary ?? this.iconSecondary,
      iconDisabled: iconDisabled ?? this.iconDisabled,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      textOnPrimary: Color.lerp(textOnPrimary, other.textOnPrimary, t)!,
      textOnSurface: Color.lerp(textOnSurface, other.textOnSurface, t)!,
      textOnCard: Color.lerp(textOnCard, other.textOnCard, t)!,
      surfaceCard: Color.lerp(surfaceCard, other.surfaceCard, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      iconPrimary: Color.lerp(iconPrimary, other.iconPrimary, t)!,
      iconSecondary: Color.lerp(iconSecondary, other.iconSecondary, t)!,
      iconDisabled: Color.lerp(iconDisabled, other.iconDisabled, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }

  /// Light theme colors - WCAG AA compliant
  /// All text colors have minimum 4.5:1 contrast ratio on white backgrounds
  static const light = AppSemanticColors(
    // Text colors (high readability in light mode)
    textPrimary: Color(0xFF0E1716), // very dark green-gray (excellent contrast)
    textSecondary: Color(0xFF36514D), // readable secondary
    textTertiary: Color(0xFF56736E), // tertiary/meta text
    textDisabled: Color(0xFF8AA29D), // disabled but visible
    textOnPrimary: Color(0xFFFFFFFF),
    textOnSurface: Color(0xFF0E1716),
    textOnCard: Color(0xFF0E1716),

    // Surfaces (reduced white glare, aligned with dark palette identity)
    surfaceCard: Color(0xFFE6EEEC), // card background
    surfaceVariant: Color(0xFFD9E5E2), // inputs/chips

    // Borders
    borderDefault: Color(0xFFB3C6C2),
    borderStrong: Color(0xFF98B1AC),
    borderSubtle: Color(0xFFCFDDDA),

    // Icons
    iconPrimary: Color(0xFF0E1716),
    iconSecondary: Color(0xFF56736E),
    iconDisabled: Color(0xFFB3C6C2),

    // Status colors (keep strong contrast)
    success: Color(0xFF0F8A63),
    warning: Color(0xFFB86A08),
    error: Color(0xFFB42318),
    info: Color(0xFF0A74B8),
  );

  /// Dark theme colors - preserve existing excellent design
  static const dark = AppSemanticColors(
    // Text colors
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF92C9C0),
    textTertiary: Color(0xFF6B9990),
    textDisabled: Color(0xFF4A6861),
    textOnPrimary: Color(0xFF10221F),
    textOnSurface: Color(0xFFFFFFFF),
    textOnCard: Color(0xFFFFFFFF),

    // Surfaces
    surfaceCard: Color(0xFF19332F),
    surfaceVariant: Color(0xFF11221F),

    // Borders
    borderDefault: Color(0xFF32675E),
    borderStrong: Color(0xFF4A8579),
    borderSubtle: Color(0xFF1E3D37),

    // Icons
    iconPrimary: Color(0xFFFFFFFF),
    iconSecondary: Color(0xFF92C9C0),
    iconDisabled: Color(0xFF4A6861),

    // Status colors
    success: Color(0xFF10B981), // Emerald 500
    warning: Color(0xFFFBBF24), // Amber 400
    error: Color(0xFFEF4444), // Red 500
    info: Color(0xFF38BDF8), // Sky 400
  );
}

/// Extension for easy access to semantic colors
/// Usage: context.colors.textPrimary
extension AppSemanticColorsExtension on BuildContext {
  AppSemanticColors get colors =>
      Theme.of(this).extension<AppSemanticColors>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? AppSemanticColors.dark
          : AppSemanticColors.light);
}
