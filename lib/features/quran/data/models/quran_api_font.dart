/// A single font entry from the fawazahmed0 Quran API fonts.json
class QuranApiFont {
  const QuranApiFont({
    required this.key,
    required this.name,
    required this.displayName,
    required this.designer,
    required this.ttfUrl,
  });

  /// JSON property key — unique stable identifier (e.g. "amiri-quran-1")
  final String key;

  /// Hyphenated CSS-style name (e.g. "amiri-quran")
  final String name;

  /// Human-readable display name (e.g. "Amiri Quran")
  final String displayName;

  /// Font designer / foundry name
  final String designer;

  /// Direct TTF download URL (jsdelivr CDN)
  final String ttfUrl;

  factory QuranApiFont.fromJson(String key, Map<String, dynamic> json) {
    return QuranApiFont(
      key: key,
      name: (json['name'] as String?) ?? key,
      displayName: (json['font'] as String?) ?? key,
      designer: (json['designer'] as String?) ?? '',
      ttfUrl: (json['ttf'] as String?) ?? '',
    );
  }

  /// Flutter font-family name after registration via FontLoader
  String get flutterFamily => 'quran_api_$key';
}
