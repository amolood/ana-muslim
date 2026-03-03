import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hadith/hadith.dart';

import '../../../../core/constants/ui_strings.dart';
import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/hadith_repository.dart';

/// Chapter section header shown above a group of hadiths in the list.
class HadithChapterHeader extends StatelessWidget {
  const HadithChapterHeader({super.key, required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 6, 0, 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.menu_book_rounded, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textDirection: TextDirection.rtl,
              style: GoogleFonts.tajawal(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count حديث',
            style: GoogleFonts.tajawal(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Single expandable hadith card with copy-to-clipboard support.
class HadithTile extends ConsumerStatefulWidget {
  const HadithTile({
    super.key,
    required this.hadith,
    required this.index,
    required this.collectionName,
  });

  final Hadith hadith;
  final int index;
  final String collectionName;

  @override
  ConsumerState<HadithTile> createState() => _HadithTileState();
}

class _HadithTileState extends ConsumerState<HadithTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final arText = HadithRepository.arabicBody(widget.hadith);
    final enText = HadithRepository.englishBody(widget.hadith);
    final chapter = HadithRepository.chapterTitle(widget.hadith);

    final displayText = arText ?? enText ?? '';
    final isLong = displayText.length > 160;
    final preview =
        isLong && !_expanded ? '${displayText.substring(0, 160)}…' : displayText;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderTeal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Top bar: hadith number + chapter ──────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.surfaceTealDark,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    'حديث ${widget.hadith.hadithNumber}',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    chapter,
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      color: AppColors.textSecondaryDark,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ],
            ),
          ),

          // ── Arabic body ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Text(
              preview,
              style: GoogleFonts.notoNaskhArabic(
                fontSize: ref.watch(hadithFontSizeProvider),
                color: Colors.white,
                height: 2.0,
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.end,
            ),
          ),

          // ── Expand / collapse + copy ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isLong)
                  TextButton(
                    onPressed: () => setState(() => _expanded = !_expanded),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      _expanded ? 'عرض أقل ▲' : 'اقرأ المزيد ▼',
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: displayText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          UiStrings.hadithCopied,
                          style: GoogleFonts.tajawal(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: AppColors.primary,
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.copy_outlined,
                        size: 14,
                        color: AppColors.textSecondaryDark,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'نسخ',
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
