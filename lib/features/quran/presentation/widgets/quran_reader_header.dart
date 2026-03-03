import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/services/quran_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import 'surah_title_text.dart';

/// Sticky header bar for the Quran reader.
/// Displays surah/page info, a favorite toggle, and the quick-actions row
/// (mode switch, juz picker, controls visibility, font size).
class QuranReaderHeader extends ConsumerWidget {
  const QuranReaderHeader({
    super.key,
    required this.surahNumber,
    required this.isPageMode,
    required this.currentPage,
    required this.selectedVerse,
    required this.onBack,
    required this.onToggleFavorite,
    required this.onToggleMode,
    required this.onJuzPicker,
    required this.onFontSize,
  });

  final int surahNumber;
  final bool isPageMode;
  final int currentPage;
  final int selectedVerse;
  final VoidCallback onBack;
  final VoidCallback onToggleFavorite;
  final VoidCallback onToggleMode;
  final VoidCallback onJuzPicker;
  final VoidCallback onFontSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controlsVisible = ref.watch(quranReaderControlsVisibleProvider);
    final favorites = ref.watch(favoriteSurahsProvider);
    final isFavorite = favorites.contains(surahNumber);

    final headerSurahNumber = isPageMode
        ? QuranService.getSurahNumberFromPage(currentPage)
        : surahNumber;
    final juzNumber = isPageMode
        ? QuranService.getJuzByPage(currentPage)
        : QuranService.getJuzNumber(
            surahNumber,
            selectedVerse > 0 ? selectedVerse : 1,
          );
    final versesCount = QuranService.getVerseCount(headerSurahNumber);
    final revelationType =
        QuranService.getPlaceOfRevelation(headerSurahNumber) == 'Makkah'
            ? 'مكية'
            : 'مدنية';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = context.colors;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Row: Back button, Title, Favorite
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 20,
                ),
                onPressed: onBack,
              ),
              Expanded(
                child: Column(
                  children: [
                    SurahTitleText(
                      isPageMode
                          ? QuranService.getPageTitle(currentPage)
                          : QuranService.getSurahNameArabicNormalized(
                              surahNumber,
                            ),
                      fontSize: isPageMode ? 18 : 22,
                      maxLines: 1,
                      color: isDark ? AppColors.mushafGold : AppColors.primary,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isPageMode
                          ? 'صفحة ${_toArabicNumber(currentPage)} • الجزء ${_toArabicNumber(juzNumber)}'
                          : '$revelationType • ${_toArabicNumber(versesCount)} آيات • الجزء ${_toArabicNumber(juzNumber)}',
                      style: GoogleFonts.tajawal(
                        fontSize: 10,
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isPageMode)
                IconButton(
                  tooltip: isFavorite ? 'إزالة من المفضلة' : 'إضافة للمفضلة',
                  onPressed: onToggleFavorite,
                  icon: Icon(
                    isFavorite ? Icons.bookmark : Icons.bookmark_border,
                    color: isFavorite
                        ? AppColors.primary
                        : context.colors.iconSecondary,
                    size: 22,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Bottom Row: Quick Actions
          Container(
            height: 36,
            decoration: BoxDecoration(
              color: colors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickAction(
                  context: context,
                  icon: isPageMode
                      ? Icons.menu_book_outlined
                      : Icons.chrome_reader_mode_rounded,
                  label: isPageMode ? 'السور' : 'الصفحات',
                  onTap: onToggleMode,
                ),
                Container(
                  width: 1,
                  height: 20,
                  color: context.colors.borderSubtle,
                ),
                if (isPageMode)
                  _buildQuickAction(
                    context: context,
                    icon: Icons.view_module_rounded,
                    label: 'الأجزاء',
                    onTap: onJuzPicker,
                  ),
                if (isPageMode)
                  Container(
                    width: 1,
                    height: 20,
                    color: context.colors.borderSubtle,
                  ),
                _buildQuickAction(
                  context: context,
                  icon: controlsVisible
                      ? Icons.visibility_off
                      : Icons.visibility,
                  label: controlsVisible ? 'إخفاء' : 'إظهار',
                  onTap: () => ref
                      .read(quranReaderControlsVisibleProvider.notifier)
                      .save(!controlsVisible),
                ),
                Container(
                  width: 1,
                  height: 20,
                  color: context.colors.borderSubtle,
                ),
                _buildQuickAction(
                  context: context,
                  icon: Icons.text_fields,
                  label: 'الخط',
                  onTap: onFontSize,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
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
