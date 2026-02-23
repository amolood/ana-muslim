import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hadith/hadith.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/hadith_repository.dart';
import '../providers/hadith_providers.dart';
import 'hadith_book_screen.dart';
import 'hadith_search_screen.dart';

class HadithScreen extends ConsumerWidget {
  const HadithScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(hadithCollectionsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: collectionsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                ),
                error: (error, _) => _CollectionsError(
                  onRetry: () => ref.invalidate(hadithCollectionsProvider),
                ),
                data: (collections) {
                  if (collections.isEmpty) {
                    return Center(
                      child: Text(
                        'لا توجد مجموعات حديث متاحة الآن',
                        style: GoogleFonts.tajawal(color: Colors.white54),
                      ),
                    );
                  }

                  return _CollectionsTabs(collections: collections);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _header(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
    child: Row(
      children: [
        GestureDetector(
          onTap: () => context.push('/hadith/islamic-content'),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: const Icon(
              Icons.library_books_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                'مكتبة الحديث الشريف',
                style: GoogleFonts.tajawal(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'كل المجموعات: البخاري، مسلم، السنن وغيرها',
                style: GoogleFonts.tajawal(
                  fontSize: 13,
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const HadithSearchScreen()),
          ),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: const Icon(Icons.search, color: AppColors.primary, size: 20),
          ),
        ),
      ],
    ),
  );
}

class _CollectionsTabs extends StatelessWidget {
  final List<HadithCollectionInfo> collections;

  const _CollectionsTabs({required this.collections});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: collections.length,
      child: Column(
        children: [
          _tabBar(),
          Expanded(
            child: TabBarView(
              children: collections
                  .map((collection) => _BooksList(collection: collection))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabBar() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: AppColors.surfaceDark,
      borderRadius: BorderRadius.circular(14),
    ),
    child: TabBar(
      isScrollable: collections.length > 3,
      indicator: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: Colors.black,
      unselectedLabelColor: AppColors.textSecondaryDark,
      dividerColor: Colors.transparent,
      tabAlignment: collections.length > 3 ? TabAlignment.start : null,
      labelStyle: GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: GoogleFonts.tajawal(fontSize: 13),
      tabs: collections.map((c) => Tab(text: c.displayName)).toList(),
    ),
  );
}

class _CollectionsError extends StatelessWidget {
  final VoidCallback onRetry;

  const _CollectionsError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'تعذر تحميل مجموعات الحديث',
            style: GoogleFonts.tajawal(color: Colors.white54),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onRetry,
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
    );
  }
}

// ── Books list for one collection ──────────────────────────────────────────
class _BooksList extends ConsumerWidget {
  final HadithCollectionInfo collection;
  const _BooksList({required this.collection});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(hadithBooksProvider(collection.slug));

    return booksAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      ),
      error: (e, _) => Center(
        child: Text(
          'حدث خطأ في تحميل البيانات',
          style: GoogleFonts.tajawal(color: Colors.white54),
        ),
      ),
      data: (books) => ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: books.length,
        itemBuilder: (ctx, i) {
          final book = books[i];
          final arName = HadithRepository.arabicBookName(book);
          return _BookTile(
            collection: collection,
            book: book,
            arabicName: arName,
            index: i + 1,
          );
        },
      ),
    );
  }
}

// ── Single book tile ───────────────────────────────────────────────────────
class _BookTile extends StatelessWidget {
  final HadithCollectionInfo collection;
  final Book book;
  final String arabicName;
  final int index;

  const _BookTile({
    required this.collection,
    required this.book,
    required this.arabicName,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
        '/hadith/book',
        extra: HadithBookArgs(
          collectionSlug: collection.slug,
          bookNumber: book.bookNumber,
          title: arabicName,
          collectionName: collection.displayName,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2D5E57), width: 1),
        ),
        child: Row(
          children: [
            // Index badge
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Book name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    arabicName,
                    style: GoogleFonts.tajawal(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${book.numberOfHadith} حديث',
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_left,
              color: AppColors.textSecondaryDark,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
