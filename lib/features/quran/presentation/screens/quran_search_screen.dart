import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/utils/arabic_utils.dart';
import '../providers/quran_search_provider.dart';
import '../widgets/surah_title_text.dart';

/// Advanced Quran search screen with full-text search
class QuranSearchScreen extends ConsumerStatefulWidget {
  const QuranSearchScreen({super.key});

  @override
  ConsumerState<QuranSearchScreen> createState() => _QuranSearchScreenState();
}

class _QuranSearchScreenState extends ConsumerState<QuranSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        ref.read(quranSearchQueryProvider.notifier).update(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final query = ref.watch(quranSearchQueryProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colors.surfaceCard,
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
      body: SafeArea(
        top: false, // AppBar handles the top
        child: Column(
        children: [
          // Search input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceCard,
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
                prefixIcon: Icon(Icons.search, color: colors.iconSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: colors.iconSecondary),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(quranSearchQueryProvider.notifier).update('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: colors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onChanged: _onQueryChanged,
              onSubmitted: (value) {
                _debounce?.cancel();
                ref.read(quranSearchQueryProvider.notifier).update(value);
              },
            ),
          ),

          // Search results
          Expanded(
            child: _buildSearchResults(query, colors),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildSearchResults(
    String query,
    AppSemanticColors colors,
  ) {
    if (query.trim().length < 2) {
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

    final resultsAsync = ref.watch(quranSearchProvider(query.trim()));

    return resultsAsync.when(
      loading: () => Center(
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
      ),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'حدث خطأ أثناء البحث',
              style: GoogleFonts.tajawal(color: colors.textSecondary),
            ),
            TextButton(
              onPressed: () => ref.invalidate(quranSearchProvider(query.trim())),
              child: Text(
                'إعادة المحاولة',
                style: GoogleFonts.tajawal(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      data: (results) => results.isEmpty
          ? _buildNoResults(colors)
          : _buildResultsList(results, colors),
    );
  }

  Widget _buildNoResults(AppSemanticColors colors) {
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
            style: GoogleFonts.tajawal(fontSize: 16, color: colors.textSecondary),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 8),
          Text(
            'جرب كلمات بحث أخرى',
            style: GoogleFonts.tajawal(fontSize: 14, color: colors.textTertiary),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(
    List<QuranSearchResult> results,
    AppSemanticColors colors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colors.surfaceVariant,
            border: Border(bottom: BorderSide(color: colors.borderSubtle)),
          ),
          child: Text(
            'وجدت ${ArabicUtils.toArabicDigits(results.length)} نتيجة',
            style: GoogleFonts.tajawal(
              fontSize: 14,
              color: colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textDirection: TextDirection.rtl,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: results.length,
            itemBuilder: (context, index) =>
                _buildResultCard(results[index], colors),
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(
    QuranSearchResult result,
    AppSemanticColors colors,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            context.push(
              Routes.quranReader(result.surahNumber, ayah: result.ayahNumber, page: result.page),
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
                      'آية ${ArabicUtils.toArabicDigits(result.ayahNumber)}',
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

                // Ayah text
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
                      'صفحة ${ArabicUtils.toArabicDigits(result.page)}',
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
                      'جزء ${ArabicUtils.toArabicDigits(result.juz)}',
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
}
