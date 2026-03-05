import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/shared_preferences_base.dart';
import '../../data/models/quran_api_font.dart';
import '../../data/services/quran_font_service.dart';

// ── Font list (fetched + cached) ───────────────────────────────────────────

final quranApiFontsProvider = FutureProvider<List<QuranApiFont>>((ref) async {
  final prefs = ref.watch(sharedPreferencesProvider);
  return QuranFontService.fetchFontList(prefs);
});

// ── Downloaded font keys ───────────────────────────────────────────────────

class DownloadedQuranFontsNotifier extends Notifier<Set<String>> {
  static const _key = 'quran_api_downloaded';

  @override
  Set<String> build() {
    final list =
        ref.watch(sharedPreferencesProvider).getStringList(_key) ?? [];
    return list.toSet();
  }

  Future<void> markDownloaded(String key) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final next = Set<String>.from(state)..add(key);
    state = next;
    await prefs.setStringList(_key, next.toList());
  }

  Future<void> markDeleted(String key) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final next = Set<String>.from(state)..remove(key);
    state = next;
    await prefs.setStringList(_key, next.toList());
  }
}

final downloadedQuranFontsProvider =
    NotifierProvider<DownloadedQuranFontsNotifier, Set<String>>(
  DownloadedQuranFontsNotifier.new,
);

// ── Selected font key (null = built-in Hafs) ──────────────────────────────

class SelectedQuranFontNotifier extends Notifier<String?> {
  static const _key = 'quran_api_font_key';

  @override
  String? build() => ref.watch(sharedPreferencesProvider).getString(_key);

  Future<void> select(String? key) async {
    state = key;
    final prefs = ref.read(sharedPreferencesProvider);
    if (key == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, key);
    }
  }
}

final selectedQuranFontKeyProvider =
    NotifierProvider<SelectedQuranFontNotifier, String?>(
  SelectedQuranFontNotifier.new,
);

// ── Download progress map (key → 0.0–1.0) ─────────────────────────────────

class QuranFontDownloadProgressNotifier
    extends Notifier<Map<String, double>> {
  @override
  Map<String, double> build() => const {};

  void set(String key, double progress) {
    state = {...state, key: progress};
  }

  void remove(String key) {
    final next = Map<String, double>.from(state);
    next.remove(key);
    state = Map.unmodifiable(next);
  }
}

final quranFontDownloadProgressProvider = NotifierProvider<
    QuranFontDownloadProgressNotifier, Map<String, double>>(
  QuranFontDownloadProgressNotifier.new,
);

// ── Active font family (registered and ready) ─────────────────────────────

/// Watches [selectedQuranFontKeyProvider], registers the font file, and
/// returns the Flutter font-family string ready for use in [TextStyle].
///
/// Returns `null` when the built-in Hafs style should be used.
final quranActiveFontFamilyProvider = FutureProvider<String?>((ref) async {
  final key = ref.watch(selectedQuranFontKeyProvider);
  if (key == null) return null;

  // Guard: if the file was deleted externally, fall back gracefully
  final path = await QuranFontService.fontPath(key);
  if (!File(path).existsSync()) {
    ref.read(selectedQuranFontKeyProvider.notifier).select(null);
    return null;
  }

  await QuranFontService.ensureRegistered(key);
  return 'quran_api_$key';
});
