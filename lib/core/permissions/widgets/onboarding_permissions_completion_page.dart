import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';

/// Third and final page of the onboarding permissions flow.
/// Confirms the setup is complete and summarises activated features.
class OnboardingPermissionsCompletionPage extends StatelessWidget {
  const OnboardingPermissionsCompletionPage({
    super.key,
    required this.isDark,
  });

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 60),

          // Success icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              size: 60,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 32),

          Text(
            'تم بنجاح! 🎉',
            style: GoogleFonts.tajawal(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'جاهز للبدء في رحلتك الإيمانية',
            style: GoogleFonts.tajawal(
              fontSize: 16,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.black.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 48),

          _buildCompletionItem(
            icon: Icons.notifications_active,
            title: 'الإشعارات مفعّلة',
            subtitle: 'ستصلك تنبيهات الأذان والأذكار',
          ),
          const SizedBox(height: 16),
          _buildCompletionItem(
            icon: Icons.explore,
            title: 'جاهز للاستخدام',
            subtitle: 'يمكنك الآن استخدام جميع الميزات',
          ),
          const SizedBox(height: 16),
          _buildCompletionItem(
            icon: Icons.tips_and_updates,
            title: 'اقتراحات ذكية',
            subtitle: 'سنقترح عليك الأذكار والعبادات في وقتها',
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark
            : AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.6)
                        : Colors.black.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
