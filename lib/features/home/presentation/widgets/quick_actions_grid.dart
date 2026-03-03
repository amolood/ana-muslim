import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_colors.dart';

/// شبكة الوصول السريع إلى الأقسام الرئيسية
class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  static const List<_QuickActionItem> _actions = [
    _QuickActionItem(
      icon: FlutterIslamicIcons.solidQuran,
      label: 'القرآن',
      subtitle: 'قراءة وورد',
      route: Routes.quran,
      accentColor: Color(0xFF2F9D95),
    ),
    _QuickActionItem(
      icon: FlutterIslamicIcons.prayer,
      label: 'المواقيت',
      subtitle: 'الصلوات اليوم',
      route: Routes.prayerTimes,
      accentColor: Color(0xFFC4873E),
    ),
    _QuickActionItem(
      icon: FlutterIslamicIcons.allah99,
      label: 'الأذكار',
      subtitle: 'أذكار يومية',
      route: Routes.azkar,
      accentColor: Color(0xFF8B8CF2),
    ),
    _QuickActionItem(
      icon: FlutterIslamicIcons.solidSajadah,
      label: 'السبحة',
      subtitle: 'عدّ الذكر',
      route: Routes.sebha,
      accentColor: Color(0xFF5DB86F),
    ),
    _QuickActionItem(
      icon: FlutterIslamicIcons.islam,
      label: 'المحتوى',
      subtitle: 'مكتبة مميزة',
      route: Routes.islamicContent,
      accentColor: Color(0xFF3E78B2),
    ),
    _QuickActionItem(
      icon: Icons.dark_mode_rounded,
      label: 'رمضان',
      subtitle: 'سحور وإفطار',
      route: Routes.ramadan,
      accentColor: Color(0xFF10B981),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border(context)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.grid_view_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'الوصول السريع',
                    style: GoogleFonts.tajawal(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                ),
                Text(
                  'اختر القسم',
                  style: GoogleFonts.tajawal(
                    fontSize: 11,
                    color: AppColors.textSecondary(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _actions.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                mainAxisExtent: 75,
              ),
              itemBuilder: (context, index) =>
                  _buildActionItem(context, _actions[index]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, _QuickActionItem action) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.push(action.route),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: action.accentColor.withValues(alpha: 0.35),
          ),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              action.accentColor.withValues(alpha: 0.2),
              AppColors.surfaceElevated(context),
            ],
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: action.accentColor.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(action.icon, color: action.accentColor, size: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary(context),
                      height: 1.2,
                    ),
                  ),
                  Text(
                    action.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.tajawal(
                      fontSize: 10,
                      color: AppColors.textSecondary(context),
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
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
