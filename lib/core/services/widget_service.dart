import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import 'quran_service.dart';

/// Manages the home-screen Quran verse widget.
///
/// Call [initialize] once after [QuranLibrary.init()] completes.
/// The widget automatically shows a new verse on each screen unlock (Android).
class WidgetService {
  static const _androidProviderName = 'QuranWidgetProvider';

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
        final ref = 'سورة $surahName • آية ${_toArabicNumber(ayahNum)}';

        await HomeWidget.saveWidgetData<String>('verse_text_$saved', text);
        await HomeWidget.saveWidgetData<String>('verse_ref_$saved', ref);
        saved++;
      }

      if (saved > 0) {
        await HomeWidget.saveWidgetData<int>('verse_count', saved);
        // Don't reset verse_index so the widget resumes from where it was
        await HomeWidget.updateWidget(androidName: _androidProviderName);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[WidgetService] save error: $e');
    }
  }

  static String _toArabicNumber(int number) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var value = number.toString();
    for (var i = 0; i < english.length; i++) {
      value = value.replaceAll(english[i], arabic[i]);
    }
    return value;
  }
}
