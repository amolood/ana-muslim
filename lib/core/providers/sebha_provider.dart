import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'shared_preferences_base.dart';

// ─── Sebha ────────────────────────────────────────────────────────────────

const sebhaDefaultDailyGoalKey = 'sebha_default_daily_goal';

class SebhaPhrase {
  final String id;
  final String text;
  final int dailyGoal; // 0 => غير محدد
  final bool isCustom;

  const SebhaPhrase({
    required this.id,
    required this.text,
    required this.dailyGoal,
    required this.isCustom,
  });

  SebhaPhrase copyWith({
    String? id,
    String? text,
    int? dailyGoal,
    bool? isCustom,
  }) {
    return SebhaPhrase(
      id: id ?? this.id,
      text: text ?? this.text,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'dailyGoal': dailyGoal,
    'isCustom': isCustom,
  };

  factory SebhaPhrase.fromJson(Map<String, dynamic> json) {
    final rawGoal = json['dailyGoal'];
    final parsedGoal = rawGoal is int
        ? rawGoal
        : int.tryParse(rawGoal?.toString() ?? '');

    return SebhaPhrase(
      id: json['id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      dailyGoal: (parsedGoal ?? 33).clamp(0, 1000000),
      isCustom: json['isCustom'] == true,
    );
  }
}

class SebhaState {
  final List<SebhaPhrase> phrases;
  final String selectedPhraseId;
  final Map<String, int> dailyCounts;
  final int totalCount;
  final String dayKey;

  const SebhaState({
    required this.phrases,
    required this.selectedPhraseId,
    required this.dailyCounts,
    required this.totalCount,
    required this.dayKey,
  });

  SebhaPhrase get selectedPhrase {
    if (phrases.isEmpty) {
      return const SebhaPhrase(
        id: 'default_0',
        text: 'سبحان الله',
        dailyGoal: 33,
        isCustom: false,
      );
    }
    for (final phrase in phrases) {
      if (phrase.id == selectedPhraseId) return phrase;
    }
    return phrases.first;
  }

  int get selectedCount => dailyCounts[selectedPhrase.id] ?? 0;
  int get todayTotalCount => dailyCounts.values.fold(0, (sum, v) => sum + v);
  int get completedGoalsCount {
    var completed = 0;
    for (final phrase in phrases) {
      final goal = phrase.dailyGoal;
      if (goal > 0 && (dailyCounts[phrase.id] ?? 0) >= goal) {
        completed++;
      }
    }
    return completed;
  }

  SebhaState copyWith({
    List<SebhaPhrase>? phrases,
    String? selectedPhraseId,
    Map<String, int>? dailyCounts,
    int? totalCount,
    String? dayKey,
  }) {
    return SebhaState(
      phrases: phrases ?? this.phrases,
      selectedPhraseId: selectedPhraseId ?? this.selectedPhraseId,
      dailyCounts: dailyCounts ?? this.dailyCounts,
      totalCount: totalCount ?? this.totalCount,
      dayKey: dayKey ?? this.dayKey,
    );
  }

  Map<String, dynamic> toJson() => {
    'phrases': phrases.map((e) => e.toJson()).toList(),
    'selectedPhraseId': selectedPhraseId,
    'dailyCounts': dailyCounts,
    'totalCount': totalCount,
    'dayKey': dayKey,
  };

  factory SebhaState.fromJson(Map<String, dynamic> json) {
    final phraseListRaw = json['phrases'];
    final phraseList = <SebhaPhrase>[];
    if (phraseListRaw is List) {
      for (final item in phraseListRaw) {
        if (item is Map) {
          phraseList.add(
            SebhaPhrase.fromJson(item.map((k, v) => MapEntry('$k', v))),
          );
        }
      }
    }

    final countMapRaw = json['dailyCounts'];
    final countMap = <String, int>{};
    if (countMapRaw is Map) {
      for (final entry in countMapRaw.entries) {
        final key = entry.key.toString();
        final value = entry.value;
        final parsed = value is int
            ? value
            : int.tryParse(value?.toString() ?? '');
        if (parsed != null && parsed > 0) {
          countMap[key] = parsed;
        }
      }
    }

    final rawTotal = json['totalCount'];
    final total = rawTotal is int
        ? rawTotal
        : int.tryParse(rawTotal?.toString() ?? '');

    return SebhaState(
      phrases: phraseList,
      selectedPhraseId: json['selectedPhraseId']?.toString() ?? '',
      dailyCounts: countMap,
      totalCount: (total ?? 0).clamp(0, 1000000000),
      dayKey: json['dayKey']?.toString() ?? '',
    );
  }
}

class SebhaTapResult {
  final bool reachedGoal;
  final bool switchedToNext;
  final SebhaPhrase completedPhrase;
  final SebhaPhrase activePhrase;

  const SebhaTapResult({
    required this.reachedGoal,
    required this.switchedToNext,
    required this.completedPhrase,
    required this.activePhrase,
  });
}

final sebhaStateProvider = NotifierProvider<SebhaStateNotifier, SebhaState>(
  SebhaStateNotifier.new,
);

final sebhaCurrentCountProvider = Provider<int>((ref) {
  return ref.watch(sebhaStateProvider).selectedCount;
});

final sebhaTotalCountProvider = Provider<int>((ref) {
  return ref.watch(sebhaStateProvider).totalCount;
});

final sebhaDailyGoalProvider = Provider<int>((ref) {
  return ref.watch(sebhaStateProvider).selectedPhrase.dailyGoal;
});

final sebhaDefaultDailyGoalProvider =
    NotifierProvider<SebhaDefaultDailyGoalNotifier, int>(
      SebhaDefaultDailyGoalNotifier.new,
    );

class SebhaDefaultDailyGoalNotifier extends Notifier<int> {
  @override
  int build() {
    final saved = ref
        .watch(sharedPreferencesProvider)
        .getInt(sebhaDefaultDailyGoalKey);
    if (saved == null) return 33;
    return saved.clamp(0, 1000000);
  }

  Future<void> save(int goal) async {
    final normalized = goal.clamp(0, 1000000);
    state = normalized;
    await ref
        .read(sharedPreferencesProvider)
        .setInt(sebhaDefaultDailyGoalKey, normalized);
  }
}

class SebhaStateNotifier extends Notifier<SebhaState> {
  static const _stateKey = 'sebha_state_v2';

  @override
  SebhaState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final saved = prefs.getString(_stateKey);
    final today = _todayKey();

    if (saved != null && saved.isNotEmpty) {
      try {
        final decoded = jsonDecode(saved);
        if (decoded is Map) {
          final parsed = SebhaState.fromJson(
            decoded.map((k, v) => MapEntry('$k', v)),
          );
          final merged = _normalizeLoadedState(parsed, today: today);
          return merged;
        }
      } catch (e) {
        if (kDebugMode) debugPrint('[SebhaNotifier] corrupt saved state, resetting: $e');
      }
    }

    final oldCurrent = prefs.getInt('sebha_current_count') ?? 0;
    final oldTotal = prefs.getInt('sebha_total_count') ?? 0;
    final oldGoal = prefs.getInt('sebha_daily_goal');
    final defaultGoal = prefs.getInt(sebhaDefaultDailyGoalKey) ?? 33;
    final firstGoal = (oldGoal == null || oldGoal <= 0) ? defaultGoal : oldGoal;
    final defaults = _defaultPhrases(firstGoal: firstGoal);

    final migrated = SebhaState(
      phrases: defaults,
      selectedPhraseId: defaults.first.id,
      dailyCounts: oldCurrent > 0 ? {defaults.first.id: oldCurrent} : const {},
      totalCount: oldTotal.clamp(0, 1000000000),
      dayKey: today,
    );

    Future.microtask(() => _persist(migrated));
    return migrated;
  }

  Future<void> ensureToday() async {
    final normalized = _normalizeDay(state, today: _todayKey());
    if (normalized.dayKey != state.dayKey) {
      state = normalized;
      await _persist(state);
    }
  }

  Future<SebhaTapResult> increment() async {
    final activeState = _ensureStateToday();
    final phrase = activeState.selectedPhrase;
    final currentCount = activeState.dailyCounts[phrase.id] ?? 0;
    final nextCount = currentCount + 1;

    final nextDailyCounts = Map<String, int>.from(activeState.dailyCounts)
      ..[phrase.id] = nextCount;

    var nextState = activeState.copyWith(
      dailyCounts: nextDailyCounts,
      totalCount: activeState.totalCount + 1,
    );

    final reachedGoal = phrase.dailyGoal > 0 && nextCount == phrase.dailyGoal;
    var switched = false;
    if (reachedGoal && nextState.phrases.length > 1) {
      final currentIndex = nextState.phrases.indexWhere(
        (p) => p.id == phrase.id,
      );
      final nextIndex = currentIndex < 0
          ? 0
          : (currentIndex + 1) % nextState.phrases.length;
      final nextPhrase = nextState.phrases[nextIndex];
      if (nextPhrase.id != phrase.id) {
        switched = true;
        nextState = nextState.copyWith(selectedPhraseId: nextPhrase.id);
      }
    }

    state = nextState;
    await _persist(nextState);

    return SebhaTapResult(
      reachedGoal: reachedGoal,
      switchedToNext: switched,
      completedPhrase: phrase,
      activePhrase: nextState.selectedPhrase,
    );
  }

  Future<void> selectPhrase(String phraseId) async {
    final activeState = _ensureStateToday();
    final exists = activeState.phrases.any((p) => p.id == phraseId);
    if (!exists) return;
    state = activeState.copyWith(selectedPhraseId: phraseId);
    await _persist(state);
  }

  Future<void> moveToNextPhrase() async {
    final activeState = _ensureStateToday();
    if (activeState.phrases.isEmpty) return;
    final currentIndex = activeState.phrases.indexWhere(
      (p) => p.id == activeState.selectedPhraseId,
    );
    final nextIndex = currentIndex < 0
        ? 0
        : (currentIndex + 1) % activeState.phrases.length;
    state = activeState.copyWith(
      selectedPhraseId: activeState.phrases[nextIndex].id,
    );
    await _persist(state);
  }

  Future<void> moveToPreviousPhrase() async {
    final activeState = _ensureStateToday();
    if (activeState.phrases.isEmpty) return;
    final currentIndex = activeState.phrases.indexWhere(
      (p) => p.id == activeState.selectedPhraseId,
    );
    final prevIndex = currentIndex <= 0
        ? activeState.phrases.length - 1
        : currentIndex - 1;
    state = activeState.copyWith(
      selectedPhraseId: activeState.phrases[prevIndex].id,
    );
    await _persist(state);
  }

  Future<void> setDailyGoalForSelected(int goal) async {
    final activeState = _ensureStateToday();
    final normalizedGoal = goal.clamp(0, 1000000);
    final selectedId = activeState.selectedPhrase.id;
    final updatedPhrases = activeState.phrases.map((phrase) {
      if (phrase.id == selectedId) {
        return phrase.copyWith(dailyGoal: normalizedGoal);
      }
      return phrase;
    }).toList();
    state = activeState.copyWith(phrases: updatedPhrases);
    await _persist(state);
  }

  Future<void> setDailyGoalForAll(int goal) async {
    final activeState = _ensureStateToday();
    final normalizedGoal = goal.clamp(0, 1000000);
    final updatedPhrases = activeState.phrases
        .map((phrase) => phrase.copyWith(dailyGoal: normalizedGoal))
        .toList(growable: false);
    state = activeState.copyWith(phrases: updatedPhrases);
    await _persist(state);
  }

  Future<bool> addCustomPhrase({
    required String text,
    required int goal,
  }) async {
    final normalizedText = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalizedText.isEmpty) return false;

    final activeState = _ensureStateToday();
    final exists = activeState.phrases.any(
      (phrase) => phrase.text == normalizedText,
    );
    if (exists) return false;

    final phrase = SebhaPhrase(
      id: 'custom_${DateTime.now().microsecondsSinceEpoch}',
      text: normalizedText,
      dailyGoal: goal.clamp(0, 1000000),
      isCustom: true,
    );

    state = activeState.copyWith(
      phrases: [...activeState.phrases, phrase],
      selectedPhraseId: phrase.id,
    );
    await _persist(state);
    return true;
  }

  Future<void> removeCustomPhrase(String phraseId) async {
    final activeState = _ensureStateToday();
    SebhaPhrase? target;
    for (final phrase in activeState.phrases) {
      if (phrase.id == phraseId) {
        target = phrase;
        break;
      }
    }
    if (target == null || !target.isCustom) return;

    final updatedPhrases = activeState.phrases
        .where((phrase) => phrase.id != phraseId)
        .toList();

    if (updatedPhrases.isEmpty) return;

    final updatedCounts = Map<String, int>.from(activeState.dailyCounts)
      ..remove(phraseId);
    final nextSelected =
        updatedPhrases.any(
          (phrase) => phrase.id == activeState.selectedPhraseId,
        )
        ? activeState.selectedPhraseId
        : updatedPhrases.first.id;

    state = activeState.copyWith(
      phrases: updatedPhrases,
      selectedPhraseId: nextSelected,
      dailyCounts: updatedCounts,
    );
    await _persist(state);
  }

  Future<void> resetSelectedCounter() async {
    final activeState = _ensureStateToday();
    final selectedId = activeState.selectedPhrase.id;
    final updatedCounts = Map<String, int>.from(activeState.dailyCounts)
      ..remove(selectedId);
    state = activeState.copyWith(dailyCounts: updatedCounts);
    await _persist(state);
  }

  Future<void> resetTodayCounters() async {
    final activeState = _ensureStateToday();
    state = activeState.copyWith(dailyCounts: const {});
    await _persist(state);
  }

  SebhaState _normalizeLoadedState(SebhaState loaded, {required String today}) {
    final defaults = _defaultPhrases();
    final defaultById = {for (final phrase in defaults) phrase.id: phrase};

    final loadedById = {for (final phrase in loaded.phrases) phrase.id: phrase};
    final mergedDefaults = defaults.map((defaultPhrase) {
      final existing = loadedById[defaultPhrase.id];
      if (existing == null) return defaultPhrase;
      return existing.copyWith(text: defaultPhrase.text, isCustom: false);
    }).toList();

    final customPhrases = loaded.phrases
        .where(
          (phrase) => phrase.isCustom && !defaultById.containsKey(phrase.id),
        )
        .toList();

    final merged = SebhaState(
      phrases: [...mergedDefaults, ...customPhrases],
      selectedPhraseId: loaded.selectedPhraseId,
      dailyCounts: loaded.dailyCounts,
      totalCount: loaded.totalCount,
      dayKey: loaded.dayKey,
    );

    final selectedValid = merged.phrases.any(
      (phrase) => phrase.id == merged.selectedPhraseId,
    );

    final fixedSelection = selectedValid
        ? merged
        : merged.copyWith(selectedPhraseId: merged.phrases.first.id);

    final normalized = _normalizeDay(fixedSelection, today: today);
    final allowedIds = normalized.phrases.map((e) => e.id).toSet();
    final filteredCounts = <String, int>{};
    for (final entry in normalized.dailyCounts.entries) {
      if (allowedIds.contains(entry.key) && entry.value > 0) {
        filteredCounts[entry.key] = entry.value;
      }
    }

    return normalized.copyWith(dailyCounts: filteredCounts);
  }

  SebhaState _ensureStateToday() {
    final normalized = _normalizeDay(state, today: _todayKey());
    if (normalized.dayKey != state.dayKey) {
      state = normalized;
      Future.microtask(() => _persist(state));
    }
    return state;
  }

  SebhaState _normalizeDay(SebhaState source, {required String today}) {
    if (source.dayKey == today) return source;
    return source.copyWith(dayKey: today, dailyCounts: const {});
  }

  List<SebhaPhrase> _defaultPhrases({int firstGoal = 33}) {
    return [
      SebhaPhrase(
        id: 'default_0',
        text: 'سبحان الله',
        dailyGoal: firstGoal.clamp(0, 1000000),
        isCustom: false,
      ),
      const SebhaPhrase(
        id: 'default_1',
        text: 'الحمد لله',
        dailyGoal: 33,
        isCustom: false,
      ),
      const SebhaPhrase(
        id: 'default_2',
        text: 'الله أكبر',
        dailyGoal: 33,
        isCustom: false,
      ),
      const SebhaPhrase(
        id: 'default_3',
        text: 'لا إله إلا الله',
        dailyGoal: 33,
        isCustom: false,
      ),
      const SebhaPhrase(
        id: 'default_4',
        text: 'أستغفر الله',
        dailyGoal: 100,
        isCustom: false,
      ),
      const SebhaPhrase(
        id: 'default_5',
        text: 'لا حول ولا قوة إلا بالله',
        dailyGoal: 33,
        isCustom: false,
      ),
      const SebhaPhrase(
        id: 'default_6',
        text: 'سبحان الله وبحمده',
        dailyGoal: 100,
        isCustom: false,
      ),
      const SebhaPhrase(
        id: 'default_7',
        text: 'سبحان الله العظيم',
        dailyGoal: 100,
        isCustom: false,
      ),
      const SebhaPhrase(
        id: 'default_8',
        text: 'اللهم صل وسلم على نبينا محمد',
        dailyGoal: 100,
        isCustom: false,
      ),
    ];
  }

  String _todayKey() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }

  Future<void> _persist(SebhaState value) {
    final encoded = jsonEncode(value.toJson());
    return ref.read(sharedPreferencesProvider).setString(_stateKey, encoded);
  }
}
