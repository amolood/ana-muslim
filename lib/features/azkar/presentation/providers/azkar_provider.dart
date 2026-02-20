import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/azkar_model.dart';
import '../../data/repositories/azkar_repository.dart';

// ─── Categories ────────────────────────────────────────────────────────────

/// Provides all azkar chapter categories (id + name) from muslim_data_flutter package.
final azkarCategoryEntriesProvider =
    FutureProvider<List<AzkarCategoryEntry>>((ref) async {
  return AzkarRepository.instance.getCategories();
});

/// Legacy-compatible provider: returns Map of chapterName to chapterId.
/// The AzkarScreen reads this map; value is now chapter ID instead of count.
final azkarCategoriesProvider =
    FutureProvider<Map<String, int>>((ref) async {
  final entries = await ref.watch(azkarCategoryEntriesProvider.future);
  return {for (final e in entries) e.name: e.id};
});

// ─── Items by chapter ──────────────────────────────────────────────────────

/// Provides azkar items for a given chapter ID.
final azkarByChapterIdProvider =
    FutureProvider.family<List<AzkarItem>, int>((ref, chapterId) async {
  return AzkarRepository.instance.getItemsByChapterId(chapterId);
});

/// Legacy-compatible family provider keyed by category name.
/// AzkarCategoryScreen passes the category title; we look up the chapter ID
/// from the categories map to load items.
final azkarByCategoryProvider =
    Provider.family<AsyncValue<List<AzkarItem>>, String>((ref, categoryName) {
  final categoriesAsync = ref.watch(azkarCategoriesProvider);
  return categoriesAsync.when(
    data: (map) {
      final chapterId = map[categoryName];
      if (chapterId == null) {
        return const AsyncValue.data([]);
      }
      return ref.watch(azkarByChapterIdProvider(chapterId));
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

// ─── Asma Allah ────────────────────────────────────────────────────────────

final asmaAllahProvider = FutureProvider<List<AsmaEntry>>((ref) async {
  return AzkarRepository.instance.getAsmaAllah();
});
