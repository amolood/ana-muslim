import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/services/quran_service.dart';

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
                Expanded(
                  child: _buildSurahList(),
                ),
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
              _buildIconButton(Icons.person),
              Text(
                'القرآن الكريم',
                style: GoogleFonts.tajawal(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
              _buildIconButton(Icons.arrow_forward_ios),
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

  Widget _buildIconButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.grey[300], size: 20),
    );
  }

  Widget _buildLastReadBanner(WidgetRef ref) {
    final lastSurah = ref.watch(lastReadSurahProvider);
    final lastPage = ref.watch(lastReadPageProvider);

    if (lastSurah == 0) {
      return const SizedBox.shrink(); // Hide if never read
    }

    final String surahName = QuranService.getSurahNameArabic(lastSurah);

    return Container(
      height: 100,
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
              child: Opacity(
                opacity: 0.05,
                child: const SizedBox.expand(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.menu_book, color: AppColors.primary, size: 16),
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
                      Text(
                        'سورة $surahName',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.notoNaskhArabic(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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
                  onPressed: () => context.push('/quran/reader/$lastSurah'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.backgroundDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
          suffixIcon: Icon(Icons.mic, color: Colors.grey[400]),
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
                        )
                      ]
                    : [],
              ),
              child: Text(
                filters[index],
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppColors.backgroundDark : Colors.grey[400],
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
    final surahs = List.generate(114, (index) => index + 1).where((surahNumber) {
      final nameArabic = QuranService.getSurahNameArabic(surahNumber);
      final place = QuranService.getPlaceOfRevelation(surahNumber);
      
      // Filter by search query
      if (searchQuery.isNotEmpty && !nameArabic.contains(searchQuery)) {
        return false;
      }
      
      // Filter by tags
      if (selectedFilterIndex == 1 && place != 'Makkah') return false; // Makki
      if (selectedFilterIndex == 2 && place != 'Madinah') return false; // Madani
      if (selectedFilterIndex == 3 && !favorites.contains(surahNumber)) return false;
      
      return true;
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
      itemCount: surahs.length,
      itemBuilder: (context, index) {
        final surahNumber = surahs[index];
        return _buildSurahItem(surahNumber);
      },
    );
  }

  Widget _buildSurahItem(int surahNumber) {
    final nameArabic = 'سورة ${QuranService.getSurahNameArabic(surahNumber)}';
    final nameEnglish = QuranService.getSurahName(surahNumber);
    final place = QuranService.getPlaceOfRevelation(surahNumber);
    final isMakki = place == 'Makkah';
    final placeArabic = isMakki ? 'مكية' : 'مدنية';
    final verseCount = QuranService.getVerseCount(surahNumber);
    final favorites = ref.watch(favoriteSurahsProvider);
    final isFavorite = favorites.contains(surahNumber);

    return GestureDetector(
      onTap: () {
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
          SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.star_border, color: AppColors.textSecondaryDark, size: 40),
                Text(
                  _toArabicNumber(surahNumber),
                  style: GoogleFonts.tajawal(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      nameArabic,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.notoNaskhArabic(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      nameEnglish,
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
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
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => ref.read(favoriteSurahsProvider.notifier).toggle(surahNumber),
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
}
