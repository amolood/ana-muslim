import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_semantic_colors.dart';
import '../models/permission_info.dart';
import '../permission_manager.dart';
import '../widgets/onboarding_permissions_completion_page.dart';
import '../widgets/onboarding_permissions_list_page.dart';
import '../widgets/onboarding_permissions_welcome_page.dart';
import '../widgets/permission_rationale_sheet.dart';

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
            _buildProgressIndicator(isDark),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  OnboardingPermissionsWelcomePage(isDark: isDark),
                  OnboardingPermissionsListPage(
                    isDark: isDark,
                    permissionStatus: Map.unmodifiable(_permissionStatus),
                  ),
                  OnboardingPermissionsCompletionPage(isDark: isDark),
                ],
              ),
            ),
            _buildBottomButtons(isDark),
          ],
        ),
      ),
    );
  }

  // ─── Progress indicator ───────────────────────────────────────────────────

  Widget _buildProgressIndicator(bool isDark) {
    final colors = context.colors;
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
                    : colors.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── Bottom buttons ───────────────────────────────────────────────────────

  Widget _buildBottomButtons(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          if (_currentPage == 1) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: _handleSkip,
              child: Text(
                'تخطي الآن (يمكن تفعيلها لاحقًا)',
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  color: context.colors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Logic ────────────────────────────────────────────────────────────────

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
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (_currentPage == 1) {
      await _requestAllPermissions();
    } else if (_currentPage == 2) {
      widget.onComplete();
    }
  }

  Future<void> _requestAllPermissions() async {
    setState(() => _isRequestingPermissions = true);

    try {
      // Walk through every permission (required first, then optional).
      // For each one we show an in-app rationale sheet BEFORE the OS dialog
      // so the user understands exactly why we need it and can make an
      // informed decision — not a cold, contextless system popup.
      final allPermissions = [
        ...AppPermissions.essentialPermissions,
        ...AppPermissions.optionalPermissions,
      ];

      for (final permission in allPermissions) {
        if (!mounted) break;

        // Skip permissions that are already granted — no need to ask again.
        if (_permissionStatus[permission.type] == true) continue;

        // ── Step 1: In-app rationale ───────────────────────────────────────
        // Show a full explanation of the permission before the OS dialog.
        // Returns true if the user tapped "السماح الآن", false if they skipped.
        final proceed = await PermissionRationaleSheet.show(context, permission);
        if (!mounted) break;
        if (!proceed) {
          // User chose to skip this permission — record as denied and continue.
          setState(() => _permissionStatus[permission.type] = false);
          continue;
        }

        // ── Step 2: OS permission dialog ───────────────────────────────────
        final granted =
            await PermissionManager.requestPermission(permission.type);
        if (mounted) {
          setState(() => _permissionStatus[permission.type] = granted);
        }
      }

      if (mounted) {
        setState(() => _isRequestingPermissions = false);
        _pageController.animateToPage(
          2,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isRequestingPermissions = false);
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
    _pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
