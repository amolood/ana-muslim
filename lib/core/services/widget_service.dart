import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'quran_service.dart';

/// Manages the home-screen Quran verse and prayer widgets.
///
/// Call [initialize] once after [QuranLibrary.init()] completes.
/// The widget automatically shows a new verse on each screen unlock (Android).
class WidgetService {
  static const _androidQuranProvider = 'QuranWidgetProvider';
  static const _androidPrayerProvider = 'PrayerWidgetProvider';
  static const _androidTransparentProvider = 'TransparentWidgetProvider';

  // Number of verses to pre-save so the widget can cycle without Flutter running
  static const _versePoolSize = 60;

  /// Initialise widget and save a fresh pool of random verses.
  static Future<void> initialize() async {
    try {
      await _saveRandomVerses();
    } catch (e) {
      if (kDebugMode) debugPrint('[WidgetService] init error: $e');
    }
  }

  /// Sync prayer and date info to home screen widgets.
  static Future<void> updatePrayerWidgets({
    required String hijriDate,
    required String gregorianDate,
    required String dayName,
    required String nextPrayerName,
    required String nextPrayerTime,
    required String countdown,
    String? textColor,
  }) async {
    try {
      // Full details for Prayer Card
      await HomeWidget.saveWidgetData<String>('hijri_date', hijriDate);
      await HomeWidget.saveWidgetData<String>('gregorian_date', gregorianDate);
      await HomeWidget.saveWidgetData<String>(
        'next_prayer_name',
        nextPrayerName,
      );
      await HomeWidget.saveWidgetData<String>(
        'next_prayer_time',
        nextPrayerTime,
      );
      await HomeWidget.saveWidgetData<String>('prayer_countdown', countdown);

      // Simplified for Transparent Widget
      await HomeWidget.saveWidgetData<String>('day_name', dayName);
      await HomeWidget.saveWidgetData<String>(
        'hijri_simple',
        hijriDate.split(' ').take(2).join(' '),
      );
      await HomeWidget.saveWidgetData<String>(
        'gregorian_simple',
        gregorianDate,
      );
      await HomeWidget.saveWidgetData<String>(
        'next_prayer_name_simple',
        nextPrayerName.replaceAll('صلاة ', ''),
      );

      if (textColor != null) {
        await HomeWidget.saveWidgetData<String>('widget_text_color', textColor);
      }

      await HomeWidget.updateWidget(androidName: _androidPrayerProvider);
      await HomeWidget.updateWidget(androidName: _androidTransparentProvider);
    } catch (e) {
      if (kDebugMode) debugPrint('[WidgetService] prayer sync error: $e');
    }
  }

  static Future<void> _saveRandomVerses() async {
    try {
      final random = Random();
      int saved = 0;

      for (int i = 0; i < _versePoolSize; i++) {
        final surahNum = random.nextInt(114) + 1;
        final ayahCount = QuranService.getVerseCount(surahNum);
        if (ayahCount == 0) continue;

        final ayahNum = random.nextInt(ayahCount) + 1;
        final text = QuranService.getVerse(surahNum, ayahNum);
        if (text.isEmpty) continue;

        final surahName = QuranService.getSurahNameArabicNormalized(surahNum);
        final ref = 'سورة $surahName • آية $ayahNum';

        await HomeWidget.saveWidgetData<String>('verse_text_$saved', text);
        await HomeWidget.saveWidgetData<String>('verse_ref_$saved', ref);
        saved++;
      }

      if (saved > 0) {
        await HomeWidget.saveWidgetData<int>('verse_count', saved);
        // Don't reset verse_index so the widget resumes from where it was
        await HomeWidget.updateWidget(androidName: _androidQuranProvider);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[WidgetService] save error: $e');
    }
  }
}
