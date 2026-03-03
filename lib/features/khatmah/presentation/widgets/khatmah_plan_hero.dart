import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/khatmah_controller.dart';
import 'khatmah_utils.dart';

/// Hero card at the top of the active plan view — shows plan type, page range,
/// overall progress bar, and key metrics (completed, remaining, streak, tasks).
class KhatmahPlanHero extends StatelessWidget {
  const KhatmahPlanHero({super.key, required this.viewState});

  final KhatmahViewState viewState;

  @override
  Widget build(BuildContext context) {
    final plan = viewState.plan!;
    final progressPercent = (viewState.progress * 100).toStringAsFixed(1);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.2),
            AppColors.primary.withValues(alpha: 0.03),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  khatmahPlanTypeLabel(plan.type),
                  style: GoogleFonts.tajawal(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.border(context)),
                ),
                child: Text(
                  '${khatmahToArabicNumberString(progressPercent)}%',
                  style: GoogleFonts.manrope(
                    color: AppColors.textPrimary(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'من صفحة ${khatmahToArabicNumber(plan.startPage)} إلى ${khatmahToArabicNumber(plan.endPage)}',
            style: GoogleFonts.tajawal(
              color: AppColors.textPrimary(context),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 9,
              value: viewState.progress,
              backgroundColor: AppColors.surface(context),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              khatmahMetricChip(
                context,
                title: 'المنجز',
                value:
                    '${khatmahToArabicNumber(viewState.completedPages)} / ${khatmahToArabicNumber(viewState.totalPages)}',
              ),
              khatmahMetricChip(
                context,
                title: 'المتبقي',
                value: '${khatmahToArabicNumber(viewState.remainingPages)} صفحة',
              ),
              khatmahMetricChip(
                context,
                title: 'سلسلة الالتزام',
                value: '${khatmahToArabicNumber(viewState.currentStreakDays)} يوم',
              ),
              khatmahMetricChip(
                context,
                title: 'المهام المكتملة',
                value:
                    '${khatmahToArabicNumber(viewState.completedTasksCount)} / ${khatmahToArabicNumber(viewState.totalTasksCount)}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
