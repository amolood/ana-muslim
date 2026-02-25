import 'package:flutter/material.dart';

/// نموذج معلومات الإذن مع الشرح والفائدة
class PermissionInfo {
  final String id;
  final String title;
  final String description;
  final String benefit;
  final IconData icon;
  final Color color;
  final PermissionType type;
  final bool isRequired;

  const PermissionInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.benefit,
    required this.icon,
    required this.color,
    required this.type,
    this.isRequired = true,
  });
}

enum PermissionType {
  notifications,
  exactAlarms,
  notificationPolicy,
  location,
  fullScreenIntent,
}

/// قائمة الأذونات المطلوبة مع شرح مفصل
class AppPermissions {
  static const List<PermissionInfo> requiredPermissions = [
    PermissionInfo(
      id: 'notifications',
      title: 'إشعارات الصلاة والأذكار',
      description: 'للحصول على تنبيهات أوقات الصلاة والأذكار اليومية',
      benefit: 'لن يفوتك وقت صلاة أو ذكر مهم',
      icon: Icons.notifications_active,
      color: Color(0xFF11D4B4),
      type: PermissionType.notifications,
      isRequired: true,
    ),
    PermissionInfo(
      id: 'exact_alarms',
      title: 'التنبيهات الدقيقة',
      description: 'لضمان وصول الأذان في الوقت المحدد بالضبط دون تأخير',
      benefit: 'أذان دقيق في وقته الصحيح تمامًا',
      icon: Icons.alarm,
      color: Color(0xFFFF6B6B),
      type: PermissionType.exactAlarms,
      isRequired: true,
    ),
    PermissionInfo(
      id: 'notification_policy',
      title: 'تجاوز وضع عدم الإزعاج',
      description: 'لإظهار الأذان حتى في الوضع الصامت أو وضع عدم الإزعاج',
      benefit: 'لن تفوتك صلاة حتى لو كان الهاتف صامتًا',
      icon: Icons.do_not_disturb_off,
      color: Color(0xFF9C27B0),
      type: PermissionType.notificationPolicy,
      isRequired: false,
    ),
    PermissionInfo(
      id: 'location',
      title: 'الموقع الجغرافي',
      description: 'لحساب مواقيت الصلاة الدقيقة حسب موقعك واتجاه القبلة',
      benefit: 'مواقيت صلاة دقيقة وقبلة صحيحة لمنطقتك',
      icon: Icons.location_on,
      color: Color(0xFF4CAF50),
      type: PermissionType.location,
      isRequired: true,
    ),
    PermissionInfo(
      id: 'full_screen_intent',
      title: 'عرض ملء الشاشة',
      description: 'لإظهار الأذان بشكل واضح حتى عند قفل الشاشة',
      benefit: 'أذان واضح ومرئي حتى مع الشاشة المقفلة',
      icon: Icons.phone_android,
      color: Color(0xFFFFC107),
      type: PermissionType.fullScreenIntent,
      isRequired: false,
    ),
  ];

  /// الأذونات الإلزامية فقط
  static List<PermissionInfo> get essentialPermissions =>
      requiredPermissions.where((p) => p.isRequired).toList();

  /// الأذونات الاختيارية
  static List<PermissionInfo> get optionalPermissions =>
      requiredPermissions.where((p) => !p.isRequired).toList();
}
