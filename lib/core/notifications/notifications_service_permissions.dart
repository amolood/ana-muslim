part of 'notifications_service.dart';

// ─── Permission requests ──────────────────────────────────────────────────────

Future<bool> _notifRequestPermission() async {
  if (Platform.isAndroid) {
    final impl = _notifPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (impl == null) return false;
    final granted = await impl.requestNotificationsPermission();
    return granted ?? false;
  } else if (Platform.isIOS) {
    final impl = _notifPlugin
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

Future<bool> _notifAreNotificationsEnabled() async {
  if (!_notifInitialized) await _notifInit();

  if (Platform.isAndroid) {
    final impl = _notifPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await impl?.areNotificationsEnabled() ?? true;
  }

  // iOS/macOS: treat as enabled when plugin is initialized.
  return true;
}

Future<bool> _notifCanScheduleExactAlarms() async {
  if (!_notifInitialized) await _notifInit();
  if (!Platform.isAndroid) return true;

  final impl = _notifPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  final can = await impl?.canScheduleExactNotifications();
  return can ?? true;
}

Future<bool> _notifRequestExactAlarmsPermission() async {
  if (!_notifInitialized) await _notifInit();
  if (!Platform.isAndroid) return true;

  final impl = _notifPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  final granted = await impl?.requestExactAlarmsPermission();
  return granted ?? false;
}

Future<bool> _notifHasNotificationPolicyAccess() async {
  if (!_notifInitialized) await _notifInit();
  if (!Platform.isAndroid) return true;

  final impl = _notifPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  final granted = await impl?.hasNotificationPolicyAccess();
  return granted ?? false;
}

Future<bool> _notifRequestNotificationPolicyAccess() async {
  if (!_notifInitialized) await _notifInit();
  if (!Platform.isAndroid) return true;

  final impl = _notifPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  final granted = await impl?.requestNotificationPolicyAccess();
  await _notifEnsureAndroidChannels();
  return granted ?? false;
}

Future<bool> _notifRequestFullScreenIntentPermission() async {
  if (!_notifInitialized) await _notifInit();
  if (!Platform.isAndroid) return true;

  final impl = _notifPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  final granted = await impl?.requestFullScreenIntentPermission();
  return granted ?? false;
}
