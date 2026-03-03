import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/azkar_model.dart';
import '../../data/repositories/azkar_repository.dart';

// ─── Section ordering & grouping helpers ────────────────────────────────────

const azkarSectionOrder = <String>[
  'أذكار يومية',
  'أذكار العبادات',
  'أذكار النوم والاستيقاظ',
  'أذكار السفر والتنقل',
  'أذكار الطعام والشراب',
  'أدعية وأذكار متنوعة',
];

String _normalizeAr(String input) {
  return input
      .toLowerCase()
      .replaceAll('أ', 'ا')
      .replaceAll('إ', 'ا')
      .replaceAll('آ', 'ا')
      .replaceAll('ة', 'ه')
      .replaceAll('ى', 'ي')
      .trim();
}

String azkarSectionForCategory(String title) {
  final normalized = _normalizeAr(title);
  if (normalized.contains('الصباح') ||
      normalized.contains('المساء') ||
      normalized.contains('اليومي')) {
    return 'أذكار يومية';
  }
  if (normalized.contains('الصلاه') ||
      normalized.contains('الاذان') ||
      normalized.contains('المسجد') ||
      normalized.contains('الوضوء')) {
    return 'أذكار العبادات';
  }
  if (normalized.contains('النوم') || normalized.contains('الاستيقاظ')) {
    return 'أذكار النوم والاستيقاظ';
  }
  if (normalized.contains('سفر') || normalized.contains('تنقل')) {
    return 'أذكار السفر والتنقل';
  }
  if (normalized.contains('طعام') ||
      normalized.contains('اكل') ||
      normalized.contains('شراب')) {
    return 'أذكار الطعام والشراب';
  }
  return 'أدعية وأذكار متنوعة';
}

// ─── Categories ────────────────────────────────────────────────────────────

/// Provides all azkar chapter categories (id + name) from remote API data.
final azkarCategoryEntriesProvider = FutureProvider<List<AzkarCategoryEntry>>((
  ref,
) async {
  return AzkarRepository.instance.getCategories();
});

/// Legacy-compatible provider: returns Map of chapterName to chapterId.
/// The AzkarScreen reads this map; value is now chapter ID instead of count.
final azkarCategoriesProvider = FutureProvider<Map<String, int>>((ref) async {
  final entries = await ref.watch(azkarCategoryEntriesProvider.future);
  return {for (final e in entries) e.name: e.id};
});

// ─── Items by chapter ──────────────────────────────────────────────────────

/// Provides azkar items for a given chapter ID.
final azkarByChapterIdProvider = FutureProvider.family<List<AzkarItem>, int>((
  ref,
  chapterId,
) async {
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

// ─── Grouped categories by section ──────────────────────────────────────────
// Derived from azkarCategoriesProvider — computed once, cached by Riverpod.
// Each value is a sorted list of (categoryName, chapterId) entries.

final azkarGroupedProvider =
    Provider<AsyncValue<Map<String, List<MapEntry<String, int>>>>>((ref) {
  final categoriesAsync = ref.watch(azkarCategoriesProvider);
  return categoriesAsync.whenData((categories) {
    final sorted = categories.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final grouped = <String, List<MapEntry<String, int>>>{
      for (final section in azkarSectionOrder) section: [],
    };
    for (final entry in sorted) {
      grouped[azkarSectionForCategory(entry.key)]!.add(entry);
    }
    return grouped;
  });
});

// ─── Asma Allah ────────────────────────────────────────────────────────────

final asmaAllahProvider = FutureProvider<List<AsmaEntry>>((ref) async {
  return AzkarRepository.instance.getAsmaAllah();
});
