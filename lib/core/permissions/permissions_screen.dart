import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

import '../services/prayer_silence_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_semantic_colors.dart';
import 'models/permission_info.dart';
import 'widgets/permission_rationale_sheet.dart';

class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen> {
  bool _locationGranted = false;
  bool _notificationGranted = false;
  bool _exactAlarmGranted = false;
  bool _dndGranted = false;
  bool _isAndroid = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    setState(() => _isChecking = true);

    _isAndroid = Platform.isAndroid;

    // Location permission
    final locationStatus = await Geolocator.checkPermission();
    _locationGranted = locationStatus == LocationPermission.always ||
        locationStatus == LocationPermission.whileInUse;

    // Notification permission
    final notificationStatus = await Permission.notification.status;
    _notificationGranted = notificationStatus.isGranted;

    // Exact alarm permission (Android 12+)
    try {
      final scheduleStatus = await Permission.scheduleExactAlarm.status;
      _exactAlarmGranted = scheduleStatus.isGranted;
    } catch (e) {
      _exactAlarmGranted = true;
    }

    // DND permission (Android only — optional)
    if (_isAndroid) {
      _dndGranted = await PrayerSilenceService.hasDndPermission();
    } else {
      _dndGranted = true;
    }

    setState(() => _isChecking = false);

    // Auto-close only when the 3 required permissions are granted
    if (_locationGranted && _notificationGranted && _exactAlarmGranted) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  // ── Rationale data ─────────────────────────────────────────────────────────
  // These mirror the AppPermissions definitions but are kept here so the
  // settings screen remains self-contained (different DND description, etc.).

  static const _locationInfo = PermissionInfo(
    id: 'location',
    title: 'الموقع الجغرافي',
    description:
        'لحساب مواقيت الصلاة الدقيقة حسب موقعك واتجاه القبلة الصحيح. '
        'لا نشارك موقعك مع أي جهة خارجية.',
    benefit: 'مواقيت صلاة دقيقة وقبلة صحيحة تمامًا لمنطقتك',
    icon: Icons.location_on,
    color: Color(0xFF4CAF50),
    type: PermissionType.location,
    isRequired: true,
  );

  static const _notificationInfo = PermissionInfo(
    id: 'notifications',
    title: 'إشعارات الصلاة والأذكار',
    description:
        'لإرسال تنبيهات أذان الصلاة في وقتها الدقيق وتذكيرك بالأذكار '
        'اليومية المهمة.',
    benefit: 'لن يفوتك وقت صلاة أو ذكر مهم مهما كنت مشغولاً',
    icon: Icons.notifications_active,
    color: Color(0xFF11D4B4),
    type: PermissionType.notifications,
    isRequired: true,
  );

  static const _exactAlarmInfo = PermissionInfo(
    id: 'exact_alarms',
    title: 'التنبيهات الدقيقة',
    description:
        'لضمان وصول الأذان في وقته الصحيح بالضبط دون تأخير. '
        'مطلوب على أجهزة Android 12 وما فوق.',
    benefit: 'أذان دقيق في ثانيته الصحيحة تمامًا',
    icon: Icons.alarm_on,
    color: Color(0xFFFF6B6B),
    type: PermissionType.exactAlarms,
    isRequired: true,
  );

  static const _dndInfo = PermissionInfo(
    id: 'dnd',
    title: 'الإسكات التلقائي عند الصلاة',
    description:
        'للسماح للتطبيق بإسكات الهاتف تلقائيًا عند دخول وقت الصلاة '
        'وإعادته للوضع الطبيعي بعد انتهاء الوقت.',
    benefit: 'لا يزعجك أحد أثناء صلاتك — يُفعَّل تلقائيًا في كل وقت صلاة',
    icon: Icons.do_not_disturb_on_rounded,
    color: Color(0xFF9C27B0),
    type: PermissionType.notificationPolicy,
    isRequired: false,
  );

  // ── Request helpers ────────────────────────────────────────────────────────

  Future<void> _requestLocation() async {
    // Show in-app rationale first, then the OS dialog.
    if (!await PermissionRationaleSheet.show(context, _locationInfo)) return;
    if (!mounted) return;

    final status = await Geolocator.requestPermission();
    setState(() {
      _locationGranted = status == LocationPermission.always ||
          status == LocationPermission.whileInUse;
    });
    _checkIfAllGranted();
  }

  Future<void> _requestNotification() async {
    if (!await PermissionRationaleSheet.show(context, _notificationInfo)) {
      return;
    }
    if (!mounted) return;

    final status = await Permission.notification.request();
    setState(() => _notificationGranted = status.isGranted);
    _checkIfAllGranted();
  }

  Future<void> _requestExactAlarm() async {
    if (!await PermissionRationaleSheet.show(context, _exactAlarmInfo)) return;
    if (!mounted) return;

    try {
      final status = await Permission.scheduleExactAlarm.request();
      setState(() => _exactAlarmGranted = status.isGranted);
    } catch (e) {
      // Android < 12 — scheduleExactAlarm doesn't exist; treat as granted.
    }
    _checkIfAllGranted();
  }

  Future<void> _requestDnd() async {
    if (!await PermissionRationaleSheet.show(context, _dndInfo)) return;
    if (!mounted) return;

    await PrayerSilenceService.openDndSettings();
    // Re-check after the user returns from the system Settings page.
    if (!mounted) return;
    final granted = await PrayerSilenceService.hasDndPermission();
    setState(() => _dndGranted = granted);
  }

  void _checkIfAllGranted() {
    // DND is optional — only block on the 3 required permissions
    if (_locationGranted && _notificationGranted && _exactAlarmGranted) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (_isChecking) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // أيقونة التطبيق
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.security,
                  size: 50,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              // العنوان
              Text(
                '🕌 مرحباً بك في أنا المسلم',
                style: GoogleFonts.tajawal(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'الصلاحيات المطلوبة',
                style: GoogleFonts.tajawal(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'لتقديم أفضل تجربة، نحتاج إلى الأذونات التالية.\nكل إذن له غرض محدد لخدمتك:',
                  style: GoogleFonts.tajawal(
                    fontSize: 14,
                    height: 1.6,
                    color: colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),
              // قائمة الصلاحيات
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildPermissionTile(
                        icon: Icons.location_on,
                        title: '📍 الموقع الجغرافي',
                        description:
                            'لحساب مواقيت الصلاة واتجاه القبلة بدقة بناءً على موقعك. لا نشارك موقعك مع أي طرف ثالث.',
                        importance: 'ضروري لمواقيت الصلاة والقبلة',
                        isGranted: _locationGranted,
                        onRequest: _requestLocation,
                      ),
                      const SizedBox(height: 16),
                      _buildPermissionTile(
                        icon: Icons.notifications_active,
                        title: '🔔 الإشعارات',
                        description:
                            'لإشعارك بأوقات الصلاة في الوقت المناسب وتذكيرك بالأذكار اليومية.',
                        importance: 'ضروري لتنبيهات الأذان والأذكار',
                        isGranted: _notificationGranted,
                        onRequest: _requestNotification,
                      ),
                      const SizedBox(height: 16),
                      _buildPermissionTile(
                        icon: Icons.alarm_on,
                        title: '⏰ المنبهات الدقيقة',
                        description:
                            'لضمان دقة توقيت الإشعارات. للأجهزة Android 12+ فقط.',
                        importance: 'ضروري لدقة مواعيد الأذان',
                        isGranted: _exactAlarmGranted,
                        onRequest: _requestExactAlarm,
                      ),
                      if (_isAndroid) ...[
                        const SizedBox(height: 16),
                        _buildPermissionTile(
                          icon: Icons.do_not_disturb_on_rounded,
                          title: '🔕 وضع عدم الإزعاج',
                          description:
                              'لإسكات الهاتف تلقائياً عند دخول وقت الصلاة وإعادته للوضع الطبيعي بعدها.',
                          importance: 'اختياري — لميزة الصمت التلقائي',
                          isGranted: _dndGranted,
                          isOptional: true,
                          onRequest: _requestDnd,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // زر المتابعة
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  // DND is optional — only require the 3 core permissions
                  onPressed:
                      _locationGranted && _notificationGranted && _exactAlarmGranted
                          ? () => Navigator.of(context).pop()
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey.withValues(alpha: 0.3),
                  ),
                  child: Text(
                    'متابعة',
                    style: GoogleFonts.tajawal(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'تخطي الآن',
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionTile({
    required IconData icon,
    required String title,
    required String description,
    required String importance,
    required bool isGranted,
    required VoidCallback onRequest,
    bool isOptional = false,
  }) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGranted
              ? AppColors.primary
              : colors.borderSubtle,
          width: isGranted ? 2 : 1,
        ),
        boxShadow: isGranted
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isGranted
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : colors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isGranted ? Icons.check_circle : icon,
                  color: isGranted
                      ? AppColors.primary
                      : colors.iconSecondary,
                  size: 24,
            ),
          ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.tajawal(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (!isGranted)
                ElevatedButton(
                  onPressed: onRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'منح',
                    style: GoogleFonts.tajawal(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // الوصف
          Text(
            description,
            style: GoogleFonts.tajawal(
              fontSize: 13,
              height: 1.5,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          // الأهمية
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isGranted
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : isOptional
                      ? Colors.blueGrey.withValues(alpha: 0.12)
                      : Colors.orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isGranted
                      ? Icons.check_circle
                      : isOptional
                          ? Icons.info_outline
                          : Icons.info_outline,
                  size: 14,
                  color: isGranted
                      ? AppColors.primary
                      : isOptional
                          ? Colors.blueGrey
                          : Colors.orange,
                ),
                const SizedBox(width: 6),
                Text(
                  isGranted ? 'تم المنح ✓' : importance,
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isGranted
                        ? AppColors.primary
                        : isOptional
                            ? Colors.blueGrey
                            : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
