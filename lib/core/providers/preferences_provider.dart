import 'dart:convert';

import 'package:adhan/adhan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider has not been initialized',
  );
});

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
      } catch (_) {}
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

// ─── Quran ────────────────────────────────────────────────────────────────

final lastReadSurahProvider = NotifierProvider<LastReadSurahNotifier, int>(
  LastReadSurahNotifier.new,
);

class LastReadSurahNotifier extends Notifier<int> {
  @override
  int build() =>
      ref.watch(sharedPreferencesProvider).getInt('last_read_surah') ?? 0;
  Future<void> save(int val) async {
    state = val;
    await ref.read(sharedPreferencesProvider).setInt('last_read_surah', val);
  }
}

final lastReadPageProvider = NotifierProvider<LastReadPageNotifier, int>(
  LastReadPageNotifier.new,
);

class LastReadPageNotifier extends Notifier<int> {
  @override
  int build() =>
      ref.watch(sharedPreferencesProvider).getInt('last_read_page') ?? 0;
  Future<void> save(int val) async {
    state = val;
    await ref.read(sharedPreferencesProvider).setInt('last_read_page', val);
  }
}

final favoriteSurahsProvider =
    NotifierProvider<FavoriteSurahsNotifier, List<int>>(
      FavoriteSurahsNotifier.new,
    );

class FavoriteSurahsNotifier extends Notifier<List<int>> {
  static const _key = 'favorite_surahs';

  @override
  List<int> build() {
    final raw =
        ref.watch(sharedPreferencesProvider).getStringList(_key) ??
        const <String>[];
    return raw.map(int.tryParse).whereType<int>().toList()..sort();
  }

  Future<void> toggle(int surahNumber) async {
    final updated = List<int>.from(state);
    if (updated.contains(surahNumber)) {
      updated.remove(surahNumber);
    } else {
      updated.add(surahNumber);
    }
    updated.sort();
    state = updated;
    await ref
        .read(sharedPreferencesProvider)
        .setStringList(_key, updated.map((e) => e.toString()).toList());
  }

  bool isFavorite(int surahNumber) => state.contains(surahNumber);
}

final quranFontSizeProvider = NotifierProvider<QuranFontSizeNotifier, double>(
  QuranFontSizeNotifier.new,
);

class QuranFontSizeNotifier extends Notifier<double> {
  static const _key = 'quran_font_size';

  @override
  double build() {
    final val = ref.watch(sharedPreferencesProvider).getDouble(_key);
    if (val == null) return 24;
    return val.clamp(18, 40).toDouble();
  }

  Future<void> save(double size) async {
    final normalized = size.clamp(18, 40).toDouble();
    state = normalized;
    await ref.read(sharedPreferencesProvider).setDouble(_key, normalized);
  }
}

final hadithFontSizeProvider = NotifierProvider<HadithFontSizeNotifier, double>(
  HadithFontSizeNotifier.new,
);

class HadithFontSizeNotifier extends Notifier<double> {
  static const _key = 'hadith_font_size';

  @override
  double build() {
    final val = ref.watch(sharedPreferencesProvider).getDouble(_key);
    if (val == null) return 17;
    return val.clamp(14, 40).toDouble();
  }

  Future<void> save(double size) async {
    final normalized = size.clamp(14, 40).toDouble();
    state = normalized;
    await ref.read(sharedPreferencesProvider).setDouble(_key, normalized);
  }
}

final quranReaderControlsVisibleProvider =
    NotifierProvider<QuranReaderControlsVisibleNotifier, bool>(
      QuranReaderControlsVisibleNotifier.new,
    );

class QuranReaderControlsVisibleNotifier extends Notifier<bool> {
  static const _key = 'quran_reader_controls_visible';

  @override
  bool build() => ref.watch(sharedPreferencesProvider).getBool(_key) ?? true;

  Future<void> save(bool visible) async {
    state = visible;
    await ref.read(sharedPreferencesProvider).setBool(_key, visible);
  }
}

// ─── Prayer notification settings ────────────────────────────────────────

/// Holds per-prayer notification enabled flags and minute offsets.
class PrayerNotifSettings {
  final bool fajrEnabled;
  final bool dhuhrEnabled;
  final bool asrEnabled;
  final bool maghribEnabled;
  final bool ishaEnabled;

  final int fajrOffset;
  final int dhuhrOffset;
  final int asrOffset;
  final int maghribOffset;
  final int ishaOffset;

  const PrayerNotifSettings({
    required this.fajrEnabled,
    required this.dhuhrEnabled,
    required this.asrEnabled,
    required this.maghribEnabled,
    required this.ishaEnabled,
    required this.fajrOffset,
    required this.dhuhrOffset,
    required this.asrOffset,
    required this.maghribOffset,
    required this.ishaOffset,
  });

  bool isEnabled(Prayer p) => switch (p) {
    Prayer.fajr => fajrEnabled,
    Prayer.dhuhr => dhuhrEnabled,
    Prayer.asr => asrEnabled,
    Prayer.maghrib => maghribEnabled,
    Prayer.isha => ishaEnabled,
    _ => false,
  };

  int offsetFor(Prayer p) => switch (p) {
    Prayer.fajr => fajrOffset,
    Prayer.dhuhr => dhuhrOffset,
    Prayer.asr => asrOffset,
    Prayer.maghrib => maghribOffset,
    Prayer.isha => ishaOffset,
    _ => 0,
  };

  PrayerNotifSettings copyWith({
    bool? fajrEnabled,
    bool? dhuhrEnabled,
    bool? asrEnabled,
    bool? maghribEnabled,
    bool? ishaEnabled,
    int? fajrOffset,
    int? dhuhrOffset,
    int? asrOffset,
    int? maghribOffset,
    int? ishaOffset,
  }) => PrayerNotifSettings(
    fajrEnabled: fajrEnabled ?? this.fajrEnabled,
    dhuhrEnabled: dhuhrEnabled ?? this.dhuhrEnabled,
    asrEnabled: asrEnabled ?? this.asrEnabled,
    maghribEnabled: maghribEnabled ?? this.maghribEnabled,
    ishaEnabled: ishaEnabled ?? this.ishaEnabled,
    fajrOffset: fajrOffset ?? this.fajrOffset,
    dhuhrOffset: dhuhrOffset ?? this.dhuhrOffset,
    asrOffset: asrOffset ?? this.asrOffset,
    maghribOffset: maghribOffset ?? this.maghribOffset,
    ishaOffset: ishaOffset ?? this.ishaOffset,
  );

  Map<Prayer, bool> get enabledMap => {
    Prayer.fajr: fajrEnabled,
    Prayer.dhuhr: dhuhrEnabled,
    Prayer.asr: asrEnabled,
    Prayer.maghrib: maghribEnabled,
    Prayer.isha: ishaEnabled,
  };

  Map<Prayer, int> get offsetMap => {
    Prayer.fajr: fajrOffset,
    Prayer.dhuhr: dhuhrOffset,
    Prayer.asr: asrOffset,
    Prayer.maghrib: maghribOffset,
    Prayer.isha: ishaOffset,
  };
}

final prayerNotifSettingsProvider =
    NotifierProvider<PrayerNotifSettingsNotifier, PrayerNotifSettings>(
      PrayerNotifSettingsNotifier.new,
    );

class PrayerNotifSettingsNotifier extends Notifier<PrayerNotifSettings> {
  SharedPreferences get _p => ref.read(sharedPreferencesProvider);

  @override
  PrayerNotifSettings build() {
    final p = ref.watch(sharedPreferencesProvider);
    return PrayerNotifSettings(
      fajrEnabled: p.getBool('notif_fajr') ?? true,
      dhuhrEnabled: p.getBool('notif_dhuhr') ?? true,
      asrEnabled: p.getBool('notif_asr') ?? true,
      maghribEnabled: p.getBool('notif_maghrib') ?? true,
      ishaEnabled: p.getBool('notif_isha') ?? true,
      fajrOffset: p.getInt('notif_off_fajr') ?? 0,
      dhuhrOffset: p.getInt('notif_off_dhuhr') ?? 0,
      asrOffset: p.getInt('notif_off_asr') ?? 0,
      maghribOffset: p.getInt('notif_off_maghrib') ?? 0,
      ishaOffset: p.getInt('notif_off_isha') ?? 0,
    );
  }

  Future<void> setEnabled(Prayer p, bool val) async {
    final key = 'notif_${p.name}';
    await _p.setBool(key, val);
    state = switch (p) {
      Prayer.fajr => state.copyWith(fajrEnabled: val),
      Prayer.dhuhr => state.copyWith(dhuhrEnabled: val),
      Prayer.asr => state.copyWith(asrEnabled: val),
      Prayer.maghrib => state.copyWith(maghribEnabled: val),
      Prayer.isha => state.copyWith(ishaEnabled: val),
      _ => state,
    };
  }

  Future<void> setOffset(Prayer p, int val) async {
    final clamped = val.clamp(-30, 30);
    final key = 'notif_off_${p.name}';
    await _p.setInt(key, clamped);
    state = switch (p) {
      Prayer.fajr => state.copyWith(fajrOffset: clamped),
      Prayer.dhuhr => state.copyWith(dhuhrOffset: clamped),
      Prayer.asr => state.copyWith(asrOffset: clamped),
      Prayer.maghrib => state.copyWith(maghribOffset: clamped),
      Prayer.isha => state.copyWith(ishaOffset: clamped),
      _ => state,
    };
  }
}

// ─── Global adhan alert toggle ────────────────────────────────────────────

final adhanAlertsProvider = NotifierProvider<AdhanAlertsNotifier, bool>(
  AdhanAlertsNotifier.new,
);

class AdhanAlertsNotifier extends Notifier<bool> {
  @override
  bool build() =>
      ref.watch(sharedPreferencesProvider).getBool('adhan_alerts_enabled') ??
      true;

  Future<void> save(bool val) async {
    state = val;
    await ref
        .read(sharedPreferencesProvider)
        .setBool('adhan_alerts_enabled', val);
  }
}

// ─── Tafsir source ────────────────────────────────────────────────────────

final tafsirSourceProvider = NotifierProvider<TafsirSourceNotifier, String>(
  TafsirSourceNotifier.new,
);

class TafsirSourceNotifier extends Notifier<String> {
  static const _key = 'tafsir_source';

  @override
  String build() =>
      ref.watch(sharedPreferencesProvider).getString(_key) ?? 'saadi';

  Future<void> save(String val) async {
    state = val;
    await ref.read(sharedPreferencesProvider).setString(_key, val);
  }
}

// ─── Hijri offset ─────────────────────────────────────────────────────────

final hijriOffsetProvider = NotifierProvider<HijriOffsetNotifier, int>(
  HijriOffsetNotifier.new,
);

class HijriOffsetNotifier extends Notifier<int> {
  static const _key = 'hijri_offset_days';

  @override
  int build() => ref.watch(sharedPreferencesProvider).getInt(_key) ?? 0;

  Future<void> save(int val) async {
    final clamped = val.clamp(-3, 3);
    state = clamped;
    await ref.read(sharedPreferencesProvider).setInt(_key, clamped);
  }
}

// ─── App settings ─────────────────────────────────────────────────────────

final calculationMethodProvider =
    NotifierProvider<CalculationMethodNotifier, String>(
      CalculationMethodNotifier.new,
    );

class CalculationMethodNotifier extends Notifier<String> {
  @override
  String build() =>
      ref.watch(sharedPreferencesProvider).getString('calculation_method') ??
      'أم القرى';

  Future<void> save(String val) async {
    state = val;
    await ref
        .read(sharedPreferencesProvider)
        .setString('calculation_method', val);
  }
}

final appThemeProvider = NotifierProvider<AppThemeNotifier, String>(
  AppThemeNotifier.new,
);

class AppThemeNotifier extends Notifier<String> {
  @override
  String build() =>
      ref.watch(sharedPreferencesProvider).getString('app_theme') ?? 'داكن';

  Future<void> save(String val) async {
    state = val;
    await ref.read(sharedPreferencesProvider).setString('app_theme', val);
  }
}

final appLanguageProvider = NotifierProvider<AppLanguageNotifier, String>(
  AppLanguageNotifier.new,
);

class AppLanguageNotifier extends Notifier<String> {
  @override
  String build() =>
      ref.watch(sharedPreferencesProvider).getString('app_language') ??
      'العربية';

  Future<void> save(String val) async {
    state = val;
    await ref.read(sharedPreferencesProvider).setString('app_language', val);
  }
}

final fontSizeProvider = NotifierProvider<FontSizeNotifier, String>(
  FontSizeNotifier.new,
);

class FontSizeNotifier extends Notifier<String> {
  @override
  String build() =>
      ref.watch(sharedPreferencesProvider).getString('font_size') ?? 'متوسط';

  Future<void> save(String val) async {
    state = val;
    await ref.read(sharedPreferencesProvider).setString('font_size', val);
  }
}

// ─── Onboarding ─────────────────────────────────────────────────────────────

final onboardingCompletedProvider =
    NotifierProvider<OnboardingCompletedNotifier, bool>(
      OnboardingCompletedNotifier.new,
    );

class OnboardingCompletedNotifier extends Notifier<bool> {
  static const _key = 'onboarding_completed';

  @override
  bool build() => ref.watch(sharedPreferencesProvider).getBool(_key) ?? false;

  Future<void> save(bool val) async {
    state = val;
    await ref.read(sharedPreferencesProvider).setBool(_key, val);
  }
}

// ─── Prayer manual exact times ──────────────────────────────────────────────

class PrayerExactTime {
  final int hour;
  final int minute;

  const PrayerExactTime({required this.hour, required this.minute});

  factory PrayerExactTime.normalized(int hour, int minute) {
    return PrayerExactTime(
      hour: hour.clamp(0, 23),
      minute: minute.clamp(0, 59),
    );
  }

  PrayerExactTime copyWith({int? hour, int? minute}) {
    return PrayerExactTime.normalized(hour ?? this.hour, minute ?? this.minute);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PrayerExactTime &&
        other.hour == hour &&
        other.minute == minute;
  }

  @override
  int get hashCode => Object.hash(hour, minute);
}

class PrayerManualExactSettings {
  final bool enabled;
  final PrayerExactTime fajr;
  final PrayerExactTime sunrise;
  final PrayerExactTime dhuhr;
  final PrayerExactTime asr;
  final PrayerExactTime maghrib;
  final PrayerExactTime isha;

  const PrayerManualExactSettings({
    required this.enabled,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  factory PrayerManualExactSettings.defaults({bool enabled = false}) {
    return PrayerManualExactSettings(
      enabled: enabled,
      fajr: const PrayerExactTime(hour: 5, minute: 0),
      sunrise: const PrayerExactTime(hour: 6, minute: 15),
      dhuhr: const PrayerExactTime(hour: 12, minute: 30),
      asr: const PrayerExactTime(hour: 15, minute: 45),
      maghrib: const PrayerExactTime(hour: 18, minute: 30),
      isha: const PrayerExactTime(hour: 20, minute: 0),
    );
  }

  PrayerExactTime timeFor(Prayer prayer) => switch (prayer) {
    Prayer.fajr => fajr,
    Prayer.sunrise => sunrise,
    Prayer.dhuhr => dhuhr,
    Prayer.asr => asr,
    Prayer.maghrib => maghrib,
    Prayer.isha => isha,
    _ => fajr,
  };

  DateTime dateTimeFor(Prayer prayer, DateTime day) {
    final value = timeFor(prayer);
    return DateTime(day.year, day.month, day.day, value.hour, value.minute);
  }

  bool get hasCustomTimes {
    final defaults = PrayerManualExactSettings.defaults(enabled: enabled);
    return fajr != defaults.fajr ||
        sunrise != defaults.sunrise ||
        dhuhr != defaults.dhuhr ||
        asr != defaults.asr ||
        maghrib != defaults.maghrib ||
        isha != defaults.isha;
  }

  PrayerManualExactSettings copyWith({
    bool? enabled,
    PrayerExactTime? fajr,
    PrayerExactTime? sunrise,
    PrayerExactTime? dhuhr,
    PrayerExactTime? asr,
    PrayerExactTime? maghrib,
    PrayerExactTime? isha,
  }) {
    return PrayerManualExactSettings(
      enabled: enabled ?? this.enabled,
      fajr: fajr ?? this.fajr,
      sunrise: sunrise ?? this.sunrise,
      dhuhr: dhuhr ?? this.dhuhr,
      asr: asr ?? this.asr,
      maghrib: maghrib ?? this.maghrib,
      isha: isha ?? this.isha,
    );
  }

  PrayerManualExactSettings copyWithPrayer(
    Prayer prayer,
    PrayerExactTime value,
  ) {
    return switch (prayer) {
      Prayer.fajr => copyWith(fajr: value),
      Prayer.sunrise => copyWith(sunrise: value),
      Prayer.dhuhr => copyWith(dhuhr: value),
      Prayer.asr => copyWith(asr: value),
      Prayer.maghrib => copyWith(maghrib: value),
      Prayer.isha => copyWith(isha: value),
      _ => this,
    };
  }
}

final prayerManualExactSettingsProvider =
    NotifierProvider<
      PrayerManualExactSettingsNotifier,
      PrayerManualExactSettings
    >(PrayerManualExactSettingsNotifier.new);

class PrayerManualExactSettingsNotifier
    extends Notifier<PrayerManualExactSettings> {
  static const _enabledKey = 'prayer_manual_exact_enabled';

  static const _trackedPrayers = <Prayer>[
    Prayer.fajr,
    Prayer.sunrise,
    Prayer.dhuhr,
    Prayer.asr,
    Prayer.maghrib,
    Prayer.isha,
  ];

  SharedPreferences get _p => ref.read(sharedPreferencesProvider);

  @override
  PrayerManualExactSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final enabled = prefs.getBool(_enabledKey) ?? false;
    final defaults = PrayerManualExactSettings.defaults(enabled: enabled);

    PrayerExactTime readPrayerTime(Prayer prayer, PrayerExactTime fallback) {
      final h = prefs.getInt('prayer_manual_exact_${prayer.name}_hour');
      final m = prefs.getInt('prayer_manual_exact_${prayer.name}_minute');
      return PrayerExactTime.normalized(
        h ?? fallback.hour,
        m ?? fallback.minute,
      );
    }

    return defaults.copyWith(
      fajr: readPrayerTime(Prayer.fajr, defaults.fajr),
      sunrise: readPrayerTime(Prayer.sunrise, defaults.sunrise),
      dhuhr: readPrayerTime(Prayer.dhuhr, defaults.dhuhr),
      asr: readPrayerTime(Prayer.asr, defaults.asr),
      maghrib: readPrayerTime(Prayer.maghrib, defaults.maghrib),
      isha: readPrayerTime(Prayer.isha, defaults.isha),
    );
  }

  Future<void> setEnabled(bool enabled) async {
    await _p.setBool(_enabledKey, enabled);
    state = state.copyWith(enabled: enabled);
  }

  Future<void> setPrayerTime(
    Prayer prayer, {
    required int hour,
    required int minute,
  }) async {
    final normalized = PrayerExactTime.normalized(hour, minute);
    await _p.setInt('prayer_manual_exact_${prayer.name}_hour', normalized.hour);
    await _p.setInt(
      'prayer_manual_exact_${prayer.name}_minute',
      normalized.minute,
    );
    state = state.copyWithPrayer(prayer, normalized);
  }

  Future<void> resetTimes() async {
    for (final prayer in _trackedPrayers) {
      await _p.remove('prayer_manual_exact_${prayer.name}_hour');
      await _p.remove('prayer_manual_exact_${prayer.name}_minute');
    }
    state = PrayerManualExactSettings.defaults(enabled: state.enabled);
  }
}

// ─── Prayer manual time offsets ───────────────────────────────────────────

class PrayerManualOffsets {
  final int fajr, sunrise, dhuhr, asr, maghrib, isha; // minutes

  const PrayerManualOffsets({
    this.fajr = 0,
    this.sunrise = 0,
    this.dhuhr = 0,
    this.asr = 0,
    this.maghrib = 0,
    this.isha = 0,
  });

  int offsetFor(Prayer p) => switch (p) {
    Prayer.fajr => fajr,
    Prayer.sunrise => sunrise,
    Prayer.dhuhr => dhuhr,
    Prayer.asr => asr,
    Prayer.maghrib => maghrib,
    Prayer.isha => isha,
    _ => 0,
  };

  bool get hasAnyOffset =>
      fajr != 0 ||
      sunrise != 0 ||
      dhuhr != 0 ||
      asr != 0 ||
      maghrib != 0 ||
      isha != 0;

  PrayerManualOffsets copyWithPrayer(Prayer p, int val) => switch (p) {
    Prayer.fajr => PrayerManualOffsets(
      fajr: val,
      sunrise: sunrise,
      dhuhr: dhuhr,
      asr: asr,
      maghrib: maghrib,
      isha: isha,
    ),
    Prayer.sunrise => PrayerManualOffsets(
      fajr: fajr,
      sunrise: val,
      dhuhr: dhuhr,
      asr: asr,
      maghrib: maghrib,
      isha: isha,
    ),
    Prayer.dhuhr => PrayerManualOffsets(
      fajr: fajr,
      sunrise: sunrise,
      dhuhr: val,
      asr: asr,
      maghrib: maghrib,
      isha: isha,
    ),
    Prayer.asr => PrayerManualOffsets(
      fajr: fajr,
      sunrise: sunrise,
      dhuhr: dhuhr,
      asr: val,
      maghrib: maghrib,
      isha: isha,
    ),
    Prayer.maghrib => PrayerManualOffsets(
      fajr: fajr,
      sunrise: sunrise,
      dhuhr: dhuhr,
      asr: asr,
      maghrib: val,
      isha: isha,
    ),
    Prayer.isha => PrayerManualOffsets(
      fajr: fajr,
      sunrise: sunrise,
      dhuhr: dhuhr,
      asr: asr,
      maghrib: maghrib,
      isha: val,
    ),
    _ => this,
  };
}

final prayerManualOffsetsProvider =
    NotifierProvider<PrayerManualOffsetsNotifier, PrayerManualOffsets>(
      PrayerManualOffsetsNotifier.new,
    );

class PrayerManualOffsetsNotifier extends Notifier<PrayerManualOffsets> {
  SharedPreferences get _p => ref.read(sharedPreferencesProvider);

  @override
  PrayerManualOffsets build() {
    final p = ref.watch(sharedPreferencesProvider);
    return PrayerManualOffsets(
      fajr: p.getInt('prayer_off_fajr') ?? 0,
      sunrise: p.getInt('prayer_off_sunrise') ?? 0,
      dhuhr: p.getInt('prayer_off_dhuhr') ?? 0,
      asr: p.getInt('prayer_off_asr') ?? 0,
      maghrib: p.getInt('prayer_off_maghrib') ?? 0,
      isha: p.getInt('prayer_off_isha') ?? 0,
    );
  }

  Future<void> setOffset(Prayer prayer, int minutes) async {
    final clamped = minutes.clamp(-60, 60);
    final key = 'prayer_off_${prayer.name}';
    await _p.setInt(key, clamped);
    state = state.copyWithPrayer(prayer, clamped);
  }

  Future<void> resetAll() async {
    for (final p in [
      Prayer.fajr,
      Prayer.sunrise,
      Prayer.dhuhr,
      Prayer.asr,
      Prayer.maghrib,
      Prayer.isha,
    ]) {
      await _p.remove('prayer_off_${p.name}');
    }
    state = const PrayerManualOffsets();
  }
}

// ─── Prayer daily progress tracking ────────────────────────────────────────

class PrayerDailyProgress {
  const PrayerDailyProgress({
    required this.dayKey,
    required this.completedPrayerKeys,
    required this.history,
  });

  final String dayKey;
  final Set<String> completedPrayerKeys;
  final Map<String, int> history; // dayKey -> completed prayers count

  static const trackedPrayers = <Prayer>[
    Prayer.fajr,
    Prayer.dhuhr,
    Prayer.asr,
    Prayer.maghrib,
    Prayer.isha,
  ];

  int get completedCount => completedPrayerKeys.length.clamp(0, 5);
  double get completionRatio => completedCount / trackedPrayers.length;

  bool isCompleted(Prayer prayer) => completedPrayerKeys.contains(prayer.name);

  PrayerDailyProgress copyWith({
    String? dayKey,
    Set<String>? completedPrayerKeys,
    Map<String, int>? history,
  }) {
    return PrayerDailyProgress(
      dayKey: dayKey ?? this.dayKey,
      completedPrayerKeys: completedPrayerKeys ?? this.completedPrayerKeys,
      history: history ?? this.history,
    );
  }

  Map<String, dynamic> toJson() => {
    'dayKey': dayKey,
    'completedPrayerKeys': completedPrayerKeys.toList(),
    'history': history,
  };

  factory PrayerDailyProgress.fromJson(Map<String, dynamic> json) {
    final keys = <String>{};
    final rawKeys = json['completedPrayerKeys'];
    if (rawKeys is List) {
      for (final key in rawKeys) {
        final value = key.toString();
        if (trackedPrayers.any((p) => p.name == value)) {
          keys.add(value);
        }
      }
    }

    final parsedHistory = <String, int>{};
    final rawHistory = json['history'];
    if (rawHistory is Map) {
      for (final entry in rawHistory.entries) {
        final day = entry.key.toString();
        final parsedValue = entry.value is int
            ? entry.value as int
            : int.tryParse(entry.value.toString());
        if (parsedValue != null) {
          parsedHistory[day] = parsedValue.clamp(0, 5);
        }
      }
    }

    return PrayerDailyProgress(
      dayKey: json['dayKey']?.toString() ?? '',
      completedPrayerKeys: keys,
      history: parsedHistory,
    );
  }
}

final prayerDailyProgressProvider =
    NotifierProvider<PrayerDailyProgressNotifier, PrayerDailyProgress>(
      PrayerDailyProgressNotifier.new,
    );

class PrayerDailyProgressNotifier extends Notifier<PrayerDailyProgress> {
  static const _key = 'prayer_daily_progress_v1';

  @override
  PrayerDailyProgress build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final today = _todayKey();
    final raw = prefs.getString(_key);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          final parsed = PrayerDailyProgress.fromJson(
            decoded.map((k, v) => MapEntry('$k', v)),
          );
          return _normalizeDay(parsed, today);
        }
      } catch (_) {}
    }
    return PrayerDailyProgress(
      dayKey: today,
      completedPrayerKeys: const <String>{},
      history: const <String, int>{},
    );
  }

  Future<void> ensureToday() async {
    final normalized = _normalizeDay(state, _todayKey());
    if (normalized.dayKey != state.dayKey) {
      state = normalized;
      await _persist();
    }
  }

  Future<void> togglePrayer(Prayer prayer) async {
    if (!_isTrackable(prayer)) return;
    final current = _normalizeDay(state, _todayKey());
    final key = prayer.name;
    final updated = Set<String>.from(current.completedPrayerKeys);
    if (updated.contains(key)) {
      updated.remove(key);
    } else {
      updated.add(key);
    }
    state = current.copyWith(completedPrayerKeys: updated);
    await _persist();
  }

  Future<void> setPrayerCompleted(Prayer prayer, bool completed) async {
    if (!_isTrackable(prayer)) return;
    final current = _normalizeDay(state, _todayKey());
    final key = prayer.name;
    final updated = Set<String>.from(current.completedPrayerKeys);
    if (completed) {
      updated.add(key);
    } else {
      updated.remove(key);
    }
    state = current.copyWith(completedPrayerKeys: updated);
    await _persist();
  }

  int historyCountForDay(String dayKey) => state.history[dayKey] ?? 0;

  PrayerDailyProgress _normalizeDay(PrayerDailyProgress source, String today) {
    if (source.dayKey == today) return source;

    final updatedHistory = Map<String, int>.from(source.history)
      ..[source.dayKey] = source.completedCount;

    // Keep only last 14 days of history.
    final sortedDays = updatedHistory.keys.toList()..sort();
    if (sortedDays.length > 14) {
      final toRemove = sortedDays.length - 14;
      for (int i = 0; i < toRemove; i++) {
        updatedHistory.remove(sortedDays[i]);
      }
    }

    return PrayerDailyProgress(
      dayKey: today,
      completedPrayerKeys: const <String>{},
      history: updatedHistory,
    );
  }

  bool _isTrackable(Prayer prayer) =>
      PrayerDailyProgress.trackedPrayers.contains(prayer);

  String _todayKey() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }

  Future<void> _persist() async {
    final encoded = jsonEncode(state.toJson());
    await ref.read(sharedPreferencesProvider).setString(_key, encoded);
  }
}

// ─── Daily reminders (Sala on Prophet + Wird) ─────────────────────────────

class DailyReminderSettings {
  final bool enabled;
  final int hour;
  final int minute;

  const DailyReminderSettings({
    this.enabled = false,
    this.hour = 8,
    this.minute = 0,
  });

  DailyReminderSettings copyWith({bool? enabled, int? hour, int? minute}) =>
      DailyReminderSettings(
        enabled: enabled ?? this.enabled,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
      );
}

final salaOnProphetReminderProvider =
    NotifierProvider<SalaOnProphetReminderNotifier, DailyReminderSettings>(
      SalaOnProphetReminderNotifier.new,
    );

class SalaOnProphetReminderNotifier extends Notifier<DailyReminderSettings> {
  static const _keyEnabled = 'sala_prophet_enabled';
  static const _keyHour = 'sala_prophet_hour';
  static const _keyMinute = 'sala_prophet_minute';

  SharedPreferences get _p => ref.read(sharedPreferencesProvider);

  @override
  DailyReminderSettings build() {
    final p = ref.watch(sharedPreferencesProvider);
    return DailyReminderSettings(
      enabled: p.getBool(_keyEnabled) ?? false,
      hour: p.getInt(_keyHour) ?? 8,
      minute: p.getInt(_keyMinute) ?? 0,
    );
  }

  Future<void> save(DailyReminderSettings v) async {
    state = v;
    await _p.setBool(_keyEnabled, v.enabled);
    await _p.setInt(_keyHour, v.hour);
    await _p.setInt(_keyMinute, v.minute);
  }
}

final dailyWirdReminderProvider =
    NotifierProvider<DailyWirdReminderNotifier, DailyReminderSettings>(
      DailyWirdReminderNotifier.new,
    );

class DailyWirdReminderNotifier extends Notifier<DailyReminderSettings> {
  static const _keyEnabled = 'wird_reminder_enabled';
  static const _keyHour = 'wird_reminder_hour';
  static const _keyMinute = 'wird_reminder_minute';

  SharedPreferences get _p => ref.read(sharedPreferencesProvider);

  @override
  DailyReminderSettings build() {
    final p = ref.watch(sharedPreferencesProvider);
    return DailyReminderSettings(
      enabled: p.getBool(_keyEnabled) ?? false,
      hour: p.getInt(_keyHour) ?? 9,
      minute: p.getInt(_keyMinute) ?? 0,
    );
  }

  Future<void> save(DailyReminderSettings v) async {
    state = v;
    await _p.setBool(_keyEnabled, v.enabled);
    await _p.setInt(_keyHour, v.hour);
    await _p.setInt(_keyMinute, v.minute);
  }
}

/// Android-only: during wake events (unlock/screen-on), show Sala reminder
/// with an internal 15-minute cooldown in native receiver.
final salaOnProphetAwakeReminderProvider =
    NotifierProvider<SalaOnProphetAwakeReminderNotifier, bool>(
      SalaOnProphetAwakeReminderNotifier.new,
    );

class SalaOnProphetAwakeReminderNotifier extends Notifier<bool> {
  static const _key = 'sala_prophet_awake_enabled';

  @override
  bool build() => ref.watch(sharedPreferencesProvider).getBool(_key) ?? false;

  Future<void> save(bool val) async {
    state = val;
    await ref.read(sharedPreferencesProvider).setBool(_key, val);
  }
}

class MotivationReminderSettings {
  const MotivationReminderSettings({
    this.enabled = false,
    this.startHour = 9,
    this.endHour = 22,
    this.remindersPerDay = 3,
  });

  final bool enabled;
  final int startHour;
  final int endHour;
  final int remindersPerDay;

  MotivationReminderSettings copyWith({
    bool? enabled,
    int? startHour,
    int? endHour,
    int? remindersPerDay,
  }) {
    return MotivationReminderSettings(
      enabled: enabled ?? this.enabled,
      startHour: startHour ?? this.startHour,
      endHour: endHour ?? this.endHour,
      remindersPerDay: remindersPerDay ?? this.remindersPerDay,
    );
  }
}

final motivationReminderProvider =
    NotifierProvider<MotivationReminderNotifier, MotivationReminderSettings>(
      MotivationReminderNotifier.new,
    );

class MotivationReminderNotifier extends Notifier<MotivationReminderSettings> {
  static const _keyEnabled = 'motivation_reminder_enabled';
  static const _keyStartHour = 'motivation_reminder_start_hour';
  static const _keyEndHour = 'motivation_reminder_end_hour';
  static const _keyPerDay = 'motivation_reminder_per_day';

  SharedPreferences get _p => ref.read(sharedPreferencesProvider);

  @override
  MotivationReminderSettings build() {
    final p = ref.watch(sharedPreferencesProvider);
    final startHour = (p.getInt(_keyStartHour) ?? 9).clamp(0, 23);
    final endHour = (p.getInt(_keyEndHour) ?? 22).clamp(1, 23);
    final safeEnd = endHour <= startHour
        ? (startHour + 1).clamp(1, 23)
        : endHour;
    return MotivationReminderSettings(
      enabled: p.getBool(_keyEnabled) ?? false,
      startHour: startHour,
      endHour: safeEnd,
      remindersPerDay: (p.getInt(_keyPerDay) ?? 3).clamp(0, 60),
    );
  }

  Future<void> save(MotivationReminderSettings settings) async {
    final start = settings.startHour.clamp(0, 23);
    final endRaw = settings.endHour.clamp(1, 23);
    final end = endRaw <= start ? (start + 1).clamp(1, 23) : endRaw;
    final normalized = settings.copyWith(
      startHour: start,
      endHour: end,
      remindersPerDay: settings.remindersPerDay.clamp(0, 60),
    );

    state = normalized;
    await _p.setBool(_keyEnabled, normalized.enabled);
    await _p.setInt(_keyStartHour, normalized.startHour);
    await _p.setInt(_keyEndHour, normalized.endHour);
    await _p.setInt(_keyPerDay, normalized.remindersPerDay);
  }
}

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

// ─── Manual location ───────────────────────────────────────────────────────

class ManualLocation {
  final double lat;
  final double lng;
  final String name;

  const ManualLocation({
    required this.lat,
    required this.lng,
    required this.name,
  });
}

final manualLocationProvider =
    NotifierProvider<ManualLocationNotifier, ManualLocation?>(
      ManualLocationNotifier.new,
    );

class ManualLocationNotifier extends Notifier<ManualLocation?> {
  SharedPreferences get _p => ref.read(sharedPreferencesProvider);

  @override
  ManualLocation? build() {
    final p = ref.watch(sharedPreferencesProvider);
    final lat = p.getDouble('manual_lat');
    final lng = p.getDouble('manual_lng');
    if (lat == null || lng == null) return null;
    return ManualLocation(
      lat: lat,
      lng: lng,
      name: p.getString('manual_loc_name') ?? '',
    );
  }

  Future<void> save(double lat, double lng, String name) async {
    state = ManualLocation(lat: lat, lng: lng, name: name);
    await _p.setDouble('manual_lat', lat);
    await _p.setDouble('manual_lng', lng);
    await _p.setString('manual_loc_name', name);
  }

  Future<void> clear() async {
    state = null;
    await _p.remove('manual_lat');
    await _p.remove('manual_lng');
    await _p.remove('manual_loc_name');
  }
}

// ─── Qibla feedback settings ───────────────────────────────────────────────

final qiblaSuccessToneProvider =
    NotifierProvider<QiblaSuccessToneNotifier, bool>(
      QiblaSuccessToneNotifier.new,
    );

class QiblaSuccessToneNotifier extends Notifier<bool> {
  static const _key = 'qibla_success_tone_enabled';

  @override
  bool build() => ref.watch(sharedPreferencesProvider).getBool(_key) ?? false;

  Future<void> save(bool enabled) async {
    state = enabled;
    await ref.read(sharedPreferencesProvider).setBool(_key, enabled);
  }
}

enum QiblaSuccessToneOption { soft, bell }

extension QiblaSuccessToneOptionX on QiblaSuccessToneOption {
  String get key => switch (this) {
    QiblaSuccessToneOption.soft => 'soft',
    QiblaSuccessToneOption.bell => 'bell',
  };

  String get label => switch (this) {
    QiblaSuccessToneOption.soft => 'نغمة هادئة',
    QiblaSuccessToneOption.bell => 'نغمة جرس',
  };

  String get assetPath => switch (this) {
    QiblaSuccessToneOption.soft => 'assets/sounds/qibla_success_soft.mp3',
    QiblaSuccessToneOption.bell => 'assets/sounds/qibla_success_bell.mp3',
  };

  static QiblaSuccessToneOption fromKey(String? raw) {
    return switch (raw) {
      'bell' => QiblaSuccessToneOption.bell,
      _ => QiblaSuccessToneOption.soft,
    };
  }
}

final qiblaSuccessToneOptionProvider =
    NotifierProvider<QiblaSuccessToneOptionNotifier, QiblaSuccessToneOption>(
      QiblaSuccessToneOptionNotifier.new,
    );

class QiblaSuccessToneOptionNotifier extends Notifier<QiblaSuccessToneOption> {
  static const _key = 'qibla_success_tone_option';

  @override
  QiblaSuccessToneOption build() {
    final raw = ref.watch(sharedPreferencesProvider).getString(_key);
    return QiblaSuccessToneOptionX.fromKey(raw);
  }

  Future<void> save(QiblaSuccessToneOption option) async {
    state = option;
    await ref.read(sharedPreferencesProvider).setString(_key, option.key);
  }
}
