import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../providers/bookmark_provider.dart';

class QuranFeatureCards extends ConsumerWidget {
  const QuranFeatureCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bookmarks = ref.watch(coloredBookmarksProvider);
    final bookmarkCount = bookmarks.values.expand((list) => list).length;

    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Search Card
          SizedBox(
            width: 160,
            child: _FeatureCard(
              icon: Icons.search,
              title: 'البحث',
              subtitle: 'في القرآن',
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF1A4D3A), const Color(0xFF0F2E22)]
                    : [const Color(0xFFE8F5F1), const Color(0xFFD1EDE5)],
              ),
              shadowColor: AppColors.primary,
              iconColor: AppColors.primary,
              onTap: () => context.push(Routes.quranSearch),
            ),
          ),

          const SizedBox(width: 12),

          // Bookmarks Card
          SizedBox(
            width: 130,
            child: _FeatureCard(
              icon: Icons.bookmark,
              title: 'العلامات',
              subtitle: '$bookmarkCount',
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF4D3A1A), const Color(0xFF2E220F)]
                    : [const Color(0xFFFFF9E6), const Color(0xFFFFF0CC)],
              ),
              shadowColor: AppColors.surahGold,
              iconColor: AppColors.surahGold,
              onTap: () => context.push(Routes.quranBookmarks),
              badge: bookmarkCount > 0 ? bookmarkCount : null,
            ),
          ),

          const SizedBox(width: 12),

          // Tahfeez Card
          SizedBox(
            width: 160,
            child: _FeatureCard(
              icon: Icons.school_outlined,
              title: 'التحفيظ',
              subtitle: 'احفظ القرآن',
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF3A1A4D), const Color(0xFF220F2E)]
                    : [const Color(0xFFF0E6FF), const Color(0xFFE0CCFF)],
              ),
              shadowColor: const Color(0xFF9C27B0),
              iconColor: const Color(0xFF9C27B0),
              onTap: () => context.push(Routes.quranTahfeez),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.iconColor,
    required this.shadowColor,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final Color iconColor;
  final Color shadowColor;
  final VoidCallback onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.borderSubtle),
            boxShadow: [
              BoxShadow(
                color: shadowColor.withValues(alpha: 0.18),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: shadowColor.withValues(alpha: 0.08),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: GoogleFonts.tajawal(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.tajawal(
                      fontSize: 11,
                      color: colors.textSecondary,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
              if (badge != null)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge.toString(),
                      style: GoogleFonts.tajawal(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
