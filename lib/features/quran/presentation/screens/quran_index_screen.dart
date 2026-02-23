import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/services/quran_service.dart';
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
            // Islamic Pattern overlay would go here
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
    return Container(
      padding: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.backgroundDark,
            AppColors.backgroundDark,
            AppColors.backgroundDark.withValues(alpha: 0.0),
          ],
        ),
      ),
      child: Column(
        children: [
          // AppBar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 40, height: 40),
              Text(
                'القرآن الكريم',
                style: GoogleFonts.tajawal(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
              _buildIconButton(
                Icons.auto_awesome_rounded,
                onTap: () => context.push('/quran/khatmah'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Last Read Banner
          _buildLastReadBanner(ref),
          const SizedBox(height: 16),
          // Search Bar
          _buildSearchBar(),
          const SizedBox(height: 12),
          // Filters
          _buildFilters(),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceDark.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.grey[300], size: 20),
      ),
    );
  }

  Widget _buildLastReadBanner(WidgetRef ref) {
    final lastSurah = ref.watch(lastReadSurahProvider);
    final lastPage = ref.watch(lastReadPageProvider);

    if (lastSurah == 0) {
      return const SizedBox.shrink(); // Hide if never read
    }

    final String surahName = _normalizeSurahName(
      QuranService.getSurahNameArabic(lastSurah),
    );

    return Container(
      constraints: const BoxConstraints(minHeight: 100),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF1A3A34), Color(0xFF11221F)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Opacity(opacity: 0.05, child: const SizedBox.expand()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.menu_book,
                            color: AppColors.primary,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'آخر قراءة',
                            style: GoogleFonts.tajawal(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      SurahTitleText(
                        surahName,
                        fontSize: 22,
                        maxLines: 1,
                        textAlign: TextAlign.start,
                        color: const Color(0xFFD6B06B),
                      ),
                      Text(
                        'صفحة رقم ${_toArabicNumber(lastPage)}',
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () =>
                      context.push('/quran/reader/$lastSurah?page=$lastPage'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.backgroundDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                  ),
                  child: Text(
                    'متابعة',
                    style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        onChanged: (value) => setState(() => searchQuery = value),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'بحث عن سورة...',
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(filters.length, (index) {
          final isSelected = selectedFilterIndex == index;
          return GestureDetector(
            onTap: () => setState(() => selectedFilterIndex = index),
            child: Container(
              margin: const EdgeInsets.only(left: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(20),
                border: isSelected
                    ? null
                    : Border.all(color: Colors.white.withValues(alpha: 0.05)),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 0),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                filters[index],
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? AppColors.backgroundDark
                      : Colors.grey[400],
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

      // Filter by search query
      if (searchQuery.isNotEmpty && !nameArabic.contains(searchQuery)) {
        return false;
      }

      // Filter by tags
      if (selectedFilterIndex == 1 && place != 'Makkah') {
        return false; // Makki
      }
      if (selectedFilterIndex == 2 && place != 'Madinah') {
        return false; // Madani
      }
      if (selectedFilterIndex == 3 && !favorites.contains(surahNumber)) {
        return false;
      }

      return true;
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
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

    return GestureDetector(
      onTap: () {
        QuranService.preloadSurah(surahNumber);
        context.push('/quran/reader/$surahNumber');
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            // Number indicator
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surfaceDarker.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFD6B06B).withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                _toArabicNumber(surahNumber),
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD6B06B),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SurahTitleText(
                    nameArabic,
                    fontSize: 24,
                    maxLines: 1,
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isMakki ? AppColors.primary : Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        placeArabic,
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_toArabicNumber(verseCount)} آيات',
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          color: const Color(0xFFD6B06B),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (hasSajdah) ...[
                        const SizedBox(width: 10),
                        Text(
                          '۩',
                          style: const TextStyle(
                            fontFamily: 'KFGQPC Uthmanic Script',
                            fontFamilyFallback: ['naskh'],
                            fontSize: 16,
                            color: Color(0xFFD6B06B),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () =>
                  ref.read(favoriteSurahsProvider.notifier).toggle(surahNumber),
              icon: Icon(
                isFavorite ? Icons.bookmark : Icons.bookmark_border,
                color: isFavorite ? AppColors.primary : Colors.grey[500],
                size: 20,
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 16),
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
