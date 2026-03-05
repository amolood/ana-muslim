import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/providers/app_version_provider.dart';
import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../core/l10n/l10n.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  /// Kicked off immediately in initState so it runs in parallel with the animation.
  late final Future<AppVersionInfo?> _versionFuture;

  @override
  void initState() {
    super.initState();

    // Start version check right away — runs parallel with the 900ms animation.
    _versionFuture = ref.read(appVersionCheckProvider.future);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateAfterSplash();
      }
    });
    _controller.forward();
  }

  Future<void> _navigateAfterSplash() async {
    if (!mounted) return;

    // Give the version check up to 1.5s after animation ends (it's already
    // been running for ~900ms, so the total window is ~2.4s).
    AppVersionInfo? versionInfo;
    try {
      versionInfo = await _versionFuture.timeout(
        const Duration(milliseconds: 1500),
        onTimeout: () => null,
      );
    } catch (_) {
      versionInfo = null;
    }

    if (!mounted) return;

    // Force update: show blocking dialog, do NOT navigate.
    if (versionInfo?.status == VersionStatus.forceUpdate) {
      await _showUpdateDialog(versionInfo!);
      return;
    }

    // Soft update: show dismissible dialog before navigating.
    if (versionInfo?.status == VersionStatus.updateAvailable) {
      await _showUpdateDialog(versionInfo!);
      if (!mounted) return;
    }

    final hasCompletedOnboarding = ref.read(onboardingCompletedProvider);
    context.go(hasCompletedOnboarding ? Routes.home : Routes.onboarding);
  }

  Future<void> _showUpdateDialog(AppVersionInfo info) async {
    if (!mounted) return;

    final isForce = info.status == VersionStatus.forceUpdate;
    final locale = Localizations.localeOf(context).languageCode;
    final message = info.messageForLocale(locale);
    final storeUrl = info.storeUrl;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: !isForce,
        onPopInvokedWithResult: (didPop, _) {},
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: AppColors.surfaceDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              isForce ? context.l10n.forceUpdateTitle : context.l10n.updateAvailableTitle,
              style: GoogleFonts.tajawal(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryDark,
              ),
            ),
            content: Text(
              message,
              style: GoogleFonts.tajawal(
                fontSize: 14,
                color: AppColors.textSecondaryDark,
                height: 1.6,
              ),
            ),
            actions: [
              if (!isForce)
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(
                    context.l10n.updateLater,
                    style: GoogleFonts.tajawal(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ),
              TextButton(
                onPressed: () async {
                  if (storeUrl.isNotEmpty) {
                    await launchUrl(
                      Uri.parse(storeUrl),
                      mode: LaunchMode.externalApplication,
                    );
                  }
                  // For soft update dismiss after opening store;
                  // for force update keep dialog open.
                  if (!isForce && ctx.mounted) {
                    Navigator.of(ctx).pop();
                  }
                },
                child: Text(
                  context.l10n.updateNow,
                  style: GoogleFonts.tajawal(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.backgroundDark, AppColors.surfaceDarker],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const BrandLogo(
                          size: 80,
                          semanticsLabel: 'شعار تطبيق أنا المسلم في شاشة البداية',
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'المسلم',
                        style: GoogleFonts.tajawal(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryDark,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'رفيقك اليومي',
                        style: GoogleFonts.tajawal(
                          fontSize: 18,
                          color: AppColors.textSecondaryDark,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
