import 'package:flutter/material.dart';

class AppColors {
  // Brand colors
  static const Color primary = Color(0xFF11D4B4);

  // ─── Light theme ──────────────────────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF6F8F8);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceLightCard = Color(0xFFEEF3F2); // slightly elevated
  static const Color textPrimaryLight = Color(0xFF0F172A); // slate-900
  static const Color textSecondaryLight = Color(0xFF5B7D78);
  static const Color borderLight = Color(0xFFD0DEDD);

  // ─── Dark theme ───────────────────────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF10221F);
  static const Color surfaceDark = Color(0xFF19332F);
  static const Color surfaceDarker = Color(0xFF11221F);
  static const Color borderDark = Color(0xFF32675E);

  // ─── Dark text ────────────────────────────────────────────────────────────
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF92C9C0);

  // ─── Theme-aware helpers ──────────────────────────────────────────────────

  /// Card / list-item background
  static Color surface(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark ? surfaceDark : surfaceLight;

  /// Elevated / nested surface (e.g. page-number box, progress-bar bg)
  static Color surfaceElevated(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
      ? surfaceDarker
      : surfaceLightCard;

  /// Primary body text
  static Color textPrimary(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
      ? textPrimaryDark
      : textPrimaryLight;

  /// Secondary / caption text
  static Color textSecondary(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
      ? textSecondaryDark
      : textSecondaryLight;

  /// Borders / dividers
  static Color border(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark ? borderDark : borderLight;
}
