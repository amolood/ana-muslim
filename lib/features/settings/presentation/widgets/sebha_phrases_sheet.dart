import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/arabic_utils.dart';

String _goalLabel(int goal) {
  if (goal <= 0) return 'غير محدد';
  return ArabicUtils.toArabicDigits(goal);
}

void _snack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message, style: GoogleFonts.tajawal())),
  );
}

/// Opens the full sebha phrases manager as a draggable bottom sheet.
///
/// Uses [Consumer] internally so the sheet stays reactive to provider
/// changes even after the parent [WidgetRef] is out of scope.
void showSebhaPhrasesSheet(BuildContext context) {
  final controller = TextEditingController();

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surfaceDark,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        minChildSize: 0.55,
        maxChildSize: 0.92,
        builder: (sheetContext, scrollController) {
          return Consumer(
            builder: (sheetContext, ref, _) {
              final sebhaState = ref.watch(sebhaStateProvider);
              final defaultGoal = ref.watch(sebhaDefaultDailyGoalProvider);

              return Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  16 + MediaQuery.of(sheetContext).viewInsets.bottom,
                ),
                child: Column(
                  children: [
                    // ─── Drag handle ────────────────────────────
                    Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // ─── Header ─────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'إدارة قائمة التسبيحات',
                            style: GoogleFonts.tajawal(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          'الهدف: ${_goalLabel(defaultGoal)}',
                          style: GoogleFonts.tajawal(
                            fontSize: 13,
                            color: AppColors.textSecondaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // ─── Add phrase input ───────────────────────
                    TextField(
                      controller: controller,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        hintText: 'أضف تسبيحة جديدة',
                        hintStyle: GoogleFonts.tajawal(
                          color: AppColors.textSecondaryDark,
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.06),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.6,
                          ),
                        ),
                        suffixIcon: IconButton(
                          tooltip: 'إضافة',
                          icon: const Icon(
                            Icons.add_circle_rounded,
                            color: AppColors.primary,
                          ),
                          onPressed: () async {
                            final text = controller.text.trim();
                            if (text.isEmpty) {
                              _snack(sheetContext, 'اكتب التسبيحة قبل الإضافة');
                              return;
                            }
                            final added = await ref
                                .read(sebhaStateProvider.notifier)
                                .addCustomPhrase(text: text, goal: defaultGoal);
                            if (!sheetContext.mounted) return;
                            if (!added) {
                              _snack(sheetContext, 'التسبيحة موجودة بالفعل');
                              return;
                            }
                            controller.clear();
                            FocusScope.of(sheetContext).unfocus();
                          },
                        ),
                      ),
                      style: GoogleFonts.tajawal(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      onSubmitted: (_) async {
                        final text = controller.text.trim();
                        if (text.isEmpty) return;
                        final added = await ref
                            .read(sebhaStateProvider.notifier)
                            .addCustomPhrase(text: text, goal: defaultGoal);
                        if (!sheetContext.mounted) return;
                        if (!added) {
                          _snack(sheetContext, 'التسبيحة موجودة بالفعل');
                          return;
                        }
                        controller.clear();
                        FocusScope.of(sheetContext).unfocus();
                      },
                    ),
                    const SizedBox(height: 10),
                    // ─── Phrases list ───────────────────────────
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        itemCount: sebhaState.phrases.length,
                        separatorBuilder: (_, _) => Divider(
                          height: 1,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                        itemBuilder: (itemContext, index) {
                          final phrase = sebhaState.phrases[index];
                          final isSelected =
                              phrase.id == sebhaState.selectedPhraseId;
                          final phraseGoal = phrase.dailyGoal <= 0
                              ? 'غير محدد'
                              : ArabicUtils.toArabicDigits(phrase.dailyGoal);

                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () async {
                                await ref
                                    .read(sebhaStateProvider.notifier)
                                    .selectPhrase(phrase.id);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isSelected
                                          ? Icons.check_circle_rounded
                                          : Icons.radio_button_unchecked_rounded,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textSecondaryDark,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            phrase.text,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.tajawal(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            phrase.isCustom
                                                ? 'مخصصة • الهدف $phraseGoal'
                                                : 'افتراضية • الهدف $phraseGoal',
                                            style: GoogleFonts.tajawal(
                                              fontSize: 12,
                                              color: AppColors.textSecondaryDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (phrase.isCustom)
                                      IconButton(
                                        tooltip: 'حذف',
                                        onPressed: () async {
                                          final shouldDelete =
                                              await showDialog<bool>(
                                                context: itemContext,
                                                builder: (dialogContext) {
                                                  return AlertDialog(
                                                    backgroundColor:
                                                        AppColors.surfaceDark,
                                                    title: Text(
                                                      'حذف التسبيحة',
                                                      style: GoogleFonts.tajawal(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      ),
                                                    ),
                                                    content: Text(
                                                      'هل تريد حذف "${phrase.text}"؟',
                                                      style: GoogleFonts.tajawal(
                                                        color: AppColors
                                                            .textSecondaryDark,
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                              dialogContext,
                                                            ).pop(false),
                                                        child: Text(
                                                          'إلغاء',
                                                          style:
                                                              GoogleFonts.tajawal(
                                                                color: AppColors
                                                                    .textSecondaryDark,
                                                              ),
                                                        ),
                                                      ),
                                                      FilledButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                              dialogContext,
                                                            ).pop(true),
                                                        style: FilledButton.styleFrom(
                                                          backgroundColor:
                                                              AppColors.primary,
                                                          foregroundColor:
                                                              AppColors
                                                                  .backgroundDark,
                                                        ),
                                                        child: Text(
                                                          'حذف',
                                                          style:
                                                              GoogleFonts.tajawal(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ) ??
                                              false;
                                          if (!shouldDelete) return;
                                          await ref
                                              .read(sebhaStateProvider.notifier)
                                              .removeCustomPhrase(phrase.id);
                                        },
                                        icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  ).whenComplete(controller.dispose);
}
