import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/preferences_provider.dart';
import '../../data/asma_local_data.dart';
import '../../data/models/asma_name.dart';

// ── All names (synchronous — data is local) ───────────────────────────────

final asmaAllProvider = Provider<List<AsmaName>>((_) => kAsmaAlHusna);

// ── Search query ──────────────────────────────────────────────────────────

class _AsmaSearchNotifier extends Notifier<String> {
  @override
  String build() => '';
  void update(String v) => state = v;
}

final asmaSearchQueryProvider =
    NotifierProvider<_AsmaSearchNotifier, String>(_AsmaSearchNotifier.new);

// ── Filtered names ────────────────────────────────────────────────────────

final asmaFilteredProvider = Provider<List<AsmaName>>((ref) {
  final all = ref.watch(asmaAllProvider);
  final query = ref.watch(asmaSearchQueryProvider).trim();

  if (query.isEmpty) return all;

  final q = query.toLowerCase();
  return all
      .where(
        (n) =>
            n.arabic.contains(query) ||
            n.transliteration.toLowerCase().contains(q) ||
            n.meaningAr.contains(query) ||
            n.meaningEn.toLowerCase().contains(q) ||
            n.number.toString() == query,
      )
      .toList();
});

// ── Favorites ─────────────────────────────────────────────────────────────

class AsmaFavoritesNotifier extends Notifier<Set<int>> {
  static const _key = 'asma_favorites';

  @override
  Set<int> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final saved = prefs.getStringList(_key) ?? [];
    return saved.map(int.parse).toSet();
  }

  Future<void> toggle(int number) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final next = Set<int>.from(state);
    if (next.contains(number)) {
      next.remove(number);
    } else {
      next.add(number);
    }
    state = next;
    await prefs.setStringList(
      _key,
      next.map((n) => n.toString()).toList(),
    );
  }

  bool isFavorite(int number) => state.contains(number);
}

final asmaFavoritesProvider =
    NotifierProvider<AsmaFavoritesNotifier, Set<int>>(
  AsmaFavoritesNotifier.new,
);

// ── Favorites-only filter ─────────────────────────────────────────────────

final asmaFavoriteNamesProvider = Provider<List<AsmaName>>((ref) {
  final all = ref.watch(asmaAllProvider);
  final favs = ref.watch(asmaFavoritesProvider);
  return all.where((n) => favs.contains(n.number)).toList();
});
