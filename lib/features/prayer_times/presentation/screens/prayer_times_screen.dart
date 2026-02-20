import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/prayer_utils.dart';
import '../providers/prayer_times_provider.dart';

class PrayerTimesScreen extends ConsumerStatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  ConsumerState<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends ConsumerState<PrayerTimesScreen> {
  Timer? _timer;
  DateTime _currentTime = DateTime.now();
  String? _lastAdhanAlertKey;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationNameAsync = ref.watch(locationNameProvider);
    final prayerTimesAsync = ref.watch(prayerTimesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              locationNameAsync.when(
                data: _buildLocationAndDate,
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text(
                    'تعذر تحديد الموقع: $e',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              prayerTimesAsync.when(
                data: _buildTimerCard,
                loading: () => const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Text(
                  'تعذر تحميل المواقيت: $e',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              const SizedBox(height: 32),
              prayerTimesAsync.when(
                data: _buildPrayerList,
                loading: () => const SizedBox.shrink(),
                error: (_, stackTrace) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCircleButton(
            icon: Icons.settings,
            onTap: () => context.push('/settings'),
          ),
          Text(
            'مواقيت الصلاة',
            style: GoogleFonts.tajawal(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          _buildCircleButton(
            icon: Icons.notifications_none,
            onTap: () => _showNotificationsSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.grey[300], size: 20),
        ),
      ),
    );
  }

  Widget _buildLocationAndDate(String locationName) {
    HijriCalendar.setLocal('ar');
    final hijri = HijriCalendar.now();
    final gregorian = DateFormat('EEEE، d MMMM yyyy', 'ar').format(DateTime.now());
    final hijriText = '${_toArabicNumber(hijri.hDay)} ${hijri.longMonthName} ${_toArabicNumber(hijri.hYear)} هـ';

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                locationName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.tajawal(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          hijriText,
          style: GoogleFonts.tajawal(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          gregorian,
          style: GoogleFonts.tajawal(
            fontSize: 13,
            color: AppColors.textSecondaryDark,
          ),
        ),
      ],
    );
  }

  Widget _buildTimerCard(PrayerTimes prayerTimes) {
    final upcoming = PrayerUtils.getUpcomingPrayer(prayerTimes, _currentTime);
    final remaining = PrayerUtils.getRemainingTime(upcoming.time, _currentTime);

    _maybeTriggerAdhanAlert(upcoming.prayer, upcoming.time);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'الصلاة القادمة',
            style: GoogleFonts.tajawal(
              fontSize: 14,
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getPrayerNameArabic(upcoming.prayer),
            style: GoogleFonts.tajawal(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _formatDuration(remaining),
            style: GoogleFonts.manrope(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'متبقي على الأذان',
            style: GoogleFonts.tajawal(
              fontSize: 14,
              color: AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerList(PrayerTimes prayerTimes) {
    final format = DateFormat('hh:mm a');
    final upcoming = PrayerUtils.getUpcomingPrayer(prayerTimes, _currentTime);

    final prayersList = [
      {'prayer': Prayer.fajr, 'name': 'الفجر', 'time': prayerTimes.fajr},
      {'prayer': Prayer.sunrise, 'name': 'الشروق', 'time': prayerTimes.sunrise},
      {'prayer': Prayer.dhuhr, 'name': 'الظهر', 'time': prayerTimes.dhuhr},
      {'prayer': Prayer.asr, 'name': 'العصر', 'time': prayerTimes.asr},
      {'prayer': Prayer.maghrib, 'name': 'المغرب', 'time': prayerTimes.maghrib},
      {'prayer': Prayer.isha, 'name': 'العشاء', 'time': prayerTimes.isha},
    ];

    final adhanAlertsEnabled = ref.watch(adhanAlertsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: prayersList.map((p) {
          final prayerType = p['prayer'] as Prayer;
          final isActive = prayerType == upcoming.prayer;
          final time = format.format((p['time'] as DateTime).toLocal());
          final timeStrAr = time.replaceAll('AM', 'ص').replaceAll('PM', 'م');

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.05),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: isActive ? AppColors.primary : AppColors.textSecondaryDark,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      p['name'] as String,
                      style: GoogleFonts.tajawal(
                        fontSize: 18,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                        color: isActive ? AppColors.primary : Colors.white,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      timeStrAr,
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                        color: isActive ? AppColors.primary : AppColors.textSecondaryDark,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      adhanAlertsEnabled ? Icons.volume_up : Icons.volume_off,
                      color: adhanAlertsEnabled ? AppColors.primary : Colors.grey[600],
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showNotificationsSheet(BuildContext context) {
    final rootContext = this.context;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final enabled = ref.watch(adhanAlertsProvider);
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تنبيهات الأذان',
                style: GoogleFonts.tajawal(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'عند تفعيلها سيتم تنبيهك داخل التطبيق عند دخول وقت الصلاة القادمة.',
                style: GoogleFonts.tajawal(
                  fontSize: 13,
                  color: AppColors.textSecondaryDark,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      enabled ? 'مفعلة' : 'غير مفعلة',
                      style: GoogleFonts.tajawal(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Switch(
                    value: enabled,
                    onChanged: (value) async {
                      ref.read(adhanAlertsProvider.notifier).save(value);
                      Navigator.of(rootContext).pop();
                      ScaffoldMessenger.of(rootContext).showSnackBar(
                          SnackBar(
                            content: Text(
                              value ? 'تم تفعيل تنبيهات الأذان' : 'تم إيقاف تنبيهات الأذان',
                              style: GoogleFonts.tajawal(),
                            ),
                          ),
                        );
                    },
                    activeThumbColor: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _maybeTriggerAdhanAlert(Prayer prayer, DateTime time) {
    final isEnabled = ref.read(adhanAlertsProvider);
    if (!isEnabled) {
      return;
    }

    final remaining = time.difference(_currentTime);
    if (remaining.inSeconds > 1 || remaining.inSeconds < 0) {
      return;
    }

    final alertKey = '${prayer.name}-${time.year}-${time.month}-${time.day}-${time.hour}-${time.minute}';
    if (_lastAdhanAlertKey == alertKey) {
      return;
    }
    _lastAdhanAlertKey = alertKey;

    SystemSound.play(SystemSoundType.alert);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          'حان الآن وقت ${_getPrayerNameArabic(prayer)}',
          style: GoogleFonts.tajawal(),
        ),
      ),
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

  String _formatDuration(Duration duration) {
    final hh = duration.inHours.toString().padLeft(2, '0');
    final mm = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final ss = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }

  String _toArabicNumber(int number) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String numStr = number.toString();
    for (int i = 0; i < english.length; i++) {
      numStr = numStr.replaceAll(english[i], arabic[i]);
    }
    return numStr;
  }
}
