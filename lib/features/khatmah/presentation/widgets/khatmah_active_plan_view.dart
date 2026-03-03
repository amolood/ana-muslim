import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/services/quran_service.dart';
import '../../../../core/theme/app_colors.dart';

import '../providers/khatmah_controller.dart';
import 'khatmah_plan_actions_card.dart';
import 'khatmah_plan_hero.dart';
import 'khatmah_timeline_card.dart';
import 'khatmah_utils.dart';

/// واجهة الختمة النشطة — تعرض التقدم والورد اليومي والجدول والإعدادات
class KhatmahActivePlanView extends ConsumerWidget {
  final KhatmahViewState viewState;

  const KhatmahActivePlanView({super.key, required this.viewState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KhatmahPlanHero(viewState: viewState),
          const SizedBox(height: 12),
          _buildTodayWirdCard(context, ref),
          if (viewState.missedTasksCount > 0) ...[
            const SizedBox(height: 12),
            _buildMissedWirdCard(context),
          ],
          const SizedBox(height: 12),
          KhatmahTimelineCard(viewState: viewState),
          const SizedBox(height: 12),
          KhatmahPlanActionsCard(viewState: viewState),
        ],
      ),
    );
  }

  Widget _buildTodayWirdCard(BuildContext context, WidgetRef ref) {
    final hasTodayRange = viewState.todayFromPage > 0;
    final fromPage = viewState.todayFromPage;
    final toPage = viewState.todayToPage;
    final totalTodayPages = hasTodayRange
        ? (toPage - fromPage + 1).clamp(0, 604)
        : 0;

    String surahRange = '';
    if (hasTodayRange) {
      final fromSurah = QuranService.getSurahNameArabicNormalized(
        QuranService.getSurahNumberFromPage(fromPage),
      );
      final toSurah = QuranService.getSurahNameArabicNormalized(
        QuranService.getSurahNumberFromPage(toPage),
      );
      surahRange =
          fromSurah == toSurah ? fromSurah : '$fromSurah - $toSurah';
    }

    final statusText = !hasTodayRange
        ? 'لا يوجد ورد محدد لليوم'
        : viewState.isTodayCompleted
        ? 'أحسنت، ورد اليوم مكتمل'
        : viewState.remainingPagesToday <= 0
        ? 'أنجزت الورد بالكامل'
        : viewState.completedPagesToday == 0
        ? 'ابدأ الآن بخطوة بسيطة'
        : 'اقتربت من الإكمال';

    final statusColor = viewState.isTodayCompleted
        ? Colors.green
        : viewState.completedPagesToday > 0
        ? AppColors.primary
        : AppColors.textSecondary(context);

    return khatmahCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              khatmahSectionTitle(context, 'ورد اليوم'),
              const Spacer(),
              if (viewState.daysRemaining != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated(context),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.border(context)),
                  ),
                  child: Text(
                    'متبقي ${khatmahToArabicNumber(viewState.daysRemaining!)} يوم',
                    style: GoogleFonts.tajawal(
                      color: AppColors.textSecondary(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (hasTodayRange) ...[
            Text(
              'من صفحة ${khatmahToArabicNumber(fromPage)} إلى ${khatmahToArabicNumber(toPage)}',
              style: GoogleFonts.tajawal(
                color: AppColors.textPrimary(context),
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              surahRange,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.notoNaskhArabic(
                color: AppColors.textSecondary(context),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: viewState.todayProgress,
                backgroundColor: AppColors.surfaceElevated(context),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                khatmahMetricChip(
                  context,
                  title: 'منجز اليوم',
                  value:
                      '${khatmahToArabicNumber(viewState.completedPagesToday)} / ${khatmahToArabicNumber(totalTodayPages)}',
                ),
                khatmahMetricChip(
                  context,
                  title: 'متبقي اليوم',
                  value:
                      '${khatmahToArabicNumber(viewState.remainingPagesToday)} صفحة',
                ),
              ],
            ),
          ] else
            Text(
              viewState.nextPendingTask == null
                  ? 'لا يوجد ورد متاح حاليًا. قد تكون الخطة بدأت في تاريخ لاحق.'
                  : 'الورد القادم يبدأ في ${khatmahFormatDateAr(viewState.nextPendingTask!.date)} من الصفحة ${khatmahToArabicNumber(viewState.nextPendingTask!.fromPage)}.',
              style: GoogleFonts.tajawal(
                color: AppColors.textSecondary(context),
                fontSize: 13,
                height: 1.6,
              ),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.circle, size: 9, color: statusColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  statusText,
                  style: GoogleFonts.tajawal(
                    color: statusColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: hasTodayRange
                      ? () => _openPageStart(context, fromPage)
                      : viewState.nextPendingTask == null
                      ? null
                      : () => _openPageStart(
                            context,
                            viewState.nextPendingTask!.fromPage,
                          ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.backgroundDark,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(
                    hasTodayRange ? 'ابدأ ورد اليوم' : 'ابدأ الورد القادم',
                    style: GoogleFonts.tajawal(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: hasTodayRange
                      ? () => _markTodayCompleted(context, ref)
                      : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary(context),
                    side: BorderSide(color: AppColors.border(context)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: Text(
                    viewState.missedTasksCount > 0
                        ? 'إكمال اليوم + الفائت'
                        : 'إكمال يدوي',
                    style: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMissedWirdCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'لديك ورد فائت: ${khatmahToArabicNumber(viewState.missedTasksCount)} يوم (${khatmahToArabicNumber(viewState.missedPagesCount)} صفحة).',
              style: GoogleFonts.tajawal(
                color: AppColors.textPrimary(context),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Navigation / actions ────────────────────────────────────────────────

  Future<void> _openPageStart(BuildContext context, int page) async {
    final safePage = khatmahClampPage(page);
    final surah = QuranService.getSurahNumberFromPage(safePage);
    if (!context.mounted) return;
    context.push(Routes.quranReader(surah, page: safePage));
  }

  Future<void> _markTodayCompleted(BuildContext context, WidgetRef ref) async {
    final changed = await ref
        .read(khatmahControllerProvider.notifier)
        .markTodayCompletedManual();
    if (!context.mounted) return;
    khatmahShowSnack(
      context,
      changed
          ? 'تم تعليم ورد اليوم كمكتمل'
          : 'لا يوجد ورد اليوم لإكماله',
    );
  }
}
