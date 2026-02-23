import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/theme/app_colors.dart';

/// Onboarding with premium dark aesthetic + responsive layout.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _controller;
  int _currentPage = 0;
  double _pageValue = 0;
  bool _saving = false;

  static const _pages = <_PageData>[
    _PageData(
      badge: 'الإصدار المميز',
      title: 'المسلم',
      headline: 'رفيقك اليومي في العبادة',
      description:
          'مواقيت صلاة دقيقة، اتجاه قبلة ثابت، وواجهة مريحة للعين لترافقك في كل وقت.',
      icon: FlutterIslamicIcons.solidMosque,
      gradient: [Color(0xFF0C1F25), Color(0xFF0F3A34), Color(0xFF13302C)],
    ),
    _PageData(
      badge: 'القرآن والأذكار',
      title: 'وردك أسهل',
      headline: 'قراءة وسماع وتذكير',
      description:
          'خط واضح، آخر موضع محفوظ، أذكار مرتبة، وكل ما تحتاجه لورد يومي منظم.',
      icon: FlutterIslamicIcons.solidQuran,
      gradient: [Color(0xFF122532), Color(0xFF15413F), Color(0xFF16322C)],
    ),
    _PageData(
      badge: 'تنبيهات ذكية',
      title: 'صلاتك في وقتها',
      headline: 'تنبيهات دقيقة بدون إزعاج',
      description:
          'تحكم كامل في تنبيهات الصلوات والأوراد مع خيارات مرنة تناسب يومك.',
      icon: FlutterIslamicIcons.calendar,
      gradient: [Color(0xFF1A221A), Color(0xFF2F3B1F), Color(0xFF152620)],
    ),
  ];

  bool get _isLast => _currentPage == _pages.length - 1;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _controller.addListener(() {
      setState(() => _pageValue = _controller.page ?? _currentPage.toDouble());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await ref.read(onboardingCompletedProvider.notifier).save(true);
      if (mounted) context.go('/home');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColors = _activeGradient;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgColors[0], bgColors[1], const Color(0xFF040C0B)],
          ),
        ),
        child: Stack(
          children: [
            _floatingBokeh(bgColors),
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: _pages.length,
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      itemBuilder: (ctx, i) => _OnboardingPage(
                        data: _pages[i],
                        progress: (_pageValue - i).clamp(-1.0, 1.0),
                        isActive: i == _currentPage,
                      ),
                    ),
                  ),
                  _bottomControls(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> get _activeGradient => _pages[_currentPage].gradient;

  Widget _bottomControls() {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final compact = screenHeight < 700;
    final veryCompact = screenHeight < 620;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        22,
        veryCompact ? 4 : 8,
        22,
        veryCompact ? 10 : (compact ? 16 : 26),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_pages.length, (i) {
              final active = i == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: active ? 30 : 10,
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.primary
                      : Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              );
            }),
          ),
          SizedBox(height: veryCompact ? 12 : 20),
          SizedBox(
            width: double.infinity,
            height: veryCompact ? 52 : (compact ? 58 : 62),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  colors: [Color(0xFFF6D365), Color(0xFFFDA085)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _saving ? null : (_isLast ? _complete : _next),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                  foregroundColor: const Color(0xFF0C1D1A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isLast ? 'ابدأ رحلتك' : 'التالي',
                      style: GoogleFonts.tajawal(
                        fontSize: veryCompact ? 16 : 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      _isLast
                          ? Icons.check_circle_outline_rounded
                          : Icons.arrow_forward_rounded,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: veryCompact ? 6 : 12),
          TextButton(
            onPressed: _saving ? null : _complete,
            child: Text(
              'تخطي المقدمة',
              style: GoogleFonts.tajawal(
                fontSize: veryCompact ? 13 : 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondaryDark.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _next() async {
    await _controller.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOutCubicEmphasized,
    );
  }

  Widget _floatingBokeh(List<Color> base) {
    Positioned bubble(double left, double top, double size, double opacity) {
      return Positioned(
        left: left,
        top: top,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                base.first.withValues(alpha: opacity),
                Colors.transparent,
              ],
            ),
          ),
        ),
      );
    }

    return IgnorePointer(
      child: Stack(
        children: [
          bubble(-40, 120, 180, 0.28),
          bubble(260, 180, 140, 0.22),
          bubble(80, 420, 200, 0.18),
          bubble(210, 580, 160, 0.24),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final _PageData data;
  final double progress;
  final bool isActive;

  const _OnboardingPage({
    required this.data,
    required this.progress,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final wobble = 1 - progress.abs() * 0.08;
    final tilt = progress * 0.05;

    return LayoutBuilder(
      builder: (context, constraints) {
        final pageHeight = constraints.maxHeight;
        final compact = pageHeight < 640;
        final veryCompact = pageHeight < 540;
        final desiredArch =
            pageHeight * (veryCompact ? 0.42 : (compact ? 0.48 : 0.56));
        final maxArch = (pageHeight - (veryCompact ? 130 : 170)).clamp(
          120.0,
          420.0,
        );
        final archHeight = desiredArch.clamp(120.0, maxArch);
        final orbSize = veryCompact ? 104.0 : (compact ? 134.0 : 170.0);
        final iconSize = veryCompact ? 56.0 : (compact ? 70.0 : 86.0);
        final titleSize = veryCompact ? 25.0 : (compact ? 30.0 : 34.0);
        final headlineSize = veryCompact ? 16.0 : (compact ? 18.0 : 20.0);
        final descSize = veryCompact ? 13.0 : (compact ? 14.0 : 15.0);
        final verticalGap = compact ? 8.0 : 12.0;

        return Column(
          children: [
            SizedBox(
              height: archHeight,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  veryCompact ? 4 : (compact ? 8 : 18),
                  20,
                  veryCompact ? 2 : (compact ? 6 : 10),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Transform.scale(
                      scale: wobble,
                      child: Transform.rotate(
                        angle: tilt,
                        child: ClipPath(
                          clipper: const _ArchClipper(),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: data.gradient,
                              ),
                            ),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.white.withValues(alpha: 0.06),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    width: orbSize,
                                    height: orbSize,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withValues(
                                        alpha: 0.07,
                                      ),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.18,
                                        ),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.28,
                                          ),
                                          blurRadius: 18,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      data.icon,
                                      size: iconSize,
                                      color: Colors.white.withValues(
                                        alpha: isActive ? 0.95 : 0.7,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: veryCompact ? 6 : (compact ? 10 : 18),
                                  right: 16,
                                  left: 16,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 9,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF0E2623,
                                        ).withValues(alpha: 0.9),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.16,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.stars_rounded,
                                            size: 16,
                                            color: Color(0xFFD4B23B),
                                          ),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              data.badge,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.tajawal(
                                                color: const Color(0xFFD4B23B),
                                                fontSize: veryCompact
                                                    ? 12
                                                    : (compact ? 13 : 15),
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  height: veryCompact
                                      ? 54
                                      : (compact ? 70 : 90),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Colors.black.withValues(alpha: 0.36),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: LayoutBuilder(
                  builder: (context, contentConstraints) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: compact ? 4 : 8),
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: contentConstraints.maxHeight,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: compact ? 4 : 12),
                            Text(
                              data.title,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.tajawal(
                                fontSize: titleSize,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                            SizedBox(height: compact ? 8 : 10),
                            Container(
                              width: 60,
                              height: 4,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF8B7832),
                                    Color(0xFFD4B23B),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: verticalGap),
                            Text(
                              data.headline,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.tajawal(
                                fontSize: headlineSize,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(height: verticalGap),
                            Text(
                              data.description,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.tajawal(
                                fontSize: descSize,
                                height: 1.7,
                                color: AppColors.textSecondaryDark,
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
          ],
        );
      },
    );
  }
}

class _PageData {
  final String badge;
  final String title;
  final String headline;
  final String description;
  final IconData icon;
  final List<Color> gradient;

  const _PageData({
    required this.badge,
    required this.title,
    required this.headline,
    required this.description,
    required this.icon,
    required this.gradient,
  });
}

class _ArchClipper extends CustomClipper<Path> {
  const _ArchClipper();

  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    path.moveTo(0, h);
    path.lineTo(0, h * 0.35);
    path.quadraticBezierTo(0, 0, w / 2, 0);
    path.quadraticBezierTo(w, 0, w, h * 0.35);
    path.lineTo(w, h);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
