import 'package:adhan/adhan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shared_preferences_base.dart';

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
