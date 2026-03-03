import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Emits the current [DateTime] every second.
/// One shared stream drives both the home prayer card and the prayer-times
/// screen, avoiding two independent [Timer.periodic] instances.
final clockProvider = StreamProvider<DateTime>((ref) {
  return Stream.periodic(
    const Duration(seconds: 1),
    (_) => DateTime.now(),
  );
});

/// Derived stream that only emits when the minute changes.
/// Consumers that only need minute-level precision (e.g., prayer lists)
/// can watch this to avoid per-second rebuilds.
final minuteClockProvider = StreamProvider<DateTime>((ref) {
  return Stream.periodic(const Duration(minutes: 1), (_) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, now.hour, now.minute);
  });
});
