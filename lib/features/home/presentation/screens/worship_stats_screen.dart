import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/utils/arabic_utils.dart';
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // ── Overall score ──────────────────────────────────────
          _OverallScoreCard(stats: stats),
          const SizedBox(height: 10),

          // ── Motivation banner ──────────────────────────────────
          _MotivationBanner(stats: stats),
          const SizedBox(height: 24),

          // ── Prayer section ─────────────────────────────────────
          _SectionHeader(
            label: 'الصلاة اليومية',
            icon: FlutterIslamicIcons.prayer,
            color: AppColors.accentPrayer,
          ),
          const SizedBox(height: 8),
          // _PrayerCard watches prayerDailyProgressProvider directly
          _PrayerCard(stats: stats),
          const SizedBox(height: 24),

          // ── Quran section ──────────────────────────────────────
          _SectionHeader(
            label: 'القرآن الكريم',
            icon: FlutterIslamicIcons.solidQuran,
            color: AppColors.accentQuran,
          ),
          const SizedBox(height: 8),
          _QuranCard(stats: stats),
          const SizedBox(height: 24),

          // ── Dhikr / Sebha section ──────────────────────────────
          _SectionHeader(
            label: 'الذكر والتسبيح',
            icon: FlutterIslamicIcons.solidSajadah,
            color: AppColors.accentSebha,
          ),
          const SizedBox(height: 8),
          _SebhaCard(stats: stats),
        ],
      ),
    );
  }
}

// ─── Overall score ─────────────────────────────────────────────────────────

class _OverallScoreCard extends StatelessWidget {
  const _OverallScoreCard({required this.stats});
  final WorshipStatsSnapshot stats;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final percent = (stats.overallScore * 100).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.22),
            AppColors.primary.withValues(alpha: 0.06),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            height: 88,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: stats.overallScore,
                  strokeWidth: 9,
                  strokeCap: StrokeCap.round,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  color: AppColors.primary,
                ),
                Text(
                  '$percent%',
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مؤشر الإنجاز اليومي',
                  style: GoogleFonts.tajawal(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                _WeightRow(
                  label: 'الصلاة',
                  value: stats.prayerProgress,
                  weight: '٤٠٪',
                  color: AppColors.accentPrayer,
                ),
                const SizedBox(height: 6),
                _WeightRow(
                  label: 'القرآن',
                  value: stats.hasKhatmahPlan
                      ? stats.khatmahTodayTargetPages > 0
                          ? (stats.khatmahTodayDonePages /
                                  stats.khatmahTodayTargetPages)
                              .clamp(0.0, 1.0)
                          : 0.0
                      : stats.quranProgress,
                  weight: '٣٥٪',
                  color: AppColors.accentQuran,
                ),
                const SizedBox(height: 6),
                _WeightRow(
                  label: 'الذكر',
                  value: stats.sebhaGoalCount > 0
                      ? (stats.sebhaCompletedGoals / stats.sebhaGoalCount)
                          .clamp(0.0, 1.0)
                      : (stats.sebhaTodayCount / 100).clamp(0.0, 1.0),
                  weight: '٢٥٪',
                  color: AppColors.accentSebha,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightRow extends StatelessWidget {
  const _WeightRow({
    required this.label,
    required this.value,
    required this.weight,
    required this.color,
  });
  final String label;
  final double value;
  final String weight;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        SizedBox(
          width: 36,
          child: Text(
            label,
            style: GoogleFonts.tajawal(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: colors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 5,
              value: value.clamp(0.0, 1.0),
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          weight,
          style: GoogleFonts.tajawal(
            fontSize: 10,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ─── Motivation banner ─────────────────────────────────────────────────────

class _MotivationBanner extends StatelessWidget {
  const _MotivationBanner({required this.stats});
  final WorshipStatsSnapshot stats;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stats.motivationTitle,
                  style: GoogleFonts.tajawal(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stats.motivationBody,
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    color: colors.textSecondary,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section header ────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.icon,
    required this.color,
  });
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 17),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ─── Prayer card ───────────────────────────────────────────────────────────
// ConsumerWidget: watches prayerDailyProgressProvider directly so it rebuilds
// only when prayer state changes, not when Quran/Sebha data changes.

class _PrayerCard extends ConsumerWidget {
  const _PrayerCard({required this.stats});
  final WorshipStatsSnapshot stats;

  static const _accent = AppColors.accentPrayer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Watch directly — circle UI updates instantly on toggle
    final prayerProgress = ref.watch(prayerDailyProgressProvider);
    final completedCount = prayerProgress.completedCount;
    final completionRatio = prayerProgress.completionRatio;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _accent.withValues(alpha: 0.25)),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: _accent.withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Five tappable prayer circles ──────────────────
                Row(
                  children: PrayerDailyProgress.trackedPrayers.map((prayer) {
                    final done = prayerProgress.isCompleted(prayer);
                    return Expanded(
                      child: _PrayerCircle(
                        prayer: prayer,
                        done: done,
                        onToggle: () async {
                          HapticFeedback.lightImpact();
                          await ref
                              .read(prayerDailyProgressProvider.notifier)
                              .togglePrayer(prayer);
                        },
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // ── Today's progress bar ───────────────────────────
                _ProgressRow(
                  title: 'المؤدّاة اليوم',
                  trailing:
                      '${ArabicUtils.toArabicDigits(completedCount)} / ${ArabicUtils.toArabicDigits(PrayerDailyProgress.trackedPrayers.length)}',
                  value: completionRatio,
                  color: _accent,
                ),
                const SizedBox(height: 16),

                // ── 14-day history bars ────────────────────────────
                if (prayerProgress.history.isNotEmpty) ...[
                  Text(
                    'الأسبوعان الأخيران',
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _PrayerHistoryBars(
                    history: prayerProgress.history,
                    todayKey: prayerProgress.dayKey,
                    todayCount: completedCount,
                    accent: _accent,
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),

          // ── Navigate to full prayer screen ─────────────────────
          const Divider(height: 1),
          InkWell(
            onTap: () => context.push(Routes.prayerTimes),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'عرض التفاصيل',
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _accent,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 12,
                    color: _accent,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Single tappable prayer circle ─────────────────────────────────────────

class _PrayerCircle extends StatelessWidget {
  const _PrayerCircle({
    required this.prayer,
    required this.done,
    required this.onToggle,
  });

  final Prayer prayer;
  final bool done;
  final VoidCallback onToggle;

  static const _names = <Prayer, String>{
    Prayer.fajr: 'الفجر',
    Prayer.dhuhr: 'الظهر',
    Prayer.asr: 'العصر',
    Prayer.maghrib: 'المغرب',
    Prayer.isha: 'العشاء',
  };

  static const _accent = AppColors.accentPrayer;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: done
                    ? _accent.withValues(alpha: 0.9)
                    : colors.surfaceVariant,
                shape: BoxShape.circle,
                border: Border.all(
                  color: done ? _accent : colors.borderDefault,
                  width: 1.5,
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  done ? Icons.check_rounded : Icons.circle_outlined,
                  key: ValueKey(done),
                  color: done ? Colors.white : colors.iconSecondary,
                  size: done ? 20 : 12,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              _names[prayer] ?? '',
              style: GoogleFonts.tajawal(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: done ? _accent : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Prayer 14-day history mini bar chart ─────────────────────────────────

class _PrayerHistoryBars extends StatelessWidget {
  const _PrayerHistoryBars({
    required this.history,
    required this.todayKey,
    required this.todayCount,
    required this.accent,
  });
  final Map<String, int> history;
  final String todayKey;
  final int todayCount;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final allEntries = Map<String, int>.from(history)..[todayKey] = todayCount;
    final sortedKeys = allEntries.keys.toList()..sort();
    final last14 = sortedKeys.length > 14
        ? sortedKeys.sublist(sortedKeys.length - 14)
        : sortedKeys;

    return SizedBox(
      height: 48,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: last14.map((key) {
          final count = allEntries[key] ?? 0;
          final isToday = key == todayKey;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Tooltip(
                message: '$count/5',
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: FractionallySizedBox(
                        heightFactor: (count / 5).clamp(0.08, 1.0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          decoration: BoxDecoration(
                            color: isToday
                                ? accent
                                : count == 5
                                    ? accent.withValues(alpha: 0.75)
                                    : count >= 3
                                        ? accent.withValues(alpha: 0.45)
                                        : accent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(height: 3),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Quran card ────────────────────────────────────────────────────────────

class _QuranCard extends StatelessWidget {
  const _QuranCard({required this.stats});
  final WorshipStatsSnapshot stats;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const accent = AppColors.accentQuran;
    final khatmahPercent = (stats.khatmahOverallProgress * 100).round();

    return _TappableCard(
      onTap: () => context.push(Routes.quran),
      accentColor: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProgressRow(
            title: 'آخر موضع قراءة',
            trailing:
                'صفحة ${ArabicUtils.toArabicDigits(stats.quranLastPage)} / ٦٠٤',
            value: stats.quranProgress,
            color: accent,
          ),
          if (stats.hasKhatmahPlan) ...[
            const SizedBox(height: 14),
            Divider(height: 1, color: colors.borderSubtle),
            const SizedBox(height: 14),
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => context.push(Routes.quranKhatmah),
              child: Row(
                children: [
                  Expanded(
                    child: _ProgressRow(
                      title: 'تقدم الختمة',
                      trailing: '$khatmahPercent%',
                      value: stats.khatmahOverallProgress,
                      color: AppColors.surahGold,
                      subtitle:
                          'ورد اليوم: ${ArabicUtils.toArabicDigits(stats.khatmahTodayDonePages)} / ${ArabicUtils.toArabicDigits(stats.khatmahTodayTargetPages)} صفحة',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 13,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
            if (stats.khatmahDaysRemaining != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.flag_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'متبقي ${ArabicUtils.toArabicDigits(stats.khatmahDaysRemaining!)} يوم لإتمام الختمة',
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}

// ─── Sebha / Dhikr card ────────────────────────────────────────────────────

class _SebhaCard extends StatelessWidget {
  const _SebhaCard({required this.stats});
  final WorshipStatsSnapshot stats;

  @override
  Widget build(BuildContext context) {
    const accent = AppColors.accentSebha;
    final ratio = stats.sebhaGoalCount == 0
        ? 0.0
        : (stats.sebhaCompletedGoals / stats.sebhaGoalCount).clamp(0.0, 1.0);

    return _TappableCard(
      onTap: () => context.push(Routes.sebha),
      accentColor: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _CountTile(
                  label: 'تسبيح اليوم',
                  value: ArabicUtils.toArabicDigits(stats.sebhaTodayCount),
                  color: accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CountTile(
                  label: 'المجموع الكلي',
                  value: ArabicUtils.toArabicDigits(stats.sebhaTotalCount),
                  color: accent.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          if (stats.sebhaGoalCount > 0) ...[
            const SizedBox(height: 14),
            _ProgressRow(
              title: 'الأهداف اليومية',
              trailing:
                  '${ArabicUtils.toArabicDigits(stats.sebhaCompletedGoals)} / ${ArabicUtils.toArabicDigits(stats.sebhaGoalCount)}',
              value: ratio,
              color: accent,
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Shared widgets ────────────────────────────────────────────────────────

/// Card wrapper with ripple and "عرض التفاصيل" navigation row.
/// Used for Quran and Sebha cards (not Prayer — which has its own structure).
class _TappableCard extends StatelessWidget {
  const _TappableCard({
    required this.child,
    required this.onTap,
    required this.accentColor,
  });
  final Widget child;
  final VoidCallback onTap;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withValues(alpha: 0.25)),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.07),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: child,
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'عرض التفاصيل',
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 12,
                      color: accentColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.title,
    required this.trailing,
    required this.value,
    required this.color,
    this.subtitle,
  });
  final String title;
  final String trailing;
  final double value;
  final Color color;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
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
                  color: colors.textPrimary,
                ),
              ),
            ),
            Text(
              trailing,
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: GoogleFonts.tajawal(
              fontSize: 11,
              color: colors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 7,
            value: value.clamp(0.0, 1.0),
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _CountTile extends StatelessWidget {
  const _CountTile({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.tajawal(
              fontSize: 11,
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
