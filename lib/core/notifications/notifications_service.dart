import 'dart:io';

import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_10y.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

const _kFajrId = 1001;
const _kDhuhrId = 1002;
const _kAsrId = 1003;
const _kMaghribId = 1004;
const _kIshaId = 1005;
const _kKhatmahBaseId = 5001;
const _kMotivationBaseId = 8001;
const _kMotivationSlotStride = 100;
const _kMotivationMaxPerDay = 60;
const _kPrayerDaysAheadDefault = 30;

int _idFor(Prayer prayer) => switch (prayer) {
  Prayer.fajr => _kFajrId,
  Prayer.dhuhr => _kDhuhrId,
  Prayer.asr => _kAsrId,
  Prayer.maghrib => _kMaghribId,
  Prayer.isha => _kIshaId,
  _ => 0,
};

String _nameAr(Prayer prayer) => switch (prayer) {
  Prayer.fajr => 'الفجر',
  Prayer.dhuhr => 'الظهر',
  Prayer.asr => 'العصر',
  Prayer.maghrib => 'المغرب',
  Prayer.isha => 'العشاء',
  _ => '',
};

// Versioned channel ids to force fresh sound settings on existing installs.
const _channelId = 'prayer_times_azan_v3';
const _channelBypassDndId = 'prayer_times_azan_bypass_v3';
const _channelName = 'مواقيت الصلاة';
const _channelDesc = 'تنبيهات أوقات الصلاة الخمس';

/// Singleton notification service for scheduling prayer-time notifications.
class NotificationsService {
  NotificationsService._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static String? _lastMotivationScheduleKey;
  static String? _lastPrayerScheduleSignature;
  static String? _lastManualPrayerScheduleSignature;

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

    await _ensureAndroidChannels();
    _initialized = true;
  }

  static Future<void> _ensureAndroidChannels() async {
    if (!Platform.isAndroid) {
      return;
    }

    final impl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (impl == null) {
      return;
    }

    await _ensureStandardAdhanChannel(impl);
    await _ensureBypassDndAdhanChannelIfAllowed(impl);
  }

  static Future<void> _ensureStandardAdhanChannel(
    AndroidFlutterLocalNotificationsPlugin impl,
  ) async {
    await impl.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('azan'),
        enableVibration: true,
        audioAttributesUsage: AudioAttributesUsage.alarm,
      ),
    );
  }

  static Future<void> _ensureBypassDndAdhanChannelIfAllowed(
    AndroidFlutterLocalNotificationsPlugin impl,
  ) async {
    final hasPolicyAccess = await impl.hasNotificationPolicyAccess() ?? false;
    if (!hasPolicyAccess) {
      return;
    }

    await impl.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelBypassDndId,
        _channelName,
        description: _channelDesc,
        importance: Importance.max,
        bypassDnd: true,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('azan'),
        enableVibration: true,
        audioAttributesUsage: AudioAttributesUsage.alarm,
      ),
    );
  }

  // ─── Permission requests ─────────────────────────────────────────────────

  static Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final impl = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (impl == null) return false;
      final granted = await impl.requestNotificationsPermission();
      return granted ?? false;
    } else if (Platform.isIOS) {
      final impl = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
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

  static Future<bool> areNotificationsEnabled() async {
    if (!_initialized) {
      await init();
    }

    if (Platform.isAndroid) {
      final impl = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await impl?.areNotificationsEnabled() ?? true;
    }

    // iOS/macOS: treat as enabled when plugin is initialized.
    return true;
  }

  static Future<bool> canScheduleExactAlarms() async {
    if (!_initialized) {
      await init();
    }
    if (!Platform.isAndroid) {
      return true;
    }

    final impl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final can = await impl?.canScheduleExactNotifications();
    return can ?? true;
  }

  static Future<bool> requestExactAlarmsPermission() async {
    if (!_initialized) {
      await init();
    }
    if (!Platform.isAndroid) {
      return true;
    }

    final impl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final granted = await impl?.requestExactAlarmsPermission();
    return granted ?? false;
  }

  static Future<bool> hasNotificationPolicyAccess() async {
    if (!_initialized) {
      await init();
    }
    if (!Platform.isAndroid) {
      return true;
    }

    final impl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final granted = await impl?.hasNotificationPolicyAccess();
    return granted ?? false;
  }

  static Future<bool> requestNotificationPolicyAccess() async {
    if (!_initialized) {
      await init();
    }
    if (!Platform.isAndroid) {
      return true;
    }

    final impl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final granted = await impl?.requestNotificationPolicyAccess();
    await _ensureAndroidChannels();
    return granted ?? false;
  }

  static Future<bool> requestFullScreenIntentPermission() async {
    if (!_initialized) {
      await init();
    }
    if (!Platform.isAndroid) {
      return true;
    }

    final impl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final granted = await impl?.requestFullScreenIntentPermission();
    return granted ?? false;
  }

  static Future<String> _resolvePrayerChannelId() async {
    if (!Platform.isAndroid) {
      return _channelId;
    }

    final impl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (impl == null) {
      return _channelId;
    }

    final hasPolicyAccess = await impl.hasNotificationPolicyAccess() ?? false;
    if (!hasPolicyAccess) {
      return _channelId;
    }

    await _ensureBypassDndAdhanChannelIfAllowed(impl);
    return _channelBypassDndId;
  }

  // ─── Scheduling ──────────────────────────────────────────────────────────

  /// Cancels all existing prayer notifications then schedules fresh ones
  /// for the next [daysAhead] days for every enabled prayer.
  static Future<void> rescheduleAll({
    required Coordinates coordinates,
    required CalculationParameters calcParams,
    required Map<Prayer, bool> enabledMap,
    required Map<Prayer, int> prayerAdjustMinutes,
    required Map<Prayer, int> offsetMinutes,
    String? scheduleSignature,
    int daysAhead = _kPrayerDaysAheadDefault,
  }) async {
    if (!_initialized) await init();
    if (scheduleSignature != null &&
        _lastPrayerScheduleSignature == scheduleSignature) {
      return;
    }
    await _cancelPrayerNotifications(daysToClear: daysAhead + 14);
    final channelId = await _resolvePrayerChannelId();
    final bypassDnd = channelId == _channelBypassDndId;

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

        final timeAdjust = prayerAdjustMinutes[prayer] ?? 0;
        final offset = offsetMinutes[prayer] ?? 0;
        final scheduled = prayerTime.add(
          Duration(minutes: timeAdjust + offset),
        );
        if (scheduled.isBefore(now)) continue;

        // Unique ID per prayer per day: base_id + day*10
        final notifId = _idFor(prayer) + (day * 10);
        await _scheduleSingle(
          id: notifId,
          prayerName: _nameAr(prayer),
          scheduledTime: scheduled,
          channelId: channelId,
          channelBypassDnd: bypassDnd,
        );
      }
    }

    if (kDebugMode) {
      debugPrint(
        '[NotificationsService] Rescheduled prayers for $daysAhead days',
      );
    }
    _lastPrayerScheduleSignature = scheduleSignature;
  }

  /// Schedules prayer notifications using explicit user-defined prayer times.
  /// [manualTimes] date parts are ignored; only hour/minute are used.
  static Future<void> rescheduleManualPrayerTimes({
    required Map<Prayer, bool> enabledMap,
    required Map<Prayer, DateTime> manualTimes,
    required Map<Prayer, int> offsetMinutes,
    String? scheduleSignature,
    int daysAhead = _kPrayerDaysAheadDefault,
  }) async {
    if (!_initialized) await init();
    if (scheduleSignature != null &&
        _lastManualPrayerScheduleSignature == scheduleSignature) {
      return;
    }
    await _cancelPrayerNotifications(daysToClear: daysAhead + 14);
    final channelId = await _resolvePrayerChannelId();
    final bypassDnd = channelId == _channelBypassDndId;

    final now = DateTime.now();
    const prayers = [
      Prayer.fajr,
      Prayer.dhuhr,
      Prayer.asr,
      Prayer.maghrib,
      Prayer.isha,
    ];

    for (int day = 0; day < daysAhead; day++) {
      final targetDate = now.add(Duration(days: day));
      for (final prayer in prayers) {
        if (!(enabledMap[prayer] ?? true)) continue;

        final configured = manualTimes[prayer];
        if (configured == null) continue;

        final scheduledBase = DateTime(
          targetDate.year,
          targetDate.month,
          targetDate.day,
          configured.hour,
          configured.minute,
        );
        final scheduled = scheduledBase.add(
          Duration(minutes: offsetMinutes[prayer] ?? 0),
        );
        if (scheduled.isBefore(now)) continue;

        final notifId = _idFor(prayer) + (day * 10);
        await _scheduleSingle(
          id: notifId,
          prayerName: _nameAr(prayer),
          scheduledTime: scheduled,
          channelId: channelId,
          channelBypassDnd: bypassDnd,
        );
      }
    }

    if (kDebugMode) {
      debugPrint(
        '[NotificationsService] Rescheduled manual prayers for $daysAhead days',
      );
    }
    _lastManualPrayerScheduleSignature = scheduleSignature;
  }

  static Future<void> _scheduleSingle({
    required int id,
    required String prayerName,
    required DateTime scheduledTime,
    required String channelId,
    required bool channelBypassDnd,
  }) async {
    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.max,
        priority: Priority.max,
        category: AndroidNotificationCategory.alarm,
        fullScreenIntent: true,
        visibility: NotificationVisibility.public,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('azan'),
        enableVibration: true,
        channelBypassDnd: channelBypassDnd,
        audioAttributesUsage: AudioAttributesUsage.alarm,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: true,
        sound: 'azan.mp3',
      ),
    );

    try {
      await _plugin.zonedSchedule(
        id: id,
        title: 'حان وقت $prayerName',
        body: 'اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ',
        scheduledDate: tzTime,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: prayerName,
      );
    } catch (e) {
      try {
        // Fallback when exact alarms are restricted by system policy.
        await _plugin.zonedSchedule(
          id: id,
          title: 'حان وقت $prayerName',
          body: 'اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ',
          scheduledDate: tzTime,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: prayerName,
        );
      } catch (fallbackError) {
        if (kDebugMode) {
          debugPrint(
            '[NotificationsService] Schedule failed for $prayerName: '
            '$e | fallback: $fallbackError',
          );
        }
      }
    }
  }

  // ─── Daily reminders ─────────────────────────────────────────────────────

  /// Schedules a daily notification at [hour]:[minute] for the next 7 days.
  /// Uses IDs [baseId, baseId+1, ..., baseId+6].
  static Future<void> scheduleDailyReminder({
    required int baseId,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    if (!_initialized) await init();

    final now = DateTime.now();
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_reminders_channel',
        'التذكيرات اليومية',
        channelDescription: 'تذكيرات يومية للصلاة على النبي والورد',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: true,
      ),
    );

    for (int day = 0; day < 7; day++) {
      final target = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      ).add(Duration(days: day));
      if (target.isBefore(now)) continue;
      final tzTime = tz.TZDateTime.from(target, tz.local);
      try {
        await _plugin.zonedSchedule(
          id: baseId + day,
          title: title,
          body: body,
          scheduledDate: tzTime,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexact,
        );
      } catch (_) {}
    }
  }

  /// Cancels daily reminder notifications for [baseId..baseId+6].
  static Future<void> cancelDailyReminder(int baseId) async {
    if (!_initialized) return;
    await _cancelByIds([for (int i = 0; i < 7; i++) baseId + i]);
  }

  static const _motivationBodies = <String>[
    'دقيقة ذكر تغيّر يومك. قل: سبحان الله',
    'لا تنس نصيبك من القرآن اليوم، ولو صفحة واحدة',
    'الذكر حياة للقلب، ابدأ الآن بتسبيحات يسيرة',
    'اجعل لسانك رطبًا بذكر الله',
    'صلّ على النبي ﷺ واغتنم الأجر',
    'تقدمك اليومي في العبادة يبني أثرًا عظيمًا',
    'اقتربت من هدفك اليومي، أكمل الطريق',
    'أفضل الأعمال أدومها وإن قلّ',
  ];

  /// Schedules motivational reminders during the day for the next 3 days.
  static Future<void> scheduleMotivationReminders({
    required bool enabled,
    required int startHour,
    required int endHour,
    required int remindersPerDay,
  }) async {
    if (!_initialized) await init();

    final safeStart = startHour.clamp(0, 23);
    final safeEndRaw = endHour.clamp(1, 23);
    final safeEnd = safeEndRaw <= safeStart
        ? (safeStart + 1).clamp(1, 23)
        : safeEndRaw;
    final perDay = remindersPerDay.clamp(0, _kMotivationMaxPerDay);
    final scheduleKey = '$enabled:$safeStart:$safeEnd:$perDay';
    if (_lastMotivationScheduleKey == scheduleKey) {
      return;
    }

    await cancelMotivationReminders();
    _lastMotivationScheduleKey = scheduleKey;
    if (!enabled || perDay == 0) return;

    final now = DateTime.now();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'motivation_reminders_channel',
        'تذكيرات التحفيز',
        channelDescription: 'تذكيرات يومية للذكر وقراءة القرآن',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: true,
      ),
    );

    final rangeMinutes = (safeEnd - safeStart) * 60;
    for (int day = 0; day < 3; day++) {
      final dayDate = DateTime(
        now.year,
        now.month,
        now.day,
      ).add(Duration(days: day));

      for (int slot = 0; slot < perDay; slot++) {
        final fraction = (slot + 1) / (perDay + 1);
        final offsetMinutes = (rangeMinutes * fraction).round();
        final target = dayDate.add(
          Duration(hours: safeStart, minutes: offsetMinutes),
        );
        if (target.isBefore(now)) continue;

        final tzTime = tz.TZDateTime.from(target, tz.local);
        final id = _kMotivationBaseId + (day * _kMotivationSlotStride) + slot;
        final body = _motivationBodies[(day + slot) % _motivationBodies.length];

        try {
          await _plugin.zonedSchedule(
            id: id,
            title: 'رفيقك في العبادة',
            body: body,
            scheduledDate: tzTime,
            notificationDetails: details,
            androidScheduleMode: AndroidScheduleMode.inexact,
          );
        } catch (_) {}
      }
    }
  }

  static Future<void> cancelMotivationReminders() async {
    if (!_initialized) return;
    final ids = await _existingIdsInRange(_kMotivationBaseId, 3000);
    if (ids.isNotEmpty) {
      await _cancelByIds(ids);
    }
    _lastMotivationScheduleKey = null;
  }

  /// Schedules a daily Khatmah reminder for the next 14 days.
  static Future<void> scheduleKhatmahReminder({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    if (!_initialized) await init();

    final now = DateTime.now();
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'khatmah_reminder_channel',
        'تذكير الختمة',
        channelDescription: 'تنبيه يومي لورد الختمة',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: true,
      ),
    );

    await cancelKhatmahReminder();

    for (int day = 0; day < 14; day++) {
      final target = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      ).add(Duration(days: day));
      if (target.isBefore(now)) continue;
      final tzTime = tz.TZDateTime.from(target, tz.local);
      try {
        await _plugin.zonedSchedule(
          id: _kKhatmahBaseId + day,
          title: title,
          body: body,
          scheduledDate: tzTime,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexact,
        );
      } catch (_) {}
    }
  }

  static Future<void> cancelKhatmahReminder() async {
    if (!_initialized) return;
    await _cancelByIds([for (int i = 0; i < 14; i++) _kKhatmahBaseId + i]);
  }

  static Future<void> cancelAll() async {
    if (!_initialized) return;
    await _plugin.cancelAll();
    _lastMotivationScheduleKey = null;
    _lastPrayerScheduleSignature = null;
    _lastManualPrayerScheduleSignature = null;
  }

  // ─── Debug helpers ───────────────────────────────────────────────────────

  static Future<List<PendingNotificationRequest>> pendingNotifications() async {
    if (!_initialized) return [];
    return _plugin.pendingNotificationRequests();
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  static DateTime? _prayerDateTime(PrayerTimes pt, Prayer prayer) =>
      switch (prayer) {
        Prayer.fajr => pt.fajr,
        Prayer.dhuhr => pt.dhuhr,
        Prayer.asr => pt.asr,
        Prayer.maghrib => pt.maghrib,
        Prayer.isha => pt.isha,
        _ => null,
      };

  static Future<void> _cancelPrayerNotifications({
    required int daysToClear,
  }) async {
    final safeDays = daysToClear.clamp(1, 120);
    final targetIds = <int>[];
    for (int day = 0; day < safeDays; day++) {
      for (final prayer in const [
        Prayer.fajr,
        Prayer.dhuhr,
        Prayer.asr,
        Prayer.maghrib,
        Prayer.isha,
      ]) {
        targetIds.add(_idFor(prayer) + (day * 10));
      }
    }
    await _cancelByIds(targetIds);
  }

  static Future<List<int>> _existingIdsInRange(int baseId, int length) async {
    if (!_initialized || length <= 0) return const [];
    final pendingIds = await _pendingIds();
    if (pendingIds.isEmpty) return const [];
    final endId = baseId + length - 1;
    return pendingIds
        .where((id) => id >= baseId && id <= endId)
        .toList(growable: false);
  }

  static Future<Set<int>> _pendingIds() async {
    final pending = await _plugin.pendingNotificationRequests();
    return pending.map((request) => request.id).toSet();
  }

  static Future<void> _cancelByIds(Iterable<int> ids) async {
    if (!_initialized) return;
    final uniqueIds = ids.toSet();
    if (uniqueIds.isEmpty) return;

    final pendingIds = await _pendingIds();
    if (pendingIds.isEmpty) return;

    for (final id in uniqueIds) {
      if (!pendingIds.contains(id)) continue;
      await _plugin.cancel(id: id);
    }
  }

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
    -9 => 'America/Anchorage',
    -8 => 'America/Los_Angeles',
    -7 => 'America/Denver',
    -6 => 'America/Chicago',
    -5 => 'America/New_York',
    -4 => 'America/Halifax',
    -3 => 'America/Sao_Paulo',
    -2 => 'Atlantic/South_Georgia',
    -1 => 'Atlantic/Azores',
    0 => 'UTC',
    1 => 'Europe/Paris',
    2 => 'Europe/Helsinki',
    3 => 'Asia/Riyadh',
    4 => 'Asia/Dubai',
    5 => 'Asia/Karachi',
    6 => 'Asia/Dhaka',
    7 => 'Asia/Bangkok',
    8 => 'Asia/Shanghai',
    9 => 'Asia/Tokyo',
    10 => 'Australia/Sydney',
    11 => 'Pacific/Guadalcanal',
    12 => 'Pacific/Auckland',
    _ => 'UTC',
  };
}
