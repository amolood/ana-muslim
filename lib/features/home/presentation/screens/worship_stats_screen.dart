import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/worship_stats_provider.dart';

class WorshipStatsScreen extends ConsumerWidget {
  const WorshipStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(worshipStatsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'الإحصائيات المتقدمة',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            _buildMotivationCard(context, stats),
            const SizedBox(height: 14),
            _buildOverallCard(context, stats),
            const SizedBox(height: 14),
            _buildMetricsGrid(context, stats),
            const SizedBox(height: 14),
            _buildQuranCard(context, stats),
            const SizedBox(height: 14),
            _buildSebhaCard(context, stats),
            const SizedBox(height: 14),
            _buildPrayerCard(context, stats),
          ],
        ),
      ),
    );
  }

  Widget _buildMotivationCard(
    BuildContext context,
    WorshipStatsSnapshot stats,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.22),
            AppColors.primary.withValues(alpha: 0.08),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stats.motivationTitle,
            style: GoogleFonts.tajawal(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            stats.motivationBody,
            style: GoogleFonts.tajawal(
              fontSize: 14,
              color: AppColors.textSecondary(context),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallCard(BuildContext context, WorshipStatsSnapshot stats) {
    final percent = (stats.overallScore * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            height: 92,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: stats.overallScore,
                  strokeWidth: 8,
                  backgroundColor: AppColors.surfaceElevated(context),
                  color: AppColors.primary,
                ),
                Text(
                  '$percent%',
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مؤشر الإنجاز اليومي',
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'يعتمد على الصلاة، التسبيح، وتقدم القرآن اليومي.',
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context, WorshipStatsSnapshot stats) {
    return Row(
      children: [
        Expanded(
          child: _metricTile(
            context,
            title: 'الصلاة',
            value: '${stats.prayerCompleted}/${stats.prayerTotal}',
            subtitle: 'اليوم',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _metricTile(
            context,
            title: 'السبحة',
            value: _toArabicNumber(stats.sebhaTodayCount),
            subtitle: 'تسبيحة اليوم',
          ),
        ),
      ],
    );
  }

  Widget _buildQuranCard(BuildContext context, WorshipStatsSnapshot stats) {
    final quranPercent = (stats.quranProgress * 100).round();
    final khatmahPercent = (stats.khatmahOverallProgress * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'القرآن والختمة',
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 10),
          _lineProgress(
            context,
            title: 'آخر موضع قراءة',
            subtitle: 'صفحة ${_toArabicNumber(stats.quranLastPage)} من ٦٠٤',
            value: stats.quranProgress,
            trailing: '$quranPercent%',
          ),
          if (stats.hasKhatmahPlan) ...[
            const SizedBox(height: 10),
            _lineProgress(
              context,
              title: 'تقدم الختمة',
              subtitle:
                  'ورد اليوم: ${_toArabicNumber(stats.khatmahTodayDonePages)} / ${_toArabicNumber(stats.khatmahTodayTargetPages)} صفحة',
              value: stats.khatmahOverallProgress,
              trailing: '$khatmahPercent%',
            ),
            if (stats.khatmahDaysRemaining != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'الأيام المتبقية: ${_toArabicNumber(stats.khatmahDaysRemaining!)}',
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildSebhaCard(BuildContext context, WorshipStatsSnapshot stats) {
    final ratio = stats.sebhaGoalCount == 0
        ? 0.0
        : (stats.sebhaCompletedGoals / stats.sebhaGoalCount).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الذكر والتسبيح',
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 10),
          _lineProgress(
            context,
            title: 'الأهداف المكتملة',
            subtitle:
                '${_toArabicNumber(stats.sebhaCompletedGoals)} من ${_toArabicNumber(stats.sebhaGoalCount)} هدف',
            value: ratio,
            trailing: '${(ratio * 100).round()}%',
          ),
          const SizedBox(height: 8),
          Text(
            'إجمالي التسبيح منذ البداية: ${_toArabicNumber(stats.sebhaTotalCount)}',
            style: GoogleFonts.tajawal(
              fontSize: 13,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerCard(BuildContext context, WorshipStatsSnapshot stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: _lineProgress(
        context,
        title: 'الصلاة اليومية',
        subtitle:
            'المؤداة: ${_toArabicNumber(stats.prayerCompleted)} من ${_toArabicNumber(stats.prayerTotal)}',
        value: stats.prayerProgress,
        trailing: '${(stats.prayerProgress * 100).round()}%',
      ),
    );
  }

  Widget _lineProgress(
    BuildContext context, {
    required String title,
    required String subtitle,
    required double value,
    required String trailing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),
            Text(
              trailing,
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.tajawal(
            fontSize: 12,
            color: AppColors.textSecondary(context),
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 7,
            value: value.clamp(0.0, 1.0),
            backgroundColor: AppColors.surfaceElevated(context),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _metricTile(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.tajawal(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.tajawal(
              fontSize: 11,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  String _toArabicNumber(int number) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var value = number.toString();
    for (int i = 0; i < english.length; i++) {
      value = value.replaceAll(english[i], arabic[i]);
    }
    return value;
  }
}
