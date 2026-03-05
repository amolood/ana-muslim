import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/hijri_calendar_day.dart';
import '../../data/services/hijri_calendar_service.dart';

/// Fetches a full Hijri month calendar.
/// Family key: (hijriMonth, hijriYear).
final hijriCalendarProvider = FutureProvider.autoDispose
    .family<List<HijriCalendarDay>, (int, int)>((ref, params) async {
  final (month, year) = params;
  return HijriCalendarService.fetchHijriMonth(month, year);
});
