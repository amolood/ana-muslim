import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../providers/quran_api_font_providers.dart';

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
                // ── Font family picker button ───────────────────────────
                _FontFamilyButton(
                  ref: ref,
                  sheetContext: sheetContext,
                ),
                const SizedBox(height: 12),
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

/// Shows the currently selected font name and opens the font picker on tap.
class _FontFamilyButton extends ConsumerWidget {
  const _FontFamilyButton({required this.ref, required this.sheetContext});

  final WidgetRef ref;
  final BuildContext sheetContext;

  @override
  Widget build(BuildContext context, WidgetRef watchRef) {
    final selectedKey = watchRef.watch(selectedQuranFontKeyProvider);
    final fontsAsync = watchRef.watch(quranApiFontsProvider);

    String label = 'الخط الافتراضي (حفص)';
    if (selectedKey != null) {
      final fonts = fontsAsync.asData?.value ?? [];
      final match = fonts.where((f) => f.key == selectedKey).firstOrNull;
      label = match?.displayName ?? selectedKey;
    }

    return OutlinedButton.icon(
      onPressed: () {
        Navigator.of(sheetContext).pop();
        sheetContext.push(Routes.quranFontPicker);
      },
      icon: const Icon(Icons.font_download_outlined, size: 18),
      label: Text(
        'نوع الخط: $label',
        style: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        minimumSize: const Size(double.infinity, 44),
      ),
    );
  }
}
