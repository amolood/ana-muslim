import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider لفحص ما إذا كانت كل الصلاحيات ممنوحة
final permissionsCheckedProvider = FutureProvider<bool>((ref) async {
  // فحص إذا كان المستخدم قد تخطى شاشة الصلاحيات من قبل
  final prefs = await SharedPreferences.getInstance();
  final hasSkipped = prefs.getBool('permissions_skipped') ?? false;

  if (hasSkipped) {
    return true; // لا تظهر الشاشة مرة أخرى
  }

  // فحص صلاحية الموقع
  final locationStatus = await Geolocator.checkPermission();
  final locationGranted = locationStatus == LocationPermission.always ||
      locationStatus == LocationPermission.whileInUse;

  // فحص صلاحية الإشعارات
  final notificationStatus = await Permission.notification.status;
  final notificationGranted = notificationStatus.isGranted;

  // فحص صلاحية المنبهات الدقيقة
  bool exactAlarmGranted = true;
  try {
    final scheduleStatus = await Permission.scheduleExactAlarm.status;
    exactAlarmGranted = scheduleStatus.isGranted;
  } catch (e) {
    // إذا كان الإصدار أقل من Android 12، اعتبر الصلاحية ممنوحة
    exactAlarmGranted = true;
  }

  // إذا كانت كل الصلاحيات ممنوحة، لا تظهر الشاشة
  return locationGranted && notificationGranted && exactAlarmGranted;
});

/// Notifier لتحديد ما إذا تم تخطي شاشة الصلاحيات
class PermissionsSkippedNotifier extends Notifier<bool> {
  static const _key = 'permissions_skipped';

  @override
  bool build() {
    return false;
  }

  Future<void> skip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    state = true;
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    state = false;
  }
}

final permissionsSkippedProvider =
    NotifierProvider<PermissionsSkippedNotifier, bool>(
  PermissionsSkippedNotifier.new,
);
