import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/providers/widget_settings_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../widgets/color_palette_picker.dart';
import '../widgets/decor_image_picker.dart';
import '../widgets/widget_content_previews.dart';

class WidgetDetailSettingsScreen extends ConsumerWidget {
  const WidgetDetailSettingsScreen({super.key, required this.widgetType});

  final WidgetType widgetType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final style = ref.watch(widgetStyleProvider(widgetType));
    final notifier = widgetStyleNotifier(ref);
    final wt = widgetType;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widgetType.displayNameAr,
          style: GoogleFonts.tajawal(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Realistic Widget Preview ──
            const SizedBox(height: 8),
            _WidgetPreview(widgetType: widgetType, style: style),
            const SizedBox(height: 28),

            // ── Text Color ──
            _SectionHeader(title: context.l10n.widgetTextColor),
            const SizedBox(height: 10),
            ColorPalettePicker(
              selectedHex: style.textColor,
              onSelected: (v) => notifier.setTextColor(wt, v),
            ),
            const SizedBox(height: 24),

            // ── Full styling controls (Prayer / Date / Hijri) ──
            if (widgetType.supportsFullStyling) ...[
              // Background color
              _SectionHeader(title: context.l10n.widgetBgColor),
              const SizedBox(height: 10),
              ColorPalettePicker(
                selectedHex: style.bgColor,
                onSelected: (v) => notifier.setBgColor(wt, v),
              ),
              const SizedBox(height: 24),

              // Background opacity
              _StyledSlider(
                label: context.l10n.widgetBgOpacity,
                value: style.bgOpacity,
                min: 0,
                max: 1,
                divisions: 20,
                displayValue: '${(style.bgOpacity * 100).round()}%',
                onChanged: (v) => notifier.setBgOpacity(wt, v),
              ),
              const SizedBox(height: 20),

              // Corner radius
              _StyledSlider(
                label: context.l10n.widgetCornerRadius,
                value: style.radius,
                min: 10,
                max: 100,
                divisions: 18,
                displayValue: '${style.radius.round()}',
                onChanged: (v) => notifier.setRadius(wt, v),
              ),
              const SizedBox(height: 20),

              // Font size — only Prayer widget uses nameFontSize/timeFontSize.
              // Date & Hijri have hardcoded sizes in Kotlin XML (20sp / 55sp).
              if (widgetType == WidgetType.prayer) ...[
                _StyledSlider(
                  label: context.l10n.widgetFontSize,
                  value: style.fontSize2,
                  min: 10,
                  max: 24,
                  divisions: 14,
                  displayValue: '${style.fontSize2.round()}sp',
                  onChanged: (v) async {
                    await notifier.setFontSize2(wt, v);
                    await notifier.setFontSize1(wt, (v - 2).clamp(8, 22));
                  },
                ),
                const SizedBox(height: 20),
              ],

              const SizedBox(height: 8),

              // Decor image
              _SectionHeader(title: context.l10n.widgetDecorImage),
              const SizedBox(height: 10),
              DecorImagePicker(
                selected: style.decorImage,
                onSelected: (v) => notifier.setDecorImage(wt, v),
                tintColor: Color(int.parse(style.decorColor, radix: 16)),
              ),

              // Decor sub-controls — only when a decor is selected
              if (style.decorImage.isNotEmpty) ...[
                const SizedBox(height: 24),
                _StyledSlider(
                  label: context.l10n.widgetDecorOpacity,
                  value: style.decorOpacity,
                  min: 0,
                  max: 1,
                  divisions: 20,
                  displayValue: '${(style.decorOpacity * 100).round()}%',
                  onChanged: (v) => notifier.setDecorOpacity(wt, v),
                ),
                const SizedBox(height: 20),
                _SectionHeader(title: context.l10n.widgetDecorColor),
                const SizedBox(height: 10),
                ColorPalettePicker(
                  selectedHex: style.decorColor,
                  onSelected: (v) => notifier.setDecorColor(wt, v),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Realistic 3-layer widget preview — matches Android's FrameLayout compositing
// ═══════════════════════════════════════════════════════════════════════════════

class _WidgetPreview extends StatelessWidget {
  const _WidgetPreview({required this.widgetType, required this.style});

  final WidgetType widgetType;
  final WidgetStyleSettings style;

  @override
  Widget build(BuildContext context) {
    final textColor = Color(int.parse(style.textColor, radix: 16));
    final radius = widgetType.supportsFullStyling
        ? style.radius.clamp(5.0, 100.0)
        : 20.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            context.l10n.widgetPreview,
            style: GoogleFonts.tajawal(
              fontSize: 12,
              color: context.colors.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: widgetPreviewHeight(widgetType),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Layer 1: Background color + opacity
                if (widgetType.supportsFullStyling)
                  Opacity(
                    opacity: style.bgOpacity.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(int.parse(style.bgColor, radix: 16)),
                        borderRadius: BorderRadius.circular(radius),
                      ),
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(radius),
                    ),
                  ),

                // Layer 2: Decor overlay (centerCrop)
                if (widgetType.supportsFullStyling &&
                    style.decorImage.isNotEmpty)
                  Opacity(
                    opacity: style.decorOpacity.clamp(0.0, 1.0),
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Color(int.parse(style.decorColor, radix: 16)),
                        BlendMode.srcIn,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(radius),
                        child: Image.asset(
                          'assets/decor/${style.decorImage}.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),

                // Layer 3: Content (shared with Level 1 mini cards)
                buildWidgetContent(
                  type: widgetType,
                  textColor: textColor,
                  style: style,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Shared UI components
// ═══════════════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: GoogleFonts.tajawal(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: context.colors.textSecondary,
        ),
      ),
    );
  }
}

class _StyledSlider extends StatelessWidget {
  const _StyledSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.displayValue,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String displayValue;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: colors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  displayValue,
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: colors.borderSubtle,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.12),
              trackHeight: 3,
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
