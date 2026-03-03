import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';

/// Shows a bottom sheet with a list of selectable string options.
///
/// [options] are the raw values stored/compared; [displayMapper] optionally
/// maps each raw value to a human-readable label shown in the list.
void showSettingsSelectionSheet(
  BuildContext context,
  String title,
  List<String> options,
  String currentValue,
  Future<void> Function(String) onSelected, {
  String Function(String)? displayMapper,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surfaceDark,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: GoogleFonts.tajawal(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              ...options.map((option) {
                final label =
                    displayMapper != null ? displayMapper(option) : option;
                return ListTile(
                  title: Text(
                    label,
                    style: GoogleFonts.tajawal(
                      fontSize: 16,
                      color: option == currentValue
                          ? AppColors.primary
                          : Colors.white,
                      fontWeight: option == currentValue
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  trailing: option == currentValue
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () async {
                    try {
                      await onSelected(option);
                      if (!sheetContext.mounted) return;
                      Navigator.pop(sheetContext);
                    } catch (e) {
                      if (!sheetContext.mounted) return;
                      ScaffoldMessenger.of(sheetContext).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تعذّر حفظ الإعداد',
                            style: GoogleFonts.tajawal(),
                          ),
                        ),
                      );
                    }
                  },
                );
              }),
            ],
          ),
        ),
      );
    },
  );
}
