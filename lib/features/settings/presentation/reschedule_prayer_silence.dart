import 'package:adhan/adhan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/prayer_silence_provider.dart';
import '../../../core/services/prayer_silence_service.dart';
import '../../prayer_times/presentation/providers/prayer_times_provider.dart';

/// Computes today + tomorrow silence windows from [adjustedPrayerTimesProvider]
/// and schedules them on Android via [PrayerSilenceService].
///
/// If the feature is disabled, all existing alarms are cancelled.
/// Returns `true` on success, `false` if prayer times are not yet loaded.
Future<bool> reschedulePrayerSilence(WidgetRef ref) async {
  final settings = ref.read(prayerSilenceProvider);

  if (!settings.enabled) {
    await PrayerSilenceService.cancelAll();
    return true;
  }

  final adjusted = ref.read(adjustedPrayerTimesProvider).asData?.value;
  if (adjusted == null) return false;

  const prayers = [
    Prayer.fajr,
    Prayer.dhuhr,
    Prayer.asr,
    Prayer.maghrib,
    Prayer.isha,
  ];

  final todayTimes = <Prayer, int>{
    for (final p in prayers)
      if (adjusted.timeForPrayer(p) != null)
        p: adjusted.timeForPrayer(p)!.millisecondsSinceEpoch,
  };

  // Tomorrow: +24 h approximation. The Kotlin BOOT_COMPLETED handler
  // re-schedules from the stored JSON (which already contains these ms values),
  // so precision improves the next time Dart recalculates (e.g. on daily open).
  const oneDayMs = 86400000;
  final tomorrowTimes = {
    for (final e in todayTimes.entries) e.key: e.value + oneDayMs,
  };

  return PrayerSilenceService.scheduleWindows(
    settings: settings,
    times: todayTimes,
    timesTomorrow: tomorrowTimes,
  );
}
