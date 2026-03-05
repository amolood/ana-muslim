import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/utils/arabic_utils.dart';
import '../../data/asma_local_data.dart';
import '../../data/models/asma_name.dart';
import '../providers/asma_provider.dart';

const _gold = AppColors.accentAsma;

class AsmaDetailScreen extends ConsumerWidget {
  const AsmaDetailScreen({super.key, required this.name});
  final AsmaName name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFav = ref.watch(
      asmaFavoritesProvider.select((s) => s.contains(name.number)),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, ref, isDark, isFav),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
              child: Column(
                children: [
                  const SizedBox(height: 28),
                  // ── Number badge ──────────────────────────────────
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          _gold.withValues(alpha: 0.30),
                          _gold.withValues(alpha: 0.06),
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _gold.withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _gold.withValues(alpha: 0.15),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        ArabicUtils.toArabicDigits(name.number),
                        style: GoogleFonts.tajawal(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: _gold,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // ── Arabic name ───────────────────────────────────
                  Text(
                    name.arabic,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.tajawal(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: colors.textPrimary,
                      height: 1.4,
                      shadows: isDark
                          ? [
                              Shadow(
                                color: _gold.withValues(alpha: 0.25),
                                blurRadius: 12,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // ── Transliteration ───────────────────────────────
                  Text(
                    name.transliteration,
                    style: GoogleFonts.tajawal(
                      fontSize: 16,
                      color: _gold,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  // ── Arabic meaning ────────────────────────────────
                  _InfoCard(
                    label: 'المعنى',
                    content: name.meaningAr,
                    colors: colors,
                    isDark: isDark,
                    icon: Icons.auto_stories_outlined,
                  ),
                  const SizedBox(height: 14),
                  // ── English meaning ───────────────────────────────
                  _InfoCard(
                    label: 'The Meaning',
                    content: name.meaningEn,
                    colors: colors,
                    isDark: isDark,
                    icon: Icons.translate_rounded,
                    isRtl: false,
                  ),
                  const SizedBox(height: 28),
                  // ── Navigation buttons ────────────────────────────
                  _NavigationRow(current: name),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    bool isFav,
  ) {
    return SliverAppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: context.colors.textPrimary,
          size: 20,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        name.arabic,
        style: GoogleFonts.tajawal(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: context.colors.textPrimary,
        ),
      ),
      centerTitle: true,
      actions: [
        // Favorite
        IconButton(
          tooltip: isFav ? 'إزالة من المفضلة' : 'إضافة للمفضلة',
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              key: ValueKey(isFav),
              color: isFav ? Colors.redAccent : context.colors.iconSecondary,
            ),
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            ref.read(asmaFavoritesProvider.notifier).toggle(name.number);
          },
        ),
        // Share
        IconButton(
          tooltip: 'مشاركة',
          icon: Icon(Icons.share_rounded, color: context.colors.iconSecondary),
          onPressed: () => _share(),
        ),
      ],
    );
  }

  void _share() {
    final text =
        '${name.arabic} — ${name.transliteration}\n\n${name.meaningAr}\n\n"${name.meaningEn}"\n\n— من أسماء الله الحسنى (#${name.number})';
    SharePlus.instance.share(ShareParams(text: text));
  }
}

// ── Info card ─────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.label,
    required this.content,
    required this.colors,
    required this.isDark,
    required this.icon,
    this.isRtl = true,
  });

  final String label;
  final String content;
  final AppSemanticColors colors;
  final bool isDark;
  final IconData icon;
  final bool isRtl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _gold.withValues(alpha: 0.18)),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: _gold.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: _gold, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.tajawal(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Directionality(
            textDirection:
                isRtl ? TextDirection.rtl : TextDirection.ltr,
            child: Text(
              content,
              style: GoogleFonts.tajawal(
                fontSize: 16,
                color: colors.textPrimary,
                height: 1.75,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Prev / Next navigation ────────────────────────────────────────────────

class _NavigationRow extends StatelessWidget {
  const _NavigationRow({required this.current});
  final AsmaName current;

  @override
  Widget build(BuildContext context) {
    final hasPrev = current.number > 1;
    final hasNext = current.number < 99;
    final prev = hasPrev ? kAsmaAlHusna[current.number - 2] : null;
    final next = hasNext ? kAsmaAlHusna[current.number] : null;
    final colors = context.colors;

    return Row(
      children: [
        // Previous
        Expanded(
          child: hasPrev
              ? _NavButton(
                  label: prev!.arabic,
                  sublabel: 'السابق',
                  onTap: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (_) => AsmaDetailScreen(name: prev),
                    ),
                  ),
                  icon: Icons.arrow_forward_ios_rounded,
                  colors: colors,
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(width: 10),
        // Next
        Expanded(
          child: hasNext
              ? _NavButton(
                  label: next!.arabic,
                  sublabel: 'التالي',
                  onTap: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (_) => AsmaDetailScreen(name: next),
                    ),
                  ),
                  icon: Icons.arrow_back_ios_new_rounded,
                  colors: colors,
                  reverse: true,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.label,
    required this.sublabel,
    required this.onTap,
    required this.icon,
    required this.colors,
    this.reverse = false,
  });

  final String label;
  final String sublabel;
  final VoidCallback onTap;
  final IconData icon;
  final AppSemanticColors colors;
  final bool reverse;

  @override
  Widget build(BuildContext context) {
    final content = [
      Icon(icon, size: 14, color: _gold),
      const SizedBox(width: 6),
      Expanded(
        child: Column(
          crossAxisAlignment:
              reverse ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Text(
              sublabel,
              style: GoogleFonts.tajawal(
                fontSize: 10,
                color: colors.textSecondary,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.tajawal(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    ];

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: colors.surfaceCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _gold.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: reverse ? content.reversed.toList() : content,
          ),
        ),
      ),
    );
  }
}
