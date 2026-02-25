import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/models/qibla_state.dart';
import '../providers/qibla_provider.dart';
import '../widgets/simple_compass_view.dart';
import '../widgets/qibla_instructions.dart';
import '../widgets/calibration_overlay.dart';
import '../../../../core/providers/preferences_provider.dart';

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

class _QiblaScreenState extends ConsumerState<QiblaScreen> {
  bool _permissionsChecked = false;
  bool _hasLocationPermission = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndStart();
  }

  @override
  void dispose() {
    // Stop listening when leaving screen
    ref.read(qiblaProvider.notifier).stopListening();
    super.dispose();
  }

  /// Check location permissions and start Qibla stream
  Future<void> _checkPermissionsAndStart() async {
    try {
      // Check if device supports Qibla
      final deviceSupport = await FlutterQiblah.androidDeviceSensorSupport();
      if (deviceSupport != null && !deviceSupport) {
        setState(() {
          _errorMessage = "جهازك لا يدعم حساسات البوصلة";
          _permissionsChecked = true;
        });
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = "يرجى السماح بالوصول للموقع لتحديد اتجاه القبلة";
          _permissionsChecked = true;
          _hasLocationPermission = false;
        });
        return;
      }

      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
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
      setState(() {
        _errorMessage = "حدث خطأ: ${e.toString()}";
        _permissionsChecked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(qiblaProvider);

    // Listen for alignment changes and trigger haptic feedback
    ref.listen(qiblaProvider.select((s) => s.isFullyAligned), (prev, next) {
      if (next == true && prev != true) {
        HapticFeedback.heavyImpact();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
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
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4AFFA3)),
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
                backgroundColor: const Color(0xFF4AFFA3),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            if (!_hasLocationPermission) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () async {
                  await Geolocator.openLocationSettings();
                },
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const Spacer(flex: 1),

                  // البوصلة في المنتصف تماماً
                  SimpleCompassView(state: state),

                  const Spacer(flex: 1),

                  // التعليمات في الأسفل
                  QiblaInstructions(state: state),

                  const SizedBox(height: 16),

                  // زر المعايرة وكتم الصوت في الأسفل
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // زر المعايرة (إذا لزم)
                      if (state.confidence < 70)
                        TextButton.icon(
                          onPressed: () {
                            ref.read(qiblaProvider.notifier).showCalibration();
                          },
                          icon: const Icon(Icons.refresh, color: Colors.white70),
                          label: const Text(
                            'تحتاج إلى معايرة البوصلة',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),

                      if (state.confidence < 70)
                        const SizedBox(width: 16),

                      // زر كتم/تشغيل صوت النجاح
                      _buildVolumeButton(),
                    ],
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
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
        color: isMuted ? Colors.white38 : const Color(0xFF4AFFA3),
      ),
      tooltip: isMuted ? 'تشغيل الصوت' : 'كتم الصوت',
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.1),
        padding: const EdgeInsets.all(12),
      ),
    );
  }
}
