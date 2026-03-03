import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../prayer_times/presentation/providers/prayer_times_provider.dart';
import '../widgets/manual_location_tile.dart';
import '../widgets/prayer_exact_time_tile.dart';
import '../widgets/prayer_offset_tile.dart';

class PrayerAdjustmentScreen extends ConsumerWidget {
  const PrayerAdjustmentScreen({super.key});

  static const _prayers = [
    Prayer.fajr,
    Prayer.sunrise,
    Prayer.dhuhr,
    Prayer.asr,
    Prayer.maghrib,
    Prayer.isha,
  ];

  static const _arNames = {
    Prayer.fajr: 'الفجر',
    Prayer.sunrise: 'الشروق',
    Prayer.dhuhr: 'الظهر',
    Prayer.asr: 'العصر',
    Prayer.maghrib: 'المغرب',
    Prayer.isha: 'العشاء',
  };

  static const _icons = {
    Prayer.fajr: Icons.wb_twilight,
    Prayer.sunrise: Icons.wb_sunny_outlined,
    Prayer.dhuhr: Icons.light_mode,
    Prayer.asr: Icons.wb_cloudy_outlined,
    Prayer.maghrib: Icons.nights_stay_outlined,
    Prayer.isha: Icons.dark_mode_outlined,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offsets = ref.watch(prayerManualOffsetsProvider);
    final manualExact = ref.watch(prayerManualExactSettingsProvider);
    final isManualMode = manualExact.enabled;
    final adjAsync = ref.watch(adjustedPrayerTimesProvider);
    final manualLoc = ref.watch(manualLocationProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 20, 6),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.textPrimary(context),
                      size: 20,
                    ),
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'ضبط مواقيت الصلاة',
                          style: GoogleFonts.tajawal(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                        Text(
                          isManualMode
                              ? 'تحديد وقت دقيق لكل صلاة يدويًا'
                              : 'أضف أو اطرح دقائق من كل صلاة',
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isManualMode && manualExact.hasCustomTimes)
                    TextButton(
                      onPressed: () => ref
                          .read(prayerManualExactSettingsProvider.notifier)
                          .resetTimes(),
                      child: Text(
                        'إعادة الأوقات',
                        style: GoogleFonts.tajawal(
                          fontSize: 13,
                          color: Colors.red.shade400,
                        ),
                      ),
                    )
                  else if (!isManualMode && offsets.hasAnyOffset)
                    TextButton(
                      onPressed: () => ref
                          .read(prayerManualOffsetsProvider.notifier)
                          .resetAll(),
                      child: Text(
                        'إعادة تعيين',
                        style: GoogleFonts.tajawal(
                          fontSize: 13,
                          color: Colors.red.shade400,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.28),
                ),
              ),
              child: SwitchListTile.adaptive(
                value: isManualMode,
                onChanged: (value) async {
                  await ref
                      .read(prayerManualExactSettingsProvider.notifier)
                      .setEnabled(value);
                },
                title: Text(
                  'تحديد يدوي كامل للمواقيت',
                  style: GoogleFonts.tajawal(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                  isManualMode
                      ? 'مفعّل الآن: الأوقات المعروضة والتنبيهات تعتمد على الوقت اليدوي.'
                      : 'معطّل الآن: الحساب تلقائي حسب الموقع + إمكانية الإزاحة بالدقائق.',
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    color: AppColors.textSecondaryDark,
                    height: 1.35,
                  ),
                ),
                activeThumbColor: AppColors.primary,
                activeTrackColor: AppColors.primary.withValues(alpha: 0.45),
              ),
            ),
            if (!isManualMode) ...[
              // ─── Manual location tile ───────────────────────────
              ManualLocationTile(manualLoc: manualLoc),
              const SizedBox(height: 4),
            ],
            // Info banner
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isManualMode
                          ? 'عند تفعيل الوضع اليدوي، تختار وقت كل صلاة مباشرة بالدقيقة.'
                          : 'القيم تُحفظ فوراً. موجب (+) يؤخّر الوقت، سالب (−) يقدّمه.',
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        color: AppColors.textSecondaryDark,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                children: isManualMode
                    ? _prayers.map((prayer) {
                        final exact = manualExact.timeFor(prayer);
                        final timeLabel = _formatTime(exact);
                        return PrayerExactTimeTile(
                          name: _arNames[prayer]!,
                          icon: _icons[prayer]!,
                          timeLabel: timeLabel,
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(
                                hour: exact.hour,
                                minute: exact.minute,
                              ),
                              builder: (context, child) => Directionality(
                                textDirection: TextDirection.rtl,
                                child: child ?? const SizedBox.shrink(),
                              ),
                            );
                            if (picked == null) return;
                            await ref
                                .read(
                                  prayerManualExactSettingsProvider.notifier,
                                )
                                .setPrayerTime(
                                  prayer,
                                  hour: picked.hour,
                                  minute: picked.minute,
                                );
                          },
                        );
                      }).toList()
                    : _prayers.map((prayer) {
                        final offset = offsets.offsetFor(prayer);
                        final adjTime = adjAsync.maybeWhen(
                          data: (a) => a.timeForPrayer(prayer),
                          orElse: () => null,
                        );
                        return PrayerOffsetTile(
                          prayer: prayer,
                          name: _arNames[prayer]!,
                          icon: _icons[prayer]!,
                          offset: offset,
                          adjustedTime: adjTime,
                          onChanged: (val) => ref
                              .read(prayerManualOffsetsProvider.notifier)
                              .setOffset(prayer, val.round()),
                        );
                      }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(PrayerExactTime value) {
    final now = DateTime.now();
    final date = DateTime(
      now.year,
      now.month,
      now.day,
      value.hour,
      value.minute,
    );
    return DateFormat(
      'hh:mm a',
    ).format(date).replaceAll('AM', 'ص').replaceAll('PM', 'م');
  }
}
