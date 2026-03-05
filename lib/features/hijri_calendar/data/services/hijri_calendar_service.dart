import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/hijri_calendar_day.dart';

/// Fetches a Hijri month calendar from the AlAdhan Islamic Calendar API.
///
/// Endpoint: GET https://api.aladhan.com/v1/hToGCalendar/{month}/{year}
/// Docs: https://aladhan.com/islamic-calendar-api
abstract final class HijriCalendarService {
  static const _base = 'https://api.aladhan.com/v1';
  static const _timeout = Duration(seconds: 12);

  /// Returns all days for the given Hijri [month] and [year].
  static Future<List<HijriCalendarDay>> fetchHijriMonth(
    int month,
    int year,
  ) async {
    final uri = Uri.parse('$_base/hToGCalendar/$month/$year');

    if (kDebugMode) debugPrint('[HijriCalendar] GET $uri');

    final response = await http.get(uri).timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('AlAdhan calendar API returned ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (json['code'] != 200) {
      throw Exception('AlAdhan calendar API error: ${json['status']}');
    }

    final data = json['data'] as List<dynamic>;
    return data
        .map((e) => HijriCalendarDay.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
