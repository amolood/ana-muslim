import 'dart:async';
import 'dart:io';

import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_10y.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

part 'notifications_service_permissions.dart';
part 'notifications_service_scheduling.dart';
part 'notifications_service_reminders.dart';

// ─── Notification ID constants ────────────────────────────────────────────────

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

int _notifIdFor(Prayer prayer) => switch (prayer) {
      Prayer.fajr => _kFajrId,
      Prayer.dhuhr => _kDhuhrId,
      Prayer.asr => _kAsrId,
      Prayer.maghrib => _kMaghribId,
      Prayer.isha => _kIshaId,
      _ => 0,
    };

String _notifNameAr(Prayer prayer) => switch (prayer) {
      Prayer.fajr => 'الفجر',
      Prayer.dhuhr => 'الظهر',
      Prayer.asr => 'العصر',
      Prayer.maghrib => 'المغرب',
      Prayer.isha => 'العشاء',
      _ => '',
    };

// Versioned channel ids to force fresh sound settings on existing installs.
const _kChannelId = 'prayer_times_azan_v3';
const _kChannelBypassDndId = 'prayer_times_azan_bypass_v3';
const _kChannelName = 'مواقيت الصلاة';
const _kChannelDesc = 'تنبيهات أوقات الصلاة الخمس';

// ─── Notification tap stream ──────────────────────────────────────────────────

final _notifTapPayloadController = StreamController<String>.broadcast();

// ─── Shared library state ─────────────────────────────────────────────────────

final _notifPlugin = FlutterLocalNotificationsPlugin();
bool _notifInitialized = false;
String _notifAdhanSoundName = 'adhan_makkah';
String? _notifLastMotivationKey;
String? _notifLastPrayerSig;
String? _notifLastManualSig;

// ─── Bootstrap ────────────────────────────────────────────────────────────────

Future<void> _notifInit() async {
  if (_notifInitialized) return;

  tz_data.initializeTimeZones();
  try {
    final tzInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzInfo.identifier));
  } catch (_) {
    _notifSetLocalFromOffset();
  }

  await _notifPlugin.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    ),
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      final payload = response.payload;
      if (payload != null && payload.isNotEmpty) {
        _notifTapPayloadController.add(payload);
      }
    },
  );

  // Handle cold start — app was launched by tapping a notification
  try {
    final launchDetails =
        await _notifPlugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp == true) {
      final payload = launchDetails!.notificationResponse?.payload;
      if (payload != null && payload.isNotEmpty) {
        // Delay slightly to let the router initialize
        Future.delayed(const Duration(milliseconds: 500), () {
          _notifTapPayloadController.add(payload);
        });
      }
    }
  } catch (e) {
    if (kDebugMode) debugPrint('[Notifications] launch details error: $e');
  }

  await _notifEnsureAndroidChannels();
  _notifInitialized = true;
}

Future<void> _notifEnsureAndroidChannels() async {
  if (!Platform.isAndroid) return;

  final impl = _notifPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  if (impl == null) return;

  await _notifEnsureStandardAdhanChannel(impl);
  await _notifEnsureBypassDndAdhanChannelIfAllowed(impl);
}

Future<void> _notifEnsureStandardAdhanChannel(
  AndroidFlutterLocalNotificationsPlugin impl,
) async {
  await impl.createNotificationChannel(
    AndroidNotificationChannel(
      _kChannelId,
      _kChannelName,
      description: _kChannelDesc,
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(_notifAdhanSoundName),
      enableVibration: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
    ),
  );
}

Future<void> _notifEnsureBypassDndAdhanChannelIfAllowed(
  AndroidFlutterLocalNotificationsPlugin impl,
) async {
  final hasPolicyAccess = await impl.hasNotificationPolicyAccess() ?? false;
  if (!hasPolicyAccess) return;

  await impl.createNotificationChannel(
    AndroidNotificationChannel(
      _kChannelBypassDndId,
      _kChannelName,
      description: _kChannelDesc,
      importance: Importance.max,
      bypassDnd: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(_notifAdhanSoundName),
      enableVibration: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
    ),
  );
}

Future<String> _notifResolvePrayerChannelId() async {
  if (!Platform.isAndroid) return _kChannelId;

  final impl = _notifPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  if (impl == null) return _kChannelId;

  final hasPolicyAccess = await impl.hasNotificationPolicyAccess() ?? false;
  if (!hasPolicyAccess) return _kChannelId;

  await _notifEnsureBypassDndAdhanChannelIfAllowed(impl);
  return _kChannelBypassDndId;
}

// ─── Cancel all + immediate + debug ──────────────────────────────────────────

Future<void> _notifCancelAll() async {
  if (!_notifInitialized) return;
  await _notifPlugin.cancelAll();
  _notifLastMotivationKey = null;
  _notifLastPrayerSig = null;
  _notifLastManualSig = null;
}

/// Shows an instant (non-scheduled) notification.
/// Used for real-time admin messages pushed via Pusher.
Future<void> _notifShowImmediate({
  required String title,
  required String body,
  String? payload,
  int id = 9001,
}) async {
  if (!_notifInitialized) await _notifInit();

  if (Platform.isAndroid) {
    final impl = _notifPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (impl != null) {
      await impl.createNotificationChannel(
        const AndroidNotificationChannel(
          'admin_notifications_channel',
          'إشعارات الإدارة',
          description: 'إشعارات فورية من الإدارة',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );
    }
  }

  const details = NotificationDetails(
    android: AndroidNotificationDetails(
      'admin_notifications_channel',
      'إشعارات الإدارة',
      channelDescription: 'إشعارات فورية من الإدارة',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  await _notifPlugin.show(
    id: id,
    title: title,
    body: body,
    notificationDetails: details,
    payload: payload,
  );
}

Future<List<PendingNotificationRequest>> _notifPendingNotifications() async {
  if (!_notifInitialized) return [];
  return _notifPlugin.pendingNotificationRequests();
}

// ─── Private helpers ──────────────────────────────────────────────────────────

DateTime? _notifPrayerDateTime(PrayerTimes pt, Prayer prayer) =>
    switch (prayer) {
      Prayer.fajr => pt.fajr,
      Prayer.dhuhr => pt.dhuhr,
      Prayer.asr => pt.asr,
      Prayer.maghrib => pt.maghrib,
      Prayer.isha => pt.isha,
      _ => null,
    };

Future<void> _notifCancelPrayerNotifications({
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
      targetIds.add(_notifIdFor(prayer) + (day * 10));
    }
  }
  await _notifCancelByIds(targetIds);
}

Future<List<int>> _notifExistingIdsInRange(int baseId, int length) async {
  if (!_notifInitialized || length <= 0) return const [];
  final pendingIds = await _notifPendingIds();
  if (pendingIds.isEmpty) return const [];
  final endId = baseId + length - 1;
  return pendingIds
      .where((id) => id >= baseId && id <= endId)
      .toList(growable: false);
}

Future<Set<int>> _notifPendingIds() async {
  final pending = await _notifPlugin.pendingNotificationRequests();
  return pending.map((request) => request.id).toSet();
}

Future<void> _notifCancelByIds(Iterable<int> ids) async {
  if (!_notifInitialized) return;
  final uniqueIds = ids.toSet();
  if (uniqueIds.isEmpty) return;

  final pendingIds = await _notifPendingIds();
  if (pendingIds.isEmpty) return;

  for (final id in uniqueIds) {
    if (!pendingIds.contains(id)) continue;
    await _notifPlugin.cancel(id: id);
  }
}

void _notifSetLocalFromOffset() {
  final hours = DateTime.now().timeZoneOffset.inHours;
  try {
    tz.setLocalLocation(tz.getLocation(_notifFallbackTz(hours)));
  } catch (e) {
    if (kDebugMode) {
      debugPrint(
        '[NotificationsService] fallback timezone failed for offset $hours: $e',
      );
    }
  }
}

String _notifFallbackTz(int h) => switch (h) {
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

// ─── Public facade ────────────────────────────────────────────────────────────

/// Singleton notification service for scheduling prayer-time notifications.
/// Implementation is split across part files by domain:
///   - [notifications_service_permissions.dart] — permission requests
///   - [notifications_service_scheduling.dart]  — prayer scheduling
///   - [notifications_service_reminders.dart]   — daily/motivation/khatmah
class NotificationsService {
  NotificationsService._();

  /// Stream of notification tap payloads (prayer names).
  /// Listen to this to navigate to the adhan screen on notification tap.
  static Stream<String> get tapStream => _notifTapPayloadController.stream;

  /// Changes the adhan sound used for notifications.
  /// Must be called before scheduling new notifications.
  static void setAdhanSound(String androidResourceName) =>
      _notifAdhanSoundName = androidResourceName;

  // ── Bootstrap ──────────────────────────────────────────────────────────────
  static Future<void> init() => _notifInit();

  // ── Permissions ────────────────────────────────────────────────────────────
  static Future<bool> requestPermission() => _notifRequestPermission();
  static Future<bool> areNotificationsEnabled() =>
      _notifAreNotificationsEnabled();
  static Future<bool> canScheduleExactAlarms() =>
      _notifCanScheduleExactAlarms();
  static Future<bool> requestExactAlarmsPermission() =>
      _notifRequestExactAlarmsPermission();
  static Future<bool> hasNotificationPolicyAccess() =>
      _notifHasNotificationPolicyAccess();
  static Future<bool> requestNotificationPolicyAccess() =>
      _notifRequestNotificationPolicyAccess();
  static Future<bool> requestFullScreenIntentPermission() =>
      _notifRequestFullScreenIntentPermission();

  // ── Prayer scheduling ──────────────────────────────────────────────────────
  static Future<void> rescheduleAll({
    required Coordinates coordinates,
    required CalculationParameters calcParams,
    required Map<Prayer, bool> enabledMap,
    required Map<Prayer, int> prayerAdjustMinutes,
    required Map<Prayer, int> offsetMinutes,
    String? scheduleSignature,
    int daysAhead = _kPrayerDaysAheadDefault,
  }) => _notifRescheduleAll(
        coordinates: coordinates,
        calcParams: calcParams,
        enabledMap: enabledMap,
        prayerAdjustMinutes: prayerAdjustMinutes,
        offsetMinutes: offsetMinutes,
        scheduleSignature: scheduleSignature,
        daysAhead: daysAhead,
      );

  static Future<void> rescheduleManualPrayerTimes({
    required Map<Prayer, bool> enabledMap,
    required Map<Prayer, DateTime> manualTimes,
    required Map<Prayer, int> offsetMinutes,
    String? scheduleSignature,
    int daysAhead = _kPrayerDaysAheadDefault,
  }) => _notifRescheduleManualPrayerTimes(
        enabledMap: enabledMap,
        manualTimes: manualTimes,
        offsetMinutes: offsetMinutes,
        scheduleSignature: scheduleSignature,
        daysAhead: daysAhead,
      );

  // ── Reminders ──────────────────────────────────────────────────────────────
  static Future<void> scheduleDailyReminder({
    required int baseId,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) => _notifScheduleDailyReminder(
        baseId: baseId,
        title: title,
        body: body,
        hour: hour,
        minute: minute,
      );

  static Future<void> cancelDailyReminder(int baseId) =>
      _notifCancelDailyReminder(baseId);

  static Future<void> scheduleMotivationReminders({
    required bool enabled,
    required int startHour,
    required int endHour,
    required int remindersPerDay,
  }) => _notifScheduleMotivationReminders(
        enabled: enabled,
        startHour: startHour,
        endHour: endHour,
        remindersPerDay: remindersPerDay,
      );

  static Future<void> cancelMotivationReminders() =>
      _notifCancelMotivationReminders();

  static Future<void> scheduleKhatmahReminder({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) => _notifScheduleKhatmahReminder(
        hour: hour,
        minute: minute,
        title: title,
        body: body,
      );

  static Future<void> cancelKhatmahReminder() => _notifCancelKhatmahReminder();

  // ── Global cancel + immediate + debug ─────────────────────────────────────
  static Future<void> cancelAll() => _notifCancelAll();

  static Future<void> showImmediate({
    required String title,
    required String body,
    String? payload,
    int id = 9001,
  }) => _notifShowImmediate(title: title, body: body, payload: payload, id: id);

  static Future<List<PendingNotificationRequest>> pendingNotifications() =>
      _notifPendingNotifications();
}
