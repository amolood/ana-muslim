import 'package:adhan/adhan.dart';

class UpcomingPrayerInfo {
  const UpcomingPrayerInfo({
    required this.prayer,
    required this.time,
  });

  final Prayer prayer;
  final DateTime time;
}

class PrayerUtils {
  static const List<Prayer> _orderedPrayers = <Prayer>[
    Prayer.fajr,
    Prayer.sunrise,
    Prayer.dhuhr,
    Prayer.asr,
    Prayer.maghrib,
    Prayer.isha,
  ];

  static UpcomingPrayerInfo getUpcomingPrayer(
    PrayerTimes prayerTimes,
    DateTime now,
  ) {
    for (final prayer in _orderedPrayers) {
      final prayerTime = prayerTimes.timeForPrayer(prayer)?.toLocal();
      if (prayerTime != null && prayerTime.isAfter(now)) {
        return UpcomingPrayerInfo(prayer: prayer, time: prayerTime);
      }
    }

    return UpcomingPrayerInfo(
      prayer: Prayer.fajr,
      time: prayerTimes.fajr.toLocal().add(const Duration(days: 1)),
    );
  }

  static Duration getRemainingTime(DateTime target, DateTime now) {
    final diff = target.difference(now);
    if (diff.isNegative) {
      return Duration.zero;
    }
    return diff;
  }
}
