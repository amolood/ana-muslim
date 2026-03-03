import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';

/// Shows a bottom sheet with a slider (18–40 pt) to adjust the Quran font size.
///
/// Persists the chosen value to [quranFontSizeProvider] on save.
Future<void> showQuranFontSizeSheet(
  BuildContext context,
  WidgetRef ref,
) async {
  final current = ref.read(quranFontSizeProvider);
  double temp = current;

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (sheetContext, setModalState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'حجم خط السورة',
                  style: GoogleFonts.tajawal(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(sheetContext).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Slider(
                  value: temp,
                  min: 18,
                  max: 40,
                  divisions: 22,
                  activeColor: AppColors.primary,
                  label: temp.toStringAsFixed(0),
                  onChanged: (value) {
                    setModalState(() => temp = value);
                  },
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'الحجم: ${temp.toStringAsFixed(0)}',
                    style: GoogleFonts.tajawal(
                      color: sheetContext.colors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await ref.read(quranFontSizeProvider.notifier).save(temp);
                      if (!sheetContext.mounted) return;
                      Navigator.of(sheetContext).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor:
                          Theme.of(sheetContext).brightness == Brightness.dark
                              ? AppColors.backgroundDark
                              : Colors.white,
                    ),
                    child: Text(
                      'حفظ',
                      style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
