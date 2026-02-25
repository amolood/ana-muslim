import 'dart:math' as math;

/// Utilities for robust circular angle mathematics
/// Prevents flickering and provides smooth compass animations
class AngleUtils {
  /// Normalizes any angle to the range [0, 360).
  ///
  /// Examples:
  /// - normalize360(450) = 90
  /// - normalize360(-90) = 270
  static double normalize360(double angle) {
    return (angle % 360 + 360) % 360;
  }

  /// Calculates the shortest signed difference between two angles.
  /// Result is in range [-180, 180].
  ///
  /// Positive means 'target' is to the right of 'current'.
  /// Negative means 'target' is to the left of 'current'.
  ///
  /// Examples:
  /// - shortestAngleDelta(10, 20) = 10 (turn right 10°)
  /// - shortestAngleDelta(350, 10) = 20 (turn right 20°, not left 340°)
  /// - shortestAngleDelta(10, 350) = -20 (turn left 20°, not right 340°)
  static double shortestAngleDelta(double current, double target) {
    double diff = normalize360(target) - normalize360(current);
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;
    return diff;
  }

  /// Linear interpolation between two angles using the shortest path.
  ///
  /// [a] - Starting angle
  /// [b] - Target angle
  /// [t] - Interpolation factor (0.0 to 1.0)
  ///
  /// This is critical for smooth compass rotation without sudden jumps.
  ///
  /// Example:
  /// - lerpAngle(350, 10, 0.5) = 0 (halfway between, going right)
  /// - lerpAngle(10, 350, 0.5) = 0 (halfway between, going left)
  static double lerpAngle(double a, double b, double t) {
    double delta = shortestAngleDelta(a, b);
    return normalize360(a + delta * t);
  }

  /// Converts degrees to radians
  static double toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  /// Converts radians to degrees
  static double toDegrees(double radians) {
    return radians * (180 / math.pi);
  }

  /// Checks if two angles are approximately equal within a threshold
  static bool areAnglesClose(double a, double b, double threshold) {
    return shortestAngleDelta(a, b).abs() <= threshold;
  }
}
