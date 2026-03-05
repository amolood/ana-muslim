import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';

/// شبكة الوصول السريع إلى جميع أقسام التطبيق
class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  static final List<_QuickActionItem> _actions = [
    _QuickActionItem(
      icon: FlutterIslamicIcons.solidQuran,
      label: 'القرآن',
      subtitle: 'قراءة وورد',
      route: Routes.quran,
      accentColor: AppColors.accentQuran,
    ),
    _QuickActionItem(
      icon: FlutterIslamicIcons.prayer,
      label: 'المواقيت',
      subtitle: 'الصلوات اليوم',
      route: Routes.prayerTimes,
      accentColor: AppColors.accentPrayer,
    ),
    _QuickActionItem(
      icon: FlutterIslamicIcons.allah99,
      label: 'الأذكار',
      subtitle: 'أذكار يومية',
      route: Routes.azkar,
      accentColor: AppColors.accentAzkar,
    ),
    _QuickActionItem(
      icon: FlutterIslamicIcons.solidSajadah,
      label: 'السبحة',
      subtitle: 'عدّ الذكر',
      route: Routes.sebha,
      accentColor: AppColors.accentSebha,
    ),
    _QuickActionItem(
      icon: FlutterIslamicIcons.qibla,
      label: 'القبلة',
      subtitle: 'اتجاه القبلة',
      route: Routes.qibla,
      accentColor: AppColors.qiblaGreen,
    ),
    _QuickActionItem(
      icon: FlutterIslamicIcons.mohammad,
      label: 'الحديث',
      subtitle: 'صحيحان وسنة',
      route: Routes.hadith,
      accentColor: AppColors.accentHadith,
    ),
    _QuickActionItem(
      icon: FlutterIslamicIcons.islam,
      label: 'المحتوى',
      subtitle: 'مكتبة مميزة',
      route: Routes.islamicContent,
      accentColor: AppColors.accentContent,
    ),
    _QuickActionItem(
      icon: Icons.menu_book_rounded,
      label: 'التحفيظ',
      subtitle: 'حفظ القرآن',
      route: Routes.quranTahfeez,
      accentColor: AppColors.accentTahfeez,
    ),
    _QuickActionItem(
      icon: Icons.nightlight_round,
      label: 'رمضان',
      subtitle: 'سحور وإفطار',
      route: Routes.ramadan,
      accentColor: AppColors.primary,
    ),
    _QuickActionItem(
      icon: Icons.auto_awesome_rounded,
      label: 'أسماء الله',
      subtitle: '٩٩ اسماً حسنى',
      route: Routes.asmaUlHusna,
      accentColor: AppColors.accentAsma,
    ),
    _QuickActionItem(
      icon: Icons.calendar_month_rounded,
      label: 'التقويم',
      subtitle: 'التاريخ الهجري',
      route: Routes.hijriCalendar,
      accentColor: AppColors.accentCalendar,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.apps_rounded,
                    color: AppColors.primary,
                    size: 17,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'جميع الأقسام',
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _actions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              mainAxisExtent: 90,
            ),
            itemBuilder: (context, index) =>
                _buildActionItem(context, colors, _actions[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context,
    AppSemanticColors colors,
    _QuickActionItem action,
  ) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push(action.route),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: colors.surfaceCard,
            border: Border.all(
              color: action.accentColor.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: action.accentColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(action.icon, color: action.accentColor, size: 22),
              ),
              const SizedBox(height: 6),
              Text(
                action.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.tajawal(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                  height: 1.2,
                ),
              ),
              Text(
                action.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.tajawal(
                  fontSize: 9.5,
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionItem {
  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.route,
    required this.accentColor,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final String route;
  final Color accentColor;
}
