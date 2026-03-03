import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';

/// First page of the onboarding permissions flow.
/// Shows the app icon, basmala, name, tagline, and a feature highlights list.
class OnboardingPermissionsWelcomePage extends StatelessWidget {
  const OnboardingPermissionsWelcomePage({
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
          const SizedBox(height: 40),

          // App icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.mosque,
              size: 60,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 32),

          Text(
            'بسم الله الرحمن الرحيم',
            style: GoogleFonts.amiriQuran(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
            textDirection: TextDirection.rtl,
          ),

          const SizedBox(height: 16),

          Text(
            'أنا المسلم',
            style: GoogleFonts.tajawal(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'رفيقك في رحلة العبادة اليومية',
            style: GoogleFonts.tajawal(
              fontSize: 18,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.8)
                  : Colors.black.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          _buildFeatureItem(
            icon: Icons.access_time,
            title: 'مواقيت الصلاة الدقيقة',
            subtitle: 'حسب موقعك بدقة عالية',
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            icon: Icons.menu_book,
            title: 'القرآن الكريم كاملاً',
            subtitle: 'مع التفسير والتلاوة والتحفيظ',
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            icon: Icons.explore,
            title: 'اتجاه القبلة',
            subtitle: 'بدقة باستخدام البوصلة الذكية',
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            icon: Icons.auto_awesome,
            title: 'اقتراحات ذكية',
            subtitle: 'تذكير بالأذكار والعبادات في وقتها',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : AppColors.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
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
