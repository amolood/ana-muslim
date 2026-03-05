import 'dart:convert';

/// Prayer times returned by the AlAdhan REST API (`api.aladhan.com/v1/timings`).
///
/// All times are in the device's local timezone (AlAdhan returns wall-clock HH:MM
/// strings already adjusted for the location's timezone, which is more accurate
/// than the local adhan library that applies only a fixed UTC offset).
class AladhanPrayerTimes {
  const AladhanPrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  // ─── Parse from API `timings` map ────────────────────────────────────────

  factory AladhanPrayerTimes.fromTimingsMap(Map<String, dynamic> timings) {
    return AladhanPrayerTimes(
      fajr: _parseHHMM(timings['Fajr'] as String),
      sunrise: _parseHHMM(timings['Sunrise'] as String),
      dhuhr: _parseHHMM(timings['Dhuhr'] as String),
      asr: _parseHHMM(timings['Asr'] as String),
      maghrib: _parseHHMM(timings['Maghrib'] as String),
      isha: _parseHHMM(timings['Isha'] as String),
    );
  }

  /// API returns "HH:MM" in 24-hour format.
  static DateTime _parseHHMM(String hhmm) {
    final parts = hhmm.split(':');
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  // ─── Disk cache serialisation (millisecondsSinceEpoch) ───────────────────

  String toJsonString() => jsonEncode({
    'fajr': fajr.millisecondsSinceEpoch,
    'sunrise': sunrise.millisecondsSinceEpoch,
    'dhuhr': dhuhr.millisecondsSinceEpoch,
    'asr': asr.millisecondsSinceEpoch,
    'maghrib': maghrib.millisecondsSinceEpoch,
    'isha': isha.millisecondsSinceEpoch,
  });

  factory AladhanPrayerTimes.fromJsonString(String jsonStr) {
    final m = jsonDecode(jsonStr) as Map<String, dynamic>;
    return AladhanPrayerTimes(
      fajr: DateTime.fromMillisecondsSinceEpoch(m['fajr'] as int),
      sunrise: DateTime.fromMillisecondsSinceEpoch(m['sunrise'] as int),
      dhuhr: DateTime.fromMillisecondsSinceEpoch(m['dhuhr'] as int),
      asr: DateTime.fromMillisecondsSinceEpoch(m['asr'] as int),
      maghrib: DateTime.fromMillisecondsSinceEpoch(m['maghrib'] as int),
      isha: DateTime.fromMillisecondsSinceEpoch(m['isha'] as int),
    );
  }
}
