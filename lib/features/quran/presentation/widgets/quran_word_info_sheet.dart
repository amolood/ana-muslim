import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_library/quran_library.dart';

import '../../../../core/services/quran_service.dart';
import '../../../../core/theme/app_colors.dart';

/// Shows a dialog for selecting a word from [surahNumber]:[ayahNumber],
/// then opens the Quran Library word-info sheet (i'rab, tassrif, qira'at).
Future<void> showQuranWordInfoSheet(
  BuildContext context, {
  required int surahNumber,
  required int ayahNumber,
}) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final ayahText = QuranService.getVerse(
    surahNumber,
    ayahNumber,
    verseEndSymbol: false,
  );
  final words = ayahText.trim().split(' ');

  await showDialog<void>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ─── Header ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'اختر الكلمة',
                      style: GoogleFonts.tajawal(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(ctx).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            // ─── Instruction ─────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                'اضغط على أي كلمة لرؤية معلوماتها (التصريف، الإعراب، القراءات)',
                style: GoogleFonts.tajawal(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurface.withValues(
                    alpha: 0.7,
                  ),
                ),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
            ),
            const Divider(height: 1),
            // ─── Word grid ───────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  textDirection: TextDirection.rtl,
                  children: List.generate(words.length, (index) {
                    return InkWell(
                      onTap: () async {
                        Navigator.of(ctx).pop();
                        try {
                          await QuranLibrary().showWordInfoByNumbers(
                            context: context,
                            surahNumber: surahNumber,
                            ayahNumber: ayahNumber,
                            wordNumber: index + 1,
                            initialKind: WordInfoKind.eerab,
                            isDark: isDark,
                          );
                        } catch (_) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'هذه الميزة تتطلب تحميل بيانات إضافية.\nيمكنك الوصول إلى معلومات الكلمات عبر الإنترنت.',
                                style: const TextStyle(fontFamily: 'Tajawal'),
                              ),
                              duration: const Duration(seconds: 4),
                              action: SnackBarAction(
                                label: 'حسناً',
                                onPressed: () {},
                              ),
                            ),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          words[index],
                          style: GoogleFonts.amiriQuran(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
