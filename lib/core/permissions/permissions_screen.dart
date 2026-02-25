import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

import '../theme/app_colors.dart';

class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen> {
  bool _locationGranted = false;
  bool _notificationGranted = false;
  bool _exactAlarmGranted = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    setState(() => _isChecking = true);

    // فحص صلاحية الموقع
    final locationStatus = await Geolocator.checkPermission();
    _locationGranted = locationStatus == LocationPermission.always ||
        locationStatus == LocationPermission.whileInUse;

    // فحص صلاحية الإشعارات
    final notificationStatus = await Permission.notification.status;
    _notificationGranted = notificationStatus.isGranted;

    // فحص صلاحية المنبهات الدقيقة (Android 12+)
    try {
      final scheduleStatus = await Permission.scheduleExactAlarm.status;
      _exactAlarmGranted = scheduleStatus.isGranted;
    } catch (e) {
      // إذا كان الإصدار أقل من Android 12، اعتبر الصلاحية ممنوحة
      _exactAlarmGranted = true;
    }

    setState(() => _isChecking = false);

    // إذا كانت جميع الصلاحيات ممنوحة، أغلق الشاشة
    if (_locationGranted && _notificationGranted && _exactAlarmGranted) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _requestLocation() async {
    final status = await Geolocator.requestPermission();
    setState(() {
      _locationGranted = status == LocationPermission.always ||
          status == LocationPermission.whileInUse;
    });

    _checkIfAllGranted();
  }

  Future<void> _requestNotification() async {
    final status = await Permission.notification.request();
    setState(() {
      _notificationGranted = status.isGranted;
    });

    _checkIfAllGranted();
  }

  Future<void> _requestExactAlarm() async {
    try {
      final status = await Permission.scheduleExactAlarm.request();
      setState(() {
        _exactAlarmGranted = status.isGranted;
      });
    } catch (e) {
      // لا شيء - الإصدار أقل من Android 12
    }

    _checkIfAllGranted();
  }

  void _checkIfAllGranted() {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isChecking) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
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
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
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
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
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
                            'نستخدم موقعك لحساب أوقات الصلاة الدقيقة بناءً على مدينتك. لا نشارك موقعك مع أي طرف ثالث.',
                        importance: 'ضروري لمعرفة أوقات الصلاة',
                        isGranted: _locationGranted,
                        onRequest: _requestLocation,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      _buildPermissionTile(
                        icon: Icons.notifications_active,
                        title: '🔔 الإشعارات',
                        description:
                            'لتذكيرك بأوقات الصلاة والأذكار اليومية. يمكنك التحكم في أنواع التنبيهات من الإعدادات.',
                        importance: 'ضروري لتنبيهات الأذان والأذكار',
                        isGranted: _notificationGranted,
                        onRequest: _requestNotification,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      _buildPermissionTile(
                        icon: Icons.alarm_on,
                        title: '⏰ المنبهات الدقيقة',
                        description:
                            'للأجهزة Android 12+، هذا الإذن يضمن تشغيل الأذان في الوقت المحدد بالضبط دون تأخير.',
                        importance: 'ضروري لدقة مواعيد الأذان',
                        isGranted: _exactAlarmGranted,
                        onRequest: _requestExactAlarm,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // زر المتابعة
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
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
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
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
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGranted
              ? AppColors.primary
              : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
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
                      : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isGranted ? Icons.check_circle : icon,
                  color: isGranted
                      ? AppColors.primary
                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
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
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
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
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 8),
          // الأهمية
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isGranted
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : (isDark ? Colors.orange.withValues(alpha: 0.15) : Colors.orange.withValues(alpha: 0.1)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isGranted ? Icons.check_circle : Icons.info_outline,
                  size: 14,
                  color: isGranted ? AppColors.primary : Colors.orange,
                ),
                const SizedBox(width: 6),
                Text(
                  isGranted ? 'تم المنح ✓' : importance,
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isGranted ? AppColors.primary : Colors.orange,
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
