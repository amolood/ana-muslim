import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/services/quran_service.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/utils/arabic_utils.dart';

/// Shows a bottom sheet listing all 30 juz with their starting pages.
///
/// Calls [onPageSelected] with the first page of the chosen juz.
Future<void> showQuranJuzPickerSheet(
  BuildContext context, {
  required Future<void> Function(int page) onPageSelected,
}) async {
  final selectedJuz = await showModalBottomSheet<int>(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (ctx) => Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Text(
              'الانتقال إلى جزء',
              style: GoogleFonts.tajawal(
                color: Theme.of(ctx).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: 30,
                itemBuilder: (_, index) {
                  final juz = index + 1;
                  final firstPage = QuranService.getFirstPageForJuz(juz);
                  return ListTile(
                    onTap: () => Navigator.of(ctx).pop(juz),
                    title: Text(
                      'الجزء ${ArabicUtils.toArabicDigits(juz)}',
                      style: GoogleFonts.tajawal(
                        color: Theme.of(ctx).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'يبدأ من صفحة ${ArabicUtils.toArabicDigits(firstPage)}',
                      style: GoogleFonts.tajawal(
                        color: ctx.colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );

  if (selectedJuz == null || !context.mounted) return;
  final page = QuranService.getFirstPageForJuz(selectedJuz);
  await onPageSelected(page);
}
