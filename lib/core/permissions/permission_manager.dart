import 'package:flutter/foundation.dart';
import '../notifications/notifications_service.dart';
import 'models/permission_info.dart';

/// مدير الأذونات المركزي
class PermissionManager {
  /// التحقق من حالة إذن معين
  static Future<bool> checkPermission(PermissionType type) async {
    switch (type) {
      case PermissionType.notifications:
        return await NotificationsService.areNotificationsEnabled();
      case PermissionType.exactAlarms:
        return await NotificationsService.canScheduleExactAlarms();
      case PermissionType.notificationPolicy:
        if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
          return await NotificationsService.hasNotificationPolicyAccess();
        }
        return true; // iOS doesn't need this
      case PermissionType.location:
        // سيتم التنفيذ مع خدمة الموقع
        return false;
      case PermissionType.fullScreenIntent:
        if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
          // Android 10+ needs this permission
          return true; // سيتم التحقق الفعلي لاحقًا
        }
        return true;
    }
  }

  /// طلب إذن معين
  static Future<bool> requestPermission(PermissionType type) async {
    switch (type) {
      case PermissionType.notifications:
        return await NotificationsService.requestPermission();
      case PermissionType.exactAlarms:
        await NotificationsService.requestExactAlarmsPermission();
        return await NotificationsService.canScheduleExactAlarms();
      case PermissionType.notificationPolicy:
        if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
          await NotificationsService.requestNotificationPolicyAccess();
          return await NotificationsService.hasNotificationPolicyAccess();
        }
        return true;
      case PermissionType.location:
        // سيتم التنفيذ مع خدمة الموقع
        return false;
      case PermissionType.fullScreenIntent:
        if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
          await NotificationsService.requestFullScreenIntentPermission();
          return true;
        }
        return true;
    }
  }

  /// التحقق من حالة جميع الأذونات
  static Future<Map<PermissionType, bool>> checkAllPermissions() async {
    final results = <PermissionType, bool>{};

    for (final permission in AppPermissions.requiredPermissions) {
      results[permission.type] = await checkPermission(permission.type);
    }

    return results;
  }

  /// التحقق من اكتمال الأذونات الأساسية
  static Future<bool> areEssentialPermissionsGranted() async {
    final results = await checkAllPermissions();

    for (final permission in AppPermissions.essentialPermissions) {
      if (results[permission.type] != true) {
        return false;
      }
    }

    return true;
  }

  /// فتح إعدادات التطبيق
  static Future<void> openSettings() async {
    // سيتم تنفيذه باستخدام app_settings package إذا لزم الأمر
  }
}
