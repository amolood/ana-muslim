import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadith/hadith.dart';

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
      final q = key.query.trim();
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
