import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
              icon: Icons.arrow_back_ios_new_rounded,
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
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.tajawal(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : _deepGreen,
                        height: 1.5,
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
                    GestureDetector(
                      onTap: () => _showGoalPicker(context, ref, selected, isDark),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? _goldAccent.withValues(alpha: 0.12)
                              : _midGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? _goldAccent.withValues(alpha: 0.3)
                                : _midGreen.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              goalText,
                              style: GoogleFonts.tajawal(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? _goldAccent : _midGreen,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.edit_rounded,
                              size: 11,
                              color: isDark
                                  ? _goldAccent.withValues(alpha: 0.7)
                                  : _midGreen.withValues(alpha: 0.7),
                            ),
                          ],
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
              icon: Icons.arrow_forward_ios_rounded,
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

// ── Goal picker dialog ─────────────────────────────────────────────────────

Future<void> _showGoalPicker(
  BuildContext context,
  WidgetRef ref,
  SebhaPhrase phrase,
  bool isDark,
) async {
  final presets = [33, 99, 100, 200, 500, 1000];
  final ctrl = TextEditingController(
    text: phrase.dailyGoal > 0 ? phrase.dailyGoal.toString() : '',
  );
  int? selectedPreset = presets.contains(phrase.dailyGoal) ? phrase.dailyGoal : null;
  bool applyToAll = false;

  final accent = isDark ? _goldAccent : _midGreen;

  await showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setS) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF0E2A1A) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'هدف التسبيح',
            style: GoogleFonts.tajawal(
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : _deepGreen,
            ),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Preset chips ─────────────────────────────────────
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    // "No goal" chip
                    _GoalChip(
                      label: 'بلا هدف',
                      isSelected: selectedPreset == 0,
                      accent: accent,
                      isDark: isDark,
                      onTap: () {
                        setS(() {
                          selectedPreset = 0;
                          ctrl.clear();
                        });
                      },
                    ),
                    for (final p in presets)
                      _GoalChip(
                        label: ArabicUtils.toArabicDigits(p),
                        isSelected: selectedPreset == p,
                        accent: accent,
                        isDark: isDark,
                        onTap: () {
                          setS(() {
                            selectedPreset = p;
                            ctrl.text = p.toString();
                            ctrl.selection = TextSelection.collapsed(
                              offset: ctrl.text.length,
                            );
                          });
                        },
                      ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Custom text field ─────────────────────────────────
                Text(
                  'أو أدخل عدداً مخصصاً',
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.6)
                        : _deepGreen.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: ctrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  autofocus: false,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  onChanged: (v) {
                    final n = int.tryParse(v);
                    setS(() {
                      selectedPreset =
                          (n != null && presets.contains(n)) ? n : null;
                    });
                  },
                  style: GoogleFonts.manrope(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : _deepGreen,
                  ),
                  decoration: InputDecoration(
                    hintText: '١٠٠',
                    hintStyle: GoogleFonts.manrope(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.25)
                          : _deepGreen.withValues(alpha: 0.25),
                    ),
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : _midGreen.withValues(alpha: 0.06),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: accent.withValues(alpha: 0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: accent.withValues(alpha: 0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: accent, width: 1.5),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Apply to all toggle ───────────────────────────────
                Row(
                  children: [
                    Checkbox(
                      value: applyToAll,
                      activeColor: accent,
                      onChanged: (v) => setS(() => applyToAll = v ?? false),
                    ),
                    Flexible(
                      child: GestureDetector(
                        onTap: () => setS(() => applyToAll = !applyToAll),
                        child: Text(
                          'تطبيق على كل الأذكار',
                          style: GoogleFonts.tajawal(
                            fontSize: 13,
                            color: isDark ? Colors.white70 : _deepGreen,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'إلغاء',
                style: GoogleFonts.tajawal(color: Colors.grey),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: accent),
              onPressed: () {
                // Determine the chosen goal value
                int goal;
                if (selectedPreset == 0) {
                  goal = 0;
                } else {
                  final parsed = int.tryParse(ctrl.text.trim());
                  if (parsed == null) return; // invalid — don't close
                  goal = parsed.clamp(0, 999999);
                }

                if (applyToAll) {
                  ref
                      .read(sebhaStateProvider.notifier)
                      .setDailyGoalForAll(goal);
                } else {
                  ref
                      .read(sebhaStateProvider.notifier)
                      .setDailyGoalForSelected(goal);
                }
                Navigator.pop(ctx);
              },
              child: Text(
                'حفظ',
                style: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    ),
  );

  ctrl.dispose();
}

class _GoalChip extends StatelessWidget {
  const _GoalChip({
    required this.label,
    required this.isSelected,
    required this.accent,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color accent;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? accent.withValues(alpha: 0.2)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.grey.withValues(alpha: 0.08)),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? accent : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected
                ? accent
                : (isDark ? Colors.white70 : _deepGreen.withValues(alpha: 0.7)),
          ),
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
