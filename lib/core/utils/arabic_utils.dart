class ArabicUtils {
  ArabicUtils._();

  static const String _latinDigits = '0123456789';
  static const String _arabicDigits = '٠١٢٣٤٥٦٧٨٩';

  static String toArabicDigitsFromText(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      final char = String.fromCharCode(rune);
      final index = _latinDigits.indexOf(char);
      buffer.write(index >= 0 ? _arabicDigits[index] : char);
    }
    return buffer.toString();
  }

  static String toArabicDigits(num value) {
    return toArabicDigitsFromText(value.toString());
  }

  static String formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return toArabicDigitsFromText('$minutes:$seconds');
  }
}
