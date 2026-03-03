import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/services/quran_service.dart';
import 'surah_title_text.dart';

class QuranSurahTile extends ConsumerWidget {
  const QuranSurahTile({required this.surahNumber, super.key});

  final int surahNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameArabic = _normalizeSurahName(
      QuranService.getSurahNameArabic(surahNumber),
    );
    final place = QuranService.getPlaceOfRevelation(surahNumber);
    final isMakki = place == 'Makkah';
    final placeArabic = isMakki ? 'مكية' : 'مدنية';
    final verseCount = QuranService.getVerseCount(surahNumber);
    final hasSajdah = QuranService.surahHasSajdah(surahNumber);
    final favorites = ref.watch(favoriteSurahsProvider);
    final isFavorite = favorites.contains(surahNumber);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = context.colors;

    final badgeColor = isDark ? AppColors.mushafGold : AppColors.primary;
    final badgeBgColor = isDark
        ? Colors.transparent
        : AppColors.primary.withValues(alpha: 0.1);
    final badgeBorderColor = isDark
        ? AppColors.mushafGold.withValues(alpha: 0.5)
        : AppColors.primary.withValues(alpha: 0.35);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            colors.surfaceCard,
            Color.alphaBlend(
              AppColors.primary.withValues(alpha: 0.04),
              colors.surfaceCard,
            ),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.borderSubtle.withValues(alpha: 0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            QuranService.preloadSurah(surahNumber);
            context.push(Routes.quranReader(surahNumber));
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Number badge
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: badgeBorderColor,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    _toArabicNumber(surahNumber),
                    style: GoogleFonts.tajawal(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: badgeColor,
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SurahTitleText(
                        nameArabic,
                        fontSize: 18,
                        maxLines: 1,
                        textAlign: TextAlign.start,
                        color: colors.textPrimary,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: (isMakki ? AppColors.primary : Colors.orange)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              placeArabic,
                              style: GoogleFonts.tajawal(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color:
                                    isMakki ? AppColors.primary : Colors.orange,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_toArabicNumber(verseCount)} آية',
                            style: GoogleFonts.tajawal(
                              fontSize: 11,
                              color: colors.textSecondary,
                            ),
                          ),
                          if (hasSajdah) ...[
                            const SizedBox(width: 6),
                            Text(
                              '۩',
                              style: TextStyle(
                                fontFamily: 'KFGQPC Uthmanic Script',
                                fontFamilyFallback: const ['naskh', 'Amiri'],
                                fontSize: 14,
                                color: isDark
                                    ? AppColors.mushafGold
                                    : AppColors.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Favorite & Arrow
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => ref
                          .read(favoriteSurahsProvider.notifier)
                          .toggle(surahNumber),
                      icon: Icon(
                        isFavorite ? Icons.bookmark : Icons.bookmark_border,
                        color: isFavorite
                            ? AppColors.primary
                            : colors.iconSecondary,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_back_ios,
                      color: colors.iconSecondary.withValues(alpha: 0.5),
                      size: 14,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _toArabicNumber(int number) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  String numStr = number.toString();
  for (int i = 0; i < english.length; i++) {
    numStr = numStr.replaceAll(english[i], arabic[i]);
  }
  return numStr;
}

String _normalizeSurahName(String raw) {
  final trimmed = raw.trim();
  final patterns = <String>['سورة ', 'سُورَةُ ', 'سُورَة ', 'سوره '];
  for (final pattern in patterns) {
    if (trimmed.startsWith(pattern)) {
      return trimmed.substring(pattern.length).trim();
    }
  }
  return trimmed;
}
