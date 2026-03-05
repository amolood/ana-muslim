import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../data/models/hijri_calendar_day.dart';
import '../providers/hijri_calendar_provider.dart';

/// Full-page Hijri calendar with month navigation.
/// Shows a Hijri month grid with Gregorian day numbers overlaid.
class HijriCalendarScreen extends ConsumerStatefulWidget {
  const HijriCalendarScreen({super.key});

  @override
  ConsumerState<HijriCalendarScreen> createState() =>
      _HijriCalendarScreenState();
}

class _HijriCalendarScreenState extends ConsumerState<HijriCalendarScreen> {
  late int _hijriMonth;
  late int _hijriYear;

  // Today in Hijri for highlight
  late int _todayHijriDay;
  late int _todayHijriMonth;
  late int _todayHijriYear;

  static const _weekdayLabels = ['ح', 'ن', 'ث', 'ر', 'خ', 'ج', 'س'];
  // Sun=0 Mon=1 Tue=2 Wed=3 Thu=4 Fri=5 Sat=6

  static const _hijriMonthNames = [
    'محرَّم',
    'صفر',
    'ربيع الأوَّل',
    'ربيع الآخر',
    'جمادى الأُولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوَّال',
    'ذو القعدة',
    'ذو الحِجَّة',
  ];

  @override
  void initState() {
    super.initState();
    HijriCalendar.setLocal('ar');
    final now = HijriCalendar.now();
    _hijriMonth = now.hMonth;
    _hijriYear = now.hYear;
    _todayHijriDay = now.hDay;
    _todayHijriMonth = now.hMonth;
    _todayHijriYear = now.hYear;
  }

  void _previousMonth() {
    setState(() {
      if (_hijriMonth == 1) {
        _hijriMonth = 12;
        _hijriYear--;
      } else {
        _hijriMonth--;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      if (_hijriMonth == 12) {
        _hijriMonth = 1;
        _hijriYear++;
      } else {
        _hijriMonth++;
      }
    });
  }

  bool _isToday(HijriCalendarDay day) =>
      day.hijriDay == _todayHijriDay &&
      day.hijriMonth == _todayHijriMonth &&
      day.hijriYear == _todayHijriYear;

  /// Maps isoWeekday (1=Mon…7=Sun) to grid column (0=Sun…6=Sat)
  int _gridColumn(int isoWeekday) => isoWeekday % 7;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final calendar =
        ref.watch(hijriCalendarProvider((_hijriMonth, _hijriYear)));

    final monthName = _hijriMonth >= 1 && _hijriMonth <= 12
        ? _hijriMonthNames[_hijriMonth - 1]
        : '';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'التقويم الهجري',
          style: GoogleFonts.tajawal(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Month header ────────────────────────────────────────
          _buildMonthHeader(colors, monthName, isDark),
          const SizedBox(height: 8),
          // ── Weekday labels ──────────────────────────────────────
          _buildWeekdayRow(colors),
          const SizedBox(height: 4),
          // ── Calendar grid ───────────────────────────────────────
          Expanded(
            child: calendar.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _buildError(colors),
              data: (days) => _buildGrid(days, colors, isDark),
            ),
          ),
          // ── Legend ──────────────────────────────────────────────
          _buildLegend(colors),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMonthHeader(
    AppSemanticColors colors,
    String monthName,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Next month (RTL: left arrow = next)
          _arrowButton(Icons.chevron_left_rounded, _nextMonth, colors),
          Column(
            children: [
              Text(
                monthName,
                style: GoogleFonts.notoNaskhArabic(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                '${_toAr(_hijriYear)} هـ',
                style: GoogleFonts.tajawal(
                  fontSize: 13,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          // Previous month (RTL: right arrow = prev)
          _arrowButton(Icons.chevron_right_rounded, _previousMonth, colors),
        ],
      ),
    );
  }

  Widget _arrowButton(
    IconData icon,
    VoidCallback onTap,
    AppSemanticColors colors,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildWeekdayRow(AppSemanticColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _weekdayLabels.map((label) {
          final isFriday = label == 'ج';
          return Expanded(
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.tajawal(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isFriday ? AppColors.primary : colors.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGrid(
    List<HijriCalendarDay> days,
    AppSemanticColors colors,
    bool isDark,
  ) {
    if (days.isEmpty) return const SizedBox.shrink();

    // Build a 7-column grid; first day determines starting column offset
    final firstCol = _gridColumn(days.first.isoWeekday);
    final totalCells = firstCol + days.length;
    final rowCount = (totalCells / 7).ceil();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: List.generate(rowCount, (row) {
          return Expanded(
            child: Row(
              children: List.generate(7, (col) {
                final cellIndex = row * 7 + col;
                final dayIndex = cellIndex - firstCol;
                if (dayIndex < 0 || dayIndex >= days.length) {
                  return const Expanded(child: SizedBox.shrink());
                }
                final day = days[dayIndex];
                return Expanded(
                  child: _buildDayCell(day, colors, isDark),
                );
              }),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDayCell(
    HijriCalendarDay day,
    AppSemanticColors colors,
    bool isDark,
  ) {
    final today = _isToday(day);
    final isFriday = day.isoWeekday == 5; // ISO 5 = Friday
    final hasHoliday = day.holidays.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(2),
      child: AspectRatio(
        aspectRatio: 0.85,
        child: Container(
          decoration: BoxDecoration(
            color: today
                ? AppColors.primary
                : hasHoliday
                ? AppColors.primary.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: today
                ? null
                : isFriday
                ? Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    width: 1,
                  )
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hijri day number (large)
              Text(
                _toAr(day.hijriDay),
                style: GoogleFonts.tajawal(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: today
                      ? Colors.white
                      : isFriday
                      ? AppColors.primary
                      : colors.textPrimary,
                  height: 1.1,
                ),
              ),
              // Gregorian day number (small)
              Text(
                day.gregorianDay.toString(),
                style: GoogleFonts.tajawal(
                  fontSize: 10,
                  color: today
                      ? Colors.white.withValues(alpha: 0.75)
                      : colors.textSecondary,
                  height: 1.1,
                ),
              ),
              if (hasHoliday && !today)
                Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(AppSemanticColors colors) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 48,
            color: colors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            'تعذّر تحميل التقويم',
            style: GoogleFonts.tajawal(
              fontSize: 16,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => ref.invalidate(
              hijriCalendarProvider((_hijriMonth, _hijriYear)),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text('إعادة المحاولة', style: GoogleFonts.tajawal()),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(AppSemanticColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem(AppColors.primary, 'اليوم', colors),
          const SizedBox(width: 20),
          _legendItem(AppColors.primary.withValues(alpha: 0.25), 'الجمعة', colors),
          const SizedBox(width: 20),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'يوم مميز',
                style: GoogleFonts.tajawal(
                  fontSize: 11,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label, AppSemanticColors colors) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: 11,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _toAr(int n) {
    const e = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const a = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var s = n.toString();
    for (int i = 0; i < e.length; i++) {
      s = s.replaceAll(e[i], a[i]);
    }
    return s;
  }
}
