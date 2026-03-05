import 'package:flutter/material.dart';

/// Single source of truth for all spacing, radius, and layout values.
///
/// Usage:
/// ```dart
/// padding: const EdgeInsets.all(AppSpacing.lg)
/// borderRadius: BorderRadius.circular(AppSpacing.radiusLg)
/// ```
abstract final class AppSpacing {
  // ─── Base spacing scale (4-pt grid) ──────────────────────────────────────
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;

  // ─── Border radii ─────────────────────────────────────────────────────────
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radiusCard = 18;
  static const double radiusFull = 999;

  // ─── Icon sizes ───────────────────────────────────────────────────────────
  static const double iconXs = 14;
  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;
  static const double iconXl = 32;

  // ─── Tap target minimum (WCAG: 44×44 logical pixels) ─────────────────────
  static const double tapTargetMin = 44;

  // ─── Common paddings ──────────────────────────────────────────────────────
  static const EdgeInsets screenPaddingH = EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
  static const EdgeInsets cardPaddingLg = EdgeInsets.all(xxl);
  static const EdgeInsets tileContentPadding =
      EdgeInsets.symmetric(horizontal: lg, vertical: md);
}
