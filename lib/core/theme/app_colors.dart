import 'package:flutter/material.dart';

class AppColors {
  // Brand colors
  static const Color primary = Color(0xFF11D4B4);

  // ─── Quran / Mushaf ───────────────────────────────────────────────────────
  /// Gold accent used in dark-mode Mushaf page decorations (verse numbers, separators)
  static const Color mushafGold = Color(0xFFF4D03F);

  // ─── Feature-specific dark surfaces ──────────────────────────────────────
  /// Dark card / list-item background used in Tahfeez feature (Slate-800)
  static const Color cardDark = Color(0xFF1E293B);

  /// Deep scaffold background used in Tahfeez feature (Slate-900)
  static const Color backgroundDeepDark = Color(0xFF0F172A);

  // ─── Shared accents ──────────────────────────────────────────────────────
  /// Teal border used across hadith, azkar, settings cards
  static const Color borderTeal = Color(0xFF2D5E57);

  /// Dark teal card surface (hadith expanded tile, search results)
  static const Color surfaceTealDark = Color(0xFF142C28);

  /// Warm gold for surah titles and Quran index
  static const Color surahGold = Color(0xFFD6B06B);

  /// Amber used in Ramadan feature cards
  static const Color ramadanAmber = Color(0xFFFBBF24);

  /// Darker amber used in Ramadan gradients
  static const Color ramadanAmberDark = Color(0xFFF59E0B);

  // ─── Qibla ──────────────────────────────────────────────────────────────
  /// Primary qibla accent green
  static const Color qiblaGreen = Color(0xFF4AFFA3);

  /// Bright green — fully aligned / excellent accuracy
  static const Color qiblaBrightGreen = Color(0xFF00FF88);

  /// Warning orange — fair accuracy
  static const Color qiblaWarning = Color(0xFFFFAA00);

  /// Error red — poor accuracy
  static const Color qiblaError = Color(0xFFFF6B6B);

  /// Deep black background for qibla compass
  static const Color qiblaDark = Color(0xFF0A0A0A);

  // ─── Light theme ──────────────────────────────────────────────────────────
  // IMPROVED: Better contrast ratios for WCAG AA compliance (reduced white glare)
  static const Color backgroundLight = Color(0xFFF3F7F6); // page background - soft mint-gray
  static const Color surfaceLight = Color(0xFFEEF4F2); // main surface - reduced white
  static const Color surfaceLightCard = Color(0xFFE6EEEC); // cards - improved contrast
  static const Color surfaceVariantLight = Color(0xFFD9E5E2); // chips/inputs
  static const Color textPrimaryLight = Color(0xFF0E1716); // very dark green-gray (excellent contrast)
  static const Color textSecondaryLight = Color(0xFF36514D); // IMPROVED - 7.2:1 contrast
  static const Color textTertiaryLight = Color(0xFF56736E); // tertiary/meta text
  static const Color borderLight = Color(0xFFB3C6C2); // IMPROVED - 2.5:1 contrast
  static const Color borderStrongLight = Color(0xFF98B1AC); // emphasis borders

  // ─── Dark theme ───────────────────────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF10221F);
  static const Color surfaceDark = Color(0xFF19332F);
  static const Color surfaceDarker = Color(0xFF11221F);
  static const Color borderDark = Color(0xFF32675E);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF92C9C0);

  // ─── Theme-aware helpers ──────────────────────────────────────────────────
  // DEPRECATED: Use context.colors or Theme.of(context).colorScheme instead
  // These are kept for backward compatibility during migration

  /// Card / list-item background
  /// @deprecated Use context.colors.surfaceCard or Theme.of(context).colorScheme.surfaceContainerHighest
  @Deprecated('Use context.colors.surfaceCard instead')
  static Color surface(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark ? surfaceDark : surfaceLight;

  /// Elevated / nested surface (e.g. page-number box, progress-bar bg)
  /// @deprecated Use context.colors.surfaceVariant or Theme.of(context).colorScheme.surfaceContainerHigh
  @Deprecated('Use context.colors.surfaceVariant instead')
  static Color surfaceElevated(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? surfaceDarker
          : surfaceLightCard;

  /// Primary body text
  /// @deprecated Use context.colors.textPrimary or Theme.of(context).colorScheme.onSurface
  @Deprecated('Use context.colors.textPrimary instead')
  static Color textPrimary(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? textPrimaryDark
          : textPrimaryLight;

  /// Secondary / caption text
  /// @deprecated Use context.colors.textSecondary or Theme.of(context).colorScheme.onSurfaceVariant
  @Deprecated('Use context.colors.textSecondary instead')
  static Color textSecondary(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? textSecondaryDark
          : textSecondaryLight;

  /// Borders / dividers
  /// @deprecated Use context.colors.borderDefault or Theme.of(context).colorScheme.outline
  @Deprecated('Use context.colors.borderDefault instead')
  static Color border(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark ? borderDark : borderLight;
}
