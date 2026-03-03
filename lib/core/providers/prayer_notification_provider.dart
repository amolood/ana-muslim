import 'package:adhan/adhan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shared_preferences_base.dart';

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
