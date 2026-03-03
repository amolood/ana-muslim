import 'dart:convert';

import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'shared_preferences_base.dart';

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

  /// Two progress values are equal when today's completed prayers are the same.
  /// History changes (e.g. day rollover writing previous-day count) do not
  /// cause widget rebuilds, which is the correct behaviour.
  @override
  bool operator ==(Object other) =>
      other is PrayerDailyProgress &&
      other.dayKey == dayKey &&
      other.completedPrayerKeys.length == completedPrayerKeys.length &&
      completedPrayerKeys.every(other.completedPrayerKeys.contains);

  @override
  int get hashCode => Object.hash(dayKey, completedPrayerKeys.length);

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
      } catch (e) {
        if (kDebugMode) debugPrint('[PrayerDailyProgressNotifier] corrupt saved state, resetting: $e');
      }
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
