import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/arabic_utils.dart';
import '../widgets/sebha_manage_card.dart';
import '../widgets/sebha_phrase_switcher.dart';
import '../widgets/sebha_stats_card.dart';

class SebhaScreen extends ConsumerStatefulWidget {
  const SebhaScreen({super.key});

  @override
  ConsumerState<SebhaScreen> createState() => _SebhaScreenState();
}

// ── Islamic palette constants ────────────────────────────────────────────────
const _deepGreen = Color(0xFF0B3D23);
const _midGreen = Color(0xFF1A6B42);
const _lightGreen = Color(0xFF34C27A);
const _goldAccent = Color(0xFFD4A537);

class _SebhaScreenState extends ConsumerState<SebhaScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  String? _completionMessage;
  Timer? _messageTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sebhaStateProvider.notifier).ensureToday();
    });
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _scaleController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(sebhaStateProvider.notifier).ensureToday();
    }
  }

  Future<void> _increment() async {
    HapticFeedback.selectionClick();
    // Quick scale-down then bounce back
    _scaleController.forward().then((_) => _scaleController.reverse());
    final result = await ref.read(sebhaStateProvider.notifier).increment();
    if (!mounted) return;

    if (result.reachedGoal) {
      HapticFeedback.heavyImpact();
      final doneMessage = result.switchedToNext
          ? context.l10n.goalReachedSwitched(result.completedPhrase.text)
          : context.l10n.goalReached(result.completedPhrase.text);
      _messageTimer?.cancel();
      setState(() => _completionMessage = doneMessage);
      _messageTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) setState(() => _completionMessage = null);
      });
    }
  }

  void _showInfo(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message, style: GoogleFonts.tajawal()),
      ),
    );
  }

  Future<void> _confirmResetSelected() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: AppColors.surface(context),
            title: Text(
              context.l10n.resetCurrentPhraseTitle,
              style: GoogleFonts.tajawal(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w700,
              ),
            ),
            content: Text(
              context.l10n.resetCurrentPhraseMsg,
              style: GoogleFonts.tajawal(color: AppColors.textSecondary(context)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  context.l10n.cancel,
                  style: GoogleFonts.tajawal(
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.backgroundDark,
                ),
                child: Text(
                  context.l10n.reset,
                  style: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed == true) {
      await ref.read(sebhaStateProvider.notifier).resetSelectedCounter();
      if (!mounted) return;
      _showInfo(context.l10n.phraseResetSuccess);
    }
  }

  Future<void> _confirmResetToday() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: AppColors.surface(context),
            title: Text(
              context.l10n.resetTodayTitle,
              style: GoogleFonts.tajawal(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w700,
              ),
            ),
            content: Text(
              context.l10n.resetTodayMsg,
              style: GoogleFonts.tajawal(color: AppColors.textSecondary(context)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  context.l10n.cancel,
                  style: GoogleFonts.tajawal(
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.backgroundDark,
                ),
                child: Text(
                  context.l10n.resetTodayBtn,
                  style: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed == true) {
      await ref.read(sebhaStateProvider.notifier).resetTodayCounters();
      if (!mounted) return;
      _showInfo(context.l10n.todayResetSuccess);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sebhaState = ref.watch(sebhaStateProvider);
    final selected = sebhaState.selectedPhrase;
    final current = sebhaState.selectedCount;
    final goal = selected.dailyGoal;
    final progress = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.sebhaTitle,
          style: GoogleFonts.tajawal(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: _confirmResetToday,
            tooltip: context.l10n.resetTodayCounters,
            icon: const Icon(Icons.restart_alt_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            SebhaPhraseSwitcher(selected: selected),
            const SizedBox(height: 14),
            _buildCounterCard(current: current, goal: goal, progress: progress),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _completionMessage != null
                  ? _buildCompletionMessage(_completionMessage!)
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 14),
            SebhaStatsCard(state: sebhaState),
            const SizedBox(height: 14),
            const SebhaManageCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionMessage(String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      key: const ValueKey('completion'),
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? _goldAccent.withValues(alpha: 0.14)
              : _midGreen.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? _goldAccent.withValues(alpha: 0.35)
                : _midGreen.withValues(alpha: 0.28),
          ),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.tajawal(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDark ? _goldAccent : _midGreen,
          ),
        ),
      ),
    );
  }

  Widget _buildCounterCard({
    required int current,
    required int goal,
    required double progress,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentText = ArabicUtils.toArabicDigits(current);
    final goalStatus = goal == 0
        ? context.l10n.goalUnsetText
        : '${ArabicUtils.toArabicDigits(current)} / ${ArabicUtils.toArabicDigits(goal)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [const Color(0xFF0E2A1A), const Color(0xFF091A10)]
              : [const Color(0xFFF0FDF4), const Color(0xFFDCFCE7)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? _goldAccent.withValues(alpha: 0.2)
              : _midGreen.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final size = math.min(constraints.maxWidth - 24, 290.0);
              return ScaleTransition(
                scale: _scaleAnimation,
                child: SizedBox(
                  width: size,
                  height: size,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glow halo behind the circle
                      Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (isDark ? _goldAccent : _midGreen)
                                  .withValues(alpha: 0.18),
                              blurRadius: 32,
                              spreadRadius: 4,
                            ),
                            BoxShadow(
                              color: (isDark ? _lightGreen : _midGreen)
                                  .withValues(alpha: 0.08),
                              blurRadius: 60,
                              spreadRadius: 12,
                            ),
                          ],
                        ),
                      ),
                      // Progress ring (thicker)
                      SizedBox(
                        width: size,
                        height: size,
                        child: CircularProgressIndicator(
                          value: goal > 0 ? progress : 0,
                          strokeWidth: 13,
                          strokeCap: StrokeCap.round,
                          backgroundColor: isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : _midGreen.withValues(alpha: 0.1),
                          color: isDark ? _goldAccent : _midGreen,
                        ),
                      ),
                      // Inner tap circle
                      GestureDetector(
                        onTap: _increment,
                        child: Container(
                          width: size - 44,
                          height: size - 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: isDark
                                  ? [
                                      _midGreen.withValues(alpha: 0.6),
                                      _deepGreen.withValues(alpha: 0.9),
                                    ]
                                  : [
                                      const Color(0xFFECFDF5),
                                      const Color(0xFFA7F3D0),
                                    ],
                              radius: 0.9,
                            ),
                            border: Border.all(
                              color: isDark
                                  ? _goldAccent.withValues(alpha: 0.3)
                                  : _midGreen.withValues(alpha: 0.35),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                currentText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.manrope(
                                  fontSize: 62,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : _deepGreen,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                goalStatus,
                                style: GoogleFonts.tajawal(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? _goldAccent.withValues(alpha: 0.85)
                                      : _midGreen,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? _goldAccent.withValues(alpha: 0.15)
                                      : _midGreen.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  context.l10n.tapToCount,
                                  style: GoogleFonts.tajawal(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: isDark ? _goldAccent : _midGreen,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _confirmResetSelected,
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? _goldAccent : _midGreen,
              side: BorderSide(
                color: isDark
                    ? _goldAccent.withValues(alpha: 0.4)
                    : _midGreen.withValues(alpha: 0.5),
              ),
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: Text(
              context.l10n.resetCurrentBtn,
              style: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

}
