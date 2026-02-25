import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/services/quran_service.dart';
import '../providers/bookmark_provider.dart';
import '../widgets/surah_title_text.dart';

class QuranIndexScreen extends ConsumerStatefulWidget {
  const QuranIndexScreen({super.key});

  @override
  ConsumerState<QuranIndexScreen> createState() => _QuranIndexScreenState();
}

class _QuranIndexScreenState extends ConsumerState<QuranIndexScreen> {
  String searchQuery = '';
  int selectedFilterIndex = 0; // 0: All, 1: Makki, 2: Madani, 3: Favorites

  final List<String> filters = ['الكل', 'مكية', 'مدنية', 'المفضلة'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildSurahList()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Container(
      padding: const EdgeInsets.only(top: 16, left: 20, right: 20, bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            backgroundColor,
            backgroundColor,
            backgroundColor.withValues(alpha: 0.0),
          ],
        ),
      ),
      child: Column(
        children: [
          // Title and Quick Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title
              Expanded(
                child: Text(
                  'القرآن الكريم',
                  style: GoogleFonts.tajawal(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: 0.5,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
              // Quick Actions
              Row(
                children: [
                  _buildActionButton(
                    icon: Icons.auto_awesome_rounded,
                    label: 'ختمة',
                    color: AppColors.primary,
                    onTap: () => context.push('/quran/khatmah'),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Feature Cards Row
          _buildFeatureCards(),

          const SizedBox(height: 16),

          // Filters
          _buildFilters(),
        ],
      ),
    );
  }

  Widget _buildFeatureCards() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bookmarks = ref.watch(coloredBookmarksProvider);
    final bookmarkCount = bookmarks.values.expand((list) => list).length;

    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Search Card
          SizedBox(
            width: 160,
            child: _buildFeatureCard(
              icon: Icons.search,
              title: 'البحث',
              subtitle: 'في القرآن',
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1A4D3A), const Color(0xFF0F2E22)]
                    : [const Color(0xFFE8F5F1), const Color(0xFFD1EDE5)],
              ),
              iconColor: AppColors.primary,
              onTap: () => context.push('/quran/search'),
            ),
          ),

          const SizedBox(width: 12),

          // Bookmarks Card
          SizedBox(
            width: 130,
            child: _buildFeatureCard(
              icon: Icons.bookmark,
              title: 'العلامات',
              subtitle: '$bookmarkCount',
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF4D3A1A), const Color(0xFF2E220F)]
                    : [const Color(0xFFFFF9E6), const Color(0xFFFFF0CC)],
              ),
              iconColor: const Color(0xFFD6B06B),
              onTap: () => context.push('/quran/bookmarks'),
              badge: bookmarkCount > 0 ? bookmarkCount : null,
            ),
          ),

          const SizedBox(width: 12),

          // Tahfeez Card
          SizedBox(
            width: 160,
            child: _buildFeatureCard(
              icon: Icons.school_outlined,
              title: 'التحفيظ',
              subtitle: 'احفظ القرآن',
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF3A1A4D), const Color(0xFF220F2E)]
                    : [const Color(0xFFF0E6FF), const Color(0xFFE0CCFF)],
              ),
              iconColor: const Color(0xFF9C27B0),
              onTap: () => context.push('/quran/tahfeez'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required Color iconColor,
    required VoidCallback onTap,
    int? badge,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: iconColor.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: GoogleFonts.tajawal(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.tajawal(
                      fontSize: 11,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.7)
                          : Colors.black.withValues(alpha: 0.5),
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
              if (badge != null)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge.toString(),
                      style: GoogleFonts.tajawal(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.tajawal(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const SizedBox(width: 6),
              Icon(icon, color: color, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLastReadBanner(WidgetRef ref) {
    final lastSurah = ref.watch(lastReadSurahProvider);
    final lastPage = ref.watch(lastReadPageProvider);

    if (lastSurah == 0) {
      return const SizedBox.shrink();
    }

    final String surahName = _normalizeSurahName(
      QuranService.getSurahNameArabic(lastSurah),
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: const BoxConstraints(minHeight: 90),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A3A34), const Color(0xFF11221F)]
              : [AppColors.primary.withValues(alpha: 0.12), AppColors.surfaceLight],
        ),
        border: Border.all(
          color: isDark
              ? AppColors.primary.withValues(alpha: 0.2)
              : AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/quran/reader/$lastSurah?page=$lastPage'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Book icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.menu_book,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'آخر قراءة',
                        style: GoogleFonts.tajawal(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: context.colors.textSecondary,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 2),
                      SurahTitleText(
                        surahName,
                        fontSize: 18,
                        maxLines: 1,
                        textAlign: TextAlign.start,
                        color: isDark ? const Color(0xFFD6B06B) : Colors.black,
                      ),
                      Text(
                        'صفحة ${_toArabicNumber(lastPage)}',
                        style: GoogleFonts.tajawal(
                          fontSize: 11,
                          color: context.colors.textTertiary,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                ),

                // Continue button
                Icon(
                  Icons.arrow_back_ios,
                  size: 18,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Row(
        children: List.generate(filters.length, (index) {
          final isSelected = selectedFilterIndex == index;
          return GestureDetector(
            onTap: () => setState(() => selectedFilterIndex = index),
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.surfaceDark
                        : Theme.of(context).colorScheme.surfaceContainerHighest),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : context.colors.borderSubtle,
                ),
              ),
              child: Text(
                filters[index],
                style: GoogleFonts.tajawal(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? (isDark ? AppColors.backgroundDark : Colors.white)
                      : context.colors.textSecondary,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSurahList() {
    final favorites = ref.watch(favoriteSurahsProvider);
    final surahs = List.generate(114, (index) => index + 1).where((
      surahNumber,
    ) {
      final nameArabic = _normalizeSurahName(
        QuranService.getSurahNameArabic(surahNumber),
      );
      final place = QuranService.getPlaceOfRevelation(surahNumber);

      if (searchQuery.isNotEmpty && !nameArabic.contains(searchQuery)) {
        return false;
      }

      if (selectedFilterIndex == 1 && place != 'Makkah') {
        return false;
      }
      if (selectedFilterIndex == 2 && place != 'Madinah') {
        return false;
      }
      if (selectedFilterIndex == 3 && !favorites.contains(surahNumber)) {
        return false;
      }

      return true;
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 100),
      cacheExtent: 520,
      itemCount: surahs.length,
      itemBuilder: (context, index) {
        final surahNumber = surahs[index];
        return _buildSurahItem(surahNumber);
      },
    );
  }

  Widget _buildSurahItem(int surahNumber) {
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

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark
            : Colors.white, // Plain white for light mode
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: context.colors.borderSubtle.withValues(alpha: 0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            QuranService.preloadSurah(surahNumber);
            context.push('/quran/reader/$surahNumber');
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Number
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [
                              AppColors.primary.withValues(alpha: 0.15),
                              AppColors.primary.withValues(alpha: 0.08),
                            ]
                          : [
                              AppColors.primary.withValues(alpha: 0.1),
                              AppColors.primary.withValues(alpha: 0.05),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (isDark ? const Color(0xFFD6B06B) : AppColors.primary)
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    _toArabicNumber(surahNumber),
                    style: GoogleFonts.tajawal(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFFD6B06B) : AppColors.primary,
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
                        color: isDark ? const Color(0xFFD6B06B) : Colors.black,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                                color: isMakki ? AppColors.primary : Colors.orange,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_toArabicNumber(verseCount)} آية',
                            style: GoogleFonts.tajawal(
                              fontSize: 11,
                              color: context.colors.textSecondary,
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
                                color: isDark ? const Color(0xFFD6B06B) : AppColors.primary,
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
                      onPressed: () =>
                          ref.read(favoriteSurahsProvider.notifier).toggle(surahNumber),
                      icon: Icon(
                        isFavorite ? Icons.bookmark : Icons.bookmark_border,
                        color: isFavorite ? AppColors.primary : context.colors.iconSecondary,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_back_ios,
                      color: context.colors.iconSecondary.withValues(alpha: 0.5),
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
}
