import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import 'khatmah_utils.dart';

/// Data class for the khatmah plan creation preview.
class KhatmahPlanPreviewData {
  const KhatmahPlanPreviewData({
    required this.startPage,
    required this.totalPages,
    required this.days,
    required this.dailyPagesLabel,
    required this.estimatedEndDate,
    required this.summaryLine,
  });

  final int startPage;
  final int totalPages;
  final int days;
  final String dailyPagesLabel;
  final DateTime estimatedEndDate;
  final String summaryLine;
}

/// Gradient header card shown at the top of the khatmah plan creation form.
class KhatmahCreatePlanHeader extends StatelessWidget {
  const KhatmahCreatePlanHeader({super.key, required this.preview});

  final KhatmahPlanPreviewData preview;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.20),
            AppColors.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'ابدأ ختمتك بخطة واضحة ومريحة',
                  style: GoogleFonts.tajawal(
                    color: AppColors.textPrimary(context),
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            preview.summaryLine,
            style: GoogleFonts.tajawal(
              color: AppColors.textSecondary(context),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Preview card showing plan metrics before the user confirms creation.
class KhatmahCreatePlanPreviewCard extends StatelessWidget {
  const KhatmahCreatePlanPreviewCard({super.key, required this.preview});

  final KhatmahPlanPreviewData preview;

  @override
  Widget build(BuildContext context) {
    return khatmahCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          khatmahSectionTitle(context, 'معاينة الخطة قبل الإنشاء'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              khatmahMetricChip(
                context,
                title: 'البداية',
                value: 'ص ${khatmahToArabicNumber(preview.startPage)}',
              ),
              khatmahMetricChip(
                context,
                title: 'الإجمالي',
                value: '${khatmahToArabicNumber(preview.totalPages)} صفحة',
              ),
              khatmahMetricChip(
                context,
                title: 'الأيام',
                value: '${khatmahToArabicNumber(preview.days)} يوم',
              ),
              khatmahMetricChip(
                context,
                title: 'ورد يومي',
                value: preview.dailyPagesLabel,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.event_available_rounded,
                size: 18,
                color: AppColors.primary.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'تاريخ إتمام متوقع: ${khatmahFormatDateAr(preview.estimatedEndDate)}',
                  style: GoogleFonts.tajawal(
                    color: AppColors.textSecondary(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
