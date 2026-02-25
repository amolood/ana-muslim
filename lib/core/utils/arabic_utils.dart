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

  static String formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
