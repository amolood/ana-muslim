import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'quran_service.dart';

/// Manages the home-screen Quran verse and prayer widgets.
///
/// Call [initialize] once after [QuranLibrary.init()] completes.
/// The widget automatically shows a new verse on each screen unlock (Android).
class WidgetService {
  // home_widget's updateWidget(androidName:) prepends context.packageName
  // automatically, so pass only the simple class name here.
  static const _androidQuranProvider = 'QuranWidgetProvider';
  static const _androidPrayerProvider = 'PrayerWidgetProvider';
  static const _androidTransparentProvider = 'TransparentWidgetProvider';
  static const _androidDateProvider = 'DateWidgetProvider';
  static const _androidHijriMonthProvider = 'HijriMonthWidgetProvider';

  // Number of verses to pre-save so the widget can cycle without Flutter running
  static const _versePoolSize = 60;

  // Throttle: prayer widget updates at most once per 60 seconds
  static DateTime? _lastPrayerUpdate;
  static const _prayerUpdateInterval = Duration(seconds: 60);

  // Track last prayer name to force update on prayer change
  static String? _lastPrayerName;

  /// Initialise widget and save a fresh pool of random verses.
  static Future<void> initialize() async {
    try {
      // Only set defaults if not already configured (avoid overwriting user settings)
      final currentFormat = await HomeWidget.getWidgetData<String>('numberFormat');
      final currentUse12h = await HomeWidget.getWidgetData<bool>('use12h');
      await Future.wait([
        if (currentFormat == null)
          HomeWidget.saveWidgetData<String>('numberFormat', 'arabic'),
        if (currentUse12h == null)
          HomeWidget.saveWidgetData<bool>('use12h', true),
        _saveRandomVerses(),
      ]);
    } catch (e) {
      if (kDebugMode) debugPrint('[WidgetService] init error: $e');
    }
  }

  /// Sync all prayer times + date info to home screen widgets.
  ///
  /// [allPrayerTimes] is a map of prayer name to its raw 24h time (e.g. "05:30").
  /// Throttled to at most once every 60 seconds, unless the next prayer changes.
  static Future<void> updatePrayerWidgets({
    required String hijriDate,
    required String gregorianDate,
    required String dayName,
    required String nextPrayerName,
    required String nextPrayerTime,
    required String countdown,
    required Map<String, String> allPrayerTimes,
    int hijriMonthNumber = 0,
    String hijriMonthName = '',
    String? textColor,
  }) async {
    // Throttle: skip if we updated recently AND the prayer hasn't changed
    final now = DateTime.now();
    final prayerChanged = _lastPrayerName != nextPrayerName;
    if (!prayerChanged &&
        _lastPrayerUpdate != null &&
        now.difference(_lastPrayerUpdate!) < _prayerUpdateInterval) {
      return;
    }

    try {
      await Future.wait([
        // ── All 5 raw prayer times (for the new PrayerWidgetProvider) ──
        HomeWidget.saveWidgetData<String>(
          'fajr_raw',
          allPrayerTimes['fajr'] ?? '--:--',
        ),
        HomeWidget.saveWidgetData<String>(
          'dhuhr_raw',
          allPrayerTimes['dhuhr'] ?? '--:--',
        ),
        HomeWidget.saveWidgetData<String>(
          'asr_raw',
          allPrayerTimes['asr'] ?? '--:--',
        ),
        HomeWidget.saveWidgetData<String>(
          'maghrib_raw',
          allPrayerTimes['maghrib'] ?? '--:--',
        ),
        HomeWidget.saveWidgetData<String>(
          'isha_raw',
          allPrayerTimes['isha'] ?? '--:--',
        ),

        // ── Date info (for DateWidgetProvider + TransparentWidgetProvider) ──
        HomeWidget.saveWidgetData<String>('hijri_date', hijriDate),
        HomeWidget.saveWidgetData<String>('gregorian_date', gregorianDate),
        HomeWidget.saveWidgetData<String>('day_name', dayName),
        HomeWidget.saveWidgetData<String>(
          'next_prayer_name',
          nextPrayerName,
        ),
        HomeWidget.saveWidgetData<String>(
          'next_prayer_time',
          nextPrayerTime,
        ),
        HomeWidget.saveWidgetData<String>('prayer_countdown', countdown),

        // ── Simplified keys for TransparentWidgetProvider ──
        HomeWidget.saveWidgetData<String>(
          'hijri_simple',
          hijriDate.split(' ').take(2).join(' '),
        ),
        HomeWidget.saveWidgetData<String>('gregorian_simple', gregorianDate),
        HomeWidget.saveWidgetData<String>(
          'next_prayer_name_simple',
          nextPrayerName.replaceAll('صلاة ', ''),
        ),

        // ── Hijri month (for HijriMonthWidgetProvider) ──
        if (hijriMonthNumber > 0)
          HomeWidget.saveWidgetData<int>(
            'hijri_month_number',
            hijriMonthNumber,
          ),
        if (hijriMonthName.isNotEmpty)
          HomeWidget.saveWidgetData<String>(
            'hijri_month_name',
            hijriMonthName,
          ),

        if (textColor != null)
          HomeWidget.saveWidgetData<String>('widget_text_color', textColor),
      ]);

      // Update all prayer/date widgets in parallel
      await Future.wait([
        HomeWidget.updateWidget(androidName: _androidPrayerProvider),
        HomeWidget.updateWidget(androidName: _androidTransparentProvider),
        HomeWidget.updateWidget(androidName: _androidDateProvider),
        HomeWidget.updateWidget(androidName: _androidHijriMonthProvider),
      ]);

      _lastPrayerUpdate = now;
      _lastPrayerName = nextPrayerName;
    } catch (e) {
      if (kDebugMode) debugPrint('[WidgetService] prayer sync error: $e');
    }
  }

  static Future<void> _saveRandomVerses() async {
    try {
      final random = Random();
      int saved = 0;
      final futures = <Future<bool?>>[];

      for (int i = 0; i < _versePoolSize; i++) {
        final surahNum = random.nextInt(114) + 1;
        final ayahCount = QuranService.getVerseCount(surahNum);
        if (ayahCount == 0) continue;

        final ayahNum = random.nextInt(ayahCount) + 1;
        final text = QuranService.getVerse(surahNum, ayahNum);
        if (text.isEmpty) continue;

        final surahName = QuranService.getSurahNameArabicNormalized(surahNum);
        final ref = 'سورة $surahName • آية $ayahNum';

        futures.add(
          HomeWidget.saveWidgetData<String>('verse_text_$saved', text),
        );
        futures.add(
          HomeWidget.saveWidgetData<String>('verse_ref_$saved', ref),
        );
        saved++;
      }

      if (saved > 0) {
        futures.add(HomeWidget.saveWidgetData<int>('verse_count', saved));
        await Future.wait(futures);
        await HomeWidget.updateWidget(androidName: _androidQuranProvider);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[WidgetService] save error: $e');
    }
  }
}
