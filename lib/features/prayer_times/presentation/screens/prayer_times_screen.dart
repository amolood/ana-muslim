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
import '../../../../core/utils/arabic_utils.dart';
import '../../../../core/utils/prayer_utils.dart';
import '../providers/prayer_times_provider.dart';
import 'package:im_muslim/features/quran/presentation/providers/audio_providers.dart';

class PrayerTimesScreen extends ConsumerStatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  ConsumerState<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends ConsumerState<PrayerTimesScreen>
    with WidgetsBindingObserver {
  Timer? _timer;
  late final ValueNotifier<DateTime> _secondClock;
  late final ValueNotifier<DateTime> _minuteClock;
  String? _lastAdhanAlertKey;
  bool _isAppResumed = true;
  bool _isTabVisible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final now = DateTime.now();
    _secondClock = ValueNotifier<DateTime>(now);
    _minuteClock = ValueNotifier<DateTime>(
      DateTime(now.year, now.month, now.day, now.hour, now.minute),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(prayerDailyProgressProvider.notifier).ensureToday();
    });
    _startTicker();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _secondClock.dispose();
    _minuteClock.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    switch (state) {
      case AppLifecycleState.resumed:
        _isAppResumed = true;
        _syncTickerState(immediateTick: true);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _isAppResumed = false;
        _syncTickerState();
        break;
    }
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  void _syncTickerState({bool immediateTick = false}) {
    final shouldRun = _isAppResumed && _isTabVisible;
    if (!shouldRun) {
      _timer?.cancel();
      _timer = null;
      return;
    }

    if (immediateTick) {
      _onTick();
    }
    _startTicker();
  }

  void _handleTabVisibility(bool visible) {
    if (_isTabVisible == visible) return;
    _isTabVisible = visible;
    _syncTickerState(immediateTick: visible);
  }

  void _onTick() {
    if (!mounted) return;
    final tick = DateTime.now();
    _secondClock.value = tick;
    final minuteTick = DateTime(
      tick.year,
      tick.month,
      tick.day,
      tick.hour,
      tick.minute,
    );
    if (_minuteClock.value != minuteTick) {
      _minuteClock.value = minuteTick;
    }
  }

  @override
  Widget build(BuildContext context) {
    _handleTabVisibility(TickerMode.valuesOf(context).enabled);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locationNameAsync = ref.watch(locationNameProvider);
    final adjustedAsync = ref.watch(adjustedPrayerTimesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            children: [
              _buildHeader(context, isDark),
              const SizedBox(height: 24),
              locationNameAsync.when(
                data: (locationName) => _buildLocationAndDate(locationName, isDark),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text(
                    'تعذر تحديد الموقع: $e',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ValueListenableBuilder<DateTime>(
                valueListenable: _secondClock,
                builder: (context, now, _) => adjustedAsync.when(
                  data: (adjusted) => _buildTimerCard(adjusted, now, isDark),
                  loading: () => const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => Text(
                    'تعذر تحميل المواقيت: $e',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ValueListenableBuilder<DateTime>(
                valueListenable: _minuteClock,
                builder: (context, now, _) => adjustedAsync.when(
                  data: (adjusted) => _buildPrayerList(adjusted, now, isDark),
                  loading: () => const SizedBox.shrink(),
                  error: (_, stackTrace) => const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCircleButton(
            context: context,
            isDark: isDark,
            icon: Icons.settings,
            onTap: () => context.push('/settings'),
          ),
          Text(
            'مواقيت الصلاة',
            style: GoogleFonts.tajawal(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
            ),
          ),
          _buildCircleButton(
            context: context,
            isDark: isDark,
            icon: Icons.notifications_none,
            onTap: () => _showNotificationsSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceDark.withValues(alpha: 0.5)
                : AppColors.surfaceLight.withValues(alpha: 0.8),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isDark ? Colors.grey[300] : AppColors.textSecondaryLight,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildLocationAndDate(String locationName, bool isDark) {
    HijriCalendar.setLocal('ar');
    final hijri = HijriCalendar.now();
    final gregorian = DateFormat(
      'EEEE، d MMMM yyyy',
      'ar',
    ).format(DateTime.now());
    final hijriText = '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} هـ';

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
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
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
            color: isDark ? Colors.white : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          gregorian,
          style: GoogleFonts.tajawal(
            fontSize: 13,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  UpcomingPrayerInfo _getUpcomingFromAdjusted(
    AdjustedPrayerTimes adjusted,
    DateTime now,
  ) {
    const orderedPrayers = [
      Prayer.fajr,
      Prayer.sunrise,
      Prayer.dhuhr,
      Prayer.asr,
      Prayer.maghrib,
      Prayer.isha,
    ];
    for (final p in orderedPrayers) {
      final t = adjusted.timeForPrayer(p)?.toLocal();
      if (t != null && t.isAfter(now)) {
        return UpcomingPrayerInfo(prayer: p, time: t);
      }
    }
    return UpcomingPrayerInfo(
      prayer: Prayer.fajr,
      time: adjusted.fajr.toLocal().add(const Duration(days: 1)),
    );
  }

  Widget _buildTimerCard(AdjustedPrayerTimes adjusted, DateTime now, bool isDark) {
    final upcoming = _getUpcomingFromAdjusted(adjusted, now);
    final remaining = PrayerUtils.getRemainingTime(upcoming.time, now);

    _maybeTriggerAdhanAlert(upcoming.prayer, upcoming.time, now);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: isDark ? 0.1 : 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.05 : 0.1),
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
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getPrayerNameArabic(upcoming.prayer),
            style: TextStyle(
              fontFamily: 'KFGQPC Uthmanic Script',
              fontFamilyFallback: ['naskh'],
              fontSize: 32,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
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
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerList(AdjustedPrayerTimes adjusted, DateTime now, bool isDark) {
    final format = DateFormat('hh:mm a');
    final upcoming = _getUpcomingFromAdjusted(adjusted, now);

    final prayersList = [
      {'prayer': Prayer.fajr, 'name': 'الفجر', 'time': adjusted.fajr},
      {'prayer': Prayer.sunrise, 'name': 'الشروق', 'time': adjusted.sunrise},
      {'prayer': Prayer.dhuhr, 'name': 'الظهر', 'time': adjusted.dhuhr},
      {'prayer': Prayer.asr, 'name': 'العصر', 'time': adjusted.asr},
      {'prayer': Prayer.maghrib, 'name': 'المغرب', 'time': adjusted.maghrib},
      {'prayer': Prayer.isha, 'name': 'العشاء', 'time': adjusted.isha},
    ];

    final adhanAlertsEnabled = ref.watch(adhanAlertsProvider);
    final prayerProgress = ref.watch(prayerDailyProgressProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: prayersList.map((p) {
          final prayerType = p['prayer'] as Prayer;
          final isActive = prayerType == upcoming.prayer;
          final isTrackable = PrayerDailyProgress.trackedPrayers.contains(
            prayerType,
          );
          final isCompleted =
              isTrackable && prayerProgress.isCompleted(prayerType);
          final time = format.format((p['time'] as DateTime).toLocal());
          final timeStrAr = ArabicUtils.ensureLatinDigits(
            time.replaceAll('AM', 'ص').replaceAll('PM', 'م'),
          );

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.green.withValues(alpha: isDark ? 0.12 : 0.15)
                  : isActive
                  ? AppColors.primary.withValues(alpha: isDark ? 0.1 : 0.15)
                  : (isDark ? AppColors.surfaceDark : Colors.white),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCompleted
                    ? Colors.green.withValues(alpha: isDark ? 0.45 : 0.5)
                    : isActive
                    ? AppColors.primary.withValues(alpha: isDark ? 0.3 : 0.4)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : AppColors.borderLight),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: isActive
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      p['name'] as String,
                      style: GoogleFonts.tajawal(
                        fontSize: 18,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isCompleted
                            ? Colors.green
                            : isActive
                            ? AppColors.primary
                            : (isDark ? Colors.white : AppColors.textPrimaryLight),
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
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isActive
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight),
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (isTrackable)
                      InkWell(
                        borderRadius: BorderRadius.circular(99),
                        onTap: () async {
                          await ref
                              .read(prayerDailyProgressProvider.notifier)
                              .togglePrayer(prayerType);
                          if (!mounted) return;
                          final nowDone = ref
                              .read(prayerDailyProgressProvider)
                              .isCompleted(prayerType);
                          HapticFeedback.lightImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              content: Text(
                                nowDone
                                    ? 'تقبّل الله، تم تعليم ${p['name']} كمؤداة'
                                    : 'تم إلغاء تعليم ${p['name']}',
                                style: GoogleFonts.tajawal(),
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            isCompleted
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: isCompleted
                                ? Colors.green
                                : (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight),
                            size: 22,
                          ),
                        ),
                      ),
                    if (isTrackable) const SizedBox(width: 8),
                    Icon(
                      adhanAlertsEnabled ? Icons.volume_up : Icons.volume_off,
                      color: adhanAlertsEnabled
                          ? AppColors.primary
                          : (isDark ? Colors.grey[600] : Colors.grey[400]),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
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
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'عند تفعيلها سيتم تنبيهك داخل التطبيق عند دخول وقت الصلاة القادمة.',
                style: GoogleFonts.tajawal(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
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
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
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
                            value
                                ? 'تم تفعيل تنبيهات الأذان'
                                : 'تم إيقاف تنبيهات الأذان',
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

  void _maybeTriggerAdhanAlert(Prayer prayer, DateTime time, DateTime now) {
    final isEnabled = ref.read(adhanAlertsProvider);
    if (!isEnabled) {
      return;
    }

    final remaining = time.difference(now);
    if (remaining.inSeconds > 1 || remaining.inSeconds < 0) {
      return;
    }

    final alertKey =
        '${prayer.name}-${time.year}-${time.month}-${time.day}-${time.hour}-${time.minute}';
    if (_lastAdhanAlertKey == alertKey) {
      return;
    }
    _lastAdhanAlertKey = alertKey;

    // Pause/stop أي صوت قرآن قبل تشغيل تنبيه الأذان
    ref.read(quranAudioProvider.notifier).stop();

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
}
