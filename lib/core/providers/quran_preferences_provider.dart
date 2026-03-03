import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'shared_preferences_base.dart';

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

// Quran Font Family Provider
final quranFontFamilyProvider = NotifierProvider<QuranFontFamilyNotifier, String>(
  QuranFontFamilyNotifier.new,
);

class QuranFontFamilyNotifier extends Notifier<String> {
  static const _key = 'quran_font_family';

  // Available Quran fonts
  static const String kfgqpcUthmanic = 'KFGQPC Uthmanic Script';
  static const String amiri = 'Amiri';
  static const String naskh = 'naskh';

  static const List<String> availableFonts = [
    kfgqpcUthmanic,
    amiri,
    naskh,
  ];

  static const Map<String, String> fontDisplayNames = {
    kfgqpcUthmanic: 'خط عثماني (KFGQPC)',
    amiri: 'خط أميري',
    naskh: 'خط نسخ',
  };

  @override
  String build() {
    final val = ref.watch(sharedPreferencesProvider).getString(_key);
    if (val == null || !availableFonts.contains(val)) {
      return kfgqpcUthmanic; // Default font
    }
    return val;
  }

  Future<void> save(String fontFamily) async {
    if (!availableFonts.contains(fontFamily)) return;
    state = fontFamily;
    await ref.read(sharedPreferencesProvider).setString(_key, fontFamily);
  }

  String get displayName => fontDisplayNames[state] ?? state;
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
