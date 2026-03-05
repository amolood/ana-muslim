import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/services/quran_service.dart';
import '../../../../core/theme/app_colors.dart';
import 'surah_title_text.dart';

/// Decorative surah title with an SVG banner ornament behind the surah name.
class SurahOrnamentTitle extends StatelessWidget {
  const SurahOrnamentTitle({super.key, required this.surahNumber});

  final int surahNumber;

  @override
  Widget build(BuildContext context) {
    final surahName = QuranService.getSurahNameArabicNormalized(surahNumber);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goldColor = isDark ? AppColors.mushafGold : AppColors.primary;

    return SizedBox(
      height: 70,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(
            isDark
                ? 'packages/quran_library/assets/svg/surahSvgBannerDark.svg'
                : 'packages/quran_library/assets/svg/surahSvgBanner.svg',
            width: 180,
            height: 70,
            colorFilter: ColorFilter.mode(goldColor, BlendMode.modulate),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: SurahTitleText(
              surahName,
              fontSize: 20,
              maxLines: 1,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
