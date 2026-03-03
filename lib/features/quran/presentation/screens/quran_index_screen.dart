import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/services/quran_service.dart';
import '../widgets/quran_feature_cards.dart';
import '../widgets/quran_surah_tile.dart';

class QuranIndexScreen extends ConsumerStatefulWidget {
  const QuranIndexScreen({super.key});

  @override
  ConsumerState<QuranIndexScreen> createState() => _QuranIndexScreenState();
}

class _QuranIndexScreenState extends ConsumerState<QuranIndexScreen> {
  String searchQuery = '';
  int selectedFilterIndex = 0; // 0: All, 1: Makki, 2: Madani, 3: Favorites
  final List<String> filters = ['الكل', 'مكية', 'مدنية', 'المفضلة'];
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
              Row(
                children: [
                  _buildActionButton(
                    icon: Icons.auto_awesome_rounded,
                    label: 'ختمة',
                    color: AppColors.primary,
                    onTap: () => context.push(Routes.quranKhatmah),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const QuranFeatureCards(),
          const SizedBox(height: 16),
          _buildSearchBar(),
          const SizedBox(height: 12),
          _buildFilters(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final colors = context.colors;

    return TextField(
      controller: _searchController,
      textDirection: TextDirection.rtl,
      onChanged: (value) => setState(() => searchQuery = value.trim()),
      style: GoogleFonts.tajawal(
        fontSize: 14,
        color: colors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: 'ابحث عن سورة...',
        hintStyle: GoogleFonts.tajawal(
          fontSize: 14,
          color: colors.textSecondary,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: colors.textSecondary,
          size: 20,
        ),
        suffixIcon: searchQuery.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: colors.textSecondary,
                  size: 18,
                ),
                onPressed: () {
                  _searchController.clear();
                  setState(() => searchQuery = '');
                },
              )
            : null,
        filled: true,
        fillColor: colors.surfaceCard,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.6),
            width: 1.5,
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
            border: Border.all(color: color.withValues(alpha: 0.3)),
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

  Widget _buildFilters() {
    final colors = context.colors;

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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : colors.surfaceVariant,
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
                  color: isSelected ? Colors.white : colors.textSecondary,
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
    final normalizedQuery = _normalizeSurahName(searchQuery);
    final surahs = List.generate(114, (index) => index + 1).where((
      surahNumber,
    ) {
      final nameArabic = _normalizeSurahName(
        QuranService.getSurahNameArabic(surahNumber),
      );
      final place = QuranService.getPlaceOfRevelation(surahNumber);

      if (searchQuery.isNotEmpty && !nameArabic.contains(normalizedQuery)) {
        return false;
      }
      if (selectedFilterIndex == 1 && place != 'Makkah') return false;
      if (selectedFilterIndex == 2 && place != 'Madinah') return false;
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
        return QuranSurahTile(surahNumber: surahs[index]);
      },
    );
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
