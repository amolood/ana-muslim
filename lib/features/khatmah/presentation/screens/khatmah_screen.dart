import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/services/quran_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/khatmah_daily_task.dart';
import '../../domain/models/khatmah_enums.dart';
import '../../domain/models/khatmah_plan.dart';
import '../../domain/services/khatmah_planner_service.dart';
import '../providers/khatmah_controller.dart';

class KhatmahScreen extends ConsumerStatefulWidget {
  const KhatmahScreen({super.key});

  @override
  ConsumerState<KhatmahScreen> createState() => _KhatmahScreenState();
}

class _KhatmahScreenState extends ConsumerState<KhatmahScreen> {
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
    final khatmahAsync = ref.watch(khatmahControllerProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'الختمة',
            style: GoogleFonts.tajawal(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(context),
            ),
          ),
        ),
        body: khatmahAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (error, _) => _buildError(error),
          data: (viewState) {
            if (!viewState.hasActivePlan) {
              return _buildCreatePlanForm();
            }
            return _buildActivePlan(viewState);
          },
        ),
      ),
    );
  }

  Widget _buildError(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Theme.of(context).colorScheme.error,
              size: 56,
            ),
            const SizedBox(height: 10),
            Text(
              'تعذر تحميل بيانات الختمة',
              style: GoogleFonts.tajawal(
                color: AppColors.textPrimary(context),
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$error',
              style: GoogleFonts.tajawal(
                color: AppColors.textSecondary(context),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(khatmahControllerProvider.notifier).refreshState();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.backgroundDark,
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                'إعادة المحاولة',
                style: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatePlanForm() {
    final lastReadPage = _clampPage(ref.watch(lastReadPageProvider));
    final preview = _computePlanPreview(lastReadPage);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCreateHeader(preview),
          const SizedBox(height: 12),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _fieldLabel('نوع الخطة'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _choiceChip(
                      selected: _type == KhatmahPlanType.fixedDays,
                      label: 'أيام محددة',
                      icon: Icons.date_range_rounded,
                      onTap: () =>
                          setState(() => _type = KhatmahPlanType.fixedDays),
                    ),
                    _choiceChip(
                      selected: _type == KhatmahPlanType.open,
                      label: 'خطة مفتوحة',
                      icon: Icons.all_inclusive_rounded,
                      onTap: () => setState(() => _type = KhatmahPlanType.open),
                    ),
                    _choiceChip(
                      selected: _type == KhatmahPlanType.ramadanPreset,
                      label: 'ختمة رمضان',
                      icon: Icons.nightlight_round,
                      onTap: () =>
                          setState(() => _type = KhatmahPlanType.ramadanPreset),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _fieldLabel('المدة'),
                if (_type == KhatmahPlanType.open)
                  _hintText(
                    'توزيع تلقائي يومي بمعدل ثابت (${KhatmahPlannerService.openPlanDailyPages} صفحة تقريبًا).',
                  )
                else if (_type == KhatmahPlanType.ramadanPreset)
                  _hintText('تُضبط تلقائيًا على ٣٠ يومًا.')
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _durationChip(7),
                      _durationChip(15),
                      _durationChip(30),
                      _durationChip(-1, label: 'مخصص'),
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
                      decoration: _inputDecoration('عدد الأيام'),
                    ),
                  ),
                const SizedBox(height: 14),
                _fieldLabel('تاريخ البداية'),
                _tapSelectionTile(
                  icon: Icons.calendar_month_rounded,
                  title: _formatDateAr(_startDate),
                  subtitle: 'بداية الورد اليومي',
                  onTap: _pickStartDate,
                ),
                const SizedBox(height: 14),
                _fieldLabel('نقطة البداية'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _choiceChip(
                      selected:
                          _startPoint == KhatmahStartPointOption.firstPage,
                      label: 'الصفحة الأولى',
                      icon: Icons.looks_one_rounded,
                      onTap: () => setState(
                        () => _startPoint = KhatmahStartPointOption.firstPage,
                      ),
                    ),
                    _choiceChip(
                      selected:
                          _startPoint == KhatmahStartPointOption.lastReadPage,
                      label: 'آخر قراءة',
                      icon: Icons.bookmark_outline_rounded,
                      onTap: () => setState(
                        () =>
                            _startPoint = KhatmahStartPointOption.lastReadPage,
                      ),
                    ),
                    _choiceChip(
                      selected:
                          _startPoint == KhatmahStartPointOption.customPage,
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
                  _startPoint == KhatmahStartPointOption.lastReadPage
                      ? 'آخر صفحة محفوظة: ${_toArabicNumber(lastReadPage)}'
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
                      decoration: _inputDecoration('رقم الصفحة من 1 إلى 604'),
                    ),
                  ),
                const SizedBox(height: 14),
                _switchTile(
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
                    child: _tapSelectionTile(
                      icon: Icons.notifications_active_rounded,
                      title: 'وقت التذكير: ${_reminderTime.format(context)}',
                      subtitle: 'يمكنك تعديله لاحقًا من إعدادات الخطة',
                      onTap: _pickReminderTime,
                    ),
                  ),
                const SizedBox(height: 10),
                _switchTile(
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
          _buildPreviewCard(preview),
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

  Widget _buildCreateHeader(_PlanPreviewData preview) {
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

  Widget _buildPreviewCard(_PlanPreviewData preview) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('معاينة الخطة قبل الإنشاء'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _metricChip(
                title: 'البداية',
                value: 'ص ${_toArabicNumber(preview.startPage)}',
              ),
              _metricChip(
                title: 'الإجمالي',
                value: '${_toArabicNumber(preview.totalPages)} صفحة',
              ),
              _metricChip(
                title: 'الأيام',
                value: '${_toArabicNumber(preview.days)} يوم',
              ),
              _metricChip(title: 'ورد يومي', value: preview.dailyPagesLabel),
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
                  'تاريخ إتمام متوقع: ${_formatDateAr(preview.estimatedEndDate)}',
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

  Widget _buildActivePlan(KhatmahViewState viewState) {
    final plan = viewState.plan!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlanHero(plan, viewState),
          const SizedBox(height: 12),
          _buildTodayWirdCard(viewState),
          if (viewState.missedTasksCount > 0) ...[
            const SizedBox(height: 12),
            _buildMissedWirdCard(viewState),
          ],
          const SizedBox(height: 12),
          _buildTimelineCard(viewState),
          const SizedBox(height: 12),
          _buildPlanActionsCard(plan, viewState),
        ],
      ),
    );
  }

  Widget _buildPlanHero(KhatmahPlan plan, KhatmahViewState viewState) {
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
                  _planTypeLabel(plan.type),
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
                  '${_toArabicNumberString(progressPercent)}%',
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
            'من صفحة ${_toArabicNumber(plan.startPage)} إلى ${_toArabicNumber(plan.endPage)}',
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
              _metricChip(
                title: 'المنجز',
                value:
                    '${_toArabicNumber(viewState.completedPages)} / ${_toArabicNumber(viewState.totalPages)}',
              ),
              _metricChip(
                title: 'المتبقي',
                value: '${_toArabicNumber(viewState.remainingPages)} صفحة',
              ),
              _metricChip(
                title: 'سلسلة الالتزام',
                value: '${_toArabicNumber(viewState.currentStreakDays)} يوم',
              ),
              _metricChip(
                title: 'المهام المكتملة',
                value:
                    '${_toArabicNumber(viewState.completedTasksCount)} / ${_toArabicNumber(viewState.totalTasksCount)}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodayWirdCard(KhatmahViewState viewState) {
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
      surahRange = fromSurah == toSurah ? fromSurah : '$fromSurah - $toSurah';
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

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _sectionTitle('ورد اليوم'),
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
                    'متبقي ${_toArabicNumber(viewState.daysRemaining!)} يوم',
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
              'من صفحة ${_toArabicNumber(fromPage)} إلى ${_toArabicNumber(toPage)}',
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
                _metricChip(
                  title: 'منجز اليوم',
                  value:
                      '${_toArabicNumber(viewState.completedPagesToday)} / ${_toArabicNumber(totalTodayPages)}',
                ),
                _metricChip(
                  title: 'متبقي اليوم',
                  value:
                      '${_toArabicNumber(viewState.remainingPagesToday)} صفحة',
                ),
              ],
            ),
          ] else
            Text(
              viewState.nextPendingTask == null
                  ? 'لا يوجد ورد متاح حاليًا. قد تكون الخطة بدأت في تاريخ لاحق.'
                  : 'الورد القادم يبدأ في ${_formatDateAr(viewState.nextPendingTask!.date)} من الصفحة ${_toArabicNumber(viewState.nextPendingTask!.fromPage)}.',
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
                      ? () => _openPageStart(fromPage)
                      : viewState.nextPendingTask == null
                      ? null
                      : () =>
                            _openPageStart(viewState.nextPendingTask!.fromPage),
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
                  onPressed: hasTodayRange ? _markTodayCompleted : null,
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

  Widget _buildMissedWirdCard(KhatmahViewState viewState) {
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
              'لديك ورد فائت: ${_toArabicNumber(viewState.missedTasksCount)} يوم (${_toArabicNumber(viewState.missedPagesCount)} صفحة).',
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

  Widget _buildTimelineCard(KhatmahViewState viewState) {
    final tasks = _visibleTimelineTasks(viewState.tasks, viewState.debugDate);

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('الجدول اليومي'),
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
            ...tasks.map((task) => _buildTaskTile(task, viewState.debugDate)),
        ],
      ),
    );
  }

  Widget _buildTaskTile(KhatmahDailyTask task, DateTime today) {
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
        onTap: () => _openPageStart(task.fromPage),
        leading: CircleAvatar(
          radius: 17,
          backgroundColor: AppColors.primary.withValues(alpha: 0.16),
          child: Text(
            _toArabicNumber(task.dayIndex),
            style: GoogleFonts.manrope(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        title: Text(
          'من ${_toArabicNumber(task.fromPage)} إلى ${_toArabicNumber(task.toPage)}',
          style: GoogleFonts.tajawal(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          '${_formatDateAr(taskDate)} • $statusText',
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
                onPressed: () => _markTaskDone(task),
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

  Widget _buildPlanActionsCard(KhatmahPlan plan, KhatmahViewState viewState) {
    return _card(
      child: Column(
        children: [
          _actionTile(
            icon: Icons.edit_calendar_rounded,
            title: 'تعديل مدة الخطة من الموضع الحالي',
            subtitle: 'إعادة تقسيم الورد على أيام جديدة',
            onTap: _showDurationEditor,
          ),
          const Divider(height: 16),
          _actionTile(
            icon: Icons.notifications_active_rounded,
            title: 'إعداد تذكير الختمة',
            subtitle: plan.dailyReminderEnabled
                ? 'مفعّل عند ${_formatTime(plan.reminderHour, plan.reminderMinute)}'
                : 'غير مفعّل',
            onTap: _showReminderEditor,
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
              if (!mounted) return;
              _showSnack('تم تحديث إعداد حمل الورد الفائت');
            },
          ),
          const Divider(height: 16),
          _actionTile(
            icon: Icons.delete_outline_rounded,
            iconColor: Theme.of(context).colorScheme.error,
            title: 'إلغاء الخطة الحالية',
            subtitle: 'سيتم حذف الخطة ومهامها اليومية',
            titleColor: Theme.of(context).colorScheme.error,
            onTap: _confirmClearPlan,
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

  Widget _metricChip({required String title, required String value}) {
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

  Widget _actionTile({
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

  Future<void> _markTaskDone(KhatmahDailyTask task) async {
    final changed = await ref
        .read(khatmahControllerProvider.notifier)
        .markTaskCompletedById(task.id);
    if (!mounted) return;
    _showSnack(changed ? 'تم تعليم الورد كمكتمل' : 'تعذر تحديث حالة هذا الورد');
  }

  Future<void> _markTodayCompleted() async {
    final changed = await ref
        .read(khatmahControllerProvider.notifier)
        .markTodayCompletedManual();
    _showSnack(
      changed ? 'تم تعليم ورد اليوم كمكتمل' : 'لا يوجد ورد اليوم لإكماله',
    );
  }

  Future<void> _openPageStart(int page) async {
    final safePage = _clampPage(page);
    final surah = QuranService.getSurahNumberFromPage(safePage);
    if (!mounted) return;
    context.push('/quran/reader/$surah?page=$safePage');
  }

  Future<void> _showDurationEditor() async {
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
                  _durationBottomSheetChip(
                    selected: selected == 7,
                    label: '٧ أيام',
                    onTap: () {
                      setSheetState(() {
                        selected = 7;
                        ctrl.text = '7';
                      });
                    },
                  ),
                  _durationBottomSheetChip(
                    selected: selected == 15,
                    label: '١٥ يوم',
                    onTap: () {
                      setSheetState(() {
                        selected = 15;
                        ctrl.text = '15';
                      });
                    },
                  ),
                  _durationBottomSheetChip(
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
                decoration: _inputDecoration('أدخل عدد الأيام'),
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
      _showSnack('الرجاء إدخال عدد أيام صحيح');
      return;
    }
    await ref
        .read(khatmahControllerProvider.notifier)
        .updateDurationFromCurrent(result);
    if (!mounted) return;
    _showSnack('تم تحديث مدة الخطة');
  }

  Widget _durationBottomSheetChip({
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
          color: selected
              ? AppColors.primary
              : AppColors.surfaceElevated(context),
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

  Future<void> _showReminderEditor() async {
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
                _tapSelectionTile(
                  icon: Icons.access_time_rounded,
                  title: 'الوقت: ${selectedTime.format(context)}',
                  subtitle: 'اختر الوقت الأنسب لوردك اليومي',
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                      helpText: 'اختر وقت تذكير الختمة',
                    );
                    if (picked == null) return;
                    setSheetState(() => selectedTime = picked);
                  },
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

    await ref
        .read(khatmahControllerProvider.notifier)
        .updateReminder(
          enabled: enabled,
          hour: selectedTime.hour,
          minute: selectedTime.minute,
        );
    if (!mounted) return;
    _showSnack('تم تحديث تذكير الختمة');
  }

  Future<void> _confirmClearPlan() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.surface(context),
          title: Text(
            'إلغاء خطة الختمة',
            style: GoogleFonts.tajawal(color: AppColors.textPrimary(context)),
          ),
          content: Text(
            'سيتم حذف خطة الختمة الحالية ومهامها اليومية.',
            style: GoogleFonts.tajawal(color: AppColors.textSecondary(context)),
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
    if (!mounted) return;
    _showSnack('تم إلغاء خطة الختمة');
  }

  Widget _durationChip(int value, {String? label}) {
    final selected = _durationOption == value;
    return _choiceChip(
      selected: selected,
      label: label ?? '${_toArabicNumber(value)} يوم',
      icon: Icons.timelapse_rounded,
      onTap: () => setState(() => _durationOption = value),
    );
  }

  Widget _choiceChip({
    required bool selected,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : AppColors.surfaceElevated(context),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border(context),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: selected ? Colors.black : AppColors.textSecondary(context),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.tajawal(
                color: selected ? Colors.black : AppColors.textPrimary(context),
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.tajawal(
                  color: AppColors.textPrimary(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.tajawal(
                  color: AppColors.textSecondary(context),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          activeThumbColor: AppColors.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _tapSelectionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.tajawal(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
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
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
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
    );
  }

  Widget _card({required Widget child}) {
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

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.tajawal(
        color: AppColors.textPrimary(context),
        fontSize: 17,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _fieldLabel(String label) {
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

  Widget _hintText(String text) {
    return Text(
      text,
      style: GoogleFonts.tajawal(
        color: AppColors.textSecondary(context),
        fontSize: 12,
        height: 1.5,
      ),
    );
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

  String _planTypeLabel(KhatmahPlanType type) {
    return switch (type) {
      KhatmahPlanType.fixedDays => 'خطة بعدد أيام محدد',
      KhatmahPlanType.open => 'خطة مفتوحة',
      KhatmahPlanType.ramadanPreset => 'ختمة رمضان',
    };
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

  _PlanPreviewData _computePlanPreview(int lastReadPage) {
    final startPage = switch (_startPoint) {
      KhatmahStartPointOption.firstPage => 1,
      KhatmahStartPointOption.lastReadPage => lastReadPage,
      KhatmahStartPointOption.customPage => _clampPage(
        int.tryParse(_customPageCtrl.text.trim()) ?? 1,
      ),
    };

    final endPage = 604;
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
        ? '${_toArabicNumber(base)} صفحة'
        : '${_toArabicNumber(base)} - ${_toArabicNumber(base + 1)} صفحة';

    final summaryLine =
        'ستبدأ من الصفحة ${_toArabicNumber(startPage)} وتكمل خلال ${_toArabicNumber(days)} يوم بورد يومي $dailyPagesLabel.';

    return _PlanPreviewData(
      startPage: startPage,
      totalPages: totalPages,
      days: days,
      dailyPagesLabel: dailyPagesLabel,
      estimatedEndDate: estimatedEndDate,
      summaryLine: summaryLine,
    );
  }

  List<KhatmahDailyTask> _visibleTimelineTasks(
    List<KhatmahDailyTask> all,
    DateTime today,
  ) {
    if (all.isEmpty) return const [];
    final dateOnlyToday = DateUtils.dateOnly(today);

    final pastAndToday =
        all
            .where(
              (task) => !DateUtils.dateOnly(task.date).isAfter(dateOnlyToday),
            )
            .toList()
          ..sort((a, b) => b.dayIndex.compareTo(a.dayIndex));

    final future =
        all
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

  int _clampPage(int value) => value.clamp(1, 604).toInt();

  String _formatDateAr(DateTime date) {
    return '${_toArabicNumber(date.day)}/${_toArabicNumber(date.month)}/${_toArabicNumber(date.year)}';
  }

  String _formatTime(int hour, int minute) {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '${_toArabicNumberString(h)}:${_toArabicNumberString(m)}';
  }

  String _toArabicNumber(int number) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var numStr = number.toString();
    for (var i = 0; i < english.length; i++) {
      numStr = numStr.replaceAll(english[i], arabic[i]);
    }
    return numStr;
  }

  String _toArabicNumberString(String text) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var out = text;
    for (var i = 0; i < english.length; i++) {
      out = out.replaceAll(english[i], arabic[i]);
    }
    return out;
  }
}

class _PlanPreviewData {
  const _PlanPreviewData({
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
