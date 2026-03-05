/// One day entry returned by the AlAdhan hToGCalendar endpoint.
class HijriCalendarDay {
  final int gregorianDay;
  final int gregorianMonth;
  final int gregorianYear;
  final String gregorianWeekdayAr;

  final int hijriDay;
  final int hijriMonth;
  final int hijriYear;
  final String hijriMonthAr;
  final List<String> holidays;

  const HijriCalendarDay({
    required this.gregorianDay,
    required this.gregorianMonth,
    required this.gregorianYear,
    required this.gregorianWeekdayAr,
    required this.hijriDay,
    required this.hijriMonth,
    required this.hijriYear,
    required this.hijriMonthAr,
    required this.holidays,
  });

  factory HijriCalendarDay.fromJson(Map<String, dynamic> json) {
    final g = json['gregorian'] as Map<String, dynamic>;
    final h = json['hijri'] as Map<String, dynamic>;

    final gDateParts = (g['date'] as String).split('-');
    final hDateParts = (h['date'] as String).split('-');

    return HijriCalendarDay(
      gregorianDay: int.parse(gDateParts[0]),
      gregorianMonth: int.parse(gDateParts[1]),
      gregorianYear: int.parse(gDateParts[2]),
      gregorianWeekdayAr:
          (g['weekday'] as Map<String, dynamic>)['ar'] as String? ?? '',
      hijriDay: int.parse(hDateParts[0]),
      hijriMonth: int.parse(hDateParts[1]),
      hijriYear: int.parse(hDateParts[2]),
      hijriMonthAr:
          (h['month'] as Map<String, dynamic>)['ar'] as String? ?? '',
      holidays:
          (h['holidays'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  /// ISO weekday index for the Gregorian date (1=Mon … 7=Sun).
  int get isoWeekday =>
      DateTime(gregorianYear, gregorianMonth, gregorianDay).weekday;
}
