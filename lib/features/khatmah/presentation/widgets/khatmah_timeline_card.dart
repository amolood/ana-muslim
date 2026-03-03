import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/services/quran_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/khatmah_daily_task.dart';
import '../providers/khatmah_controller.dart';
import 'khatmah_utils.dart';

/// Card listing the nearest past and upcoming daily tasks (up to 5 past + 3 future).
/// Each row taps directly into the Quran reader at the task's start page.
class KhatmahTimelineCard extends ConsumerWidget {
  const KhatmahTimelineCard({super.key, required this.viewState});

  final KhatmahViewState viewState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = khatmahVisibleTimelineTasks(
      viewState.tasks,
      viewState.debugDate,
    );

    return khatmahCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          khatmahSectionTitle(context, 'الجدول اليومي'),
          const SizedBox(height: 8),
          if (tasks.isEmpty)
            Text(
              'لا توجد مهام لعرضها حالياً.',
              style: GoogleFonts.tajawal(
                color: AppColors.textSecondary(context),
                fontSize: 13,
              ),
            )
          else
            ...tasks.map(
              (task) => _buildTaskTile(
                context,
                ref,
                task,
                viewState.debugDate,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTaskTile(
    BuildContext context,
    WidgetRef ref,
    KhatmahDailyTask task,
    DateTime today,
  ) {
    final taskDate = DateTime(task.date.year, task.date.month, task.date.day);
    final isToday = taskDate == today;
    final isPast = taskDate.isBefore(today);

    final statusText = task.completed
        ? 'مكتمل'
        : isToday
        ? 'ورد اليوم'
        : isPast
        ? 'فاتك هذا الورد'
        : 'قادم';

    final statusColor = task.completed
        ? Colors.green
        : isPast
        ? Colors.orange
        : AppColors.textSecondary(context);

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isToday
              ? AppColors.primary.withValues(alpha: 0.5)
              : AppColors.border(context),
        ),
      ),
      child: ListTile(
        onTap: () => _openPageStart(context, task.fromPage),
        leading: CircleAvatar(
          radius: 17,
          backgroundColor: AppColors.primary.withValues(alpha: 0.16),
          child: Text(
            khatmahToArabicNumber(task.dayIndex),
            style: GoogleFonts.manrope(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        title: Text(
          'من ${khatmahToArabicNumber(task.fromPage)} إلى ${khatmahToArabicNumber(task.toPage)}',
          style: GoogleFonts.tajawal(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          '${khatmahFormatDateAr(taskDate)} • $statusText',
          style: GoogleFonts.tajawal(
            color: statusColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: task.completed
            ? const Icon(Icons.check_circle_rounded, color: Colors.green)
            : isPast || isToday
            ? TextButton(
                onPressed: () => _markTaskDone(context, ref, task),
                child: Text(
                  'إنجاز',
                  style: GoogleFonts.tajawal(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              )
            : Icon(
                Icons.schedule_rounded,
                color: AppColors.textSecondary(context),
              ),
      ),
    );
  }

  Future<void> _openPageStart(BuildContext context, int page) async {
    final safePage = khatmahClampPage(page);
    final surah = QuranService.getSurahNumberFromPage(safePage);
    if (!context.mounted) return;
    context.push(Routes.quranReader(surah, page: safePage));
  }

  Future<void> _markTaskDone(
    BuildContext context,
    WidgetRef ref,
    KhatmahDailyTask task,
  ) async {
    final changed = await ref
        .read(khatmahControllerProvider.notifier)
        .markTaskCompletedById(task.id);
    if (!context.mounted) return;
    khatmahShowSnack(
      context,
      changed ? 'تم تعليم الورد كمكتمل' : 'تعذر تحديث حالة هذا الورد',
    );
  }
}
