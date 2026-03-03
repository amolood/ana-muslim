import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/preferences_provider.dart';
import '../../../prayer_times/presentation/providers/prayer_times_provider.dart';
import '../../data/models/ramadan_model.dart';
import '../../data/repositories/ramadan_repository.dart';

/// Provides the full 30-day Ramadan schedule for the user's nearest city.
final ramadanScheduleProvider = FutureProvider.autoDispose<RamadanSchedule?>((
  ref,
) async {
  final appLanguage = ref.watch(appLanguageProvider);
  final langCode = switch (appLanguage) {
    'English' => 'en',
    'Français' => 'fr',
    _ => 'ar',
  };

  double lat = 21.3891;
  double lon = 39.8579;
  try {
    final position = await ref.watch(locationProvider.future);
    lat = position.latitude;
    lon = position.longitude;
  } catch (e) {
    if (kDebugMode) debugPrint('[ramadanScheduleProvider] location unavailable, using Mecca: $e');
  }

  return RamadanRepository.instance.getSchedule(
    lat: lat,
    lon: lon,
    lang: langCode,
  );
});

/// Provides only today's Ramadan fasting entry.
final ramadanTodayProvider = FutureProvider.autoDispose<RamadanDay?>((
  ref,
) async {
  final appLanguage = ref.watch(appLanguageProvider);
  final langCode = switch (appLanguage) {
    'English' => 'en',
    'Français' => 'fr',
    _ => 'ar',
  };

  double lat = 21.3891;
  double lon = 39.8579;
  try {
    final position = await ref.watch(locationProvider.future);
    lat = position.latitude;
    lon = position.longitude;
  } catch (e) {
    if (kDebugMode) debugPrint('[ramadanTodayProvider] location unavailable, using Mecca: $e');
  }

  return RamadanRepository.instance.getToday(
    lat: lat,
    lon: lon,
    lang: langCode,
  );
});

/// Whether we are currently in Ramadan 2026.
bool isRamadanPeriod() {
  final now = DateTime.now();
  final start = DateTime(2026, 2, 18);
  final end = DateTime(2026, 3, 20);
  return now.isAfter(start) && now.isBefore(end);
}
