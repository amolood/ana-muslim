import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/khatmah_enums.dart';
import '../providers/khatmah_controller.dart';
import 'khatmah_utils.dart';

/// Settings / actions card at the bottom of the active plan view.
///
/// Contains: edit plan duration, configure daily reminder, carry-missed-wird
/// toggle, and cancel plan. Each action opens a modal sheet or dialog.
class KhatmahPlanActionsCard extends ConsumerWidget {
  const KhatmahPlanActionsCard({super.key, required this.viewState});

  final KhatmahViewState viewState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = viewState.plan!;
    final errorColor = Theme.of(context).colorScheme.error;

    return khatmahCard(
      context,
      child: Column(
        children: [
          _actionTile(
            context,
            icon: Icons.edit_calendar_rounded,
            title: 'تعديل مدة الخطة من الموضع الحالي',
            subtitle: 'إعادة تقسيم الورد على أيام جديدة',
            onTap: () => _showDurationEditor(context, ref),
          ),
          const Divider(height: 16),
          _actionTile(
            context,
            icon: Icons.notifications_active_rounded,
            title: 'إعداد تذكير الختمة',
            subtitle: plan.dailyReminderEnabled
                ? 'مفعّل عند ${khatmahFormatTime(plan.reminderHour, plan.reminderMinute)}'
                : 'غير مفعّل',
            onTap: () => _showReminderEditor(context, ref),
          ),
          const Divider(height: 16),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            activeThumbColor: AppColors.primary,
            value: plan.carryMissedWird,
            title: Text(
              'حمل ورد الأيام الفائتة',
              style: GoogleFonts.tajawal(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              'يجمع الورد الفائت مع ورد اليوم تلقائيًا',
              style: GoogleFonts.tajawal(
                color: AppColors.textSecondary(context),
                fontSize: 12,
              ),
            ),
            onChanged: (value) async {
              await ref
                  .read(khatmahControllerProvider.notifier)
                  .updateCarryMissedWird(value);
              if (!context.mounted) return;
              khatmahShowSnack(context, 'تم تحديث إعداد حمل الورد الفائت');
            },
          ),
          const Divider(height: 16),
          _actionTile(
            context,
            icon: Icons.delete_outline_rounded,
            iconColor: errorColor,
            title: 'إلغاء الخطة الحالية',
            subtitle: 'سيتم حذف الخطة ومهامها اليومية',
            titleColor: errorColor,
            onTap: () => _confirmClearPlan(context, ref),
          ),
          if (viewState.plan?.status == KhatmahPlanStatus.completed) ...[
            const SizedBox(height: 8),
            Text(
              'مبارك! تم إكمال الختمة الحالية.',
              style: GoogleFonts.tajawal(
                color: Colors.green,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Sheet / dialog builders ────────────────────────────────────────────

  Future<void> _showDurationEditor(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController(text: '30');
    var selected = 30;

    final result = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setSheetState) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تعديل مدة الخطة',
                style: GoogleFonts.tajawal(
                  color: AppColors.textPrimary(context),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'سيتم إعادة التقسيم من الموضع الحالي في الختمة.',
                style: GoogleFonts.tajawal(
                  color: AppColors.textSecondary(context),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _durationChip(
                    context,
                    selected: selected == 7,
                    label: '٧ أيام',
                    onTap: () {
                      setSheetState(() {
                        selected = 7;
                        ctrl.text = '7';
                      });
                    },
                  ),
                  _durationChip(
                    context,
                    selected: selected == 15,
                    label: '١٥ يوم',
                    onTap: () {
                      setSheetState(() {
                        selected = 15;
                        ctrl.text = '15';
                      });
                    },
                  ),
                  _durationChip(
                    context,
                    selected: selected == 30,
                    label: '٣٠ يوم',
                    onTap: () {
                      setSheetState(() {
                        selected = 30;
                        ctrl.text = '30';
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                style: GoogleFonts.tajawal(
                  color: AppColors.textPrimary(context),
                ),
                decoration: InputDecoration(
                  hintText: 'أدخل عدد الأيام',
                  hintStyle: GoogleFonts.tajawal(
                    color: AppColors.textSecondary(context),
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceElevated(context),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border(context)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
                onChanged: (_) {
                  setSheetState(() {
                    selected = int.tryParse(ctrl.text.trim()) ?? -1;
                  });
                },
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx2).pop(int.tryParse(ctrl.text.trim()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                  ),
                  child: Text(
                    'تطبيق',
                    style: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    ctrl.dispose();
    if (result == null) return;
    if (result < 1) {
      if (!context.mounted) return;
      khatmahShowSnack(context, 'الرجاء إدخال عدد أيام صحيح');
      return;
    }
    await ref
        .read(khatmahControllerProvider.notifier)
        .updateDurationFromCurrent(result);
    if (!context.mounted) return;
    khatmahShowSnack(context, 'تم تحديث مدة الخطة');
  }

  Future<void> _showReminderEditor(BuildContext context, WidgetRef ref) async {
    final plan = ref.read(khatmahControllerProvider).asData?.value.plan;
    if (plan == null) return;

    var enabled = plan.dailyReminderEnabled;
    var selectedTime = TimeOfDay(
      hour: plan.reminderHour,
      minute: plan.reminderMinute,
    );

    final shouldSave = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setSheetState) => Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تحديث تذكير الختمة',
                  style: GoogleFonts.tajawal(
                    color: AppColors.textPrimary(context),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile.adaptive(
                  value: enabled,
                  activeThumbColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (next) {
                    setSheetState(() => enabled = next);
                  },
                  title: Text(
                    'تفعيل التذكير اليومي',
                    style: GoogleFonts.tajawal(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                      helpText: 'اختر وقت تذكير الختمة',
                    );
                    if (picked == null) return;
                    setSheetState(() => selectedTime = picked);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border(context)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'الوقت: ${selectedTime.format(context)}',
                                style: GoogleFonts.tajawal(
                                  color: AppColors.textPrimary(context),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'اختر الوقت الأنسب لوردك اليومي',
                                style: GoogleFonts.tajawal(
                                  color: AppColors.textSecondary(context),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_left_rounded,
                          color: AppColors.textSecondary(context),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx2).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                    ),
                    child: Text(
                      'حفظ',
                      style: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (shouldSave != true) return;

    await ref.read(khatmahControllerProvider.notifier).updateReminder(
          enabled: enabled,
          hour: selectedTime.hour,
          minute: selectedTime.minute,
        );
    if (!context.mounted) return;
    khatmahShowSnack(context, 'تم تحديث تذكير الختمة');
  }

  Future<void> _confirmClearPlan(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.surface(context),
          title: Text(
            'إلغاء خطة الختمة',
            style: GoogleFonts.tajawal(
              color: AppColors.textPrimary(context),
            ),
          ),
          content: Text(
            'سيتم حذف خطة الختمة الحالية ومهامها اليومية.',
            style: GoogleFonts.tajawal(
              color: AppColors.textSecondary(context),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(
                'تراجع',
                style: GoogleFonts.tajawal(
                  color: AppColors.textSecondary(context),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(
                'إلغاء الخطة',
                style: GoogleFonts.tajawal(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) return;
    await ref.read(khatmahControllerProvider.notifier).clearPlan();
    if (!context.mounted) return;
    khatmahShowSnack(context, 'تم إلغاء خطة الختمة');
  }

  // ─── Primitive builders ────────────────────────────────────────────────

  Widget _actionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Icon(icon, color: iconColor ?? AppColors.textPrimary(context)),
      title: Text(
        title,
        style: GoogleFonts.tajawal(
          color: titleColor ?? AppColors.textPrimary(context),
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.tajawal(
          color: AppColors.textSecondary(context),
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.chevron_left_rounded,
        color: AppColors.textSecondary(context),
      ),
    );
  }

  Widget _durationChip(
    BuildContext context, {
    required bool selected,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceElevated(context),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border(context),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.tajawal(
            color: selected ? Colors.black : AppColors.textPrimary(context),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
