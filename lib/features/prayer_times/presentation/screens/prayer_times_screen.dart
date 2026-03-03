import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/clock_provider.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
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
  late final ValueNotifier<DateTime> _secondClock;
  late final ValueNotifier<DateTime> _minuteClock;
  String? _lastAdhanAlertKey;
  bool _isAppResumed = true;

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
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _secondClock.dispose();
    _minuteClock.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    _isAppResumed = state == AppLifecycleState.resumed;
  }

  @override
  Widget build(BuildContext context) {
    final tickerActive = TickerMode.valuesOf(context).enabled;

    // Drive ValueNotifiers from the shared clock provider instead of a local timer.
    ref.listen<AsyncValue<DateTime>>(clockProvider, (_, next) {
      if (!_isAppResumed || !tickerActive || !mounted) return;
      next.whenData((tick) {
        _secondClock.value = tick;
        final minuteTick = DateTime(
          tick.year,
          tick.month,
          tick.day,
          tick.hour,
          tick.minute,
        );
        if (_minuteClock.value != minuteTick) _minuteClock.value = minuteTick;
      });
    });

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
              _buildHeader(context),
              const SizedBox(height: 24),
              locationNameAsync.when(
                data: (locationName) => _buildLocationAndDate(locationName),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_off_rounded, color: Colors.red, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'تعذر تحديد الموقع',
                        style: GoogleFonts.tajawal(color: Colors.red, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => ref.invalidate(locationNameProvider),
                        icon: const Icon(Icons.refresh, size: 16),
                        label: Text('إعادة المحاولة', style: GoogleFonts.tajawal(fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ValueListenableBuilder<DateTime>(
                valueListenable: _secondClock,
                builder: (context, now, _) => adjustedAsync.when(
                  data: (adjusted) => _buildTimerCard(adjusted, now),
                  loading: () => const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.schedule_rounded, color: Colors.red, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          'تعذر تحميل المواقيت',
                          style: GoogleFonts.tajawal(color: Colors.red, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () {
                            ref.invalidate(locationProvider);
                            ref.invalidate(adjustedPrayerTimesProvider);
                          },
                          icon: const Icon(Icons.refresh, size: 16),
                          label: Text('إعادة المحاولة', style: GoogleFonts.tajawal(fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ValueListenableBuilder<DateTime>(
                valueListenable: _minuteClock,
                builder: (context, now, _) => adjustedAsync.when(
                  data: (adjusted) => _buildPrayerList(adjusted, now),
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

  Widget _buildHeader(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCircleButton(
            context: context,
            icon: Icons.settings,
            onTap: () => context.push(Routes.settings),
          ),
          Text(
            'مواقيت الصلاة',
            style: GoogleFonts.tajawal(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          _buildCircleButton(
            context: context,
            icon: Icons.notifications_none,
            onTap: () => _showNotificationsSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colors.surfaceCard,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: colors.iconSecondary,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildLocationAndDate(String locationName) {
    final colors = context.colors;
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
                  color: colors.textPrimary,
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
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          gregorian,
          style: GoogleFonts.tajawal(
            fontSize: 13,
            color: colors.textSecondary,
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

  Widget _buildTimerCard(AdjustedPrayerTimes adjusted, DateTime now) {
    final upcoming = _getUpcomingFromAdjusted(adjusted, now);
    final remaining = PrayerUtils.getRemainingTime(upcoming.time, now);
    final colors = context.colors;

    _maybeTriggerAdhanAlert(upcoming.prayer, upcoming.time, now);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
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
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            upcoming.prayer.ar,
            style: TextStyle(
              fontFamily: 'KFGQPC Uthmanic Script',
              fontFamilyFallback: ['naskh'],
              fontSize: 32,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            ArabicUtils.formatCountdown(remaining),
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
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerList(AdjustedPrayerTimes adjusted, DateTime now) {
    final format = DateFormat('hh:mm a');
    final upcoming = _getUpcomingFromAdjusted(adjusted, now);
    final colors = context.colors;

    final prayersList = [
      {'prayer': Prayer.fajr, 'name': Prayer.fajr.ar, 'time': adjusted.fajr},
      {'prayer': Prayer.sunrise, 'name': Prayer.sunrise.ar, 'time': adjusted.sunrise},
      {'prayer': Prayer.dhuhr, 'name': Prayer.dhuhr.ar, 'time': adjusted.dhuhr},
      {'prayer': Prayer.asr, 'name': Prayer.asr.ar, 'time': adjusted.asr},
      {'prayer': Prayer.maghrib, 'name': Prayer.maghrib.ar, 'time': adjusted.maghrib},
      {'prayer': Prayer.isha, 'name': Prayer.isha.ar, 'time': adjusted.isha},
    ];

    final adhanAlertsEnabled = ref.watch(adhanAlertsProvider);

    // .select() extracts a Dart-3 record of 5 booleans (one per tracked prayer).
    // Records have structural equality, so Riverpod skips rebuilds when no
    // prayer completion status actually changed — even if other PrayerDailyProgress
    // fields (e.g. history) update.
    final completions = ref.watch(
      prayerDailyProgressProvider.select(
        (p) => (
          p.isCompleted(Prayer.fajr),
          p.isCompleted(Prayer.dhuhr),
          p.isCompleted(Prayer.asr),
          p.isCompleted(Prayer.maghrib),
          p.isCompleted(Prayer.isha),
        ),
      ),
    );

    bool checkCompleted(Prayer prayer) => switch (prayer) {
      Prayer.fajr => completions.$1,
      Prayer.dhuhr => completions.$2,
      Prayer.asr => completions.$3,
      Prayer.maghrib => completions.$4,
      Prayer.isha => completions.$5,
      _ => false,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: prayersList.map((p) {
          final prayerType = p['prayer'] as Prayer;
          final isActive = prayerType == upcoming.prayer;
          final isTrackable = PrayerDailyProgress.trackedPrayers.contains(
            prayerType,
          );
          final isCompleted = isTrackable && checkCompleted(prayerType);
          final time = format.format((p['time'] as DateTime).toLocal());
          final timeStrAr = ArabicUtils.ensureLatinDigits(
            time.replaceAll('AM', 'ص').replaceAll('PM', 'م'),
          );

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.green.withValues(alpha: 0.12)
                  : isActive
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : colors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCompleted
                    ? Colors.green.withValues(alpha: 0.45)
                    : isActive
                    ? AppColors.primary.withValues(alpha: 0.35)
                    : colors.borderSubtle,
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
                          : colors.iconSecondary,
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
                            : colors.textPrimary,
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
                            : colors.textSecondary,
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
                                : colors.iconSecondary,
                            size: 22,
                          ),
                        ),
                      ),
                    if (isTrackable) const SizedBox(width: 8),
                    Icon(
                      adhanAlertsEnabled ? Icons.volume_up : Icons.volume_off,
                      color: adhanAlertsEnabled
                          ? AppColors.primary
                          : colors.iconSecondary,
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
    final sheetColors = context.colors;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: sheetColors.surfaceCard,
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
                  color: sheetColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'عند تفعيلها سيتم تنبيهك داخل التطبيق عند دخول وقت الصلاة القادمة.',
                style: GoogleFonts.tajawal(
                  fontSize: 13,
                  color: sheetColors.textSecondary,
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
                        color: sheetColors.textPrimary,
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
          'حان الآن وقت ${prayer.ar}',
          style: GoogleFonts.tajawal(),
        ),
      ),
    );
  }

}
