import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/services/quran_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/prayer_utils.dart';
import '../../../prayer_times/presentation/providers/prayer_times_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _timer;
  DateTime _currentTime = DateTime.now();

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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildNextPrayerCard(ref),
              const SizedBox(height: 32),
              _buildQuickActions(context),
              const SizedBox(height: 32),
              _buildVerseOfTheDay(context, ref),
              const SizedBox(height: 32),
              _buildContinueReading(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    HijriCalendar.setLocal('ar');
    final hijri = HijriCalendar.now();
    final gregorian = DateFormat('EEEE، d MMMM yyyy', 'ar').format(DateTime.now());
    final hijriText = '${_toArabicNumber(hijri.hDay)} ${hijri.longMonthName} ${_toArabicNumber(hijri.hYear)} هـ';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'التاريخ اليوم',
              style: GoogleFonts.tajawal(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hijriText,
              style: GoogleFonts.tajawal(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              gregorian,
              style: GoogleFonts.tajawal(
                fontSize: 14,
                color: AppColors.textSecondaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextPrayerCard(WidgetRef ref) {
    final prayerTimesAsync = ref.watch(prayerTimesProvider);
    final locationNameAsync = ref.watch(locationNameProvider);

    return prayerTimesAsync.when(
      data: (prayerTimes) {
        final upcoming = PrayerUtils.getUpcomingPrayer(prayerTimes, _currentTime);
        final remaining = PrayerUtils.getRemainingTime(upcoming.time, _currentTime);
        final countdownStr = _formatDuration(remaining);

        return locationNameAsync.when(
          data: (locName) => _buildHeroCardContent(
            locName,
            _getPrayerNameArabic(upcoming.prayer),
            countdownStr,
          ),
          loading: () => _buildHeroCardContent(
            'جاري تحديد الموقع',
            _getPrayerNameArabic(upcoming.prayer),
            countdownStr,
          ),
          error: (_, stackTrace) => _buildHeroCardContent(
            'موقع غير معروف',
            _getPrayerNameArabic(upcoming.prayer),
            countdownStr,
          ),
        );
      },
      loading: () => _buildHeroCardContent('جاري التحميل', '...', '00:00:00'),
      error: (_, stackTrace) => _buildHeroCardContent('خطأ', 'غير متاح', '--:--:--'),
    );
  }

  Widget _buildHeroCardContent(String location, String prayerName, String countdown) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 192,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: const DecorationImage(
            image: NetworkImage(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuB6KxZxa16dutls65VR4QpbI_KZtJsLzjlWkVTu0gNqHoI0dQ-ZNDN_LRi3bHOJjGoARV5lVjvOdVvoqu1xQ8KNnDivp-DiE4nSTLza8rTkbRQrko2w1Kc45Mc4XvKXZDPeEQI5Fvvvk3h7o5CVtxxqSuDoWQiXtHXcZ-35TEcDNe5sYkHDxOml78SxMjT0rTHfELe9P4KMPdjQxXqsUOwHYwzmS8ah4lLaR615qAtEGmmrApRMmOUV5AMeJ7K8qz300AqgokciiA',
            ),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                AppColors.surfaceDarker,
                AppColors.surfaceDark.withValues(alpha: 0.8),
                Colors.transparent,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDarker.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        'الصلاة القادمة',
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDarker.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.tajawal(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prayerName,
                          style: GoogleFonts.tajawal(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.schedule, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              countdown,
                              style: GoogleFonts.manrope(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.5,
                                color: AppColors.textSecondaryDark,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'متبقي',
                              style: GoogleFonts.tajawal(
                                fontSize: 14,
                                color: AppColors.textSecondaryDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDarker.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.explore,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionItem(context, Icons.menu_book, 'القرآن', '/quran'),
          _buildActionItem(context, Icons.access_time_filled, 'المواقيت', '/prayer-times'),
          _buildActionItem(context, Icons.volunteer_activism, 'الأذكار', '/azkar'),
          _buildActionItem(context, Icons.fiber_smart_record, 'السبحة', '/sebha'),
        ],
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, IconData icon, String label, String routeName) {
    return GestureDetector(
      onTap: () => context.push(routeName),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF32675E)),
            ),
            child: Center(
              child: Icon(icon, color: AppColors.primary, size: 32),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.tajawal(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerseOfTheDay(BuildContext context, WidgetRef ref) {
    final wird = _dailyWirdForToday();
    final verse = QuranService.getVerse(wird.surah, wird.ayah, verseEndSymbol: false);
    final surahName = QuranService.getSurahNameArabic(wird.surah);
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
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: () => context.push('/quran/reader/${wird.surah}?ayah=${wird.ayah}'),
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
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF32675E)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"$verse"',
                  style: GoogleFonts.notoNaskhArabic(
                    fontSize: 22,
                    color: Colors.white,
                    height: 1.9,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'سورة $surahName - آية ${_toArabicNumber(wird.ayah)}',
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => context.push('/quran/reader/${wird.surah}?ayah=${wird.ayah}'),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.play_arrow, color: AppColors.surfaceDarker),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'اقرأ الآن',
                            style: GoogleFonts.tajawal(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
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
                                    '$verse\n\nسورة $surahName - آية ${_toArabicNumber(wird.ayah)}\nمن تطبيق المسلم',
                              ),
                            );
                          },
                          icon: const Icon(Icons.share, color: AppColors.textSecondaryDark, size: 20),
                        ),
                        IconButton(
                          onPressed: () async {
                            await ref.read(favoriteSurahsProvider.notifier).toggle(wird.surah);
                          },
                          icon: Icon(
                            isFavorite ? Icons.bookmark : Icons.bookmark_border,
                            color: isFavorite ? AppColors.primary : AppColors.textSecondaryDark,
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

    final surahName = QuranService.getSurahNameArabic(lastSurah);
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
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => context.push('/quran/reader/$lastSurah'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF32675E)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDarker,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
                              child: Text(
                                'سورة $surahName',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.notoNaskhArabic(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'صفحة ${_toArabicNumber(lastPage)}',
                              style: GoogleFonts.tajawal(
                                fontSize: 12,
                                color: AppColors.textSecondaryDark,
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
                                color: AppColors.surfaceDarker,
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
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.textSecondaryDark,
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
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String numStr = number.toString();
    for (int i = 0; i < english.length; i++) {
      numStr = numStr.replaceAll(english[i], arabic[i]);
    }
    return numStr;
  }
}

class _DailyWird {
  const _DailyWird({
    required this.surah,
    required this.ayah,
  });

  final int surah;
  final int ayah;
}
