part of 'notifications_service.dart';

// ─── Daily reminders ──────────────────────────────────────────────────────────

/// Schedules a daily notification at [hour]:[minute] for the next 7 days.
/// Uses IDs [baseId, baseId+1, ..., baseId+6].
Future<void> _notifScheduleDailyReminder({
  required int baseId,
  required String title,
  required String body,
  required int hour,
  required int minute,
}) async {
  if (!_notifInitialized) await _notifInit();

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
      await _notifPlugin.zonedSchedule(
        id: baseId + day,
        title: title,
        body: body,
        scheduledDate: tzTime,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexact,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationsService] daily reminder slot failed: $e');
      }
    }
  }
}

/// Cancels daily reminder notifications for [baseId..baseId+6].
Future<void> _notifCancelDailyReminder(int baseId) async {
  if (!_notifInitialized) return;
  await _notifCancelByIds([for (int i = 0; i < 7; i++) baseId + i]);
}

// ─── Motivation reminders ─────────────────────────────────────────────────────

const _notifMotivationBodies = <String>[
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
Future<void> _notifScheduleMotivationReminders({
  required bool enabled,
  required int startHour,
  required int endHour,
  required int remindersPerDay,
}) async {
  if (!_notifInitialized) await _notifInit();

  final safeStart = startHour.clamp(0, 23);
  final safeEndRaw = endHour.clamp(1, 23);
  final safeEnd =
      safeEndRaw <= safeStart ? (safeStart + 1).clamp(1, 23) : safeEndRaw;
  final perDay = remindersPerDay.clamp(0, _kMotivationMaxPerDay);
  final scheduleKey = '$enabled:$safeStart:$safeEnd:$perDay';
  if (_notifLastMotivationKey == scheduleKey) return;

  await _notifCancelMotivationReminders();
  _notifLastMotivationKey = scheduleKey;
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
      final slotOffsetMinutes = (rangeMinutes * fraction).round();
      final target = dayDate.add(
        Duration(hours: safeStart, minutes: slotOffsetMinutes),
      );
      if (target.isBefore(now)) continue;

      final tzTime = tz.TZDateTime.from(target, tz.local);
      final id = _kMotivationBaseId + (day * _kMotivationSlotStride) + slot;
      final body =
          _notifMotivationBodies[(day + slot) % _notifMotivationBodies.length];

      try {
        await _notifPlugin.zonedSchedule(
          id: id,
          title: 'رفيقك في العبادة',
          body: body,
          scheduledDate: tzTime,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexact,
        );
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[NotificationsService] motivation slot failed: $e');
        }
      }
    }
  }
}

Future<void> _notifCancelMotivationReminders() async {
  if (!_notifInitialized) return;
  final ids = await _notifExistingIdsInRange(_kMotivationBaseId, 3000);
  if (ids.isNotEmpty) await _notifCancelByIds(ids);
  _notifLastMotivationKey = null;
}

// ─── Khatmah reminder ─────────────────────────────────────────────────────────

/// Schedules a daily Khatmah reminder for the next 14 days.
Future<void> _notifScheduleKhatmahReminder({
  required int hour,
  required int minute,
  required String title,
  required String body,
}) async {
  if (!_notifInitialized) await _notifInit();

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

  await _notifCancelKhatmahReminder();

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
      await _notifPlugin.zonedSchedule(
        id: _kKhatmahBaseId + day,
        title: title,
        body: body,
        scheduledDate: tzTime,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexact,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationsService] khatmah slot failed: $e');
      }
    }
  }
}

Future<void> _notifCancelKhatmahReminder() async {
  if (!_notifInitialized) return;
  await _notifCancelByIds([for (int i = 0; i < 14; i++) _kKhatmahBaseId + i]);
}
