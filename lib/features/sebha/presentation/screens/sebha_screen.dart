import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/arabic_utils.dart';

class SebhaScreen extends ConsumerStatefulWidget {
  const SebhaScreen({super.key});

  @override
  ConsumerState<SebhaScreen> createState() => _SebhaScreenState();
}

class _SebhaScreenState extends ConsumerState<SebhaScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sebhaStateProvider.notifier).ensureToday();
    });
  }

  @override
  void dispose() {
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
    final result = await ref.read(sebhaStateProvider.notifier).increment();
    if (!mounted) return;

    if (result.reachedGoal) {
      HapticFeedback.heavyImpact();
      final doneMessage = result.switchedToNext
          ? 'أكملت هدف "${result.completedPhrase.text}" وتم الانتقال للتسبيحة التالية'
          : 'أكملت هدف "${result.completedPhrase.text}"';
      _showInfo(doneMessage);
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
        return AlertDialog(
          backgroundColor: AppColors.surface(context),
          title: Text(
            'تصفير التسبيحة الحالية',
            style: GoogleFonts.tajawal(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'سيتم تصفير عداد التسبيحة المختارة فقط.',
            style: GoogleFonts.tajawal(color: AppColors.textSecondary(context)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'إلغاء',
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
                'تصفير',
                style: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await ref.read(sebhaStateProvider.notifier).resetSelectedCounter();
      if (!mounted) return;
      _showInfo('تم تصفير التسبيحة الحالية');
    }
  }

  Future<void> _confirmResetToday() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface(context),
          title: Text(
            'تصفير عداد اليوم',
            style: GoogleFonts.tajawal(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'سيتم تصفير جميع عدادات اليوم لكل التسبيحات.',
            style: GoogleFonts.tajawal(color: AppColors.textSecondary(context)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'إلغاء',
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
                'تصفير اليوم',
                style: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await ref.read(sebhaStateProvider.notifier).resetTodayCounters();
      if (!mounted) return;
      _showInfo('تم تصفير عداد اليوم');
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
          'السبحة',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: _confirmResetToday,
            tooltip: 'تصفير عدادات اليوم',
            icon: const Icon(Icons.restart_alt_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            _buildPhraseSwitcher(selected),
            const SizedBox(height: 14),
            _buildCounterCard(current: current, goal: goal, progress: progress),
            const SizedBox(height: 14),
            _buildStatsCard(sebhaState),
            const SizedBox(height: 14),
            _buildManageFromSettingsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhraseSwitcher(SebhaPhrase selected) {
    final textColor = AppColors.textPrimary(context);
    final goalText = selected.dailyGoal == 0
        ? 'هدف يومي: غير محدد'
        : 'هدف يومي: ${ArabicUtils.toArabicDigits(selected.dailyGoal)}';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          _buildSwitcherButton(
            icon: Icons.arrow_forward_ios_rounded,
            label: 'السابق',
            onPressed: () =>
                ref.read(sebhaStateProvider.notifier).moveToPreviousPhrase(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  Text(
                    selected.text,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.tajawal(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    goalText,
                    style: GoogleFonts.tajawal(
                      fontSize: 13,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildSwitcherButton(
            icon: Icons.arrow_back_ios_new_rounded,
            label: 'التالي',
            onPressed: () =>
                ref.read(sebhaStateProvider.notifier).moveToNextPhrase(),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitcherButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onPressed,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterCard({
    required int current,
    required int goal,
    required double progress,
  }) {
    final currentText = ArabicUtils.toArabicDigits(current);
    final goalStatus = goal == 0
        ? 'هدف غير محدد'
        : '${ArabicUtils.toArabicDigits(current)} / ${ArabicUtils.toArabicDigits(goal)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final size = math.min(constraints.maxWidth - 24, 280.0);
              return SizedBox(
                width: size,
                height: size,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: size,
                      height: size,
                      child: CircularProgressIndicator(
                        value: goal > 0 ? progress : 0,
                        strokeWidth: 8,
                        backgroundColor: AppColors.surfaceElevated(context),
                        color: AppColors.primary,
                      ),
                    ),
                    Material(
                      color: AppColors.surfaceElevated(context),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _increment,
                        child: SizedBox(
                          width: size - 36,
                          height: size - 36,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                currentText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.manrope(
                                  fontSize: 58,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary(context),
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                goalStatus,
                                style: GoogleFonts.tajawal(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary(context),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.14,
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'اضغط للتسبيح',
                                  style: GoogleFonts.tajawal(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _confirmResetSelected,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(
              'تصفير الحالية',
              style: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(SebhaState state) {
    final items = [
      ('إجمالي التسبيح', ArabicUtils.toArabicDigits(state.totalCount)),
      ('مجموع اليوم', ArabicUtils.toArabicDigits(state.todayTotalCount)),
      ('أهداف مكتملة', ArabicUtils.toArabicDigits(state.completedGoalsCount)),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: items
            .map((item) {
              return Expanded(
                child: Column(
                  children: [
                    Text(
                      item.$2,
                      style: GoogleFonts.tajawal(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.$1,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        color: AppColors.textSecondary(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }

  Widget _buildManageFromSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إدارة التسبيحات والأهداف',
            style: GoogleFonts.tajawal(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'إضافة وحذف التسبيحات وتحديد الهدف الافتراضي أصبحت من شاشة الإعدادات.',
            style: GoogleFonts.tajawal(
              fontSize: 12,
              color: AppColors.textSecondary(context),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => context.push('/settings'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.backgroundDark,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.settings_rounded),
              label: Text(
                'فتح الإعدادات',
                style: GoogleFonts.tajawal(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
