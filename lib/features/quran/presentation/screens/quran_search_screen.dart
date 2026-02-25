import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/services/quran_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../widgets/surah_title_text.dart';

/// Advanced Quran search screen with full-text search
class QuranSearchScreen extends ConsumerStatefulWidget {
  const QuranSearchScreen({super.key});

  @override
  ConsumerState<QuranSearchScreen> createState() => _QuranSearchScreenState();
}

class _QuranSearchScreenState extends ConsumerState<QuranSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<SearchResult> _searchResults = [];
  bool _isSearching = false;
  String _lastQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty || query.trim().length < 2) {
      setState(() {
        _searchResults = [];
        _lastQuery = '';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _lastQuery = query;
    });

    // Simulate async search (in production, this would use an indexed database)
    final results = await _searchInQuran(query.trim());

    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  Future<List<SearchResult>> _searchInQuran(String query) async {
    final results = <SearchResult>[];
    final normalizedQuery = _normalizeArabic(query);

    // Search through all surahs
    for (int surahNum = 1; surahNum <= 114; surahNum++) {
      final verseCount = QuranService.getVerseCount(surahNum);

      for (int verseNum = 1; verseNum <= verseCount; verseNum++) {
        final verseText = QuranService.getVerse(
          surahNum,
          verseNum,
          verseEndSymbol: false,
        );
        final normalizedVerse = _normalizeArabic(verseText);

        if (normalizedVerse.contains(normalizedQuery)) {
          results.add(
            SearchResult(
              surahNumber: surahNum,
              surahName: QuranService.getSurahNameArabicNormalized(surahNum),
              ayahNumber: verseNum,
              ayahText: verseText,
              page: QuranService.getPageNumber(surahNum, verseNum),
              juz: QuranService.getJuzNumber(surahNum, verseNum),
            ),
          );
        }
      }
    }

    return results;
  }

  String _normalizeArabic(String input) {
    return input
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll(RegExp(r'[ًٌٍَُِّْ]'), '') // Remove tashkeel
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize spaces
        .trim();
  }


  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : colors.surfaceCard,
        elevation: 0,
        title: Text(
          'البحث في القرآن',
          style: GoogleFonts.tajawal(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.iconPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Search input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : colors.surfaceCard,
              border: Border(
                bottom: BorderSide(color: colors.borderSubtle),
              ),
            ),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              textDirection: TextDirection.rtl,
              style: GoogleFonts.tajawal(
                fontSize: 16,
                color: colors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'ابحث في آيات القرآن...',
                hintStyle: GoogleFonts.tajawal(
                  color: colors.textSecondary,
                  fontSize: 14,
                ),
                hintTextDirection: TextDirection.rtl,
                prefixIcon: _isSearching
                    ? Padding(
                        padding: const EdgeInsets.all(14),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(AppColors.primary),
                          ),
                        ),
                      )
                    : Icon(Icons.search, color: colors.iconSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: colors.iconSecondary),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark
                    ? AppColors.surfaceDarker
                    : colors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onChanged: (value) {
                // Debounce search
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (_searchController.text == value) {
                    _performSearch(value);
                  }
                });
              },
              onSubmitted: _performSearch,
            ),
          ),

          // Search results
          Expanded(
            child: _buildSearchResults(colors, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(AppSemanticColors colors, bool isDark) {
    if (_lastQuery.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: colors.iconSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'ابحث في آيات القرآن الكريم',
              style: GoogleFonts.tajawal(
                fontSize: 16,
                color: colors.textSecondary,
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 8),
            Text(
              'أدخل كلمة أو جملة للبحث',
              style: GoogleFonts.tajawal(
                fontSize: 14,
                color: colors.textTertiary,
              ),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      );
    }

    if (_isSearching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'جاري البحث...',
              style: GoogleFonts.tajawal(
                fontSize: 14,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: colors.iconSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'لم يتم العثور على نتائج',
              style: GoogleFonts.tajawal(
                fontSize: 16,
                color: colors.textSecondary,
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 8),
            Text(
              'جرب كلمات بحث أخرى',
              style: GoogleFonts.tajawal(
                fontSize: 14,
                color: colors.textTertiary,
              ),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Results count
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : colors.surfaceVariant,
            border: Border(
              bottom: BorderSide(color: colors.borderSubtle),
            ),
          ),
          child: Text(
            'وجدت ${_toArabicNumber(_searchResults.length)} نتيجة',
            style: GoogleFonts.tajawal(
              fontSize: 14,
              color: colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textDirection: TextDirection.rtl,
          ),
        ),

        // Results list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final result = _searchResults[index];
              return _buildResultCard(result, colors, isDark);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(
    SearchResult result,
    AppSemanticColors colors,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : colors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Navigate to the ayah
            context.push(
              '/quran/reader/${result.surahNumber}?ayah=${result.ayahNumber}&page=${result.page}',
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Surah info
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: SurahTitleText(
                        result.surahName,
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'آية ${_toArabicNumber(result.ayahNumber)}',
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_back_ios,
                      size: 14,
                      color: colors.iconSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Ayah text with highlighting
                Text(
                  result.ayahText,
                  style: GoogleFonts.amiri(
                    fontSize: 18,
                    height: 1.8,
                    color: colors.textPrimary,
                  ),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.justify,
                ),

                const SizedBox(height: 8),

                // Page and Juz info
                Row(
                  children: [
                    Icon(
                      Icons.menu_book,
                      size: 14,
                      color: colors.iconSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'صفحة ${_toArabicNumber(result.page)}',
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        color: colors.textTertiary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.bookmark_border,
                      size: 14,
                      color: colors.iconSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'جزء ${_toArabicNumber(result.juz)}',
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        color: colors.textTertiary,
                      ),
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
}

/// Model for search results
class SearchResult {
  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final String ayahText;
  final int page;
  final int juz;

  SearchResult({
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.ayahText,
    required this.page,
    required this.juz,
  });
}
