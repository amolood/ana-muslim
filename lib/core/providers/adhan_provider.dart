import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shared_preferences_base.dart';

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

// ─── Adhan Sound Option ───────────────────────────────────────────────────

enum AdhanSoundOption {
  makkah,
  makkahFajr,
  madina,
  madinaFajr,
  madinaShort,
  classic,
  bismillah1,
  bismillah2,
  bismillahilladhi,
  high,
  highLong,
  iqama,
  iqama2,
  iqama3,
  custom,
}

extension AdhanSoundOptionX on AdhanSoundOption {
  String get key => switch (this) {
    AdhanSoundOption.makkah => 'makkah',
    AdhanSoundOption.makkahFajr => 'makkah_fajr',
    AdhanSoundOption.madina => 'madina',
    AdhanSoundOption.madinaFajr => 'madina_fajr',
    AdhanSoundOption.madinaShort => 'madina_short',
    AdhanSoundOption.classic => 'classic',
    AdhanSoundOption.bismillah1 => 'bismillah1',
    AdhanSoundOption.bismillah2 => 'bismillah2',
    AdhanSoundOption.bismillahilladhi => 'bismillahilladhi',
    AdhanSoundOption.high => 'high',
    AdhanSoundOption.highLong => 'high_long',
    AdhanSoundOption.iqama => 'iqama',
    AdhanSoundOption.iqama2 => 'iqama2',
    AdhanSoundOption.iqama3 => 'iqama3',
    AdhanSoundOption.custom => 'custom',
  };

  String get label => switch (this) {
    AdhanSoundOption.makkah => 'أذان مكة',
    AdhanSoundOption.makkahFajr => 'أذان مكة (الفجر)',
    AdhanSoundOption.madina => 'أذان المدينة',
    AdhanSoundOption.madinaFajr => 'أذان المدينة (الفجر)',
    AdhanSoundOption.madinaShort => 'أذان المدينة (قصير)',
    AdhanSoundOption.classic => 'أذان كلاسيكي',
    AdhanSoundOption.bismillah1 => 'بسم الله 1',
    AdhanSoundOption.bismillah2 => 'بسم الله 2',
    AdhanSoundOption.bismillahilladhi => 'بسم الله الذي',
    AdhanSoundOption.high => 'نغمة عالية',
    AdhanSoundOption.highLong => 'نغمة عالية (طويلة)',
    AdhanSoundOption.iqama => 'الإقامة 1',
    AdhanSoundOption.iqama2 => 'الإقامة 2',
    AdhanSoundOption.iqama3 => 'الإقامة 3',
    AdhanSoundOption.custom => 'ملف مخصص',
  };

  String get assetPath => switch (this) {
    AdhanSoundOption.makkah => 'assets/sounds/azan/adhan_makkah.mp3',
    AdhanSoundOption.makkahFajr => 'assets/sounds/azan/adhan_makkah_fajr.mp3',
    AdhanSoundOption.madina => 'assets/sounds/azan/adhan_madina.mp3',
    AdhanSoundOption.madinaFajr => 'assets/sounds/azan/adhan_madina_fajr.mp3',
    AdhanSoundOption.madinaShort => 'assets/sounds/azan/adhan_madina_short.m4a',
    AdhanSoundOption.classic => 'assets/sounds/azan/azan.mp3',
    AdhanSoundOption.bismillah1 => 'assets/sounds/azan/noti_bismillah1.m4a',
    AdhanSoundOption.bismillah2 => 'assets/sounds/azan/noti_bismillah2.m4a',
    AdhanSoundOption.bismillahilladhi => 'assets/sounds/azan/noti_bismillahilladhi.m4a',
    AdhanSoundOption.high => 'assets/sounds/azan/noti_high.m4a',
    AdhanSoundOption.highLong => 'assets/sounds/azan/noti_high_long.m4a',
    AdhanSoundOption.iqama => 'assets/sounds/azan/noti_iqama.m4a',
    AdhanSoundOption.iqama2 => 'assets/sounds/azan/noti_iqama2.m4a',
    AdhanSoundOption.iqama3 => 'assets/sounds/azan/noti_iqama3.m4a',
    AdhanSoundOption.custom => '', // Will be overridden by custom path
  };

  /// للاستخدام في Android native code (بدون assets/ وامتداد)
  String get androidResourceName => switch (this) {
    AdhanSoundOption.makkah => 'adhan_makkah',
    AdhanSoundOption.makkahFajr => 'adhan_makkah_fajr',
    AdhanSoundOption.madina => 'adhan_madina',
    AdhanSoundOption.madinaFajr => 'adhan_madina_fajr',
    AdhanSoundOption.madinaShort => 'adhan_madina_short',
    AdhanSoundOption.classic => 'azan',
    AdhanSoundOption.bismillah1 => 'noti_bismillah1',
    AdhanSoundOption.bismillah2 => 'noti_bismillah2',
    AdhanSoundOption.bismillahilladhi => 'noti_bismillahilladhi',
    AdhanSoundOption.high => 'noti_high',
    AdhanSoundOption.highLong => 'noti_high_long',
    AdhanSoundOption.iqama => 'noti_iqama',
    AdhanSoundOption.iqama2 => 'noti_iqama2',
    AdhanSoundOption.iqama3 => 'noti_iqama3',
    AdhanSoundOption.custom => 'custom_adhan', // Will be replaced with actual file
  };

  static AdhanSoundOption fromKey(String? raw) {
    return switch (raw) {
      'makkah' => AdhanSoundOption.makkah,
      'makkah_fajr' => AdhanSoundOption.makkahFajr,
      'makkah_short' => AdhanSoundOption.classic, // إعادة توجيه للافتراضي
      'madina' => AdhanSoundOption.madina,
      'madina_fajr' => AdhanSoundOption.madinaFajr,
      'madina_short' => AdhanSoundOption.madinaShort,
      'classic' => AdhanSoundOption.classic,
      'bismillah1' => AdhanSoundOption.bismillah1,
      'bismillah2' => AdhanSoundOption.bismillah2,
      'bismillahilladhi' => AdhanSoundOption.bismillahilladhi,
      'high' => AdhanSoundOption.high,
      'high_long' => AdhanSoundOption.highLong,
      'iqama' => AdhanSoundOption.iqama,
      'iqama2' => AdhanSoundOption.iqama2,
      'iqama3' => AdhanSoundOption.iqama3,
      'custom' => AdhanSoundOption.custom,
      _ => AdhanSoundOption.classic, // ✅ الافتراضي: أذان كلاسيكي
    };
  }
}

final adhanSoundOptionProvider =
    NotifierProvider<AdhanSoundOptionNotifier, AdhanSoundOption>(
      AdhanSoundOptionNotifier.new,
    );

class AdhanSoundOptionNotifier extends Notifier<AdhanSoundOption> {
  static const _key = 'adhan_sound_option';

  @override
  AdhanSoundOption build() {
    final raw = ref.watch(sharedPreferencesProvider).getString(_key);
    return AdhanSoundOptionX.fromKey(raw);
  }

  Future<void> save(AdhanSoundOption option) async {
    state = option;
    await ref.read(sharedPreferencesProvider).setString(_key, option.key);
  }
}

// ─── Custom Adhan File Path ───────────────────────────────────────────────

final customAdhanFilePathProvider =
    NotifierProvider<CustomAdhanFilePathNotifier, String?>(
      CustomAdhanFilePathNotifier.new,
    );

class CustomAdhanFilePathNotifier extends Notifier<String?> {
  static const _key = 'custom_adhan_file_path';

  @override
  String? build() {
    return ref.watch(sharedPreferencesProvider).getString(_key);
  }

  Future<void> save(String? path) async {
    state = path;
    if (path == null) {
      await ref.read(sharedPreferencesProvider).remove(_key);
    } else {
      await ref.read(sharedPreferencesProvider).setString(_key, path);
    }
  }
}

// ─── Qibla Success Tone ───────────────────────────────────────────────────

enum QiblaSuccessToneOption { high, bell, labbaik }

extension QiblaSuccessToneOptionX on QiblaSuccessToneOption {
  String get key => switch (this) {
    QiblaSuccessToneOption.high => 'high',
    QiblaSuccessToneOption.bell => 'bell',
    QiblaSuccessToneOption.labbaik => 'labbaik',
  };

  String get label => switch (this) {
    QiblaSuccessToneOption.high => 'نغمة عالية',
    QiblaSuccessToneOption.bell => 'نغمة جرس',
    QiblaSuccessToneOption.labbaik => 'لبيك اللهم',
  };

  String get assetPath => switch (this) {
    QiblaSuccessToneOption.high => 'assets/sounds/azan/noti_high.m4a',
    QiblaSuccessToneOption.bell => 'assets/sounds/qibla_success_bell.mp3',
    QiblaSuccessToneOption.labbaik => 'assets/sounds/azan/noti_labbaik_allahuma.m4a',
  };

  static QiblaSuccessToneOption fromKey(String? raw) {
    return switch (raw) {
      'bell' => QiblaSuccessToneOption.bell,
      'labbaik' => QiblaSuccessToneOption.labbaik,
      _ => QiblaSuccessToneOption.high,
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

// ─── Qibla Success Sound Mute ─────────────────────────────────────────────

final qiblaSuccessSoundMutedProvider =
    NotifierProvider<QiblaSuccessSoundMutedNotifier, bool>(
      QiblaSuccessSoundMutedNotifier.new,
    );

class QiblaSuccessSoundMutedNotifier extends Notifier<bool> {
  static const _key = 'qibla_success_sound_muted';

  @override
  bool build() {
    return ref.watch(sharedPreferencesProvider).getBool(_key) ?? false;
  }

  Future<void> save(bool isMuted) async {
    state = isMuted;
    await ref.read(sharedPreferencesProvider).setBool(_key, isMuted);
  }
}
