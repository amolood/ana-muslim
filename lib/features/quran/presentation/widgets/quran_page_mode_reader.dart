import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_library/quran_library.dart';

import '../../../../core/services/quran_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import 'surah_title_text.dart';

/// PageView-based Quran reader for page mode.
/// Renders full Mushaf pages with verse numbers, surah separators, and
/// sajdah icons. Has no provider dependencies — all data comes from
/// [QuranService] static methods and constructor parameters.
class QuranPageModeReader extends StatelessWidget {
  const QuranPageModeReader({
    super.key,
    required this.pageController,
    required this.quranFontSize,
    required this.textColor,
    required this.onPageChanged,
  });

  final PageController pageController;
  final double quranFontSize;
  final Color textColor;

  /// Called with the new 1-indexed page number whenever the user swipes.
  final Future<void> Function(int page) onPageChanged;

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController,
      reverse: false,
      itemCount: QuranService.totalPagesCount,
      onPageChanged: (index) => onPageChanged(index + 1),
      itemBuilder: (_, index) {
        final pageNumber = index + 1;
        final pageAyahs = QuranService.getPageAyahs(pageNumber);
        final pageTitle = QuranService.getPageTitle(pageNumber);
        final juz = QuranService.getJuzByPage(pageNumber);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.40),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: context.colors.borderSubtle),
            ),
            child: Column(
              children: [
                SurahTitleText(
                  pageTitle,
                  fontSize: 26,
                  maxLines: 1,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.mushafGold
                      : AppColors.primary,
                ),
                const SizedBox(height: 6),
                Text(
                  'الجزء ${_toArabicNumber(juz)} • الصفحة ${_toArabicNumber(pageNumber)}',
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                RichText(
                  textAlign: TextAlign.justify,
                  textDirection: TextDirection.rtl,
                  text: TextSpan(
                    children: _buildPageTextSpans(
                      context: context,
                      pageAyahs: pageAyahs,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<InlineSpan> _buildPageTextSpans({
    required BuildContext context,
    required List<AyahModel> pageAyahs,
  }) {
    if (pageAyahs.isEmpty) return const [TextSpan(text: '')];

    final spans = <InlineSpan>[];
    int? lastSurahNumber;

    for (final ayah in pageAyahs) {
      final currentSurah = ayah.surahNumber ?? 0;

      // Surah-change separator (۞ ornament)
      if (lastSurahNumber != null &&
          currentSurah != 0 &&
          currentSurah != lastSurahNumber) {
        spans.add(
          TextSpan(
            text: '  ۞  ',
            style: _quranTextStyle(
              size: quranFontSize - 1,
              color: AppColors.mushafGold,
              height: 2.0,
            ),
          ),
        );
      }

      spans.add(
        TextSpan(
          text: ayah.text.trim(),
          style: _quranTextStyle(
            size: quranFontSize + 1,
            color: textColor,
            height: 2.0,
          ),
        ),
      );

      if (_isAyahSajdah(ayah)) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: SvgPicture.asset(
                'packages/quran_library/assets/svg/sajdaIcon.svg',
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                  AppColors.mushafGold,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        );
      }

      // Verse number badge
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(
                  'packages/quran_library/assets/svg/suraNum.svg',
                  width: 32,
                  height: 32,
                  colorFilter: ColorFilter.mode(
                    AppColors.mushafGold,
                    BlendMode.srcIn,
                  ),
                ),
                Text(
                  _toArabicNumber(ayah.ayahNumber),
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.8),
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      lastSurahNumber = currentSurah;
    }
    return spans;
  }

  bool _isAyahSajdah(AyahModel ayah) {
    if (ayah.sajdaBool == true) return true;
    final dynamic sajda = ayah.sajda;
    if (sajda == null || sajda == false) return false;
    if (sajda is Map) {
      return sajda['recommended'] == true || sajda['obligatory'] == true;
    }
    if (sajda is bool) return sajda;
    return true;
  }

  TextStyle _quranTextStyle({
    required double size,
    required Color color,
    required double height,
  }) {
    return QuranLibrary().hafsStyle.copyWith(
          fontSize: size,
          height: height,
          color: color,
        );
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
}
