import 'package:quran_library/quran_library.dart';

class QuranService {
  static const String basmala = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';

  static QuranCtrl get _ctrl => QuranLibrary.quranCtrl;

  static List<SurahModel> get _surahs => _ctrl.state.surahs;

  static int get surahCount => _surahs.isEmpty ? 114 : _surahs.length;

  static int get totalPagesCount {
    final pages = _ctrl.state.pages.length;
    return pages == 0 ? 604 : pages;
  }

  static bool _isValidSurah(int surahNumber) {
    return surahNumber >= 1 && surahNumber <= surahCount;
  }

  static bool _isValidAyah(int surahNumber, int ayahNumber) {
    if (!_isValidSurah(surahNumber)) {
      return false;
    }
    return ayahNumber >= 1 && ayahNumber <= getVerseCount(surahNumber);
  }

  static String getSurahNameArabic(int surahNumber) {
    if (!_isValidSurah(surahNumber)) {
      return '';
    }
    return _surahs[surahNumber - 1].arabicName;
  }

  static String getSurahName(int surahNumber) {
    if (!_isValidSurah(surahNumber)) {
      return '';
    }
    return _surahs[surahNumber - 1].englishName;
  }

  static int getVerseCount(int surahNumber) {
    if (!_isValidSurah(surahNumber)) {
      return 0;
    }
    return _surahs[surahNumber - 1].ayahs.length;
  }

  static String getPlaceOfRevelation(int surahNumber) {
    if (!_isValidSurah(surahNumber)) {
      return '';
    }

    final revelationType = _surahs[surahNumber - 1].revelationType ?? '';
    final lower = revelationType.toLowerCase();
    if (lower.contains('mad')) {
      return 'Madinah';
    }
    return 'Makkah';
  }

  static String getVerse(
    int surahNumber,
    int ayahNumber, {
    bool verseEndSymbol = false,
  }) {
    if (!_isValidAyah(surahNumber, ayahNumber)) {
      return '';
    }
    final ayah = _ctrl.getSingleAyahByAyahAndSurahNumber(ayahNumber, surahNumber);
    final text = ayah.text.trim();
    if (!verseEndSymbol) {
      return text;
    }
    return '$text ﴿$ayahNumber﴾';
  }

  static int getPageNumber(int surahNumber, int ayahNumber) {
    if (!_isValidAyah(surahNumber, ayahNumber)) {
      return 1;
    }
    return _ctrl.getPageNumberByAyahAndSurahNumber(ayahNumber, surahNumber);
  }

  static int getJuzNumber(int surahNumber, int ayahNumber) {
    if (!_isValidAyah(surahNumber, ayahNumber)) {
      return 1;
    }
    final ayah = _ctrl.getSingleAyahByAyahAndSurahNumber(ayahNumber, surahNumber);
    return ayah.juz;
  }

  static int getAyahUniqueNumber(int surahNumber, int ayahNumber) {
    if (!_isValidAyah(surahNumber, ayahNumber)) {
      return 1;
    }
    final ayah = _ctrl.getSingleAyahByAyahAndSurahNumber(ayahNumber, surahNumber);
    return ayah.ayahUQNumber;
  }
}
