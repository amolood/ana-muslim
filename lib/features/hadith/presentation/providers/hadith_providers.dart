import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadith/hadith.dart';

import '../../../../core/utils/arabic_utils.dart';
import '../../data/hadith_repository.dart';

/// Available hadith collections from backend.
final hadithCollectionsProvider = FutureProvider<List<HadithCollectionInfo>>(
  (ref) => HadithRepository.getCollections(),
);

/// Books list for a given collection slug.
final hadithBooksProvider = FutureProvider.family<List<Book>, String>(
  (ref, collectionSlug) => HadithRepository.getBooks(collectionSlug),
);

/// Key for loading hadiths in a specific book.
typedef HadithBookKey = ({String collectionSlug, String bookNumber});

/// Hadiths for a specific book in a collection.
final hadithBookProvider = FutureProvider.family<List<Hadith>, HadithBookKey>((
  ref,
  key,
) {
  return HadithRepository.getHadithsForBook(key.collectionSlug, key.bookNumber);
});

/// Search key: (query, optional collection slug filter).
typedef HadithSearchKey = ({String query, String? collectionSlug});

/// Search results across one or all collections.
final hadithSearchProvider =
    FutureProvider.family<List<HadithSearchResult>, HadithSearchKey>((
      ref,
      key,
    ) async {
      // Normalize query: strip tashkeel + normalize hamza variants so that
      // searching "بسم" matches "بِسْمِ" and vice versa.
      final q = ArabicUtils.normalizeArabic(key.query.trim());
      if (q.length < 2) {
        return [];
      }

      final collections = key.collectionSlug != null
          ? [key.collectionSlug!]
          : (await HadithRepository.getCollections())
                .map((c) => c.slug)
                .toList();

      if (collections.isEmpty) {
        return [];
      }

      final lists = await Future.wait(
        collections.map((slug) => HadithRepository.search(slug, q)),
      );
      return lists.expand((r) => r).toList();
    });

// ── Grouped search result rows ─────────────────────────────────────────────

/// A row in the grouped search results list.
sealed class HadithResultRow {
  const HadithResultRow();
}

/// A section header separating results from one collection.
class HadithResultSection extends HadithResultRow {
  const HadithResultSection({required this.title, required this.count});
  final String title;
  final int count;
}

/// A single hadith result item.
class HadithResultItem extends HadithResultRow {
  const HadithResultItem({required this.result});
  final HadithSearchResult result;
}

/// Derived provider: groups and orders search result rows by collection.
///
/// Computation runs once per unique [HadithSearchKey] — not on every widget
/// rebuild — because the result is cached by Riverpod alongside the underlying
/// [hadithSearchProvider].
final hadithGroupedResultsProvider =
    Provider.family<AsyncValue<List<HadithResultRow>>, HadithSearchKey>((
      ref,
      key,
    ) {
      final resultsAsync = ref.watch(hadithSearchProvider(key));
      final collections =
          ref.watch(hadithCollectionsProvider).asData?.value ?? [];

      return resultsAsync.whenData((results) {
        // Flat list when a single collection is selected or results empty.
        if (key.collectionSlug != null || results.isEmpty) {
          return [for (final r in results) HadithResultItem(result: r)];
        }

        // Group by slug preserving collection metadata order.
        final grouped = <String, List<HadithSearchResult>>{};
        for (final r in results) {
          grouped.putIfAbsent(r.collectionSlug, () => []).add(r);
        }

        final nameBySlug = {
          for (final c in collections) c.slug: c.displayName,
        };
        final orderedSlugs = collections.map((c) => c.slug).toList();
        final rows = <HadithResultRow>[];

        for (final slug in orderedSlugs) {
          final bucket = grouped.remove(slug);
          if (bucket == null || bucket.isEmpty) continue;
          rows.add(HadithResultSection(
            title: nameBySlug[slug] ?? bucket.first.collectionTitle,
            count: bucket.length,
          ));
          rows.addAll([for (final item in bucket) HadithResultItem(result: item)]);
        }

        // Keep results for slugs not present in metadata (e.g. API additions).
        for (final entry in grouped.entries) {
          if (entry.value.isEmpty) continue;
          rows.add(HadithResultSection(
            title: entry.value.first.collectionTitle,
            count: entry.value.length,
          ));
          rows.addAll([
            for (final item in entry.value) HadithResultItem(result: item),
          ]);
        }

        return rows;
      });
    });

// ── Search UI state ────────────────────────────────────────────────────────

/// Current debounced search query driving [hadithSearchProvider].
class _HadithSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void update(String v) => state = v;
}

final hadithSearchQueryProvider =
    NotifierProvider<_HadithSearchQueryNotifier, String>(
      _HadithSearchQueryNotifier.new,
    );

/// Currently selected collection slug filter (null = search all).
class _HadithSearchSlugNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void update(String? v) => state = v;
}

final hadithSearchSlugProvider =
    NotifierProvider<_HadithSearchSlugNotifier, String?>(
      _HadithSearchSlugNotifier.new,
    );
