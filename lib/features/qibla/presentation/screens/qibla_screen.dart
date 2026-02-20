import 'dart:math' show pi;
import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart'; // Added for LocationPermission
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import 'package:im_muslim/core/utils/prayer_utils.dart';
import 'package:im_muslim/features/prayer_times/presentation/providers/prayer_times_provider.dart';

class QiblaScreen extends ConsumerWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: FutureBuilder(
                future: FlutterQiblah.checkLocationStatus(),
                builder: (context, AsyncSnapshot<LocationStatus> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white)));
                  }

                  if (snapshot.data!.enabled == true) {
                    switch (snapshot.data!.status) {
                      case LocationPermission.always:
                      case LocationPermission.whileInUse:
                        return _buildQiblaCompass();
                      case LocationPermission.denied:
                        return const Center(child: Text("يرجى إعطاء صلاحية الموقع لمعرفة اتجاه القبلة", style: TextStyle(color: Colors.white)));
                      case LocationPermission.deniedForever:
                        return const Center(child: Text("صلاحية الموقع مرفوضة دائمًا، يرجى تفعيلها من الإعدادات", style: TextStyle(color: Colors.white)));
                      default:
                        return const Center(child: Text("يرجى تفعيل خدمات الموقع", style: TextStyle(color: Colors.white)));
                    }
                  } else {
                    return const Center(child: Text("خدمات الموقع غير مفعلة", style: TextStyle(color: Colors.white)));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceDark.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.help_outline, color: Colors.grey[300], size: 20),
          ),
          Text(
            'القبلة',
            style: GoogleFonts.tajawal(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 40), // Balance the header
        ],
      ),
    );
  }

  Widget _buildQiblaCompass() {
    return StreamBuilder(
      stream: FlutterQiblah.qiblahStream,
      builder: (_, AsyncSnapshot<QiblahDirection> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              "خطأ في قراءة المستشعرات: ${snapshot.error}",
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        final qiblahDirection = snapshot.data!;
        // The angle between Magnetic North and Qibla.
        final qiblaAngle = qiblahDirection.qiblah * (pi / 180);
        // The angle between Magnetic North and Device heading (which is stored in 'direction')
        final compassAngle = qiblahDirection.direction * (pi / 180);

        // Calculate offset difference
        final difference = (qiblahDirection.qiblah - qiblahDirection.direction).abs();
        final isFacingQibla = difference < 10 || difference > 350;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isFacingQibla ? 'أنت في اتجاه القبلة' : 'وجه الهاتف نحو القبلة',
              style: GoogleFonts.tajawal(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isFacingQibla ? AppColors.primary : Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${qiblahDirection.direction.toInt()}°',
              style: GoogleFonts.manrope(
                fontSize: 20,
                color: AppColors.textSecondaryDark,
              ),
            ),
            const SizedBox(height: 60),
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer Compass Decoration
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isFacingQibla ? AppColors.primary : AppColors.surfaceDark,
                      width: 8,
                    ),
                    gradient: RadialGradient(
                      colors: [
                        AppColors.surfaceDark.withValues(alpha: 0.2),
                        AppColors.surfaceDark.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                ),
                
                // Compass markings
                ...List.generate(72, (index) {
                  final isMajor = index % 18 == 0;
                  return Transform.rotate(
                    angle: index * 5 * pi / 180,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        margin: const EdgeInsets.only(top: 10),
                        width: isMajor ? 3 : 1,
                        height: isMajor ? 12 : 6,
                        color: isMajor ? Colors.white.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  );
                }),

                // Rotating Compass Dial
                Transform.rotate(
                  angle: compassAngle * -1,
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/compass-rose.png', // Fallback or mock image
                    width: 260,
                    height: 260,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.explore,
                        size: 260,
                        color: AppColors.surfaceDark,
                      );
                    },
                  ),
                ),

                // Qibla Indicator (Kaaba)
                Transform.rotate(
                  angle: qiblaAngle,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      margin: const EdgeInsets.only(top: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on,
                            color: isFacingQibla ? AppColors.primary : Colors.white,
                            size: 40,
                          ),
                          Container(
                            width: 20,
                            height: 20,
                            color: Colors.black, // Kaaba representation
                            child: Center(
                              child: Container(
                                width: 20,
                                height: 4,
                                color: Colors.amber, // Golden band
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
            Consumer(
              builder: (context, ref, _) {
                final locationAsync = ref.watch(locationProvider);
                return locationAsync.when(
                  data: (position) => Column(
                    children: [
                      Text(
                        'موقعي الحالي',
                        style: GoogleFonts.tajawal(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, stackTrace) => const SizedBox.shrink(),
                );
              },
            ),
            const SizedBox(height: 20),
            Consumer(
              builder: (context, ref, _) {
                final prayerTimesAsync = ref.watch(prayerTimesProvider);
                return prayerTimesAsync.when(
                  data: (prayerTimes) {
                    final upcoming = PrayerUtils.getUpcomingPrayer(prayerTimes, DateTime.now());
                    final time = DateFormat('hh:mm a')
                        .format(upcoming.time)
                        .replaceAll('AM', 'ص')
                        .replaceAll('PM', 'م');
                    return Text(
                      'الصلاة القادمة: ${_getPrayerNameArabic(upcoming.prayer)} - $time',
                      style: GoogleFonts.tajawal(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, stackTrace) => const SizedBox.shrink(),
                );
              },
            ),
          ],
        );
      },
    );
  }

  String _getPrayerNameArabic(Prayer prayer) {
    return switch (prayer) {
      Prayer.fajr => 'الفجر',
      Prayer.sunrise => 'الشروق',
      Prayer.dhuhr => 'الظهر',
      Prayer.asr => 'العصر',
      Prayer.maghrib => 'المغرب',
      Prayer.isha => 'العشاء',
      Prayer.none => 'لا يوجد',
    };
  }
}
