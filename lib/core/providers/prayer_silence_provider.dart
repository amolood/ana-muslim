import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'shared_preferences_base.dart';

// ── Silence mode ──────────────────────────────────────────────────────────────

enum PrayerSilenceMode { dnd, silent, vibrate }

// ── Settings model ────────────────────────────────────────────────────────────

@immutable
class PrayerSilenceSettings {
  const PrayerSilenceSettings({
    this.enabled = false,
    this.includeFajr = true,
    this.includeDhuhr = true,
    this.includeAsr = true,
    this.includeMaghrib = true,
    this.includeIsha = true,
    this.minutesBefore = 0,
    this.minutesAfter = 30,
    this.mode = PrayerSilenceMode.silent,
    this.autoRestore = true,
  });

  final bool enabled;
  final bool includeFajr;
  final bool includeDhuhr;
  final bool includeAsr;
  final bool includeMaghrib;
  final bool includeIsha;
  final int minutesBefore;
  final int minutesAfter;
  final PrayerSilenceMode mode;
  final bool autoRestore;

  bool isIncluded(Prayer prayer) => switch (prayer) {
    Prayer.fajr    => includeFajr,
    Prayer.dhuhr   => includeDhuhr,
    Prayer.asr     => includeAsr,
    Prayer.maghrib => includeMaghrib,
    Prayer.isha    => includeIsha,
    _              => false,
  };

  PrayerSilenceSettings copyWith({
    bool? enabled,
    bool? includeFajr,
    bool? includeDhuhr,
    bool? includeAsr,
    bool? includeMaghrib,
    bool? includeIsha,
    int? minutesBefore,
    int? minutesAfter,
    PrayerSilenceMode? mode,
    bool? autoRestore,
  }) => PrayerSilenceSettings(
    enabled:        enabled        ?? this.enabled,
    includeFajr:    includeFajr    ?? this.includeFajr,
    includeDhuhr:   includeDhuhr   ?? this.includeDhuhr,
    includeAsr:     includeAsr     ?? this.includeAsr,
    includeMaghrib: includeMaghrib ?? this.includeMaghrib,
    includeIsha:    includeIsha    ?? this.includeIsha,
    minutesBefore:  minutesBefore  ?? this.minutesBefore,
    minutesAfter:   minutesAfter   ?? this.minutesAfter,
    mode:           mode           ?? this.mode,
    autoRestore:    autoRestore    ?? this.autoRestore,
  );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class PrayerSilenceNotifier extends Notifier<PrayerSilenceSettings> {
  static const _kEnabled     = 'ps_enabled';
  static const _kFajr        = 'ps_fajr';
  static const _kDhuhr       = 'ps_dhuhr';
  static const _kAsr         = 'ps_asr';
  static const _kMaghrib     = 'ps_maghrib';
  static const _kIsha        = 'ps_isha';
  static const _kBefore      = 'ps_before';
  static const _kAfter       = 'ps_after';
  static const _kMode        = 'ps_mode';
  static const _kAutoRestore = 'ps_auto_restore';

  @override
  PrayerSilenceSettings build() {
    final p = ref.watch(sharedPreferencesProvider);
    return PrayerSilenceSettings(
      enabled:        p.getBool(_kEnabled)     ?? false,
      includeFajr:    p.getBool(_kFajr)        ?? true,
      includeDhuhr:   p.getBool(_kDhuhr)       ?? true,
      includeAsr:     p.getBool(_kAsr)         ?? true,
      includeMaghrib: p.getBool(_kMaghrib)     ?? true,
      includeIsha:    p.getBool(_kIsha)        ?? true,
      minutesBefore:  p.getInt(_kBefore)       ?? 0,
      minutesAfter:   p.getInt(_kAfter)        ?? 30,
      mode: PrayerSilenceMode.values[
        (p.getInt(_kMode) ?? PrayerSilenceMode.silent.index)
            .clamp(0, PrayerSilenceMode.values.length - 1)
      ],
      autoRestore: p.getBool(_kAutoRestore) ?? true,
    );
  }

  Future<void> setEnabled(bool val) async {
    state = state.copyWith(enabled: val);
    await ref.read(sharedPreferencesProvider).setBool(_kEnabled, val);
  }

  Future<void> setIncluded(Prayer prayer, bool val) async {
    state = switch (prayer) {
      Prayer.fajr    => state.copyWith(includeFajr:    val),
      Prayer.dhuhr   => state.copyWith(includeDhuhr:   val),
      Prayer.asr     => state.copyWith(includeAsr:     val),
      Prayer.maghrib => state.copyWith(includeMaghrib: val),
      Prayer.isha    => state.copyWith(includeIsha:    val),
      _              => state,
    };
    final key = switch (prayer) {
      Prayer.fajr    => _kFajr,
      Prayer.dhuhr   => _kDhuhr,
      Prayer.asr     => _kAsr,
      Prayer.maghrib => _kMaghrib,
      Prayer.isha    => _kIsha,
      _              => null,
    };
    if (key != null) {
      await ref.read(sharedPreferencesProvider).setBool(key, val);
    }
  }

  Future<void> setMinutesBefore(int val) async {
    final clamped = val.clamp(0, 60);
    state = state.copyWith(minutesBefore: clamped);
    await ref.read(sharedPreferencesProvider).setInt(_kBefore, clamped);
  }

  Future<void> setMinutesAfter(int val) async {
    final clamped = val.clamp(5, 120);
    state = state.copyWith(minutesAfter: clamped);
    await ref.read(sharedPreferencesProvider).setInt(_kAfter, clamped);
  }

  Future<void> setMode(PrayerSilenceMode val) async {
    state = state.copyWith(mode: val);
    await ref.read(sharedPreferencesProvider).setInt(_kMode, val.index);
  }

  Future<void> setAutoRestore(bool val) async {
    state = state.copyWith(autoRestore: val);
    await ref.read(sharedPreferencesProvider).setBool(_kAutoRestore, val);
  }
}

final prayerSilenceProvider =
    NotifierProvider<PrayerSilenceNotifier, PrayerSilenceSettings>(
  PrayerSilenceNotifier.new,
);
