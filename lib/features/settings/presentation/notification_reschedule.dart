import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/notifications/notifications_service.dart';
import '../../../core/providers/preferences_provider.dart';
import '../../prayer_times/presentation/providers/prayer_times_provider.dart';

/// Builds [CalculationParameters] from the Arabic method display string.
///
/// This is the **single source of truth** for prayer calculation params.
/// Used by: display ([prayerTimesProvider]), notification scheduling
/// ([_NotificationScheduler]), and manual reschedule triggers.
/// Always sets [Madhab.shafi] so Asr times are consistent everywhere.
CalculationParameters buildCalculationParams(String method) {
  final params = switch (method) {
    'رابطة العالم الإسلامي' =>
      CalculationMethod.muslim_world_league.getParameters(),
    'الهيئة العامة للمساحة المصرية' =>
      CalculationMethod.egyptian.getParameters(),
    'جامعة العلوم الإسلامية بكراتشي' =>
      CalculationMethod.karachi.getParameters(),
    'الجمعية الإسلامية لأمريكا الشمالية' =>
      CalculationMethod.north_america.getParameters(),
    _ => CalculationMethod.umm_al_qura.getParameters(),
  };
  params.madhab = Madhab.shafi;
  return params;
}

/// Automatically reschedules prayer notifications based on current settings.
/// Can be called from any screen when notification-related settings change.
Future<void> reschedulePrayerNotifications(
  WidgetRef ref, {
  BuildContext? context,
  bool showSuccessMessage = false,
}) async {
  try {
    final globalEnabled = ref.read(adhanAlertsProvider);
    final notifSettings = ref.read(prayerNotifSettingsProvider);
    final manualExact = ref.read(prayerManualExactSettingsProvider);

    const prayers = [
      Prayer.fajr,
      Prayer.dhuhr,
      Prayer.asr,
      Prayer.maghrib,
      Prayer.isha,
    ];
    final enabledMap = <Prayer, bool>{
      for (final p in prayers) p: globalEnabled && notifSettings.isEnabled(p),
    };
    final offsetMap = <Prayer, int>{
      for (final p in prayers) p: notifSettings.offsetFor(p),
    };

    if (manualExact.enabled) {
      final now = DateTime.now();
      await NotificationsService.rescheduleManualPrayerTimes(
        enabledMap: enabledMap,
        manualTimes: <Prayer, DateTime>{
          Prayer.fajr: manualExact.dateTimeFor(Prayer.fajr, now),
          Prayer.dhuhr: manualExact.dateTimeFor(Prayer.dhuhr, now),
          Prayer.asr: manualExact.dateTimeFor(Prayer.asr, now),
          Prayer.maghrib: manualExact.dateTimeFor(Prayer.maghrib, now),
          Prayer.isha: manualExact.dateTimeFor(Prayer.isha, now),
        },
        offsetMinutes: offsetMap,
      );
    } else {
      final position = await ref.read(locationProvider.future);
      final calcMethodStr = ref.read(calculationMethodProvider);
      final coords = Coordinates(position.latitude, position.longitude);
      final params = buildCalculationParams(calcMethodStr);
      final prayerAdjust = ref.read(prayerManualOffsetsProvider);

      await NotificationsService.rescheduleAll(
        coordinates: coords,
        calcParams: params,
        enabledMap: enabledMap,
        prayerAdjustMinutes: <Prayer, int>{
          Prayer.fajr: prayerAdjust.fajr,
          Prayer.dhuhr: prayerAdjust.dhuhr,
          Prayer.asr: prayerAdjust.asr,
          Prayer.maghrib: prayerAdjust.maghrib,
          Prayer.isha: prayerAdjust.isha,
        },
        offsetMinutes: offsetMap,
      );
    }

    if (showSuccessMessage && context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تمت إعادة جدولة تنبيهات الصلاة',
            style: GoogleFonts.tajawal(),
          ),
        ),
      );
    }
  } catch (e) {
    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذّر إعادة الجدولة: $e',
            style: GoogleFonts.tajawal(),
          ),
        ),
      );
    }
  }
}
