import 'package:adhan/adhan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../../core/providers/preferences_provider.dart';

final locationProvider = FutureProvider<Position>((ref) async {
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

  return await Geolocator.getCurrentPosition();
});

final locationNameProvider = FutureProvider<String>((ref) async {
  final position = await ref.watch(locationProvider.future);
  try {
    final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      String city = place.locality ?? place.subAdministrativeArea ?? place.administrativeArea ?? "";
      String country = place.country ?? "";
      if (city.isNotEmpty && country.isNotEmpty) {
        return '$city، $country';
      } else if (city.isNotEmpty) {
        return city;
      } else if (country.isNotEmpty) {
        return country;
      }
    }
  } catch (e) {
    // Ignore error, fallback below
  }
  return 'موقع غير معروف';
});

final prayerTimesProvider = FutureProvider<PrayerTimes>((ref) async {
  final position = await ref.watch(locationProvider.future);
  final calcMethodStr = ref.watch(calculationMethodProvider);
  
  CalculationMethod method = CalculationMethod.umm_al_qura;
  switch (calcMethodStr) {
    case 'رابطة العالم الإسلامي': method = CalculationMethod.muslim_world_league; break;
    case 'الهيئة العامة للمساحة المصرية': method = CalculationMethod.egyptian; break;
    case 'جامعة العلوم الإسلامية بكراتشي': method = CalculationMethod.karachi; break;
    case 'الجمعية الإسلامية لأمريكا الشمالية': method = CalculationMethod.north_america; break;
    case 'أم القرى':
    default: method = CalculationMethod.umm_al_qura; break;
  }
  
  final coordinates = Coordinates(position.latitude, position.longitude);
  final params = method.getParameters();
  params.madhab = Madhab.shafi;
  
  final date = DateComponents.from(DateTime.now());
  
  return PrayerTimes(coordinates, date, params);
});
