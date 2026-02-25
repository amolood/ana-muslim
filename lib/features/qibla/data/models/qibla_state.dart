/// UI State for Qibla feature
/// Immutable data class holding all compass-related data
class QiblaUiState {
  /// Raw heading from sensor (unfiltered)
  final double? rawHeading;

  /// Smoothed heading using EMA filter
  final double? smoothedHeading;

  /// Qibla bearing (direction to Kaaba from user's location)
  final double? qiblaBearing;

  /// Angular difference between smoothed heading and qibla bearing
  /// Positive = turn right, Negative = turn left
  final double delta;

  /// Confidence level (0-100) based on sensor stability
  final double confidence;

  /// True if user has been aligned for the stability duration
  final bool isFullyAligned;

  /// True if calibration overlay should be shown
  final bool needsCalibration;

  /// User's current location (for debugging/display)
  final String? locationName;

  /// Location accuracy in meters
  final double? locationAccuracy;

  /// Location confidence (0-100) based on GPS accuracy
  final double? locationConfidence;

  const QiblaUiState({
    this.rawHeading,
    this.smoothedHeading,
    this.qiblaBearing,
    this.delta = 0.0,
    this.confidence = 0.0,
    this.isFullyAligned = false,
    this.needsCalibration = false,
    this.locationName,
    this.locationAccuracy,
    this.locationConfidence,
  });

  /// Check if user is near alignment (within 10 degrees)
  bool get isNear => delta.abs() < 10.0;

  /// Check if user is within acceptable tolerance (45 degrees)
  bool get isWithinTolerance => delta.abs() < 45.0;

  /// Get alignment status as enum
  AlignmentStatus get alignmentStatus {
    if (isFullyAligned) return AlignmentStatus.perfect;
    if (delta.abs() < 3.0) return AlignmentStatus.excellent;
    if (delta.abs() < 10.0) return AlignmentStatus.good;
    if (delta.abs() < 45.0) return AlignmentStatus.acceptable;
    return AlignmentStatus.off;
  }

  QiblaUiState copyWith({
    double? rawHeading,
    double? smoothedHeading,
    double? qiblaBearing,
    double? delta,
    double? confidence,
    bool? isFullyAligned,
    bool? needsCalibration,
    String? locationName,
    double? locationAccuracy,
    double? locationConfidence,
  }) {
    return QiblaUiState(
      rawHeading: rawHeading ?? this.rawHeading,
      smoothedHeading: smoothedHeading ?? this.smoothedHeading,
      qiblaBearing: qiblaBearing ?? this.qiblaBearing,
      delta: delta ?? this.delta,
      confidence: confidence ?? this.confidence,
      isFullyAligned: isFullyAligned ?? this.isFullyAligned,
      needsCalibration: needsCalibration ?? this.needsCalibration,
      locationName: locationName ?? this.locationName,
      locationAccuracy: locationAccuracy ?? this.locationAccuracy,
      locationConfidence: locationConfidence ?? this.locationConfidence,
    );
  }
}

/// Enum for alignment status
enum AlignmentStatus {
  perfect, // < 3° with stability hold
  excellent, // < 3° without stability
  good, // < 10°
  acceptable, // < 45°
  off, // > 45°
}
