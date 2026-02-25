import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/notifications/notifications_service.dart';
import '../../core/providers/preferences_provider.dart';

/// شاشة الترحيب الأولية التي تظهر عند تشغيل التطبيق لأول مرة
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // حالة الأذونات
  bool _locationGranted = false;
  bool _notificationGranted = false;
  bool _exactAlarmGranted = false;
  bool _isRequestingPermission = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    if (_isRequestingPermission) return;
    setState(() => _isRequestingPermission = true);

    try {
      final status = await Geolocator.requestPermission();
      setState(() {
        _locationGranted = status == LocationPermission.always ||
            status == LocationPermission.whileInUse;
        _isRequestingPermission = false;
      });

      // الانتقال تلقائياً إلى الصفحة التالية إذا تم منح الإذن
      if (_locationGranted && _currentPage == 1) {
        await Future.delayed(const Duration(milliseconds: 500));
        _nextPage();
      }
    } catch (e) {
      setState(() => _isRequestingPermission = false);
    }
  }

  Future<void> _requestNotificationPermission() async {
    if (_isRequestingPermission) return;
    setState(() => _isRequestingPermission = true);

    try {
      // طلب إذن الإشعارات
      final notifGranted = await NotificationsService.requestPermission();

      // طلب إذن المنبهات الدقيقة
      final canExact = await NotificationsService.canScheduleExactAlarms();
      if (!canExact) {
        await NotificationsService.requestExactAlarmsPermission();
      }

      // طلب إذن تجاوز وضع عدم الإزعاج
      final hasPolicy = await NotificationsService.hasNotificationPolicyAccess();
      if (!hasPolicy) {
        await NotificationsService.requestNotificationPolicyAccess();
      }

      // التحقق من جميع الأذونات
      final exactGranted = await NotificationsService.canScheduleExactAlarms();

      setState(() {
        _notificationGranted = notifGranted;
        _exactAlarmGranted = exactGranted;
        _isRequestingPermission = false;
      });

      // الانتقال تلقائياً إلى الصفحة التالية إذا تم منح جميع الأذونات
      if (_notificationGranted && _exactAlarmGranted && _currentPage == 2) {
        await Future.delayed(const Duration(milliseconds: 500));
        _nextPage();
      }
    } catch (e) {
      setState(() => _isRequestingPermission = false);
    }
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.animateToPage(
        _currentPage - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finishOnboarding() async {
    // حفظ أن المستخدم أكمل الترحيب
    // ✅ Use Riverpod provider to persist state and keep UI in sync
    await ref.read(onboardingCompletedProvider.notifier).save(true);

    // ✅ Navigate to home using go_router (replaces current route)
    // This ensures a valid non-empty router configuration
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ Prevent back navigation during onboarding to avoid popping the last route
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        // Block system back button - user must complete onboarding
        if (didPop) return;
      },
      child: Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // مؤشر التقدم
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: List.generate(
                  4,
                  (index) => Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(
                        right: index < 3 ? 8 : 0,
                      ),
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? AppColors.primary
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.2)
                                : Colors.grey.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // المحتوى
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                },
                children: [
                  _buildWelcomePage(isDark),
                  _buildLocationPermissionPage(isDark),
                  _buildNotificationPermissionPage(isDark),
                  _buildReadyPage(isDark),
                ],
              ),
            ),

            // الأزرار السفلية
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  // زر الرجوع
                  if (_currentPage > 0)
                    TextButton.icon(
                      onPressed: _previousPage,
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(
                        'السابق',
                        style: GoogleFonts.tajawal(fontSize: 16),
                      ),
                    ),
                  const Spacer(),
                  // زر التالي/البدء
                  ElevatedButton(
                    onPressed: _canProceed() ? _nextPage : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: Colors.grey.withValues(alpha: 0.3),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentPage == 3 ? 'ابدأ الآن' : 'التالي',
                          style: GoogleFonts.tajawal(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_back, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  bool _canProceed() {
    switch (_currentPage) {
      case 0:
        return true; // صفحة الترحيب - يمكن المتابعة دائماً
      case 1:
        return _locationGranted; // صفحة الموقع - يجب منح الإذن
      case 2:
        return _notificationGranted && _exactAlarmGranted; // صفحة الإشعارات
      case 3:
        return true; // صفحة الجاهزية
      default:
        return false;
    }
  }

  // صفحة الترحيب
  Widget _buildWelcomePage(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // أيقونة التطبيق
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.mosque,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          // العنوان
          Text(
            'أهلاً بك في',
            style: GoogleFonts.tajawal(
              fontSize: 18,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'أنا المسلم',
            style: GoogleFonts.tajawal(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 20),

          // الوصف
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceDark
                  : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'رفيقك اليومي في رحلة الإيمان',
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                _buildFeatureRow(
                  Icons.access_time,
                  'أوقات الصلاة الدقيقة',
                  isDark,
                ),
                const SizedBox(height: 8),
                _buildFeatureRow(
                  Icons.notifications_active,
                  'تنبيهات الأذان والأذكار',
                  isDark,
                ),
                const SizedBox(height: 8),
                _buildFeatureRow(
                  Icons.menu_book,
                  'القرآن الكريم والتفسير',
                  isDark,
                ),
                const SizedBox(height: 8),
                _buildFeatureRow(
                  Icons.explore,
                  'اتجاه القبلة',
                  isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'دعنا نجهز التطبيق معاً في خطوات بسيطة',
            style: GoogleFonts.tajawal(
              fontSize: 14,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.tajawal(
              fontSize: 14,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ),
      ],
    );
  }

  // صفحة إذن الموقع
  Widget _buildLocationPermissionPage(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // أيقونة الموقع
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: _locationGranted
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : Colors.blue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _locationGranted ? Icons.check_circle : Icons.location_on,
              size: 50,
              color: _locationGranted ? AppColors.primary : Colors.blue,
            ),
          ),
          const SizedBox(height: 20),

          // العنوان
          Text(
            _locationGranted ? 'تم منح الإذن بنجاح ✓' : 'الموقع الجغرافي',
            style: GoogleFonts.tajawal(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _locationGranted
                  ? AppColors.primary
                  : (isDark ? Colors.white : AppColors.textPrimaryLight),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // الوصف
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceDark
                  : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _locationGranted
                    ? AppColors.primary
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.2)),
                width: _locationGranted ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'لماذا نحتاج موقعك؟',
                        style: GoogleFonts.tajawal(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildReasonRow(
                  '🕌',
                  'حساب أوقات الصلاة الدقيقة',
                  'حسب مدينتك والإحداثيات الجغرافية',
                  isDark,
                ),
                const SizedBox(height: 8),
                _buildReasonRow(
                  '🧭',
                  'تحديد اتجاه القبلة',
                  'بدقة عالية باستخدام موقعك الحالي',
                  isDark,
                ),
                const SizedBox(height: 8),
                _buildReasonRow(
                  '🔒',
                  'خصوصيتك محفوظة',
                  'لا نشارك موقعك مع أي طرف ثالث',
                  isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // زر طلب الإذن
          if (!_locationGranted)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isRequestingPermission ? null : _requestLocationPermission,
                icon: _isRequestingPermission
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.location_on, size: 22),
                label: Text(
                  _isRequestingPermission ? 'جارٍ الطلب...' : 'منح إذن الموقع',
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // صفحة إذن الإشعارات
  Widget _buildNotificationPermissionPage(bool isDark) {
    final allGranted = _notificationGranted && _exactAlarmGranted;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // أيقونة الإشعارات
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: allGranted
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : Colors.orange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              allGranted ? Icons.check_circle : Icons.notifications_active,
              size: 50,
              color: allGranted ? AppColors.primary : Colors.orange,
            ),
          ),
          const SizedBox(height: 20),

          // العنوان
          Text(
            allGranted ? 'تم منح جميع الأذونات ✓' : 'التنبيهات والإشعارات',
            style: GoogleFonts.tajawal(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: allGranted
                  ? AppColors.primary
                  : (isDark ? Colors.white : AppColors.textPrimaryLight),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // الوصف
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceDark
                  : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: allGranted
                    ? AppColors.primary
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.2)),
                width: allGranted ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'لماذا نحتاج التنبيهات؟',
                        style: GoogleFonts.tajawal(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildReasonRow(
                  '🔔',
                  'تنبيهات الأذان',
                  'تذكيرك بأوقات الصلاة الخمس بالصوت',
                  isDark,
                ),
                const SizedBox(height: 8),
                _buildReasonRow(
                  '📿',
                  'الأذكار اليومية',
                  'تذكيرك بأذكار الصباح والمساء',
                  isDark,
                ),
                const SizedBox(height: 8),
                _buildReasonRow(
                  '⏰',
                  'دقة التوقيت',
                  'ضمان تشغيل الأذان في الوقت المحدد بالضبط',
                  isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // رسالة توضيحية
          if (!allGranted)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'سيطلب منك النظام عدة أذونات متتالية. الرجاء الموافقة على جميعها لضمان عمل التطبيق بشكل كامل.',
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        color: Colors.orange,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // زر طلب الإذن
          if (!allGranted)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isRequestingPermission ? null : _requestNotificationPermission,
                icon: _isRequestingPermission
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.notifications_active, size: 22),
                label: Text(
                  _isRequestingPermission ? 'جارٍ الطلب...' : 'منح أذونات التنبيهات',
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildReasonRow(String emoji, String title, String description, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: GoogleFonts.tajawal(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // صفحة الجاهزية
  Widget _buildReadyPage(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          const SizedBox(height: 30),
          // أيقونة النجاح
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green,
                  Colors.green.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_circle,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          // العنوان
          Text(
            'كل شيء جاهز!',
            style: GoogleFonts.tajawal(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 12),

          Text(
            'تم تجهيز التطبيق بنجاح',
            style: GoogleFonts.tajawal(
              fontSize: 16,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 24),

          // ملخص الأذونات
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceDark
                  : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'ما تم تفعيله',
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 14),
                _buildSuccessRow(
                  Icons.location_on,
                  'حساب أوقات الصلاة حسب موقعك',
                  isDark,
                ),
                const SizedBox(height: 10),
                _buildSuccessRow(
                  Icons.notifications_active,
                  'تنبيهات الأذان والأذكار',
                  isDark,
                ),
                const SizedBox(height: 10),
                _buildSuccessRow(
                  Icons.alarm_on,
                  'دقة التوقيت للتنبيهات',
                  isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // نصيحة
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.tips_and_updates,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'يمكنك تعديل جميع الإعدادات من قسم الإعدادات في أي وقت',
                    style: GoogleFonts.tajawal(
                      fontSize: 13,
                      color: AppColors.primary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSuccessRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.tajawal(
              fontSize: 14,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ),
        const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 20,
        ),
      ],
    );
  }
}
