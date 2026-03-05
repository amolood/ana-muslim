import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/quran_api_font.dart';

/// Handles fetching, downloading, caching, and registering Quran API fonts.
///
/// Font files are stored in `<documents>/quran_api_fonts/<key>.ttf`.
/// Once a font is registered with [FontLoader] in this session, its
/// family name can be used directly in [TextStyle].
class QuranFontService {
  static const _jsonUrl =
      'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/fonts.json';
  static const _cacheJsonKey = 'quran_api_fonts_json';
  static const _cacheTimeKey = 'quran_api_fonts_json_ts';
  static const _cacheTtlMs = 86400000; // 24 hours
  static const _dirName = 'quran_api_fonts';

  /// In-memory set of font family names already registered this session.
  static final Set<String> _registered = {};

  // ── Font list ──────────────────────────────────────────────────────────────

  /// Fetches and parses the fonts.json list.
  /// Result is cached in SharedPreferences for 24 h.
  static Future<List<QuranApiFont>> fetchFontList(
    SharedPreferences prefs,
  ) async {
    final cached = prefs.getString(_cacheJsonKey);
    final ts = prefs.getInt(_cacheTimeKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (cached != null && now - ts < _cacheTtlMs) {
      return _parse(cached);
    }

    try {
      final res = await http
          .get(Uri.parse(_jsonUrl))
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        await prefs.setString(_cacheJsonKey, res.body);
        await prefs.setInt(_cacheTimeKey, now);
        return _parse(res.body);
      }
    } catch (_) {}

    // Network failed — return stale cache if available
    if (cached != null) return _parse(cached);
    return [];
  }

  static List<QuranApiFont> _parse(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    return map.entries
        .where((e) => e.value is Map)
        .map(
          (e) => QuranApiFont.fromJson(
            e.key,
            e.value as Map<String, dynamic>,
          ),
        )
        .where((f) => f.ttfUrl.isNotEmpty)
        .toList()
      ..sort((a, b) => a.displayName.compareTo(b.displayName));
  }

  // ── File system ────────────────────────────────────────────────────────────

  static Future<Directory> _fontsDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/$_dirName');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  /// Absolute path for a font file on disk.
  static Future<String> fontPath(String key) async {
    final dir = await _fontsDir();
    return '${dir.path}/$key.ttf';
  }

  static Future<bool> isFontDownloaded(String key) async {
    final path = await fontPath(key);
    return File(path).existsSync();
  }

  // ── Download ───────────────────────────────────────────────────────────────

  /// Downloads a font TTF file, calling [onProgress] with 0.0–1.0 as it goes.
  static Future<void> downloadFont(
    String key,
    String ttfUrl, {
    required void Function(double progress) onProgress,
  }) async {
    final path = await fontPath(key);
    final client = http.Client();
    try {
      final req = http.Request('GET', Uri.parse(ttfUrl));
      final res = await client.send(req).timeout(const Duration(seconds: 60));
      final total = res.contentLength ?? 0;
      var received = 0;
      final chunks = <int>[];

      await for (final chunk in res.stream) {
        chunks.addAll(chunk);
        received += chunk.length;
        if (total > 0) onProgress(received / total);
      }

      await File(path).writeAsBytes(chunks);
      onProgress(1.0);
    } finally {
      client.close();
    }
  }

  static Future<void> deleteFont(String key) async {
    final path = await fontPath(key);
    final file = File(path);
    if (file.existsSync()) file.deleteSync();
    _registered.remove('quran_api_$key');
  }

  // ── Registration ───────────────────────────────────────────────────────────

  /// Registers a downloaded font with Flutter's engine.
  ///
  /// No-op if the font is already registered this session.
  /// Must be called before the font family is used in [TextStyle].
  static Future<void> ensureRegistered(String key) async {
    final family = 'quran_api_$key';
    if (_registered.contains(family)) return;

    final path = await fontPath(key);
    final file = File(path);
    if (!file.existsSync()) return;

    final bytes = await file.readAsBytes();
    final loader = FontLoader(family);
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
    await loader.load();
    _registered.add(family);
  }
}
