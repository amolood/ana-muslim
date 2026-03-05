import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/models/qibla_state.dart';
import '../providers/qibla_provider.dart';
import '../widgets/simple_compass_view.dart';
import '../widgets/calibration_overlay.dart';
import '../../../../core/providers/navigation_provider.dart';
import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/theme/app_colors.dart';

/// Main Qibla screen with Fixed-Target / Rotating-Compass design
///
/// Implementation follows the pattern where:
/// - Kaaba icon is fixed at top of screen (0°)
/// - Compass rotates beneath it
/// - User turns phone to align indicator with Kaaba
class QiblaScreen extends ConsumerStatefulWidget {
  const QiblaScreen({super.key});

  @override
  ConsumerState<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends ConsumerState<QiblaScreen>
    with WidgetsBindingObserver {
  bool _permissionsChecked = false;
  bool _hasLocationPermission = false;
  bool _usingCachedLocation = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissionsAndStart();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Stop sensor when leaving screen
    ref.read(qiblaProvider.notifier).stopListening();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!_hasLocationPermission) return;
    if (state == AppLifecycleState.paused) {
      ref.read(qiblaProvider.notifier).stopListening();
    } else if (state == AppLifecycleState.resumed) {
      ref.read(qiblaProvider.notifier).startListening();
    }
  }

  /// Returns true and starts compass using cached location if one exists.
  bool _tryStartWithCache() {
    final prefs = ref.read(sharedPreferencesProvider);
    final savedLat = prefs.getDouble('qibla_saved_lat');
    final savedLng = prefs.getDouble('qibla_saved_lng');
    if (savedLat == null || savedLng == null) return false;

    setState(() {
      _permissionsChecked = true;
      _hasLocationPermission = false;
      _usingCachedLocation = true;
    });
    // Start the magnetometer stream; provider already has the cached bearing
    ref.read(qiblaProvider.notifier).startListening();
    return true;
  }

  /// Check location permissions and start Qibla stream
  Future<void> _checkPermissionsAndStart() async {
    try {
      // Check if device supports Qibla
      final deviceSupport = await FlutterQiblah.androidDeviceSensorSupport();
      if (!mounted) return;
      if (deviceSupport != null && !deviceSupport) {
        setState(() {
          _errorMessage = "جهازك لا يدعم حساسات البوصلة";
          _permissionsChecked = true;
        });
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (!mounted) return;

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (!mounted) return;
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (_tryStartWithCache()) return;
        setState(() {
          _errorMessage = "يرجى السماح بالوصول للموقع لتحديد اتجاه القبلة";
          _permissionsChecked = true;
          _hasLocationPermission = false;
        });
        return;
      }

      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!mounted) return;
      if (!serviceEnabled) {
        if (_tryStartWithCache()) return;
        setState(() {
          _errorMessage = "يرجى تفعيل خدمات الموقع (GPS)";
          _permissionsChecked = true;
          _hasLocationPermission = false;
        });
        return;
      }

      // All good - start listening
      setState(() {
        _permissionsChecked = true;
        _hasLocationPermission = true;
      });

      // Start Qibla stream
      ref.read(qiblaProvider.notifier).startListening();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "حدث خطأ: ${e.toString()}";
        _permissionsChecked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(qiblaProvider);

    // Start/stop sensor when Qibla tab becomes active/inactive
    ref.listen<int>(activeBranchIndexProvider, (prev, next) {
      if (next == kQiblaBranchIndex) {
        if (_hasLocationPermission || _usingCachedLocation) {
          ref.read(qiblaProvider.notifier).startListening();
        }
      } else {
        ref.read(qiblaProvider.notifier).stopListening();
      }
    });

    // Listen for alignment changes and trigger haptic feedback
    ref.listen(qiblaProvider.select((s) => s.isFullyAligned), (prev, next) {
      if (next == true && prev != true) {
        HapticFeedback.heavyImpact();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.qiblaDark,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            if (!_permissionsChecked)
              _buildLoading()
            else if (_errorMessage != null)
              _buildError()
            else
              _buildCompassView(state),

            // Calibration overlay (if needed)
            if (_hasLocationPermission && state.needsCalibration)
              CalibrationOverlay(
                onDismiss: () {
                  ref.read(qiblaProvider.notifier).hideCalibration();
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.qiblaGreen),
          ),
          SizedBox(height: 24),
          Text(
            "جارٍ التحضير...",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: 64,
            ),
            const SizedBox(height: 24),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'Tajawal',
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _checkPermissionsAndStart,
              icon: const Icon(Icons.refresh),
              label: const Text("إعادة المحاولة"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.qiblaGreen,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            if (!_hasLocationPermission) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => Geolocator.openLocationSettings(),
                icon: const Icon(Icons.settings),
                label: const Text("فتح الإعدادات"),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white70,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompassView(QiblaUiState state) {
    return Column(
      children: [
        if (_usingCachedLocation)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white.withValues(alpha: 0.07),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.location_off_rounded,
                    color: Colors.white54, size: 14),
                SizedBox(width: 6),
                Text(
                  'يستخدم الموقع المحفوظ',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
          ),

        const Spacer(),

        // Compass centered
        Center(
          child: SimpleCompassView(state: state),
        ),

        const Spacer(),

        // Bottom bar: calibration + volume
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (state.confidence < 70)
                IconButton(
                  onPressed: () {
                    ref.read(qiblaProvider.notifier).showCalibration();
                  },
                  icon: const Icon(Icons.explore, color: Colors.white70),
                  tooltip: 'معايرة البوصلة',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              if (state.confidence < 70) const SizedBox(width: 12),
              _buildVolumeButton(),
            ],
          ),
        ),
      ],
    );
  }

  /// زر التحكم في صوت النجاح (كتم/تشغيل)
  Widget _buildVolumeButton() {
    final isMuted = ref.watch(qiblaSuccessSoundMutedProvider);

    return IconButton(
      onPressed: () async {
        await ref
            .read(qiblaSuccessSoundMutedProvider.notifier)
            .save(!isMuted);
      },
      icon: Icon(
        isMuted ? Icons.volume_off : Icons.volume_up,
        color: isMuted ? Colors.white38 : AppColors.qiblaGreen,
      ),
      tooltip: isMuted ? 'تشغيل الصوت' : 'كتم الصوت',
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.1),
        padding: const EdgeInsets.all(12),
      ),
    );
  }
}
