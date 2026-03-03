import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_semantic_colors.dart';
import '../../core/notifications/notifications_service.dart';
import '../../core/providers/preferences_provider.dart';
import 'widgets/onboarding_location_page.dart';
import 'widgets/onboarding_notification_page.dart';
import 'widgets/onboarding_ready_page.dart';
import 'widgets/onboarding_welcome_page.dart';

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
        if (!mounted) return;
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
      final notifGranted = await NotificationsService.requestPermission();

      final canExact = await NotificationsService.canScheduleExactAlarms();
      if (!canExact) {
        await NotificationsService.requestExactAlarmsPermission();
      }

      final hasPolicy = await NotificationsService.hasNotificationPolicyAccess();
      if (!hasPolicy) {
        await NotificationsService.requestNotificationPolicyAccess();
      }

      final exactGranted = await NotificationsService.canScheduleExactAlarms();

      setState(() {
        _notificationGranted = notifGranted;
        _exactAlarmGranted = exactGranted;
        _isRequestingPermission = false;
      });

      // الانتقال تلقائياً إلى الصفحة التالية إذا تم منح جميع الأذونات
      if (_notificationGranted && _exactAlarmGranted && _currentPage == 2) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
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
    await ref.read(onboardingCompletedProvider.notifier).save(true);
    if (mounted) {
      context.go(Routes.home);
    }
  }

  bool _canProceed() {
    switch (_currentPage) {
      case 0:
        return true;
      case 1:
        return _locationGranted;
      case 2:
        return _notificationGranted && _exactAlarmGranted;
      case 3:
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = context.colors;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        // Block system back button — user must complete onboarding
        if (didPop) return;
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // ── Progress bar ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: List.generate(
                    4,
                    (index) => Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                        decoration: BoxDecoration(
                          color: index <= _currentPage
                              ? AppColors.primary
                              : colors.borderSubtle,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Pages ──────────────────────────────────────────
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) {
                    setState(() => _currentPage = page);
                  },
                  children: [
                    OnboardingWelcomePage(isDark: isDark),
                    OnboardingLocationPage(
                      isDark: isDark,
                      isGranted: _locationGranted,
                      isRequesting: _isRequestingPermission,
                      onRequest: _requestLocationPermission,
                    ),
                    OnboardingNotificationPage(
                      isDark: isDark,
                      isGranted: _notificationGranted && _exactAlarmGranted,
                      isRequesting: _isRequestingPermission,
                      onRequest: _requestNotificationPermission,
                    ),
                    OnboardingReadyPage(isDark: isDark),
                  ],
                ),
              ),

              // ── Bottom buttons ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
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
                        disabledBackgroundColor:
                            Colors.grey.withValues(alpha: 0.3),
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
}
