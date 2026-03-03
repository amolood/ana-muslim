import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/notifications/notifications_service.dart';
import '../../../../core/theme/app_colors.dart';

class NotificationPermissionBanner extends StatefulWidget {
  const NotificationPermissionBanner({super.key});

  @override
  State<NotificationPermissionBanner> createState() =>
      _NotificationPermissionBannerState();
}

class _NotificationPermissionBannerState
    extends State<NotificationPermissionBanner> {
  bool? _notificationsGranted;
  bool? _exactAlarmsGranted;
  bool? _policyAccessGranted;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final notificationsGranted =
        await NotificationsService.areNotificationsEnabled();
    final exactAlarmsGranted =
        await NotificationsService.canScheduleExactAlarms();
    final policyAccessGranted =
        await NotificationsService.hasNotificationPolicyAccess();
    if (!mounted) return;
    setState(() {
      _notificationsGranted = notificationsGranted;
      _exactAlarmsGranted = exactAlarmsGranted;
      _policyAccessGranted = policyAccessGranted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final needsPolicyAccess =
        !kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android &&
        _policyAccessGranted != true;

    if (_notificationsGranted == true &&
        _exactAlarmsGranted == true &&
        !needsPolicyAccess) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'تم ضبط أذونات الأذان بالكامل (إشعارات + إنذارات دقيقة)',
                style: GoogleFonts.tajawal(color: AppColors.primary),
              ),
            ),
          ],
        ),
      );
    }

    final needsNotifications = _notificationsGranted != true;
    final needsExact = !needsNotifications && (_exactAlarmsGranted != true);
    final needsPolicy = !needsNotifications && !needsExact && needsPolicyAccess;
    final message = needsNotifications
        ? 'اضغط للسماح بإشعارات الصلاة'
        : needsExact
        ? 'فعّل الإنذارات الدقيقة لتحسين دقة الأذان'
        : 'فعّل تجاوز وضع عدم الإزعاج لضمان سماع الأذان';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.tajawal(color: Colors.orange),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (needsNotifications) {
                await NotificationsService.requestPermission();
              } else if (needsExact) {
                await NotificationsService.requestExactAlarmsPermission();
              } else if (needsPolicy) {
                await NotificationsService.requestNotificationPolicyAccess();
                await NotificationsService.requestFullScreenIntentPermission();
              }
              await _checkPermission();
            },
            child: Text(
              needsNotifications
                  ? 'السماح'
                  : needsExact
                  ? 'تفعيل'
                  : 'فتح الإعدادات',
              style: GoogleFonts.tajawal(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
