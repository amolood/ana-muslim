import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/arabic_utils.dart';
import '../../../../core/routing/routes.dart';
import '../providers/adhan_player_provider.dart';

class AdhanPlayerScreen extends ConsumerStatefulWidget {
  const AdhanPlayerScreen({required this.prayerName, super.key});

  final String prayerName;

  @override
  ConsumerState<AdhanPlayerScreen> createState() => _AdhanPlayerScreenState();
}

class _AdhanPlayerScreenState extends ConsumerState<AdhanPlayerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adhanPlayerProvider.notifier).startAdhan(widget.prayerName);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _dismiss() {
    ref.read(adhanPlayerProvider.notifier).stop();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adhanPlayerProvider);
    final isPlaying = state.status == AdhanPlaybackStatus.playing;
    final isCompleted = state.status == AdhanPlaybackStatus.completed;

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          ref.read(adhanPlayerProvider.notifier).stop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundDeepDark,
        body: SafeArea(
          child: Stack(
            children: [
              // Background gradient
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.backgroundDeepDark,
                        AppColors.primary.withValues(alpha: 0.06),
                        AppColors.backgroundDeepDark,
                      ],
                    ),
                  ),
                ),
              ),

              // Main content
              Column(
                children: [
                  // Top bar — dismiss button
                  Align(
                    alignment: AlignmentDirectional.topEnd,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: IconButton(
                        onPressed: _dismiss,
                        icon: const Icon(Icons.close_rounded),
                        color: Colors.white70,
                        iconSize: 28,
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Mosque icon with pulse
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final scale = 1.0 +
                          (isPlaying ? _pulseController.value * 0.08 : 0);
                      final glowAlpha =
                          isPlaying ? _pulseController.value * 0.25 : 0.1;
                      return Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withValues(alpha: 0.08),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.primary.withValues(alpha: glowAlpha),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Transform.scale(
                          scale: scale,
                          child: const Icon(
                            Icons.mosque_rounded,
                            size: 56,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Prayer name
                  Text(
                    'حان وقت ${widget.prayerName}',
                    style: GoogleFonts.tajawal(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Dua
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ وَالصَّلَاةِ القَائِمَةِ',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.amiriQuran(
                        fontSize: 16,
                        color: AppColors.primary.withValues(alpha: 0.8),
                        height: 2,
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Progress bar
                  if (state.status != AdhanPlaybackStatus.idle &&
                      state.status != AdhanPlaybackStatus.error)
                    _buildProgress(state),

                  const SizedBox(height: 24),

                  // Controls
                  _buildControls(state, isPlaying, isCompleted),

                  const Spacer(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgress(AdhanPlaybackState state) {
    final maxMs =
        state.duration.inMilliseconds <= 0 ? 1 : state.duration.inMilliseconds;
    final posMs = state.position.inMilliseconds.clamp(0, maxMs);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                thumbColor: AppColors.primary,
                trackHeight: 3,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 14),
              ),
              child: Slider(
                value: posMs.toDouble(),
                min: 0,
                max: maxMs.toDouble(),
                onChanged: (v) {
                  ref
                      .read(adhanPlayerProvider.notifier)
                      .seekTo(Duration(milliseconds: v.round()));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ArabicUtils.formatDuration(state.position),
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: Colors.white54,
                    ),
                  ),
                  Text(
                    ArabicUtils.formatDuration(state.duration),
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(
    AdhanPlaybackState state,
    bool isPlaying,
    bool isCompleted,
  ) {
    if (state.status == AdhanPlaybackStatus.loading) {
      return const CircularProgressIndicator(color: AppColors.primary);
    }

    if (state.status == AdhanPlaybackStatus.error) {
      return Column(
        children: [
          Text(
            state.errorMessage ?? 'خطأ',
            style: GoogleFonts.tajawal(color: AppColors.qiblaError),
          ),
          const SizedBox(height: 16),
          _actionButton(
            icon: Icons.refresh_rounded,
            label: 'إعادة المحاولة',
            onTap: () => ref
                .read(adhanPlayerProvider.notifier)
                .startAdhan(widget.prayerName),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Stop
        _actionButton(
          icon: Icons.stop_rounded,
          label: 'إيقاف',
          onTap: _dismiss,
          size: 44,
        ),

        const SizedBox(width: 24),

        // Play/Pause — central large button
        GestureDetector(
          onTap: () {
            final notifier = ref.read(adhanPlayerProvider.notifier);
            if (isCompleted) {
              notifier.startAdhan(widget.prayerName);
            } else if (isPlaying) {
              notifier.pause();
            } else {
              notifier.resume();
            }
          },
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              isCompleted
                  ? Icons.replay_rounded
                  : isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
              size: 36,
              color: AppColors.backgroundDeepDark,
            ),
          ),
        ),

        const SizedBox(width: 24),

        // Dismiss
        _actionButton(
          icon: Icons.check_rounded,
          label: 'إغلاق',
          onTap: _dismiss,
          size: 44,
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    double size = 48,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            child: Icon(icon, color: Colors.white70, size: size * 0.5),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: 11,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }
}
