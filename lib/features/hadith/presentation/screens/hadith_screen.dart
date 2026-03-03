import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hadith/hadith.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../data/hadith_repository.dart';
import '../providers/hadith_providers.dart';
import 'hadith_book_screen.dart';

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
                        context.l10n.noHadithCollections,
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
  Widget _header(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            tooltip: context.l10n.back,
            icon: Icon(
              Icons.arrow_back_ios,
              color: colors.textPrimary,
            ),
            style: IconButton.styleFrom(
              backgroundColor: colors.surfaceCard,
              padding: const EdgeInsets.all(8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.l10n.hadithLibraryTitle,
              style: GoogleFonts.tajawal(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
          ),
          Tooltip(
            message: context.l10n.search,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.push(Routes.hadithSearch),
                borderRadius: BorderRadius.circular(12),
                child: Ink(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.surfaceCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.search,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
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
          _tabBar(context),
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

  Widget _tabBar(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        isScrollable: collections.length > 3,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : AppColors.surfaceDarker,
        unselectedLabelColor: colors.textSecondary,
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
}

class _CollectionsError extends StatelessWidget {
  final VoidCallback onRetry;

  const _CollectionsError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.hadithCollectionsError,
            style: GoogleFonts.tajawal(color: colors.textSecondary),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onRetry,
            child: Text(
              context.l10n.retry,
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
          context.l10n.hadithDataError,
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
    final colors = context.colors;

    return GestureDetector(
      onTap: () => context.push(
        Routes.hadithBook,
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
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colors.borderDefault,
            width: 1,
          ),
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
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.l10n.hadithCount(book.numberOfHadith),
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_left,
              color: colors.iconSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
