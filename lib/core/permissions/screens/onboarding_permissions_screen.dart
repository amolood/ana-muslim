import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../models/permission_info.dart';
import '../permission_manager.dart';

/// شاشة الترحيب والأذونات الاحترافية
class OnboardingPermissionsScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingPermissionsScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<OnboardingPermissionsScreen> createState() =>
      _OnboardingPermissionsScreenState();
}

class _OnboardingPermissionsScreenState
    extends State<OnboardingPermissionsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final Map<PermissionType, bool> _permissionStatus = {};
  bool _isRequestingPermissions = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    final results = await PermissionManager.checkAllPermissions();
    if (mounted) {
      setState(() {
        _permissionStatus.addAll(results);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            _buildProgressIndicator(isDark),

            // Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildWelcomePage(isDark),
                  _buildPermissionsPage(isDark),
                  _buildCompletionPage(isDark),
                ],
              ),
            ),

            // Bottom buttons
            _buildBottomButtons(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index == _currentPage;
          final isPassed = index < _currentPage;

          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(left: index > 0 ? 8 : 0),
              decoration: BoxDecoration(
                color: isActive || isPassed
                    ? AppColors.primary
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.1)),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWelcomePage(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // App icon
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
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.mosque,
              size: 60,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 32),

          // Welcome title
          Text(
            'بسم الله الرحمن الرحيم',
            style: GoogleFonts.amiriQuran(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
            textDirection: TextDirection.rtl,
          ),

          const SizedBox(height: 16),

          Text(
            'أنا المسلم',
            style: GoogleFonts.tajawal(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'رفيقك في رحلة العبادة اليومية',
            style: GoogleFonts.tajawal(
              fontSize: 18,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.8)
                  : Colors.black.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // Features list
          _buildFeatureItem(
            icon: Icons.access_time,
            title: 'مواقيت الصلاة الدقيقة',
            subtitle: 'حسب موقعك بدقة عالية',
            isDark: isDark,
          ),

          const SizedBox(height: 16),

          _buildFeatureItem(
            icon: Icons.menu_book,
            title: 'القرآن الكريم كاملاً',
            subtitle: 'مع التفسير والتلاوة والتحفيظ',
            isDark: isDark,
          ),

          const SizedBox(height: 16),

          _buildFeatureItem(
            icon: Icons.explore,
            title: 'اتجاه القبلة',
            subtitle: 'بدقة باستخدام البوصلة الذكية',
            isDark: isDark,
          ),

          const SizedBox(height: 16),

          _buildFeatureItem(
            icon: Icons.auto_awesome,
            title: 'اقتراحات ذكية',
            subtitle: 'تذكير بالأذكار والعبادات في وقتها',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark
            : AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : AppColors.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.6)
                        : Colors.black.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsPage(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Title
          Text(
            'الأذونات المطلوبة',
            style: GoogleFonts.tajawal(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'لتوفير أفضل تجربة، نحتاج بعض الأذونات',
            style: GoogleFonts.tajawal(
              fontSize: 15,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.black.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Essential permissions
          Text(
            'الأذونات الأساسية',
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 16),

          ...AppPermissions.essentialPermissions.map(
            (permission) => _buildPermissionCard(permission, isDark),
          ),

          const SizedBox(height: 24),

          // Optional permissions
          if (AppPermissions.optionalPermissions.isNotEmpty) ...[
            Text(
              'الأذونات الاختيارية (موصى بها)',
              style: GoogleFonts.tajawal(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.7)
                    : Colors.black.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            ...AppPermissions.optionalPermissions.map(
              (permission) => _buildPermissionCard(permission, isDark),
            ),
          ],

          const SizedBox(height: 24),

          // Privacy note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceDark
                  : Colors.blue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.security,
                  color: Colors.blue,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'نحترم خصوصيتك. جميع البيانات محفوظة محليًا على جهازك فقط',
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionCard(PermissionInfo permission, bool isDark) {
    final isGranted = _permissionStatus[permission.type] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGranted
              ? AppColors.primary.withValues(alpha: 0.3)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.1)),
          width: isGranted ? 2 : 1,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: permission.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  permission.icon,
                  color: permission.color,
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // Title and status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      permission.title,
                      style: GoogleFonts.tajawal(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    if (isGranted)
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'مفعّل',
                            style: GoogleFonts.tajawal(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // Required badge
              if (permission.isRequired)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'مطلوب',
                    style: GoogleFonts.tajawal(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Description
          Text(
            permission.description,
            style: GoogleFonts.tajawal(
              fontSize: 13,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.black.withValues(alpha: 0.6),
            ),
          ),

          const SizedBox(height: 8),

          // Benefit
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: permission.color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.star,
                  size: 16,
                  color: permission.color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    permission.benefit,
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: permission.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionPage(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 60),

          // Success icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              size: 60,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 32),

          Text(
            'تم بنجاح! 🎉',
            style: GoogleFonts.tajawal(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'جاهز للبدء في رحلتك الإيمانية',
            style: GoogleFonts.tajawal(
              fontSize: 16,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.black.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 48),

          _buildCompletionItem(
            icon: Icons.notifications_active,
            title: 'الإشعارات مفعّلة',
            subtitle: 'ستصلك تنبيهات الأذان والأذكار',
            isDark: isDark,
          ),

          const SizedBox(height: 16),

          _buildCompletionItem(
            icon: Icons.explore,
            title: 'جاهز للاستخدام',
            subtitle: 'يمكنك الآن استخدام جميع الميزات',
            isDark: isDark,
          ),

          const SizedBox(height: 16),

          _buildCompletionItem(
            icon: Icons.tips_and_updates,
            title: 'اقتراحات ذكية',
            subtitle: 'سنقترح عليك الأذكار والعبادات في وقتها',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark
            : AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.6)
                        : Colors.black.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isRequestingPermissions ? null : _handleNextButton,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isRequestingPermissions
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _getButtonText(),
                      style: GoogleFonts.tajawal(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),

          // Skip button (only on permissions page)
          if (_currentPage == 1) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: _handleSkip,
              child: Text(
                'تخطي الآن (يمكن تفعيلها لاحقًا)',
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.6)
                      : Colors.black.withValues(alpha: 0.4),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getButtonText() {
    switch (_currentPage) {
      case 0:
        return 'ابدأ الآن';
      case 1:
        return 'منح الأذونات';
      case 2:
        return 'دخول التطبيق';
      default:
        return 'التالي';
    }
  }

  Future<void> _handleNextButton() async {
    if (_currentPage == 0) {
      // Move to permissions page
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (_currentPage == 1) {
      // Request permissions
      await _requestAllPermissions();
    } else if (_currentPage == 2) {
      // Complete onboarding
      widget.onComplete();
    }
  }

  Future<void> _requestAllPermissions() async {
    setState(() {
      _isRequestingPermissions = true;
    });

    try {
      // Request essential permissions first
      for (final permission in AppPermissions.essentialPermissions) {
        final granted = await PermissionManager.requestPermission(
          permission.type,
        );
        _permissionStatus[permission.type] = granted;
      }

      // Request optional permissions
      for (final permission in AppPermissions.optionalPermissions) {
        final granted = await PermissionManager.requestPermission(
          permission.type,
        );
        _permissionStatus[permission.type] = granted;
      }

      if (mounted) {
        setState(() {
          _isRequestingPermissions = false;
        });

        // Move to completion page
        _pageController.animateToPage(
          2,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRequestingPermissions = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء طلب الأذونات',
              style: GoogleFonts.tajawal(),
            ),
          ),
        );
      }
    }
  }

  void _handleSkip() {
    // Skip to completion
    _pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
