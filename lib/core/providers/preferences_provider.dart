import 'package:adhan/adhan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider has not been initialized');
});

// ─── Sebha ────────────────────────────────────────────────────────────────

final sebhaCurrentCountProvider =
    NotifierProvider<SebhaCurrentCountNotifier, int>(
        SebhaCurrentCountNotifier.new);

class SebhaCurrentCountNotifier extends Notifier<int> {
  @override
  int build() =>
      ref.watch(sharedPreferencesProvider).getInt('sebha_current_count') ?? 0;
  Future<void> save(int val) async {
    state = val;
    await ref.read(sharedPreferencesProvider).setInt('sebha_current_count', val);
  }
}

final sebhaTotalCountProvider =
    NotifierProvider<SebhaTotalCountNotifier, int>(SebhaTotalCountNotifier.new);

class SebhaTotalCountNotifier extends Notifier<int> {
  @override
  int build() =>
      ref.watch(sharedPreferencesProvider).getInt('sebha_total_count') ?? 0;
  Future<void> save(int val) async {
    state = val;
    await ref.read(sharedPreferencesProvider).setInt('sebha_total_count', val);
  }
}

final sebhaDailyGoalProvider =
    NotifierProvider<SebhaDailyGoalNotifier, int>(SebhaDailyGoalNotifier.new);

class SebhaDailyGoalNotifier extends Notifier<int> {
  @override
  int build() {
    final val =
        ref.watch(sharedPreferencesProvider).getInt('sebha_daily_goal');
    return (val == null || val == 0) ? 100 : val;
  }

  Future<void> save(int val) async {
    state = val;
    await ref.read(sharedPreferencesProvider).setInt('sebha_daily_goal', val);
  }
}

// ─── Quran ────────────────────────────────────────────────────────────────

final lastReadSurahProvider =
    NotifierProvider<LastReadSurahNotifier, int>(LastReadSurahNotifier.new);

class LastReadSurahNotifier extends Notifier<int> {
  @override
  int build() =>
      ref.watch(sharedPreferencesProvider).getInt('last_read_surah') ?? 0;
  Future<void> save(int val) async {
    state = val;
    await ref.read(sharedPreferencesProvider).setInt('last_read_surah', val);
  }
}

final lastReadPageProvider =
    NotifierProvider<LastReadPageNotifier, int>(LastReadPageNotifier.new);

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
        FavoriteSurahsNotifier.new);

class FavoriteSurahsNotifier extends Notifier<List<int>> {
  static const _key = 'favorite_surahs';

  @override
  List<int> build() {
    final raw = ref.watch(sharedPreferencesProvider).getStringList(_key) ??
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
    await ref.read(sharedPreferencesProvider).setStringList(
      _key,
      updated.map((e) => e.toString()).toList(),
    );
  }

  bool isFavorite(int surahNumber) => state.contains(surahNumber);
}

final quranFontSizeProvider =
    NotifierProvider<QuranFontSizeNotifier, double>(
        QuranFontSizeNotifier.new);

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
        Prayer.fajr    => fajrEnabled,
        Prayer.dhuhr   => dhuhrEnabled,
        Prayer.asr     => asrEnabled,
        Prayer.maghrib => maghribEnabled,
        Prayer.isha    => ishaEnabled,
        _              => false,
      };

  int offsetFor(Prayer p) => switch (p) {
        Prayer.fajr    => fajrOffset,
        Prayer.dhuhr   => dhuhrOffset,
        Prayer.asr     => asrOffset,
        Prayer.maghrib => maghribOffset,
        Prayer.isha    => ishaOffset,
        _              => 0,
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
  }) =>
      PrayerNotifSettings(
        fajrEnabled:    fajrEnabled    ?? this.fajrEnabled,
        dhuhrEnabled:   dhuhrEnabled   ?? this.dhuhrEnabled,
        asrEnabled:     asrEnabled     ?? this.asrEnabled,
        maghribEnabled: maghribEnabled ?? this.maghribEnabled,
        ishaEnabled:    ishaEnabled    ?? this.ishaEnabled,
        fajrOffset:     fajrOffset     ?? this.fajrOffset,
        dhuhrOffset:    dhuhrOffset    ?? this.dhuhrOffset,
        asrOffset:      asrOffset      ?? this.asrOffset,
        maghribOffset:  maghribOffset  ?? this.maghribOffset,
        ishaOffset:     ishaOffset     ?? this.ishaOffset,
      );

  Map<Prayer, bool> get enabledMap => {
        Prayer.fajr:    fajrEnabled,
        Prayer.dhuhr:   dhuhrEnabled,
        Prayer.asr:     asrEnabled,
        Prayer.maghrib: maghribEnabled,
        Prayer.isha:    ishaEnabled,
      };

  Map<Prayer, int> get offsetMap => {
        Prayer.fajr:    fajrOffset,
        Prayer.dhuhr:   dhuhrOffset,
        Prayer.asr:     asrOffset,
        Prayer.maghrib: maghribOffset,
        Prayer.isha:    ishaOffset,
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
      fajrEnabled:    p.getBool('notif_fajr')    ?? true,
      dhuhrEnabled:   p.getBool('notif_dhuhr')   ?? true,
      asrEnabled:     p.getBool('notif_asr')     ?? true,
      maghribEnabled: p.getBool('notif_maghrib') ?? true,
      ishaEnabled:    p.getBool('notif_isha')    ?? true,
      fajrOffset:     p.getInt('notif_off_fajr')    ?? 0,
      dhuhrOffset:    p.getInt('notif_off_dhuhr')   ?? 0,
      asrOffset:      p.getInt('notif_off_asr')     ?? 0,
      maghribOffset:  p.getInt('notif_off_maghrib') ?? 0,
      ishaOffset:     p.getInt('notif_off_isha')    ?? 0,
    );
  }

  Future<void> setEnabled(Prayer p, bool val) async {
    final key = 'notif_${p.name}';
    await _p.setBool(key, val);
    state = switch (p) {
      Prayer.fajr    => state.copyWith(fajrEnabled: val),
      Prayer.dhuhr   => state.copyWith(dhuhrEnabled: val),
      Prayer.asr     => state.copyWith(asrEnabled: val),
      Prayer.maghrib => state.copyWith(maghribEnabled: val),
      Prayer.isha    => state.copyWith(ishaEnabled: val),
      _              => state,
    };
  }

  Future<void> setOffset(Prayer p, int val) async {
    final clamped = val.clamp(-30, 30);
    final key = 'notif_off_${p.name}';
    await _p.setInt(key, clamped);
    state = switch (p) {
      Prayer.fajr    => state.copyWith(fajrOffset: clamped),
      Prayer.dhuhr   => state.copyWith(dhuhrOffset: clamped),
      Prayer.asr     => state.copyWith(asrOffset: clamped),
      Prayer.maghrib => state.copyWith(maghribOffset: clamped),
      Prayer.isha    => state.copyWith(ishaOffset: clamped),
      _              => state,
    };
  }
}

// ─── Global adhan alert toggle ────────────────────────────────────────────

final adhanAlertsProvider =
    NotifierProvider<AdhanAlertsNotifier, bool>(AdhanAlertsNotifier.new);

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

final tafsirSourceProvider =
    NotifierProvider<TafsirSourceNotifier, String>(TafsirSourceNotifier.new);

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

final hijriOffsetProvider =
    NotifierProvider<HijriOffsetNotifier, int>(HijriOffsetNotifier.new);

class HijriOffsetNotifier extends Notifier<int> {
  static const _key = 'hijri_offset_days';

  @override
  int build() =>
      ref.watch(sharedPreferencesProvider).getInt(_key) ?? 0;

  Future<void> save(int val) async {
    final clamped = val.clamp(-3, 3);
    state = clamped;
    await ref.read(sharedPreferencesProvider).setInt(_key, clamped);
  }
}

// ─── App settings ─────────────────────────────────────────────────────────

final calculationMethodProvider =
    NotifierProvider<CalculationMethodNotifier, String>(
        CalculationMethodNotifier.new);

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

final appThemeProvider =
    NotifierProvider<AppThemeNotifier, String>(AppThemeNotifier.new);

class AppThemeNotifier extends Notifier<String> {
  @override
  String build() =>
      ref.watch(sharedPreferencesProvider).getString('app_theme') ?? 'داكن';

  Future<void> save(String val) async {
    state = val;
    await ref.read(sharedPreferencesProvider).setString('app_theme', val);
  }
}

final appLanguageProvider =
    NotifierProvider<AppLanguageNotifier, String>(AppLanguageNotifier.new);

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

final fontSizeProvider =
    NotifierProvider<FontSizeNotifier, String>(FontSizeNotifier.new);

class FontSizeNotifier extends Notifier<String> {
  @override
  String build() =>
      ref.watch(sharedPreferencesProvider).getString('font_size') ?? 'متوسط';

  Future<void> save(String val) async {
    state = val;
    await ref.read(sharedPreferencesProvider).setString('font_size', val);
  }
}
