import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:quran_library/quran_library.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/permissions/permissions_provider.dart';
import '../../../../core/permissions/permissions_screen.dart';
import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/services/quran_service.dart';
import '../../../../core/services/widget_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/arabic_utils.dart';
import '../../../../core/utils/prayer_utils.dart';
import '../../../khatmah/presentation/providers/khatmah_controller.dart';
import '../providers/worship_stats_provider.dart';
import '../../../prayer_times/presentation/providers/prayer_times_provider.dart';
import '../../../quran/presentation/providers/audio_providers.dart';
import '../../../quran/presentation/widgets/surah_title_text.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  Timer? _timer;
  late final ValueNotifier<DateTime> _clock;
  late final ValueNotifier<DateTime> _todayDate;
  late DateTime _lastDayMarker;
  bool _isAppResumed = true;
  bool _isTabVisible = true;

  static const List<_DailyWird> _dailyWirdPlan = <_DailyWird>[
    _DailyWird(surah: 2, ayah: 255),
    _DailyWird(surah: 36, ayah: 58),
    _DailyWird(surah: 67, ayah: 1),
    _DailyWird(surah: 55, ayah: 13),
    _DailyWird(surah: 3, ayah: 8),
    _DailyWird(surah: 18, ayah: 10),
    _DailyWird(surah: 94, ayah: 5),
    _DailyWird(surah: 33, ayah: 56),
    _DailyWird(surah: 39, ayah: 53),
    _DailyWird(surah: 13, ayah: 28),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final now = DateTime.now();
    _clock = ValueNotifier<DateTime>(now);
    _lastDayMarker = DateTime(now.year, now.month, now.day);
    _todayDate = ValueNotifier<DateTime>(_lastDayMarker);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(prayerDailyProgressProvider.notifier).ensureToday();
      ref.read(sebhaStateProvider.notifier).ensureToday();
      _checkAndShowPermissions();
    });
    _startClockTicker();
  }

  Future<void> _checkAndShowPermissions() async {
    // فحص ما إذا كانت جميع الصلاحيات ممنوحة
    final permissionsAsync = ref.read(permissionsCheckedProvider);
    final allGranted = await permissionsAsync.whenOrNull(
      data: (value) => value,
    );

    if (allGranted == false && mounted) {
      // إظهار شاشة الصلاحيات
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const PermissionsScreen(),
          fullscreenDialog: true,
        ),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _clock.dispose();
    _todayDate.dispose();
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

  void _startClockTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _handleClockTick();
    });
  }

  void _syncTickerState({bool immediateTick = false}) {
    final shouldRun = _isAppResumed && _isTabVisible;
    if (!shouldRun) {
      _timer?.cancel();
      _timer = null;
      return;
    }

    if (immediateTick) {
      _handleClockTick();
    }
    _startClockTicker();
  }

  void _handleTabVisibility(bool visible) {
    if (_isTabVisible == visible) return;
    _isTabVisible = visible;
    _syncTickerState(immediateTick: visible);
  }

  void _handleClockTick() {
    if (!mounted) return;
    final current = DateTime.now();
    _clock.value = current;

    final dayMarker = DateTime(current.year, current.month, current.day);
    if (dayMarker != _lastDayMarker) {
      _lastDayMarker = dayMarker;
      _todayDate.value = dayMarker;
      ref.invalidate(khatmahControllerProvider);
      ref.read(prayerDailyProgressProvider.notifier).ensureToday();
      ref.read(sebhaStateProvider.notifier).ensureToday();
    }
  }

  @override
  Widget build(BuildContext context) {
    _handleTabVisibility(TickerMode.valuesOf(context).enabled);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBrandingHeader(context),
              ValueListenableBuilder<DateTime>(
                valueListenable: _clock,
                builder: (context, now, _) => Consumer(
                  builder: (context, localRef, _) =>
                      _buildDatePrayerCard(localRef, now),
                ),
              ),
              Consumer(
                builder: (context, localRef, _) =>
                    _buildNowPlayingCard(context, localRef),
              ),
              const SizedBox(height: 24),
              _buildQuickActions(context),
              const SizedBox(height: 32),
              _buildMotivationStatsCard(context, ref),
              const SizedBox(height: 24),
              ValueListenableBuilder<DateTime>(
                valueListenable: _todayDate,
                builder: (context, _, _) => _buildVerseOfTheDay(context, ref),
              ),
              const SizedBox(height: 32),
              _buildContinueReading(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandingHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/branding/logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'انا المسلم',
                    style: GoogleFonts.tajawal(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary(context),
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'انا المسلم',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: Icon(
              Icons.settings_outlined,
              color: AppColors.textSecondary(context),
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNowPlayingCard(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(quranAudioProvider);
    if (!audioState.hasAudio) return const SizedBox.shrink();

    final surahNumber = audioState.surahNumber ?? 1;
    final surahName = QuranService.getSurahNameArabicNormalized(surahNumber);
    final page = QuranService.getPageNumber(surahNumber, 1);
    final hasDuration =
        audioState.duration != null && audioState.duration!.inSeconds > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () {
          QuranService.preloadSurah(surahNumber);
          QuranService.preloadPage(page);
          context.push('/quran/reader/$surahNumber?page=$page');
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.graphic_eq_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'يعمل الآن',
                          style: GoogleFonts.tajawal(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SurahTitleText(
                          surahName,
                          fontSize: 21,
                          maxLines: 1,
                          textAlign: TextAlign.start,
                        ),
                        Text(
                          audioState.reciter?.name ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: audioState.isLoading
                        ? null
                        : () async {
                            final notifier = ref.read(
                              quranAudioProvider.notifier,
                            );
                            if (audioState.isPlaying) {
                              await notifier.pause();
                            } else {
                              await notifier.resume();
                            }
                          },
                    icon: Icon(
                      audioState.isPlaying
                          ? Icons.pause_circle_filled_rounded
                          : Icons.play_circle_fill_rounded,
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        ref.read(quranAudioProvider.notifier).stop(),
                    icon: Icon(
                      Icons.stop_circle_rounded,
                      color: AppColors.textSecondary(context),
                      size: 28,
                    ),
                  ),
                ],
              ),
              if (hasDuration) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 4,
                    value: audioState.progress,
                    backgroundColor: AppColors.surfaceElevated(context),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePrayerCard(WidgetRef ref, DateTime now) {
    final prayerTimesAsync = ref.watch(prayerTimesProvider);
    final locationNameAsync = ref.watch(locationNameProvider);
    HijriCalendar.setLocal('ar');
    final hijri = HijriCalendar.now();
    final gregorian = DateFormat('EEEE، d MMMM yyyy', 'ar').format(now);
    final hijriText = '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} هـ';

    return prayerTimesAsync.when(
      data: (prayerTimes) {
        final upcoming = PrayerUtils.getUpcomingPrayer(prayerTimes, now);
        final remaining = PrayerUtils.getRemainingTime(upcoming.time, now);
        final countdownStr = _formatDuration(remaining);

        // Sync to Home Widgets
        WidgetsBinding.instance.addPostFrameCallback((_) {
          WidgetService.updatePrayerWidgets(
            hijriDate: hijriText,
            gregorianDate: gregorian,
            dayName: DateFormat('EEEE', 'ar').format(now),
            nextPrayerName: _getPrayerNameArabic(upcoming.prayer),
            nextPrayerTime: ArabicUtils.ensureLatinDigits(
              DateFormat.jm('ar').format(upcoming.time),
            ),
            countdown: 'متبقي $countdownStr',
          );
        });

        return locationNameAsync.when(
          data: (locName) => _buildDatePrayerCardContent(
            hijriText: hijriText,
            gregorian: gregorian,
            location: locName,
            prayerName: _getPrayerNameArabic(upcoming.prayer),
            countdown: countdownStr,
          ),
          loading: () => _buildDatePrayerCardContent(
            hijriText: hijriText,
            gregorian: gregorian,
            location: 'جاري تحديد الموقع',
            prayerName: _getPrayerNameArabic(upcoming.prayer),
            countdown: countdownStr,
          ),
          error: (_, stackTrace) => _buildDatePrayerCardContent(
            hijriText: hijriText,
            gregorian: gregorian,
            location: 'موقع غير معروف',
            prayerName: _getPrayerNameArabic(upcoming.prayer),
            countdown: countdownStr,
          ),
        );
      },
      loading: () => _buildDatePrayerCardContent(
        hijriText: hijriText,
        gregorian: gregorian,
        location: 'جاري التحميل',
        prayerName: '...',
        countdown: '٠٠:٠٠:٠٠',
      ),
      error: (_, stackTrace) => _buildDatePrayerCardContent(
        hijriText: hijriText,
        gregorian: gregorian,
        location: 'خطأ في الموقع',
        prayerName: 'غير متاح',
        countdown: '--:--:--',
      ),
    );
  }

  Widget _buildDatePrayerCardContent({
    required String hijriText,
    required String gregorian,
    required String location,
    required String prayerName,
    required String countdown,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          // خلفية داكنة بدون تدرج
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1B5A52) // لون داكن في الوضع المظلم
              : AppColors.surfaceLightCard, // لون فاتح في الوضع النهاري
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withValues(alpha: 0.3)
                  : AppColors.primary.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'التاريخ اليوم',
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hijriText,
                        style: GoogleFonts.tajawal(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      Text(
                        gregorian,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.surfaceDarker.withValues(alpha: 0.50)
                          : Colors.white.withValues(alpha: 0.50),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: AppColors.primary,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.tajawal(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Divider(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.14)
                    : AppColors.borderLight.withValues(alpha: 0.3),
                height: 1,
              ),
            ),
            Row(
              children: [
                const Icon(
                  FlutterIslamicIcons.solidPrayer,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'الصلاة القادمة',
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                Text(
                  countdown,
                  style: GoogleFonts.manrope(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : AppColors.textPrimaryLight,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'متبقي',
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                prayerName,
                style: TextStyle(
                  fontFamily: 'KFGQPC Uthmanic Script',
                  fontFamilyFallback: ['naskh'],
                  fontSize: 32,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFFD6B06B)
                      : AppColors.primary,
                  height: 1.15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = <_QuickActionItem>[
      const _QuickActionItem(
        icon: FlutterIslamicIcons.solidQuran,
        label: 'القرآن',
        subtitle: 'قراءة وورد',
        route: '/quran',
        accentColor: Color(0xFF2F9D95),
      ),
      const _QuickActionItem(
        icon: FlutterIslamicIcons.prayer,
        label: 'المواقيت',
        subtitle: 'الصلوات اليوم',
        route: '/prayer-times',
        accentColor: Color(0xFFC4873E),
      ),
      const _QuickActionItem(
        icon: FlutterIslamicIcons.allah99,
        label: 'الأذكار',
        subtitle: 'أذكار يومية',
        route: '/azkar',
        accentColor: Color(0xFF8B8CF2),
      ),
      const _QuickActionItem(
        icon: FlutterIslamicIcons.solidSajadah,
        label: 'السبحة',
        subtitle: 'عدّ الذكر',
        route: '/sebha',
        accentColor: Color(0xFF5DB86F),
      ),
      const _QuickActionItem(
        icon: FlutterIslamicIcons.islam,
        label: 'المحتوى',
        subtitle: 'مكتبة مميزة',
        route: '/hadith/islamic-content',
        accentColor: Color(0xFF3E78B2),
      ),
      const _QuickActionItem(
        icon: Icons.dark_mode_rounded,
        label: 'رمضان',
        subtitle: 'سحور وإفطار',
        route: '/ramadan',
        accentColor: Color(0xFF10B981),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border(context)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.grid_view_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'الوصول السريع',
                    style: GoogleFonts.tajawal(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                ),
                Text(
                  'اختر القسم',
                  style: GoogleFonts.tajawal(
                    fontSize: 11,
                    color: AppColors.textSecondary(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: actions.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                mainAxisExtent: 75,
              ),
              itemBuilder: (context, index) =>
                  _buildActionItem(context, actions[index]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, _QuickActionItem action) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.push(action.route),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: action.accentColor.withValues(alpha: 0.35)),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              action.accentColor.withValues(alpha: 0.2),
              AppColors.surfaceElevated(context),
            ],
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: action.accentColor.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(action.icon, color: action.accentColor, size: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary(context),
                      height: 1.2,
                    ),
                  ),
                  Text(
                    action.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.tajawal(
                      fontSize: 10,
                      color: AppColors.textSecondary(context),
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotivationStatsCard(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(worshipStatsProvider);
    final scorePercent = (stats.overallScore * 100).round();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border(context)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    stats.motivationTitle,
                    style: GoogleFonts.tajawal(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                ),
                Text(
                  '${ArabicUtils.toArabicDigits(scorePercent)}%',
                  style: GoogleFonts.tajawal(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              stats.motivationBody,
              style: GoogleFonts.tajawal(
                fontSize: 13,
                color: AppColors.textSecondary(context),
                height: 1.55,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 7,
                value: stats.overallScore,
                backgroundColor: AppColors.surfaceElevated(context),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _miniMetric(
                  context,
                  icon: FlutterIslamicIcons.quran,
                  text: 'القرآن ${_toArabicNumber(stats.quranLastPage)} / ٦٠٤',
                ),
                const SizedBox(width: 10),
                _miniMetric(
                  context,
                  icon: Icons.self_improvement_rounded,
                  text:
                      'الصلاة ${_toArabicNumber(stats.prayerCompleted)} / ${_toArabicNumber(stats.prayerTotal)}',
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push('/home/worship-stats'),
                icon: const Icon(Icons.insights_rounded),
                label: Text(
                  'عرض الإحصائيات المتقدمة',
                  style: GoogleFonts.tajawal(fontWeight: FontWeight.w800),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniMetric(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border(context).withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.tajawal(
                  fontSize: 11,
                  color: AppColors.textSecondary(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerseOfTheDay(BuildContext context, WidgetRef ref) {
    final khatmahAsync = ref.watch(khatmahControllerProvider);
    return khatmahAsync.maybeWhen(
      data: (viewState) {
        if (viewState.hasActivePlan && viewState.todayFromPage > 0) {
          return _buildKhatmahTodayCard(context, ref, viewState);
        }
        return _buildDailyVerseCard(context, ref);
      },
      orElse: () => _buildDailyVerseCard(context, ref),
    );
  }

  Widget _buildKhatmahTodayCard(
    BuildContext context,
    WidgetRef ref,
    KhatmahViewState viewState,
  ) {
    final fromPage = viewState.todayFromPage;
    final toPage = viewState.todayToPage;
    final totalTodayPages = (toPage - fromPage + 1).clamp(0, 604);
    final completedToday = viewState.completedPagesToday.clamp(
      0,
      totalTodayPages,
    );
    final progress = totalTodayPages == 0
        ? 0.0
        : (completedToday / totalTodayPages).clamp(0.0, 1.0);

    final startSurah = QuranService.getSurahNameArabicNormalized(
      QuranService.getSurahNumberFromPage(fromPage),
    );
    final endSurah = QuranService.getSurahNameArabicNormalized(
      QuranService.getSurahNumberFromPage(toPage),
    );
    final rangeSurahText = startSurah == endSurah
        ? startSurah
        : '$startSurah - $endSurah';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ورد اليوم',
            style: GoogleFonts.tajawal(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'خطة الختمة',
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'من صفحة ${_toArabicNumber(fromPage)} إلى ${_toArabicNumber(toPage)}',
                  style: GoogleFonts.tajawal(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 2),
                SurahTitleText(
                  rangeSurahText,
                  fontSize: 20,
                  maxLines: 1,
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 7,
                    value: progress,
                    backgroundColor: AppColors.surfaceElevated(context),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'أنجزت ${_toArabicNumber(completedToday)} من ${_toArabicNumber(totalTodayPages)} صفحة',
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final surah = QuranService.getSurahNumberFromPage(
                            fromPage,
                          );
                          QuranService.preloadSurah(surah);
                          QuranService.preloadPage(fromPage);
                          context.push('/quran/reader/$surah?page=$fromPage');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.surfaceDarker
                              : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text(
                          'ابدأ ورد اليوم',
                          style: GoogleFonts.tajawal(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final changed = await ref
                              .read(khatmahControllerProvider.notifier)
                              .markTodayCompletedManual();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              content: Text(
                                changed
                                    ? 'تم تعليم ورد اليوم كمكتمل'
                                    : 'لا يوجد ورد متاح لليوم',
                                style: GoogleFonts.tajawal(),
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary(context),
                          side: BorderSide(color: AppColors.border(context)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'إكمال يدوي',
                          style: GoogleFonts.tajawal(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyVerseCard(BuildContext context, WidgetRef ref) {
    final wird = _dailyWirdForToday();
    final verse = QuranService.getVerse(
      wird.surah,
      wird.ayah,
      verseEndSymbol: false,
    );
    final surahName = QuranService.getSurahNameArabicNormalized(wird.surah);
    final favoriteSurahs = ref.watch(favoriteSurahsProvider);
    final isFavorite = favoriteSurahs.contains(wird.surah);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ورد اليوم',
                style: GoogleFonts.tajawal(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
              TextButton(
                onPressed: () {
                  QuranService.preloadSurah(wird.surah);
                  context.push('/quran/reader/${wird.surah}?ayah=${wird.ayah}');
                },
                child: Text(
                  'عرض المزيد',
                  style: GoogleFonts.tajawal(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"$verse"',
                  style: TextStyle(
                    fontFamily: 'KFGQPC Uthmanic Script',
                    fontFamilyFallback: ['naskh'],
                    fontSize: 22,
                    color: AppColors.textPrimary(context),
                    height: 1.9,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$surahName - آية ${_toArabicNumber(wird.ayah)}',
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () async {
                        try {
                          await AudioCtrl.instance.stopRangePlayback();

                          await AudioCtrl.instance.playAyahRange(
                            context: context,
                            surahNumber: wird.surah,
                            startAyah: wird.ayah,
                            endAyah: wird.ayah,
                          );

                          if (context.mounted) {
                            QuranService.preloadSurah(wird.surah);
                            context.push(
                              '/quran/reader/${wird.surah}?ayah=${wird.ayah}',
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('حدث خطأ أثناء التشغيل'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.play_arrow,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.surfaceDarker
                                  : Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'اقرأ الآن',
                            style: GoogleFonts.tajawal(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            SharePlus.instance.share(
                              ShareParams(
                                text:
                                    '$verse\n\n$surahName - آية ${_toArabicNumber(wird.ayah)}\nمن تطبيق المسلم',
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.share,
                            color: AppColors.textSecondary(context),
                            size: 20,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            await ref
                                .read(favoriteSurahsProvider.notifier)
                                .toggle(wird.surah);
                          },
                          icon: Icon(
                            isFavorite ? Icons.bookmark : Icons.bookmark_border,
                            color: isFavorite
                                ? AppColors.primary
                                : AppColors.textSecondary(context),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueReading(BuildContext context, WidgetRef ref) {
    final lastSurah = ref.watch(lastReadSurahProvider);
    final lastPage = ref.watch(lastReadPageProvider);

    if (lastSurah == 0) {
      return const SizedBox.shrink();
    }

    final surahName = QuranService.getSurahNameArabicNormalized(lastSurah);
    final progress = (lastPage / QuranService.totalPagesCount).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'استكمل القراءة',
            style: GoogleFonts.tajawal(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              QuranService.preloadSurah(lastSurah);
              QuranService.preloadPage(lastPage);
              context.push('/quran/reader/$lastSurah?page=$lastPage');
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border(context)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.border(context).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _toArabicNumber(lastPage),
                        style: GoogleFonts.tajawal(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: SurahTitleText(
                                surahName,
                                fontSize: 22,
                                maxLines: 1,
                                textAlign: TextAlign.start,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              flex: 0,
                              child: Text(
                                'صفحة ${_toArabicNumber(lastPage)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.tajawal(
                                  fontSize: 12,
                                  color: AppColors.textSecondary(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return Container(
                              height: 6,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated(context),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  width: constraints.maxWidth * progress,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.textSecondary(context),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _DailyWird _dailyWirdForToday() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    return _dailyWirdPlan[dayOfYear % _dailyWirdPlan.length];
  }

  String _getPrayerNameArabic(Prayer prayer) {
    return switch (prayer) {
      Prayer.fajr => 'صلاة الفجر',
      Prayer.sunrise => 'وقت الشروق',
      Prayer.dhuhr => 'صلاة الظهر',
      Prayer.asr => 'صلاة العصر',
      Prayer.maghrib => 'صلاة المغرب',
      Prayer.isha => 'صلاة العشاء',
      Prayer.none => '--:--',
    };
  }

  String _formatDuration(Duration duration) {
    final hh = duration.inHours.toString().padLeft(2, '0');
    final mm = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final ss = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }

  String _toArabicNumber(int number) {
    // Disabled: Return original Latin digits 1,2,3... as requested by user
    return number.toString();
  }
}

class _DailyWird {
  const _DailyWird({required this.surah, required this.ayah});

  final int surah;
  final int ayah;
}

class _QuickActionItem {
  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.route,
    required this.accentColor,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final String route;
  final Color accentColor;
}
