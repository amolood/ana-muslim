import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/khatmah_enums.dart';
import '../../domain/models/khatmah_plan.dart';
import '../../domain/services/khatmah_planner_service.dart';
import '../providers/khatmah_controller.dart';
import 'khatmah_plan_form_controls.dart';
import 'khatmah_plan_preview_widgets.dart';
import 'khatmah_utils.dart';

/// نموذج إنشاء خطة ختمة جديدة
class KhatmahCreatePlanForm extends ConsumerStatefulWidget {
  const KhatmahCreatePlanForm({super.key});

  @override
  ConsumerState<KhatmahCreatePlanForm> createState() =>
      _KhatmahCreatePlanFormState();
}

class _KhatmahCreatePlanFormState
    extends ConsumerState<KhatmahCreatePlanForm> {
  KhatmahPlanType _type = KhatmahPlanType.fixedDays;
  int _durationOption = 30;
  final TextEditingController _customDurationCtrl = TextEditingController(
    text: '30',
  );
  DateTime _startDate = DateTime.now();
  KhatmahStartPointOption _startPoint = KhatmahStartPointOption.firstPage;
  final TextEditingController _customPageCtrl = TextEditingController(
    text: '1',
  );
  bool _reminderEnabled = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  bool _carryMissed = false;
  bool _submitting = false;

  @override
  void dispose() {
    _customDurationCtrl.dispose();
    _customPageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lastReadPage = khatmahClampPage(ref.watch(lastReadPageProvider));
    final preview = _computePlanPreview(lastReadPage);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KhatmahCreatePlanHeader(preview: preview),
          const SizedBox(height: 12),
          khatmahCard(
            context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _fieldLabel(context, 'نوع الخطة'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    khatmahPlanChoiceChip(
                      context,
                      selected: _type == KhatmahPlanType.fixedDays,
                      label: 'أيام محددة',
                      icon: Icons.date_range_rounded,
                      onTap: () =>
                          setState(() => _type = KhatmahPlanType.fixedDays),
                    ),
                    khatmahPlanChoiceChip(
                      context,
                      selected: _type == KhatmahPlanType.open,
                      label: 'خطة مفتوحة',
                      icon: Icons.all_inclusive_rounded,
                      onTap: () =>
                          setState(() => _type = KhatmahPlanType.open),
                    ),
                    khatmahPlanChoiceChip(
                      context,
                      selected: _type == KhatmahPlanType.ramadanPreset,
                      label: 'ختمة رمضان',
                      icon: Icons.nightlight_round,
                      onTap: () => setState(
                        () => _type = KhatmahPlanType.ramadanPreset,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildDurationSection(context),
                const SizedBox(height: 14),
                _fieldLabel(context, 'تاريخ البداية'),
                khatmahPlanTapSelectionTile(
                  context,
                  icon: Icons.calendar_month_rounded,
                  title: khatmahFormatDateAr(_startDate),
                  subtitle: 'بداية الورد اليومي',
                  onTap: _pickStartDate,
                ),
                const SizedBox(height: 14),
                _buildStartPointSection(context, lastReadPage: lastReadPage),
                const SizedBox(height: 14),
                khatmahPlanSwitchTile(
                  context,
                  title: 'تذكير يومي للورد',
                  subtitle: 'إرسال إشعار يومي لتذكيرك بالختمة',
                  value: _reminderEnabled,
                  onChanged: (value) {
                    setState(() => _reminderEnabled = value);
                  },
                ),
                if (_reminderEnabled)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: khatmahPlanTapSelectionTile(
                      context,
                      icon: Icons.notifications_active_rounded,
                      title:
                          'وقت التذكير: ${_reminderTime.format(context)}',
                      subtitle: 'يمكنك تعديله لاحقًا من إعدادات الخطة',
                      onTap: _pickReminderTime,
                    ),
                  ),
                const SizedBox(height: 10),
                khatmahPlanSwitchTile(
                  context,
                  title: 'حمل ورد الأيام الفائتة',
                  subtitle: 'يجمع الورد الفائت مع ورد اليوم تلقائيًا',
                  value: _carryMissed,
                  onChanged: (value) {
                    setState(() => _carryMissed = value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          KhatmahCreatePlanPreviewCard(preview: preview),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submitting ? null : _createPlan,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.backgroundDark,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Icon(Icons.check_circle_outline_rounded),
              label: Text(
                _submitting ? 'جاري إنشاء الخطة...' : 'إنشاء خطة الختمة',
                style: GoogleFonts.tajawal(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createPlan() async {
    final targetDays = _resolveTargetDays();
    if (_type != KhatmahPlanType.open &&
        (targetDays == null || targetDays <= 0)) {
      _showSnack('يرجى تحديد مدة صحيحة للخطة');
      return;
    }

    final customPage = int.tryParse(_customPageCtrl.text.trim());
    if (_startPoint == KhatmahStartPointOption.customPage &&
        (customPage == null || customPage < 1 || customPage > 604)) {
      _showSnack('رقم الصفحة يجب أن يكون بين 1 و 604');
      return;
    }

    final draft = KhatmahPlanDraft(
      type: _type,
      targetDays: targetDays,
      startDate: _startDate,
      startPoint: _startPoint,
      customStartPage: customPage,
      dailyReminderEnabled: _reminderEnabled,
      reminderHour: _reminderTime.hour,
      reminderMinute: _reminderTime.minute,
      carryMissedWird: _carryMissed,
    );

    setState(() => _submitting = true);
    await ref.read(khatmahControllerProvider.notifier).createPlan(draft);
    if (mounted) {
      setState(() => _submitting = false);
      _showSnack('تم إنشاء خطة الختمة بنجاح');
    }
  }

  int? _resolveTargetDays() {
    if (_type == KhatmahPlanType.open) return null;
    if (_type == KhatmahPlanType.ramadanPreset) return 30;
    if (_durationOption != -1) return _durationOption;
    return int.tryParse(_customDurationCtrl.text.trim());
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      helpText: 'اختر وقت التذكير',
    );
    if (picked != null) {
      setState(() => _reminderTime = picked);
    }
  }

  KhatmahPlanPreviewData _computePlanPreview(int lastReadPage) {
    final startPage = switch (_startPoint) {
      KhatmahStartPointOption.firstPage => 1,
      KhatmahStartPointOption.lastReadPage => lastReadPage,
      KhatmahStartPointOption.customPage => khatmahClampPage(
        int.tryParse(_customPageCtrl.text.trim()) ?? 1,
      ),
    };

    const endPage = 604;
    final totalPages = endPage - startPage + 1;

    int days;
    if (_type == KhatmahPlanType.open) {
      days = (totalPages / KhatmahPlannerService.openPlanDailyPages).ceil();
      if (days < 1) days = 1;
    } else if (_type == KhatmahPlanType.ramadanPreset) {
      days = 30;
    } else {
      days = (_resolveTargetDays() ?? 30).clamp(1, 365);
    }

    if (days > totalPages) {
      days = totalPages;
    }

    final base = totalPages ~/ days;
    final remainder = totalPages % days;
    final estimatedEndDate = DateUtils.dateOnly(
      _startDate,
    ).add(Duration(days: days - 1));

    final dailyPagesLabel = remainder == 0
        ? '${khatmahToArabicNumber(base)} صفحة'
        : '${khatmahToArabicNumber(base)} - ${khatmahToArabicNumber(base + 1)} صفحة';

    final summaryLine =
        'ستبدأ من الصفحة ${khatmahToArabicNumber(startPage)} وتكمل خلال ${khatmahToArabicNumber(days)} يوم بورد يومي $dailyPagesLabel.';

    return KhatmahPlanPreviewData(
      startPage: startPage,
      totalPages: totalPages,
      days: days,
      dailyPagesLabel: dailyPagesLabel,
      estimatedEndDate: estimatedEndDate,
      summaryLine: summaryLine,
    );
  }

  Widget _buildDurationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(context, 'المدة'),
        if (_type == KhatmahPlanType.open)
          _hintText(
            context,
            'توزيع تلقائي يومي بمعدل ثابت (${KhatmahPlannerService.openPlanDailyPages} صفحة تقريبًا).',
          )
        else if (_type == KhatmahPlanType.ramadanPreset)
          _hintText(context, 'تُضبط تلقائيًا على ٣٠ يومًا.')
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _durationChip(context, 7),
              _durationChip(context, 15),
              _durationChip(context, 30),
              _durationChip(context, -1, label: 'مخصص'),
            ],
          ),
        if (_type == KhatmahPlanType.fixedDays && _durationOption == -1)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: TextField(
              controller: _customDurationCtrl,
              keyboardType: TextInputType.number,
              style: GoogleFonts.tajawal(
                color: AppColors.textPrimary(context),
              ),
              decoration: khatmahPlanInputDecoration(context, 'عدد الأيام'),
            ),
          ),
      ],
    );
  }

  Widget _buildStartPointSection(
    BuildContext context, {
    required int lastReadPage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(context, 'نقطة البداية'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            khatmahPlanChoiceChip(
              context,
              selected: _startPoint == KhatmahStartPointOption.firstPage,
              label: 'الصفحة الأولى',
              icon: Icons.looks_one_rounded,
              onTap: () => setState(
                () => _startPoint = KhatmahStartPointOption.firstPage,
              ),
            ),
            khatmahPlanChoiceChip(
              context,
              selected: _startPoint == KhatmahStartPointOption.lastReadPage,
              label: 'آخر قراءة',
              icon: Icons.bookmark_outline_rounded,
              onTap: () => setState(
                () => _startPoint = KhatmahStartPointOption.lastReadPage,
              ),
            ),
            khatmahPlanChoiceChip(
              context,
              selected: _startPoint == KhatmahStartPointOption.customPage,
              label: 'صفحة مخصصة',
              icon: Icons.tune_rounded,
              onTap: () => setState(
                () => _startPoint = KhatmahStartPointOption.customPage,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _hintText(
          context,
          _startPoint == KhatmahStartPointOption.lastReadPage
              ? 'آخر صفحة محفوظة: ${khatmahToArabicNumber(lastReadPage)}'
              : 'يمكنك البدء من الموضع الأنسب لوردك اليومي.',
        ),
        if (_startPoint == KhatmahStartPointOption.customPage)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: TextField(
              controller: _customPageCtrl,
              keyboardType: TextInputType.number,
              style: GoogleFonts.tajawal(
                color: AppColors.textPrimary(context),
              ),
              decoration: khatmahPlanInputDecoration(
                context,
                'رقم الصفحة من 1 إلى 604',
              ),
            ),
          ),
      ],
    );
  }

  Widget _durationChip(BuildContext context, int value, {String? label}) {
    final selected = _durationOption == value;
    return khatmahPlanChoiceChip(
      context,
      selected: selected,
      label: label ?? '${khatmahToArabicNumber(value)} يوم',
      icon: Icons.timelapse_rounded,
      onTap: () => setState(() => _durationOption = value),
    );
  }

  void _showSnack(String text) {
    if (!mounted) return;
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
}

// ─── Local form helpers ────────────────────────────────────────────────────

Widget _fieldLabel(BuildContext context, String label) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      label,
      style: GoogleFonts.tajawal(
        color: AppColors.textPrimary(context),
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

Widget _hintText(BuildContext context, String text) {
  return Text(
    text,
    style: GoogleFonts.tajawal(
      color: AppColors.textSecondary(context),
      fontSize: 12,
      height: 1.5,
    ),
  );
}
