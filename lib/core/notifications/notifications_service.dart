import 'dart:io';

import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_10y.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

const _kFajrId    = 1001;
const _kDhuhrId   = 1002;
const _kAsrId     = 1003;
const _kMaghribId = 1004;
const _kIshaId    = 1005;

int _idFor(Prayer prayer) => switch (prayer) {
      Prayer.fajr    => _kFajrId,
      Prayer.dhuhr   => _kDhuhrId,
      Prayer.asr     => _kAsrId,
      Prayer.maghrib => _kMaghribId,
      Prayer.isha    => _kIshaId,
      _              => 0,
    };

String _nameAr(Prayer prayer) => switch (prayer) {
      Prayer.fajr    => 'الفجر',
      Prayer.dhuhr   => 'الظهر',
      Prayer.asr     => 'العصر',
      Prayer.maghrib => 'المغرب',
      Prayer.isha    => 'العشاء',
      _              => '',
    };

const _channelId   = 'prayer_times_channel';
const _channelName = 'مواقيت الصلاة';
const _channelDesc = 'تنبيهات أوقات الصلاة الخمس';

/// Singleton notification service for scheduling prayer-time notifications.
class NotificationsService {
  NotificationsService._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  // ─── Bootstrap ───────────────────────────────────────────────────────────

  static Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    try {
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(tzInfo.identifier));
    } catch (_) {
      _setLocalFromOffset();
    }

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );

    _initialized = true;
  }

  // ─── Permission requests ─────────────────────────────────────────────────

  static Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final impl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (impl == null) return false;
      final granted = await impl.requestNotificationsPermission();
      return granted ?? false;
    } else if (Platform.isIOS) {
      final impl = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (impl == null) return false;
      final granted = await impl.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return true;
  }

  // ─── Scheduling ──────────────────────────────────────────────────────────

  /// Cancels all existing prayer notifications then schedules fresh ones
  /// for the next [daysAhead] days for every enabled prayer.
  static Future<void> rescheduleAll({
    required Coordinates coordinates,
    required CalculationParameters calcParams,
    required Map<Prayer, bool> enabledMap,
    required Map<Prayer, int> offsetMinutes,
    int daysAhead = 7,
  }) async {
    if (!_initialized) await init();
    await cancelAll();

    final now = DateTime.now();

    for (int day = 0; day < daysAhead; day++) {
      final targetDate = now.add(Duration(days: day));
      final dateComponents = DateComponents.from(targetDate);
      final pt = PrayerTimes(coordinates, dateComponents, calcParams);

      for (final prayer in [
        Prayer.fajr,
        Prayer.dhuhr,
        Prayer.asr,
        Prayer.maghrib,
        Prayer.isha,
      ]) {
        if (!(enabledMap[prayer] ?? true)) continue;

        final prayerTime = _prayerDateTime(pt, prayer);
        if (prayerTime == null) continue;

        final offset = offsetMinutes[prayer] ?? 0;
        final scheduled = prayerTime.add(Duration(minutes: offset));
        if (scheduled.isBefore(now)) continue;

        // Unique ID per prayer per day: base_id + day*10
        final notifId = _idFor(prayer) + (day * 10);
        await _scheduleSingle(
          id: notifId,
          prayerName: _nameAr(prayer),
          scheduledTime: scheduled,
        );
      }
    }

    if (kDebugMode) {
      debugPrint(
          '[NotificationsService] Rescheduled prayers for $daysAhead days');
    }
  }

  static Future<void> _scheduleSingle({
    required int id,
    required String prayerName,
    required DateTime scheduledTime,
  }) async {
    final tzTime =
        tz.TZDateTime.from(scheduledTime.toUtc(), tz.UTC);

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: true,
      ),
    );

    try {
      await _plugin.zonedSchedule(
        id: id,
        title: 'حان وقت $prayerName',
        body: 'اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ',
        scheduledDate: tzTime,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexact,
        payload: prayerName,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
            '[NotificationsService] Schedule failed for $prayerName: $e');
      }
    }
  }

  static Future<void> cancelAll() async {
    if (!_initialized) return;
    await _plugin.cancelAll();
  }

  // ─── Debug helpers ───────────────────────────────────────────────────────

  static Future<List<PendingNotificationRequest>> pendingNotifications() async {
    if (!_initialized) return [];
    return _plugin.pendingNotificationRequests();
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  static DateTime? _prayerDateTime(PrayerTimes pt, Prayer prayer) =>
      switch (prayer) {
        Prayer.fajr    => pt.fajr,
        Prayer.dhuhr   => pt.dhuhr,
        Prayer.asr     => pt.asr,
        Prayer.maghrib => pt.maghrib,
        Prayer.isha    => pt.isha,
        _              => null,
      };

  static void _setLocalFromOffset() {
    final hours = DateTime.now().timeZoneOffset.inHours;
    try {
      tz.setLocalLocation(tz.getLocation(_fallbackTz(hours)));
    } catch (_) {}
  }

  static String _fallbackTz(int h) => switch (h) {
        -12 => 'Pacific/Wake',
        -11 => 'Pacific/Midway',
        -10 => 'Pacific/Honolulu',
        -9  => 'America/Anchorage',
        -8  => 'America/Los_Angeles',
        -7  => 'America/Denver',
        -6  => 'America/Chicago',
        -5  => 'America/New_York',
        -4  => 'America/Halifax',
        -3  => 'America/Sao_Paulo',
        -2  => 'Atlantic/South_Georgia',
        -1  => 'Atlantic/Azores',
        0   => 'UTC',
        1   => 'Europe/Paris',
        2   => 'Europe/Helsinki',
        3   => 'Asia/Riyadh',
        4   => 'Asia/Dubai',
        5   => 'Asia/Karachi',
        6   => 'Asia/Dhaka',
        7   => 'Asia/Bangkok',
        8   => 'Asia/Shanghai',
        9   => 'Asia/Tokyo',
        10  => 'Australia/Sydney',
        11  => 'Pacific/Guadalcanal',
        12  => 'Pacific/Auckland',
        _   => 'UTC',
      };
}
