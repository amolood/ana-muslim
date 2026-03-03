import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

/// Onboarding page that explains and requests location permission.
class OnboardingLocationPage extends StatelessWidget {
  const OnboardingLocationPage({
    super.key,
    required this.isDark,
    required this.isGranted,
    required this.isRequesting,
    required this.onRequest,
  });

  final bool isDark;
  final bool isGranted;
  final bool isRequesting;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: isGranted
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : Colors.blue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isGranted ? Icons.check_circle : Icons.location_on,
              size: 50,
              color: isGranted ? AppColors.primary : Colors.blue,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isGranted ? 'تم منح الإذن بنجاح ✓' : 'الموقع الجغرافي',
            style: GoogleFonts.tajawal(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isGranted
                  ? AppColors.primary
                  : (isDark ? Colors.white : AppColors.textPrimaryLight),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isGranted
                    ? AppColors.primary
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.2)),
                width: isGranted ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'لماذا نحتاج موقعك؟',
                        style: GoogleFonts.tajawal(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildReasonRow(
                  '🕌',
                  'حساب أوقات الصلاة الدقيقة',
                  'حسب مدينتك والإحداثيات الجغرافية',
                ),
                const SizedBox(height: 8),
                _buildReasonRow(
                  '🧭',
                  'تحديد اتجاه القبلة',
                  'بدقة عالية باستخدام موقعك الحالي',
                ),
                const SizedBox(height: 8),
                _buildReasonRow(
                  '🔒',
                  'خصوصيتك محفوظة',
                  'لا نشارك موقعك مع أي طرف ثالث',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (!isGranted)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isRequesting ? null : onRequest,
                icon: isRequesting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.location_on, size: 22),
                label: Text(
                  isRequesting ? 'جارٍ الطلب...' : 'منح إذن الموقع',
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildReasonRow(String emoji, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: GoogleFonts.tajawal(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
