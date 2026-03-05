import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/providers/preferences_provider.dart';
import '../../../settings/presentation/notification_reschedule.dart';
import '../../data/models/aladhan_prayer_times.dart';
import '../../data/services/aladhan_service.dart';

/// Prayer times with manual offsets applied.
class AdjustedPrayerTimes {
  final DateTime fajr, sunrise, dhuhr, asr, maghrib, isha;

  const AdjustedPrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  DateTime? timeForPrayer(Prayer p) => switch (p) {
    Prayer.fajr => fajr,
    Prayer.sunrise => sunrise,
    Prayer.dhuhr => dhuhr,
    Prayer.asr => asr,
    Prayer.maghrib => maghrib,
    Prayer.isha => isha,
    _ => null,
  };

  /// Value equality — prevents unnecessary rebuilds when [adjustedPrayerTimesProvider]
  /// resolves with identical times (e.g. on hot-reload or settings round-trip).
  @override
  bool operator ==(Object other) =>
      other is AdjustedPrayerTimes &&
      other.fajr == fajr &&
      other.sunrise == sunrise &&
      other.dhuhr == dhuhr &&
      other.asr == asr &&
      other.maghrib == maghrib &&
      other.isha == isha;

  @override
  int get hashCode => Object.hash(fajr, sunrise, dhuhr, asr, maghrib, isha);
}

final locationProvider = FutureProvider<Position>((ref) async {
  // Use manual location if configured — no GPS required
  final manual = ref.watch(manualLocationProvider);
  if (manual != null) {
    return Position(
      latitude: manual.lat,
      longitude: manual.lng,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }

  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('خدمات الموقع غير مفعلة');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('تم رفض صلاحية الموقع');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw Exception('صلاحية الموقع مرفوضة بشكل دائم');
  }

  try {
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    ).timeout(const Duration(seconds: 10));
  } on TimeoutException {
    final lastKnown = await Geolocator.getLastKnownPosition();
    if (lastKnown != null) return lastKnown;
    rethrow;
  } catch (_) {
    final lastKnown = await Geolocator.getLastKnownPosition();
    if (lastKnown != null) return lastKnown;
    rethrow;
  }
});

final locationNameProvider = FutureProvider<String>((ref) async {
  // If manual location is set, use its stored name
  final manual = ref.watch(manualLocationProvider);
  if (manual != null && manual.name.isNotEmpty) return manual.name;

  final position = await ref.watch(locationProvider.future);
  try {
    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      final city =
          place.locality ??
          place.subAdministrativeArea ??
          place.administrativeArea ??
          '';
      final country = place.country ?? '';
      if (city.isNotEmpty && country.isNotEmpty) return '$city، $country';
      if (city.isNotEmpty) return city;
      if (country.isNotEmpty) return country;
    }
  } catch (e) {
    if (kDebugMode) debugPrint('[locationNameProvider] geocoding failed: $e');
  }
  return 'موقع غير معروف';
});

/// Local adhan-library prayer times — used as fallback when the AlAdhan API
/// is unavailable, and as the source for notification scheduling (which does
/// NOT use the API to avoid network dependency at alarm time).
final prayerTimesProvider = FutureProvider<PrayerTimes>((ref) async {
  final position = await ref.watch(locationProvider.future);
  final calcMethodStr = ref.watch(calculationMethodProvider);
  final madhabStr = ref.watch(madhabProvider);

  final coordinates = Coordinates(position.latitude, position.longitude);
  final params = buildCalculationParams(calcMethodStr, madhab: madhabStr);
  final date = DateComponents.from(DateTime.now());
  return PrayerTimes(coordinates, date, params);
});

/// Primary display source: AlAdhan REST API with disk-cache and adhan fallback.
///
/// Cache key: `aladhan_{method}_{madhab}_{YYYY-MM-DD}` in SharedPreferences.
/// This provider is reactive — it auto-recomputes when location, method, or
/// madhab change, and is invalidated at midnight by the home screen.
final aladhanTimesProvider = FutureProvider<AladhanPrayerTimes>((ref) async {
  final position = await ref.watch(locationProvider.future);
  final method = ref.watch(calculationMethodProvider);
  final madhab = ref.watch(madhabProvider);
  final prefs = ref.watch(sharedPreferencesProvider);

  final today = () {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }();

  // Safe key — strip characters that might be problematic in prefs keys
  final safeMethod = method.replaceAll(' ', '_');
  final cacheKey = 'aladhan_${safeMethod}_${madhab}_$today';

  // 1. Try disk cache (valid until midnight via key date component)
  final cached = prefs.getString(cacheKey);
  if (cached != null) {
    try {
      if (kDebugMode) debugPrint('[AlAdhan] using disk cache for $today');
      return AladhanPrayerTimes.fromJsonString(cached);
    } catch (e) {
      if (kDebugMode) debugPrint('[AlAdhan] cache parse failed: $e');
    }
  }

  // 2. Fetch from API
  try {
    final times = await AladhanService.fetchTimings(
      lat: position.latitude,
      lng: position.longitude,
      method: method,
      madhab: madhab,
    );
    // Persist to disk (valid until tomorrow's key changes)
    await prefs.setString(cacheKey, times.toJsonString());
    if (kDebugMode) debugPrint('[AlAdhan] fetched and cached for $today');
    return times;
  } catch (e) {
    if (kDebugMode) debugPrint('[AlAdhan] API failed, falling back to adhan lib: $e');
  }

  // 3. Fallback to local adhan library (always available offline)
  final raw = await ref.read(prayerTimesProvider.future);
  return AladhanPrayerTimes(
    fajr: raw.fajr,
    sunrise: raw.sunrise,
    dhuhr: raw.dhuhr,
    asr: raw.asr,
    maghrib: raw.maghrib,
    isha: raw.isha,
  );
});

/// Prayer times with manual offsets applied — use this everywhere for DISPLAY.
///
/// Sources in priority order:
/// 1. Manual exact times (if user has enabled them)
/// 2. [aladhanTimesProvider] (AlAdhan API → disk cache → adhan fallback)
final adjustedPrayerTimesProvider = FutureProvider<AdjustedPrayerTimes>((
  ref,
) async {
  final manualExact = ref.watch(prayerManualExactSettingsProvider);
  if (manualExact.enabled) {
    final now = DateTime.now();
    return AdjustedPrayerTimes(
      fajr: manualExact.dateTimeFor(Prayer.fajr, now),
      sunrise: manualExact.dateTimeFor(Prayer.sunrise, now),
      dhuhr: manualExact.dateTimeFor(Prayer.dhuhr, now),
      asr: manualExact.dateTimeFor(Prayer.asr, now),
      maghrib: manualExact.dateTimeFor(Prayer.maghrib, now),
      isha: manualExact.dateTimeFor(Prayer.isha, now),
    );
  }

  final raw = await ref.watch(aladhanTimesProvider.future);
  final offsets = ref.watch(prayerManualOffsetsProvider);

  Duration d(Prayer p) => Duration(minutes: offsets.offsetFor(p));

  return AdjustedPrayerTimes(
    fajr: raw.fajr.add(d(Prayer.fajr)),
    sunrise: raw.sunrise.add(d(Prayer.sunrise)),
    dhuhr: raw.dhuhr.add(d(Prayer.dhuhr)),
    asr: raw.asr.add(d(Prayer.asr)),
    maghrib: raw.maghrib.add(d(Prayer.maghrib)),
    isha: raw.isha.add(d(Prayer.isha)),
  );
});
