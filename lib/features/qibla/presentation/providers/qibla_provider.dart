import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';
import 'package:just_audio/just_audio.dart';
import '../../domain/angle_utils.dart';
import '../../domain/qibla_calculator.dart';
import '../../data/models/qibla_state.dart';
import '../../core/constants.dart';
import '../../../../core/providers/preferences_provider.dart';

/// Notifier for managing Qibla compass state
/// Handles sensor streaming, smoothing, and stability logic
/// Now with enhanced accuracy using precise location-based calculations
class QiblaNotifier extends Notifier<QiblaUiState> {
  StreamSubscription? _subscription;
  Timer? _stabilityTimer;
  StreamSubscription? _positionStream;
  final Queue<double> _recentHeadings = Queue<double>();
  final Queue<Position> _recentPositions = Queue<Position>();

  double? _calculatedQiblaBearing;
  final AudioPlayer _successPlayer = AudioPlayer();
  bool _hasPlayedSuccess = false;

  @override
  QiblaUiState build() {
    ref.onDispose(() {
      _subscription?.cancel();
      _stabilityTimer?.cancel();
      _positionStream?.cancel();
      _successPlayer.dispose();
      _recentHeadings.clear();
      _recentPositions.clear();
    });
    return const QiblaUiState();
  }

  /// Start listening to Qibla sensor stream with enhanced location tracking
  Future<void> startListening() async {
    // Check if device supports Qibla
    final deviceSupport = await FlutterQiblah.androidDeviceSensorSupport();
    if (deviceSupport != null && !deviceSupport) {
      state = state.copyWith(
        needsCalibration: true,
        confidence: 0.0,
      );
      return;
    }

    // Start location tracking for accurate Qibla calculation
    await _startLocationTracking();

    _subscription?.cancel();
    _subscription = FlutterQiblah.qiblahStream.listen(
      (data) {
        // Use our calculated Qibla bearing instead of the library's one
        final qiblaBearing = _calculatedQiblaBearing ?? data.qiblah;
        _processSensorData(data.direction, qiblaBearing);
      },
      onError: (error) {
        // Handle stream errors
        state = state.copyWith(
          needsCalibration: true,
          confidence: 0.0,
        );
      },
    );
  }

  /// Start tracking user location for precise Qibla calculation
  Future<void> _startLocationTracking() async {
    try {
      // Get initial position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      _updatePositionAndCalculateQibla(position);

      // Listen to position changes for continuous updates
      _positionStream?.cancel();
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Update every 10 meters
        ),
      ).listen(_updatePositionAndCalculateQibla);
    } catch (e) {
      // If location fails, fall back to library calculation
      _calculatedQiblaBearing = null;
    }
  }

  /// Update position and recalculate Qibla bearing
  void _updatePositionAndCalculateQibla(Position position) {
    _recentPositions.add(position);

    // Keep only last 5 positions for averaging
    if (_recentPositions.length > 5) {
      _recentPositions.removeFirst();
    }

    // Calculate accurate Qibla bearing using our algorithm
    _calculatedQiblaBearing = QiblaCalculator.calculateQiblaDirection(position);

    // Update state with location info
    final distance = QiblaCalculator.calculateDistanceToKaaba(position);
    final locationConfidence = QiblaCalculator.calculateLocationConfidence(position);

    state = state.copyWith(
      locationName: '${distance.toStringAsFixed(0)} كم من الكعبة',
      locationAccuracy: position.accuracy,
      locationConfidence: locationConfidence,
    );
  }

  /// Stop listening to sensor stream
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _stabilityTimer?.cancel();
    _stabilityTimer = null;
  }

  /// Process incoming sensor data with smoothing and stability logic
  void _processSensorData(double heading, double qiblaBearing) {
    // 1. Add to recent samples for confidence calculation
    _recentHeadings.add(heading);
    if (_recentHeadings.length > kConfidenceSampleSize) {
      _recentHeadings.removeFirst();
    }

    // 2. Apply EMA smoothing filter
    final smoothedHeading = AngleUtils.lerpAngle(
      state.smoothedHeading ?? heading,
      heading,
      kSmoothingFactor,
    );

    // 3. Calculate delta (shortest angular distance to target)
    // Since Kaaba is fixed at 0° (top of screen), we rotate compass by this delta
    final delta = AngleUtils.shortestAngleDelta(smoothedHeading, qiblaBearing);
    final absDelta = delta.abs();

    // 4. Calculate confidence based on variance
    final confidence = _calculateConfidence();

    // 5. Check if calibration is needed
    final needsCalibration = confidence < kLowConfidenceThreshold;

    // 6. Stability hold logic
    bool isAligned = absDelta <= kSuccessThreshold;
    if (isAligned && !state.isFullyAligned) {
      // Start stability timer
      _stabilityTimer ??= Timer(kStabilityDuration, () {
        state = state.copyWith(isFullyAligned: true);

        // تشغيل نغمة النجاح عند المحاذاة
        if (!_hasPlayedSuccess) {
          _playSuccessSound();
          _hasPlayedSuccess = true;
        }
      });
    } else if (!isAligned) {
      // Cancel stability timer if user moved away
      _stabilityTimer?.cancel();
      _stabilityTimer = null;
      if (state.isFullyAligned) {
        state = state.copyWith(isFullyAligned: false);
        _hasPlayedSuccess = false; // إعادة تعيين لتشغيل الصوت مرة أخرى
      }
    }

    // 7. Update state
    state = state.copyWith(
      rawHeading: heading,
      smoothedHeading: smoothedHeading,
      qiblaBearing: qiblaBearing,
      delta: delta,
      confidence: confidence,
      needsCalibration: needsCalibration,
    );
  }

  /// Calculate confidence based on variance of recent samples
  /// High variance = low confidence = need calibration
  /// Low variance = high confidence = stable readings
  double _calculateConfidence() {
    if (_recentHeadings.length < 2) return 50.0;

    // Calculate variance using circular statistics
    double sumX = 0, sumY = 0;
    for (final angle in _recentHeadings) {
      final rad = AngleUtils.toRadians(angle);
      sumX += rad.cos();
      sumY += rad.sin();
    }

    final n = _recentHeadings.length;
    final meanX = sumX / n;
    final meanY = sumY / n;
    final r = (meanX * meanX + meanY * meanY).sqrt();

    // R-bar ranges from 0 (high variance) to 1 (low variance)
    // Convert to confidence percentage
    final confidence = r * 100;

    return confidence.clamp(0.0, 100.0);
  }

  /// Manually trigger calibration overlay
  void showCalibration() {
    state = state.copyWith(needsCalibration: true);
  }

  /// Hide calibration overlay
  void hideCalibration() {
    state = state.copyWith(needsCalibration: false);
  }

  /// Set user location name (for display)
  void setLocationName(String name) {
    state = state.copyWith(locationName: name);
  }

  /// تشغيل نغمة النجاح عند المحاذاة
  Future<void> _playSuccessSound() async {
    try {
      // التحقق من أن الصوت غير مكتوم
      final isMuted = ref.read(qiblaSuccessSoundMutedProvider);
      if (isMuted) return;

      final toneOption = ref.read(qiblaSuccessToneOptionProvider);
      final soundPath = toneOption.assetPath;

      await _successPlayer.setAsset(soundPath);
      await _successPlayer.play();
    } catch (e) {
      // تجاهل الأخطاء في تشغيل الصوت
    }
  }
}

/// Provider instance
final qiblaProvider = NotifierProvider<QiblaNotifier, QiblaUiState>(() {
  return QiblaNotifier();
});

// Extension for math operations
extension on double {
  double cos() => math.cos(this);
  double sin() => math.sin(this);
  double sqrt() => math.sqrt(this);
}
