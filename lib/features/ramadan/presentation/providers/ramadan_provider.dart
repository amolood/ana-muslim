import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../prayer_times/presentation/providers/prayer_times_provider.dart';
import '../../data/models/ramadan_model.dart';
import '../../data/repositories/ramadan_repository.dart';

/// Provides the full 30-day Ramadan schedule for the user's nearest city.
final ramadanScheduleProvider =
    FutureProvider.autoDispose<RamadanSchedule?>((ref) async {
  final positionAsync = ref.watch(locationProvider);
  final position = positionAsync.valueOrNull;

  return RamadanRepository.instance.getSchedule(
    lat: position?.latitude ?? 21.3891,
    lon: position?.longitude ?? 39.8579,
  );
});

/// Provides only today's Ramadan fasting entry.
final ramadanTodayProvider =
    FutureProvider.autoDispose<RamadanDay?>((ref) async {
  final positionAsync = ref.watch(locationProvider);
  final position = positionAsync.valueOrNull;

  return RamadanRepository.instance.getToday(
    lat: position?.latitude ?? 21.3891,
    lon: position?.longitude ?? 39.8579,
  );
});

/// Whether we are currently in Ramadan 2026.
bool isRamadanPeriod() {
  final now = DateTime.now();
  // Ramadan 2026: approximately Feb 18 – Mar 19
  final start = DateTime(2026, 2, 18);
  final end = DateTime(2026, 3, 20);
  return now.isAfter(start) && now.isBefore(end);
}
