import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shared_preferences_base.dart';

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
