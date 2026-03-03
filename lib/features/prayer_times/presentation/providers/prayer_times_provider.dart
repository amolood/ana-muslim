import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/providers/preferences_provider.dart';
import '../../../settings/presentation/notification_reschedule.dart';

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

final prayerTimesProvider = FutureProvider<PrayerTimes>((ref) async {
  final position = await ref.watch(locationProvider.future);
  final calcMethodStr = ref.watch(calculationMethodProvider);

  // Uses the shared buildCalculationParams() so that display, notification
  // scheduling, and manual-reschedule all use identical CalculationParameters
  // (including madhab). This guarantees the adhan fires at the exact time shown.
  final coordinates = Coordinates(position.latitude, position.longitude);
  final params = buildCalculationParams(calcMethodStr);
  final date = DateComponents.from(DateTime.now());
  return PrayerTimes(coordinates, date, params);
});

/// Prayer times with manual offsets applied — use this for display.
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

  final raw = await ref.watch(prayerTimesProvider.future);
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
