import 'package:adhan/adhan.dart';

extension PrayerAr on Prayer {
  /// Short Arabic name: الفجر, الشروق, ...
  String get ar => switch (this) {
    Prayer.fajr => 'الفجر',
    Prayer.sunrise => 'الشروق',
    Prayer.dhuhr => 'الظهر',
    Prayer.asr => 'العصر',
    Prayer.maghrib => 'المغرب',
    Prayer.isha => 'العشاء',
    Prayer.none => 'لا يوجد',
  };

  /// Full Arabic name: صلاة الفجر, وقت الشروق, ...
  String get arLong => switch (this) {
    Prayer.fajr => 'صلاة الفجر',
    Prayer.sunrise => 'وقت الشروق',
    Prayer.dhuhr => 'صلاة الظهر',
    Prayer.asr => 'صلاة العصر',
    Prayer.maghrib => 'صلاة المغرب',
    Prayer.isha => 'صلاة العشاء',
    Prayer.none => '--:--',
  };
}

class UpcomingPrayerInfo {
  const UpcomingPrayerInfo({required this.prayer, required this.time});

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
