import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/providers/clock_provider.dart';
import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/services/widget_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/utils/arabic_utils.dart';
import '../../../../core/utils/prayer_utils.dart';
import '../../../prayer_times/presentation/providers/prayer_times_provider.dart';

/// بطاقة التاريخ والصلاة القادمة — تُحدَّث تلقائيًا عبر [clockProvider]
class PrayerTimesCard extends ConsumerWidget {
  const PrayerTimesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider).asData?.value ?? DateTime.now();
    final adjustedPrayerTimesAsync = ref.watch(adjustedPrayerTimesProvider);
    final locationNameAsync = ref.watch(locationNameProvider);
    final hijriOffset = ref.watch(hijriOffsetProvider);

    HijriCalendar.setLocal('ar');
    final adjustedForHijri = now.add(Duration(days: hijriOffset));
    final hijri = HijriCalendar.fromDate(adjustedForHijri);
    final gregorian = DateFormat('EEEE، d MMMM yyyy', 'ar').format(now);
    final hijriText = '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} هـ';

    return adjustedPrayerTimesAsync.when(
      data: (adjustedPrayerTimes) {
        final upcoming = _getUpcomingPrayer(adjustedPrayerTimes, now);
        final remaining = PrayerUtils.getRemainingTime(upcoming.time, now);
        final countdownStr = ArabicUtils.formatCountdown(remaining);

        // Sync prayer data to home-screen widgets.
        // WidgetService internally throttles to ≤1 update per minute
        // (unless the next prayer changes), so this is safe to call
        // every build without overwhelming the platform channel.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Format raw 24h times for the all-5-prayers widget
          String raw24(DateTime dt) =>
              '${dt.toLocal().hour.toString().padLeft(2, '0')}:'
              '${dt.toLocal().minute.toString().padLeft(2, '0')}';

          final dayIndexSun1 = _dayIndexSun1(now);

          WidgetService.updatePrayerWidgets(
            hijriDate: hijriText,
            gregorianDate: gregorian,
            dayName: DateFormat('EEEE', 'ar').format(now),
            dayCalligraphyDigit: dayIndexSun1.toString(),
            dayIndexSun1: dayIndexSun1,
            widgetPayloadVersion: 2,
            nextPrayerName: upcoming.prayer.arLong,
            nextPrayerTime: ArabicUtils.ensureLatinDigits(
              DateFormat.jm('ar').format(upcoming.time),
            ),
            countdown: 'متبقي $countdownStr',
            allPrayerTimes: {
              'fajr': raw24(adjustedPrayerTimes.fajr),
              'dhuhr': raw24(adjustedPrayerTimes.dhuhr),
              'asr': raw24(adjustedPrayerTimes.asr),
              'maghrib': raw24(adjustedPrayerTimes.maghrib),
              'isha': raw24(adjustedPrayerTimes.isha),
            },
            hijriMonthNumber: hijri.hMonth,
            hijriMonthName: hijri.longMonthName,
          );
        });

        return locationNameAsync.when(
          data: (locName) => _buildContent(
            context,
            hijriText: hijriText,
            gregorian: gregorian,
            location: locName,
            prayerName: upcoming.prayer.arLong,
            countdown: countdownStr,
          ),
          loading: () => _buildContent(
            context,
            hijriText: hijriText,
            gregorian: gregorian,
            location: context.l10n.locating,
            prayerName: upcoming.prayer.arLong,
            countdown: countdownStr,
          ),
          error: (_, _) => _buildContent(
            context,
            hijriText: hijriText,
            gregorian: gregorian,
            location: context.l10n.unknownLocation,
            prayerName: upcoming.prayer.arLong,
            countdown: countdownStr,
          ),
        );
      },
      loading: () => _buildContent(
        context,
        hijriText: hijriText,
        gregorian: gregorian,
        location: context.l10n.loading,
        prayerName: '...',
        countdown: '٠٠:٠٠:٠٠',
      ),
      error: (_, _) => _buildContent(
        context,
        hijriText: hijriText,
        gregorian: gregorian,
        location: context.l10n.locationError,
        prayerName: '--',
        countdown: '--:--:--',
      ),
    );
  }

  UpcomingPrayerInfo _getUpcomingPrayer(
    AdjustedPrayerTimes adjustedPrayerTimes,
    DateTime now,
  ) {
    const orderedPrayers = <Prayer>[
      Prayer.fajr,
      Prayer.sunrise,
      Prayer.dhuhr,
      Prayer.asr,
      Prayer.maghrib,
      Prayer.isha,
    ];

    for (final prayer in orderedPrayers) {
      final prayerTime = adjustedPrayerTimes.timeForPrayer(prayer)?.toLocal();
      if (prayerTime != null && prayerTime.isAfter(now)) {
        return UpcomingPrayerInfo(prayer: prayer, time: prayerTime);
      }
    }

    return UpcomingPrayerInfo(
      prayer: Prayer.fajr,
      time: adjustedPrayerTimes.fajr.toLocal().add(const Duration(days: 1)),
    );
  }

  int _dayIndexSun1(DateTime dateTime) {
    return dateTime.weekday == DateTime.sunday ? 1 : dateTime.weekday + 1;
  }

  Widget _buildContent(
    BuildContext context, {
    required String hijriText,
    required String gregorian,
    required String location,
    required String prayerName,
    required String countdown,
  }) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: GestureDetector(
        onTap: () => context.push(Routes.prayerTimes),
        child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isDark
              ? const Color(0xFF1B5A52)
              : AppColors.surfaceLightCard,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : AppColors.primary.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.todayDateLabel,
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hijriText,
                        style: GoogleFonts.tajawal(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                        ),
                      ),
                      Text(
                        gregorian,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceDarker.withValues(alpha: 0.50)
                          : Colors.white.withValues(alpha: 0.50),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: AppColors.primary,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.tajawal(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Divider(
                color: colors.borderSubtle.withValues(alpha: 0.5),
                height: 1,
              ),
            ),
            Row(
              children: [
                const Icon(
                  FlutterIslamicIcons.solidPrayer,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.nextPrayerLabel,
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                Text(
                  countdown,
                  style: GoogleFonts.manrope(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  context.l10n.remainingLabel,
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                prayerName,
                style: TextStyle(
                  fontFamily: 'KFGQPC Uthmanic Script',
                  fontFamilyFallback: const ['naskh'],
                  fontSize: 32,
                  color: isDark
                      ? AppColors.surahGold
                      : AppColors.primary,
                  height: 1.15,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'عرض جميع الصلوات',
                  style: GoogleFonts.tajawal(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.primary,
                  size: 11,
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}


