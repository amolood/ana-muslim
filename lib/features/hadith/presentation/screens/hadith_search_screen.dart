import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/arabic_utils.dart';
import '../../data/hadith_repository.dart';
import '../providers/hadith_providers.dart';

class HadithSearchScreen extends ConsumerStatefulWidget {
  const HadithSearchScreen({super.key});

  @override
  ConsumerState<HadithSearchScreen> createState() => _HadithSearchScreenState();
}

class _HadithSearchScreenState extends ConsumerState<HadithSearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNode.requestFocus(),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        ref.read(hadithSearchQueryProvider.notifier).update(value.trim());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final collectionsAsync = ref.watch(hadithCollectionsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCollectionFilter(collectionsAsync),
            const SizedBox(height: 4),
            Expanded(child: _buildResults()),
          ],
        ),
      ),
    );
  }

  // ── Header with search bar ─────────────────────────────────────────────────
  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(8, 10, 16, 6),
    child: Row(
      children: [
        IconButton(
          icon: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        Expanded(
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
              ),
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              textDirection: TextDirection.rtl,
              onChanged: _onQueryChanged,
              style: GoogleFonts.tajawal(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'ابحث بالنص أو رقم الحديث...',
                hintStyle: GoogleFonts.tajawal(
                  color: AppColors.textSecondaryDark,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textSecondaryDark,
                  size: 20,
                ),
                suffixIcon: ref.watch(hadithSearchQueryProvider).isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _controller.clear();
                          ref.read(hadithSearchQueryProvider.notifier).update('');
                        },
                        child: const Icon(
                          Icons.close,
                          color: Colors.white38,
                          size: 18,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: const Icon(Icons.text_increase, color: Colors.white, size: 22),
          onPressed: () => _showFontSizeSheet(context, ref),
        ),
      ],
    ),
  );

  Future<void> _showFontSizeSheet(BuildContext context, WidgetRef ref) async {
    final current = ref.read(hadithFontSizeProvider);
    double temp = current;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'حجم خط الحديث',
                    style: GoogleFonts.tajawal(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: temp,
                    min: 14,
                    max: 40,
                    divisions: 26,
                    activeColor: AppColors.primary,
                    label: temp.toStringAsFixed(0),
                    onChanged: (value) {
                      setModalState(() => temp = value);
                    },
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'الحجم: ${temp.toStringAsFixed(0)}',
                      style: GoogleFonts.tajawal(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await ref
                            .read(hadithFontSizeProvider.notifier)
                            .save(temp);
                        if (!context.mounted) {
                          return;
                        }
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.backgroundDark,
                      ),
                      child: Text(
                        'حفظ',
                        style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── Collection filter chips ────────────────────────────────────────────────
  Widget _buildCollectionFilter(
    AsyncValue<List<HadithCollectionInfo>> collectionsAsync,
  ) {
    return collectionsAsync.when(
      loading: () => const SizedBox(
        height: 40,
        child: Center(
          child: SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
      error: (_, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'تعذر تحميل المجموعات',
                style: GoogleFonts.tajawal(
                  fontSize: 13,
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ),
            TextButton(
              onPressed: () => ref.invalidate(hadithCollectionsProvider),
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
      data: (collections) {
        if (collections.isEmpty) {
          return const SizedBox.shrink();
        }

        final selectedSlug = ref.watch(hadithSearchSlugProvider);
        if (selectedSlug != null &&
            !collections.any((c) => c.slug == selectedSlug)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ref.read(hadithSearchSlugProvider.notifier).update(null);
            }
          });
        }

        return SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: collections.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _chip(value: null, label: 'الكل');
              }
              final collection = collections[index - 1];
              return _chip(
                value: collection.slug,
                label: collection.displayName,
              );
            },
          ),
        );
      },
    );
  }

  Widget _chip({required String? value, required String label}) {
    final isSelected = ref.watch(hadithSearchSlugProvider) == value;
    return GestureDetector(
      onTap: () => ref.read(hadithSearchSlugProvider.notifier).update(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderTeal,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.black : AppColors.textSecondaryDark,
          ),
        ),
      ),
    );
  }

  // ── Search results ─────────────────────────────────────────────────────────
  Widget _buildResults() {
    final query = ref.watch(hadithSearchQueryProvider);

    if (query.length < 2) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search,
              color: AppColors.textSecondaryDark,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'ابحث في مكتبة الحديث',
              style: GoogleFonts.tajawal(
                fontSize: 16,
                color: AppColors.textSecondaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'يمكنك البحث بالنص أو برقم الحديث',
              style: GoogleFonts.tajawal(
                fontSize: 13,
                color: AppColors.textSecondaryDark.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    final slug = ref.watch(hadithSearchSlugProvider);
    final key = (query: query, collectionSlug: slug);
    final rowsAsync = ref.watch(hadithGroupedResultsProvider(key));

    return rowsAsync.when(
      loading: () => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
            const SizedBox(height: 16),
            Text(
              'جاري البحث…',
              style: GoogleFonts.tajawal(color: AppColors.textSecondaryDark),
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
              style: GoogleFonts.tajawal(color: Colors.white54),
            ),
            TextButton(
              onPressed: () => ref.invalidate(hadithSearchProvider(key)),
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
      data: (rows) {
        final resultCount =
            rows.whereType<HadithResultItem>().length;

        if (resultCount == 0) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.search_off,
                  color: AppColors.textSecondaryDark,
                  size: 52,
                ),
                const SizedBox(height: 14),
                Text(
                  'لا توجد نتائج لـ "$query"',
                  style: GoogleFonts.tajawal(
                    fontSize: 15,
                    color: Colors.white54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Text(
                  '${ArabicUtils.toArabicDigits(resultCount)} نتيجة',
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                itemCount: rows.length,
                itemBuilder: (ctx, i) {
                  final row = rows[i];
                  return switch (row) {
                    HadithResultSection s => Padding(
                      padding: const EdgeInsets.fromLTRB(0, 6, 0, 8),
                      child: _ResultSectionHeader(
                        title: s.title,
                        count: s.count,
                      ),
                    ),
                    HadithResultItem item => _SearchResultTile(
                      result: item.result,
                    ),
                  };
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ResultSectionHeader extends StatelessWidget {
  const _ResultSectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderTeal),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.tajawal(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          Text(
            ArabicUtils.toArabicDigits(count),
            style: GoogleFonts.tajawal(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Single result tile ────────────────────────────────────────────────────────
class _SearchResultTile extends ConsumerStatefulWidget {
  final HadithSearchResult result;
  const _SearchResultTile({required this.result});

  @override
  ConsumerState<_SearchResultTile> createState() => _SearchResultTileState();
}

class _SearchResultTileState extends ConsumerState<_SearchResultTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final hadith = widget.result.hadith;
    final collName = widget.result.collectionTitle;
    final body =
        HadithRepository.arabicBody(hadith) ??
        HadithRepository.englishBody(hadith) ??
        '';
    final isLong = body.length > 200;
    final preview = isLong && !_expanded ? '${body.substring(0, 200)}…' : body;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderTeal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.surfaceTealDark,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    'حديث ${hadith.hadithNumber}',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    collName,
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.rtl,
                  ),
                ),
                Text(
                  'كتاب ${hadith.bookNumber}',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Text(
              preview,
              style: GoogleFonts.notoNaskhArabic(
                fontSize: ref.watch(hadithFontSizeProvider),
                color: Colors.white,
                height: 2.0,
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.end,
            ),
          ),

          // Expand + copy
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isLong)
                  TextButton(
                    onPressed: () => setState(() => _expanded = !_expanded),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      _expanded ? 'عرض أقل ▲' : 'اقرأ المزيد ▼',
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: body));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'تم نسخ الحديث',
                          style: GoogleFonts.tajawal(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.copy_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'نسخ',
                          style: GoogleFonts.tajawal(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
