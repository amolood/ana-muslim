import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/providers/widget_settings_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../widgets/settings_item_tile.dart';
import '../widgets/settings_selection_sheet.dart';
import '../widgets/widget_content_previews.dart';

class WidgetSettingsScreen extends ConsumerWidget {
  const WidgetSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final numberFormat = ref.watch(widgetNumberFormatProvider);
    final use12h = ref.watch(widgetUse12hProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.l10n.widgetSettingsTitle,
          style: GoogleFonts.tajawal(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)
            .copyWith(bottom: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── General section ──
            _buildSectionTitle(context.l10n.widgetGeneral, context),
            _buildSectionContainer(
              context,
              children: [
                SettingsItemTile(
                  icon: Icons.pin_rounded,
                  title: context.l10n.widgetNumberFormat,
                  trailingText:
                      numberFormat == 'arabic' ? '٠١٢' : '012',
                  onTap: () => showSettingsSelectionSheet(
                    context,
                    context.l10n.widgetNumberFormat,
                    ['arabic', 'english'],
                    numberFormat,
                    (val) async =>
                        ref.read(widgetNumberFormatProvider.notifier).save(val),
                    displayMapper: (val) =>
                        val == 'arabic' ? 'عربي ٠١٢' : 'English 012',
                  ),
                ),
                _buildDivider(context),
                SettingsItemTile(
                  icon: Icons.access_time_rounded,
                  title: context.l10n.widgetTimeFormat,
                  trailingText: use12h ? '12h' : '24h',
                  onTap: () => showSettingsSelectionSheet(
                    context,
                    context.l10n.widgetTimeFormat,
                    ['true', 'false'],
                    use12h ? 'true' : 'false',
                    (val) async => ref
                        .read(widgetUse12hProvider.notifier)
                        .save(val == 'true'),
                    displayMapper: (val) =>
                        val == 'true' ? '١٢ ساعة' : '٢٤ ساعة',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ── Widget cards ──
            _buildSectionTitle(context.l10n.widgetSettingsSubtitle, context),
            const SizedBox(height: 4),
            for (final type in WidgetType.values) ...[
              _WidgetPreviewCard(type: type),
              const SizedBox(height: 14),
            ],
          ],
        ),
      ),
    );
  }

  static Widget _buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
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

  static Widget _buildSectionContainer(
    BuildContext context, {
    required List<Widget> children,
  }) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.borderSubtle, width: 1.5),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(children: children),
    );
  }

  static Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: context.colors.borderSubtle,
      indent: 64,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Widget preview card — shows a mini realistic widget with tap-to-customize
// Uses shared buildWidgetContent() at scale 0.65 to avoid content duplication
// ═══════════════════════════════════════════════════════════════════════════════

class _WidgetPreviewCard extends ConsumerWidget {
  const _WidgetPreviewCard({required this.type});
  final WidgetType type;

  static const _miniScale = 0.65;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final style = ref.watch(widgetStyleProvider(type));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Color(int.parse(style.textColor, radix: 16));
    final radius = type.supportsFullStyling
        ? style.radius.clamp(5.0, 100.0)
        : 20.0;

    return GestureDetector(
      onTap: () => context.push('/settings/widgets/${type.name}'),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.borderSubtle, width: 1.5),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.15),
                          AppColors.primary.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(type.icon, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      type.displayNameAr,
                      style: GoogleFonts.tajawal(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: colors.iconSecondary,
                    size: 14,
                  ),
                ],
              ),
            ),

            // Mini widget preview — uses shared content at reduced scale
            Container(
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              height: widgetPreviewHeight(type, scale: _miniScale),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(radius.clamp(8.0, 30.0)),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Layer 1: Background
                  if (type.supportsFullStyling)
                    Opacity(
                      opacity: style.bgOpacity.clamp(0.0, 1.0),
                      child: Container(
                        color: Color(int.parse(style.bgColor, radix: 16)),
                      ),
                    )
                  else
                    Container(
                      color: Colors.black.withValues(alpha: 0.45),
                    ),

                  // Layer 2: Decor overlay
                  if (type.supportsFullStyling &&
                      style.decorImage.isNotEmpty)
                    Opacity(
                      opacity: style.decorOpacity.clamp(0.0, 1.0),
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          Color(int.parse(style.decorColor, radix: 16)),
                          BlendMode.srcIn,
                        ),
                        child: Image.asset(
                          'assets/decor/${style.decorImage}.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              const SizedBox.shrink(),
                        ),
                      ),
                    ),

                  // Layer 3: Content — same builder, smaller scale
                  buildWidgetContent(
                    type: type,
                    textColor: textColor,
                    style: style,
                    scale: _miniScale,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
