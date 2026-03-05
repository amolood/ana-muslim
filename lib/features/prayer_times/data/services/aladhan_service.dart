import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/aladhan_prayer_times.dart';

/// Fetches prayer times from the AlAdhan REST API.
///
/// Endpoint: `GET https://api.aladhan.com/v1/timings/{DD-MM-YYYY}`
/// Docs: https://aladhan.com/prayer-times-api
///
/// Method numbers: https://aladhan.com/prayer-times-api#GetTimings
/// School (madhab): 0 = Shafi (default), 1 = Hanafi
abstract final class AladhanService {
  static const _base = 'https://api.aladhan.com/v1';
  static const _timeout = Duration(seconds: 12);

  static Future<AladhanPrayerTimes> fetchTimings({
    required double lat,
    required double lng,
    required String method,
    required String madhab,
  }) async {
    final now = DateTime.now();
    final date =
        '${now.day.toString().padLeft(2, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.year}';

    final uri = Uri.parse('$_base/timings/$date').replace(
      queryParameters: {
        'latitude': lat.toStringAsFixed(6),
        'longitude': lng.toStringAsFixed(6),
        'method': _methodNumber(method).toString(),
        'school': (madhab == 'حنفي' ? 1 : 0).toString(),
        'tune': '0,0,0,0,0,0,0,0,0', // No adjustments at API level
      },
    );

    if (kDebugMode) debugPrint('[AlAdhan] GET $uri');

    final response = await http.get(uri).timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('AlAdhan API returned ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (json['code'] != 200) {
      throw Exception('AlAdhan API error: ${json['status']}');
    }

    final data = json['data'] as Map<String, dynamic>;
    final timings = data['timings'] as Map<String, dynamic>;
    return AladhanPrayerTimes.fromTimingsMap(timings);
  }

  // ─── Method number map ────────────────────────────────────────────────────
  // Reference: https://aladhan.com/prayer-times-api#GetTimings (method table)

  static int _methodNumber(String method) => switch (method) {
    'جامعة العلوم الإسلامية بكراتشي' => 1,
    'الجمعية الإسلامية لأمريكا الشمالية' => 2,
    'رابطة العالم الإسلامي' => 3,
    'أم القرى' => 4,
    'الهيئة العامة للمساحة المصرية' => 5,
    'إيران' => 7,
    'الكويت' => 9,
    'قطر' => 10,
    'سنغافورة' => 11,
    'تركيا' => 13,
    'دبي' => 16,
    _ => 4, // fallback to أم القرى
  };
}
