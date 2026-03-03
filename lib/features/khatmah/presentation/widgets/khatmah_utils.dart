import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/khatmah_daily_task.dart';
import '../../domain/models/khatmah_enums.dart';

// ─── Number / date helpers ─────────────────────────────────────────────────

String khatmahToArabicNumber(int number) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  var numStr = number.toString();
  for (var i = 0; i < english.length; i++) {
    numStr = numStr.replaceAll(english[i], arabic[i]);
  }
  return numStr;
}

String khatmahToArabicNumberString(String text) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  var out = text;
  for (var i = 0; i < english.length; i++) {
    out = out.replaceAll(english[i], arabic[i]);
  }
  return out;
}

String khatmahFormatDateAr(DateTime date) {
  return '${khatmahToArabicNumber(date.day)}/${khatmahToArabicNumber(date.month)}/${khatmahToArabicNumber(date.year)}';
}

String khatmahFormatTime(int hour, int minute) {
  final h = hour.toString().padLeft(2, '0');
  final m = minute.toString().padLeft(2, '0');
  return '${khatmahToArabicNumberString(h)}:${khatmahToArabicNumberString(m)}';
}

String khatmahPlanTypeLabel(KhatmahPlanType type) {
  return switch (type) {
    KhatmahPlanType.fixedDays => 'خطة بعدد أيام محدد',
    KhatmahPlanType.open => 'خطة مفتوحة',
    KhatmahPlanType.ramadanPreset => 'ختمة رمضان',
  };
}

int khatmahClampPage(int value) => value.clamp(1, 604).toInt();

List<KhatmahDailyTask> khatmahVisibleTimelineTasks(
  List<KhatmahDailyTask> all,
  DateTime today,
) {
  if (all.isEmpty) return const [];
  final dateOnlyToday = DateUtils.dateOnly(today);

  final pastAndToday = all
      .where(
        (task) => !DateUtils.dateOnly(task.date).isAfter(dateOnlyToday),
      )
      .toList()
    ..sort((a, b) => b.dayIndex.compareTo(a.dayIndex));

  final future = all
      .where(
        (task) => DateUtils.dateOnly(task.date).isAfter(dateOnlyToday),
      )
      .toList()
    ..sort((a, b) => a.dayIndex.compareTo(b.dayIndex));

  final selected = <KhatmahDailyTask>[
    ...pastAndToday.take(5),
    ...future.take(3),
  ]..sort((a, b) => a.dayIndex.compareTo(b.dayIndex));

  return selected;
}

// ─── Shared widget builders ────────────────────────────────────────────────

Widget khatmahCard(BuildContext context, {required Widget child}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surface(context),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border(context)),
    ),
    child: child,
  );
}

Widget khatmahSectionTitle(BuildContext context, String title) {
  return Text(
    title,
    style: GoogleFonts.tajawal(
      color: AppColors.textPrimary(context),
      fontSize: 17,
      fontWeight: FontWeight.w800,
    ),
  );
}

Widget khatmahMetricChip(
  BuildContext context, {
  required String title,
  required String value,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: AppColors.surfaceElevated(context),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border(context)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: GoogleFonts.tajawal(
            color: AppColors.textSecondary(context),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.tajawal(
            color: AppColors.textPrimary(context),
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

void khatmahShowSnack(BuildContext context, String text) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        text,
        style: GoogleFonts.tajawal(),
        textDirection: TextDirection.rtl,
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
