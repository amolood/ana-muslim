import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shared_preferences_base.dart';

// ─── Default Quran reciter ─────────────────────────────────────────────────

final defaultReciterIdProvider =
    NotifierProvider<DefaultReciterIdNotifier, int?>(
      DefaultReciterIdNotifier.new,
    );

class DefaultReciterIdNotifier extends Notifier<int?> {
  @override
  int? build() =>
      ref.watch(sharedPreferencesProvider).getInt('default_reciter_id');

  Future<void> save(int id) async {
    state = id;
    await ref.read(sharedPreferencesProvider).setInt('default_reciter_id', id);
  }

  Future<void> clear() async {
    state = null;
    await ref.read(sharedPreferencesProvider).remove('default_reciter_id');
  }
}

final defaultReciterNameProvider =
    NotifierProvider<DefaultReciterNameNotifier, String?>(
      DefaultReciterNameNotifier.new,
    );

class DefaultReciterNameNotifier extends Notifier<String?> {
  @override
  String? build() =>
      ref.watch(sharedPreferencesProvider).getString('default_reciter_name');

  Future<void> save(String name) async {
    state = name;
    await ref
        .read(sharedPreferencesProvider)
        .setString('default_reciter_name', name);
  }

  Future<void> clear() async {
    state = null;
    await ref.read(sharedPreferencesProvider).remove('default_reciter_name');
  }
}

final favoriteReciterIdsProvider =
    NotifierProvider<FavoriteReciterIdsNotifier, List<int>>(
      FavoriteReciterIdsNotifier.new,
    );

class FavoriteReciterIdsNotifier extends Notifier<List<int>> {
  static const _key = 'favorite_reciter_ids';

  @override
  List<int> build() {
    final raw =
        ref.watch(sharedPreferencesProvider).getStringList(_key) ??
        const <String>[];
    final parsed = <int>[];
    final seen = <int>{};

    for (final item in raw) {
      final id = int.tryParse(item);
      if (id == null || !seen.add(id)) continue;
      parsed.add(id);
    }

    return parsed;
  }

  bool isFavorite(int reciterId) => state.contains(reciterId);

  Future<void> toggle(int reciterId) async {
    final updated = List<int>.from(state);
    if (updated.contains(reciterId)) {
      updated.remove(reciterId);
    } else {
      updated.insert(0, reciterId);
    }
    state = updated;
    await _persist(updated);
  }

  Future<void> add(int reciterId) async {
    if (state.contains(reciterId)) return;
    final updated = [reciterId, ...state];
    state = updated;
    await _persist(updated);
  }

  Future<void> remove(int reciterId) async {
    if (!state.contains(reciterId)) return;
    final updated = List<int>.from(state)..remove(reciterId);
    state = updated;
    await _persist(updated);
  }

  Future<void> clear() async {
    state = const <int>[];
    await ref.read(sharedPreferencesProvider).remove(_key);
  }

  Future<void> _persist(List<int> values) async {
    await ref
        .read(sharedPreferencesProvider)
        .setStringList(_key, values.map((id) => id.toString()).toList());
  }
}

final preferredReciterMoshafProvider =
    NotifierProvider<PreferredReciterMoshafNotifier, Map<int, int>>(
      PreferredReciterMoshafNotifier.new,
    );

class PreferredReciterMoshafNotifier extends Notifier<Map<int, int>> {
  static const _key = 'preferred_reciter_moshaf_map';

  SharedPreferences get _p => ref.read(sharedPreferencesProvider);

  @override
  Map<int, int> build() {
    final raw = ref.watch(sharedPreferencesProvider).getStringList(_key) ?? [];
    final parsed = <int, int>{};

    for (final entry in raw) {
      final parts = entry.split(':');
      if (parts.length != 2) continue;
      final reciterId = int.tryParse(parts[0]);
      final moshafId = int.tryParse(parts[1]);
      if (reciterId == null || moshafId == null) continue;
      parsed[reciterId] = moshafId;
    }

    return parsed;
  }

  int? selectedMoshafIdForReciter(int reciterId) => state[reciterId];

  Future<void> saveSelection(int reciterId, int moshafId) async {
    state = {...state, reciterId: moshafId};
    await _persist();
  }

  Future<void> clearForReciter(int reciterId) async {
    if (!state.containsKey(reciterId)) return;
    final updated = Map<int, int>.from(state)..remove(reciterId);
    state = updated;
    await _persist();
  }

  Future<void> clearAll() async {
    state = {};
    await _p.remove(_key);
  }

  Future<void> _persist() async {
    final encoded = state.entries
        .map((entry) => '${entry.key}:${entry.value}')
        .toList();
    await _p.setStringList(_key, encoded);
  }
}
