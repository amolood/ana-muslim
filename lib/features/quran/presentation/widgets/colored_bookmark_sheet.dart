import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/services/quran_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../providers/bookmark_provider.dart';

/// Bottom sheet for selecting colored bookmarks
class ColoredBookmarkSheet extends ConsumerWidget {
  const ColoredBookmarkSheet({
    super.key,
    required this.surahNumber,
    required this.ayahNumber,
  });

  final int surahNumber;
  final int ayahNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final bookmarks = ref.watch(coloredBookmarksProvider);
    final ayahId = QuranService.getAyahUniqueNumber(surahNumber, ayahNumber);
    final page = QuranService.getPageNumber(surahNumber, ayahNumber);
    final surahName = QuranService.getSurahNameArabicNormalized(surahNumber);

    // Check if this ayah is bookmarked
    final existingBookmark = bookmarks.values
        .expand((list) => list)
        .where((b) => b.ayahId == ayahId)
        .firstOrNull;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.bookmark, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'العلامات المرجعية الملونة',
                  style: GoogleFonts.tajawal(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
              if (existingBookmark != null)
                IconButton(
                  icon: Icon(Icons.delete_outline, color: colors.error),
                  onPressed: () {
                    ref
                        .read(coloredBookmarksProvider.notifier)
                        .removeBookmark(existingBookmark.id);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'تمت إزالة العلامة المرجعية',
                          style: GoogleFonts.tajawal(),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$surahName - آية $ayahNumber',
            style: GoogleFonts.tajawal(
              fontSize: 14,
              color: colors.textSecondary,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 24),

          // Color options
          ...BookmarkColor.values.map((bookmarkColor) {
            final isSelected = existingBookmark?.colorCode == bookmarkColor.colorCode;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  // Remove existing bookmark if any
                  if (existingBookmark != null) {
                    ref
                        .read(coloredBookmarksProvider.notifier)
                        .removeBookmark(existingBookmark.id);
                  }

                  // Add new bookmark with selected color
                  ref.read(coloredBookmarksProvider.notifier).addBookmark(
                        surahName: surahName,
                        ayahId: ayahId,
                        ayahNumber: ayahNumber,
                        page: page,
                        color: bookmarkColor,
                      );

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'تمت إضافة ${bookmarkColor.arabicName}',
                        style: GoogleFonts.tajawal(),
                      ),
                      backgroundColor: Color(bookmarkColor.colorCode),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Color(bookmarkColor.colorCode).withValues(alpha: 0.2)
                        : colors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Color(bookmarkColor.colorCode)
                          : colors.borderSubtle,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(bookmarkColor.colorCode),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          bookmarkColor.arabicName,
                          style: GoogleFonts.tajawal(
                            fontSize: 16,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: colors.textPrimary,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: Color(bookmarkColor.colorCode),
                          size: 24,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Show the colored bookmark bottom sheet
Future<void> showColoredBookmarkSheet(
  BuildContext context, {
  required int surahNumber,
  required int ayahNumber,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ColoredBookmarkSheet(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
    ),
  );
}
