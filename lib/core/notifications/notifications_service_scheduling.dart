part of 'notifications_service.dart';

// ─── Prayer scheduling ────────────────────────────────────────────────────────

/// Cancels all existing prayer notifications then schedules fresh ones
/// for the next [daysAhead] days for every enabled prayer.
Future<void> _notifRescheduleAll({
  required Coordinates coordinates,
  required CalculationParameters calcParams,
  required Map<Prayer, bool> enabledMap,
  required Map<Prayer, int> prayerAdjustMinutes,
  required Map<Prayer, int> offsetMinutes,
  String? scheduleSignature,
  int daysAhead = _kPrayerDaysAheadDefault,
}) async {
  if (!_notifInitialized) await _notifInit();
  if (scheduleSignature != null && _notifLastPrayerSig == scheduleSignature) {
    return;
  }
  await _notifCancelPrayerNotifications(daysToClear: daysAhead + 14);
  final channelId = await _notifResolvePrayerChannelId();
  final bypassDnd = channelId == _kChannelBypassDndId;

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

      final prayerTime = _notifPrayerDateTime(pt, prayer);
      if (prayerTime == null) continue;

      final timeAdjust = prayerAdjustMinutes[prayer] ?? 0;
      final offset = offsetMinutes[prayer] ?? 0;
      final scheduled = prayerTime.add(Duration(minutes: timeAdjust + offset));
      if (scheduled.isBefore(now)) continue;

      final notifId = _notifIdFor(prayer) + (day * 10);
      await _notifScheduleSingle(
        id: notifId,
        prayerName: _notifNameAr(prayer),
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
  _notifLastPrayerSig = scheduleSignature;
}

/// Schedules prayer notifications using explicit user-defined prayer times.
/// [manualTimes] date parts are ignored; only hour/minute are used.
Future<void> _notifRescheduleManualPrayerTimes({
  required Map<Prayer, bool> enabledMap,
  required Map<Prayer, DateTime> manualTimes,
  required Map<Prayer, int> offsetMinutes,
  String? scheduleSignature,
  int daysAhead = _kPrayerDaysAheadDefault,
}) async {
  if (!_notifInitialized) await _notifInit();
  if (scheduleSignature != null && _notifLastManualSig == scheduleSignature) {
    return;
  }
  await _notifCancelPrayerNotifications(daysToClear: daysAhead + 14);
  final channelId = await _notifResolvePrayerChannelId();
  final bypassDnd = channelId == _kChannelBypassDndId;

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

      final notifId = _notifIdFor(prayer) + (day * 10);
      await _notifScheduleSingle(
        id: notifId,
        prayerName: _notifNameAr(prayer),
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
  _notifLastManualSig = scheduleSignature;
}

Future<void> _notifScheduleSingle({
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
      _kChannelName,
      channelDescription: _kChannelDesc,
      importance: Importance.max,
      priority: Priority.max,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
      visibility: NotificationVisibility.public,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(_notifAdhanSoundName),
      enableVibration: true,
      channelBypassDnd: channelBypassDnd,
      audioAttributesUsage: AudioAttributesUsage.alarm,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: true,
      sound: '$_notifAdhanSoundName.mp3',
    ),
  );

  try {
    await _notifPlugin.zonedSchedule(
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
      await _notifPlugin.zonedSchedule(
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
