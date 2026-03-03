class ArabicUtils {
  ArabicUtils._();

  static const String _latinDigits = '0123456789';
  static const String _arabicDigits = '٠١٢٣٤٥٦٧٨٩';

  static String ensureLatinDigits(String input) {
    var result = input;
    for (var i = 0; i < _arabicDigits.length; i++) {
      result = result.replaceAll(_arabicDigits[i], _latinDigits[i]);
    }
    return result;
  }

  static String toArabicDigitsFromText(String input) {
    // Disabled: Return Latin digits as requested
    return ensureLatinDigits(input);
  }

  static String toArabicDigits(num value) {
    return value.toString();
  }

  /// Formats a duration as `MM:SS`, or `HH:MM:SS` when hours > 0.
  /// Use for audio/video progress where the total length determines the format.
  static String formatDuration(Duration duration) {
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (h > 0) return '${h.toString().padLeft(2, '0')}:$m:$s';
    return '$m:$s';
  }

  /// Formats a duration always as `HH:MM:SS`.
  /// Use for fixed-width countdown timers where layout stability matters.
  static String formatCountdown(Duration duration) {
    final h = duration.inHours.toString().padLeft(2, '0');
    final m = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  /// Normalizes an Arabic string for search/comparison.
  ///
  /// - Unifies alef variants (أ إ آ) → ا
  /// - Unifies tah marbuta (ة) → ه
  /// - Unifies alef maqsura (ى) → ي
  /// - Strips tashkeel (diacritics)
  /// - Collapses repeated whitespace and trims
  static String normalizeArabic(String input) {
    return input
        .toLowerCase()
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll(RegExp(r'[ًٌٍَُِّْ]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
