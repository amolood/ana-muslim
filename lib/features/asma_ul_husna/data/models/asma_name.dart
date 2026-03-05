class AsmaName {
  final int number;

  /// Arabic name with full diacritics.
  final String arabic;

  /// English transliteration (e.g. "Ar-Rahmaan").
  final String transliteration;

  /// Short English meaning (e.g. "The Beneficent").
  final String meaningEn;

  /// Arabic explanation / meaning.
  final String meaningAr;

  const AsmaName({
    required this.number,
    required this.arabic,
    required this.transliteration,
    required this.meaningEn,
    required this.meaningAr,
  });
}
