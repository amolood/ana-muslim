import 'dart:io';

import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../providers/prayer_silence_provider.dart';

/// One silence window — start/end in UTC epoch milliseconds.
class SilenceWindow {
  const SilenceWindow({
    required this.prayer,
    required this.startMs,
    required this.endMs,
  });

  final Prayer prayer;
  final int startMs;
  final int endMs;
}

/// Wraps the native `im_muslim/prayer_silence` MethodChannel.
///
/// All calls are no-ops on iOS (the feature is Android-only).
abstract final class PrayerSilenceService {
  static const _channel = MethodChannel('im_muslim/prayer_silence');

  static const _prayers = [
    Prayer.fajr,
    Prayer.dhuhr,
    Prayer.asr,
    Prayer.maghrib,
    Prayer.isha,
  ];

  // ── Permission ─────────────────────────────────────────────────────────────

  /// Returns `true` if DND policy access is granted (or on iOS where the
  /// feature is not supported).
  static Future<bool> hasDndPermission() async {
    if (!Platform.isAndroid) return true;
    try {
      return await _channel.invokeMethod<bool>('checkDndPermission') ?? false;
    } on PlatformException catch (e) {
      if (kDebugMode) debugPrint('[PrayerSilenceService] checkDndPermission: $e');
      return false;
    }
  }

  /// Opens the Android system DND-access settings page.
  static Future<void> openDndSettings() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('openDndSettings');
    } on PlatformException catch (e) {
      if (kDebugMode) debugPrint('[PrayerSilenceService] openDndSettings: $e');
    }
  }

  // ── Scheduling ─────────────────────────────────────────────────────────────

  /// Schedules silence windows on Android via AlarmManager.
  ///
  /// [times] and [timesTomorrow] map each [Prayer] to a UTC epoch-ms value.
  /// Returns `true` on success.
  static Future<bool> scheduleWindows({
    required PrayerSilenceSettings settings,
    required Map<Prayer, int> times,
    required Map<Prayer, int> timesTomorrow,
  }) async {
    if (!Platform.isAndroid) return false;

    final windows = _buildWindows(
      settings: settings,
      times: times,
      timesTomorrow: timesTomorrow,
    );

    if (windows.isEmpty) {
      await cancelAll();
      return true;
    }

    final payload = windows
        .map((w) => {
              'prayer': w.prayer.name,
              'startMs': w.startMs,
              'endMs': w.endMs,
            })
        .toList();

    try {
      final ok = await _channel.invokeMethod<bool>('scheduleWindows', {
        'windows': payload,
        'mode': settings.mode.index,
        'autoRestore': settings.autoRestore,
      });
      return ok ?? false;
    } on PlatformException catch (e) {
      if (kDebugMode) debugPrint('[PrayerSilenceService] scheduleWindows: $e');
      return false;
    }
  }

  /// Cancels all previously scheduled silence alarms.
  static Future<void> cancelAll() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('cancelAllWindows');
    } on PlatformException catch (e) {
      if (kDebugMode) debugPrint('[PrayerSilenceService] cancelAll: $e');
    }
  }

  // ── Window building (also used for the "Today's Schedule" display) ─────────

  /// Builds windows from [times] + [timesTomorrow], filtered by [settings].
  ///
  /// Useful for showing a preview in the settings UI without a platform call.
  static List<SilenceWindow> buildWindowsForDisplay({
    required PrayerSilenceSettings settings,
    required Map<Prayer, int> times,
    required Map<Prayer, int> timesTomorrow,
  }) =>
      _buildWindows(
        settings: settings,
        times: times,
        timesTomorrow: timesTomorrow,
      );

  static List<SilenceWindow> _buildWindows({
    required PrayerSilenceSettings settings,
    required Map<Prayer, int> times,
    required Map<Prayer, int> timesTomorrow,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final windows = <SilenceWindow>[];

    for (final prayer in _prayers) {
      if (!settings.isIncluded(prayer)) continue;
      for (final dayTimes in [times, timesTomorrow]) {
        final adhanMs = dayTimes[prayer];
        if (adhanMs == null) continue;
        final start = adhanMs - settings.minutesBefore * 60000;
        final end = adhanMs + settings.minutesAfter * 60000;
        if (end <= now) continue; // fully elapsed
        windows.add(SilenceWindow(prayer: prayer, startMs: start, endMs: end));
      }
    }

    return windows;
  }
}
