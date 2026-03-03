import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/utils/arabic_utils.dart';

// ── Islamic palette constants ────────────────────────────────────────────────
const _deepGreen = Color(0xFF0B3D23);
const _midGreen = Color(0xFF1A6B42);
const _goldAccent = Color(0xFFD4A537);

class SebhaPhraseSwitcher extends ConsumerWidget {
  const SebhaPhraseSwitcher({required this.selected, super.key});

  final SebhaPhrase selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goalText = selected.dailyGoal == 0
        ? context.l10n.dailyGoalUnset
        : context.l10n.dailyGoalLabel(
            ArabicUtils.toArabicDigits(selected.dailyGoal),
          );

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! > 200) {
          ref.read(sebhaStateProvider.notifier).moveToPreviousPhrase();
        } else if (details.primaryVelocity! < -200) {
          ref.read(sebhaStateProvider.notifier).moveToNextPhrase();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: isDark
                ? [_deepGreen.withValues(alpha: 0.8), const Color(0xFF0F2D1E)]
                : [
                    const Color(0xFFECFDF5),
                    const Color(0xFFD1FAE5),
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? _goldAccent.withValues(alpha: 0.25)
                : _midGreen.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: isDark
              ? [
                  BoxShadow(
                    color: _goldAccent.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: _midGreen.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Row(
          children: [
            _SwitcherButton(
              icon: Icons.arrow_forward_ios_rounded,
              label: context.l10n.prevPhrase,
              isDark: isDark,
              onPressed: () =>
                  ref.read(sebhaStateProvider.notifier).moveToPreviousPhrase(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    Text(
                      selected.text,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.tajawal(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : _deepGreen,
                        height: 1.4,
                        shadows: isDark
                            ? [
                                Shadow(
                                  color: _goldAccent.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? _goldAccent.withValues(alpha: 0.12)
                            : _midGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        goalText,
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? _goldAccent : _midGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'مرر يميناً/يساراً للتبديل',
                      style: GoogleFonts.tajawal(
                        fontSize: 10,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.3)
                            : _midGreen.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _SwitcherButton(
              icon: Icons.arrow_back_ios_new_rounded,
              label: context.l10n.nextPhraseLabel,
              isDark: isDark,
              onPressed: () =>
                  ref.read(sebhaStateProvider.notifier).moveToNextPhrase(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwitcherButton extends StatelessWidget {
  const _SwitcherButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onPressed,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isDark
              ? _goldAccent.withValues(alpha: 0.08)
              : _midGreen.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? _goldAccent.withValues(alpha: 0.2)
                : _midGreen.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isDark ? _goldAccent : _midGreen,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? _goldAccent.withValues(alpha: 0.8)
                    : _midGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
