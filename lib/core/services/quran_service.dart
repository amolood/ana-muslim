import 'package:quran_library/quran_library.dart';

class QuranService {
  static const String basmala = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';
  static const List<String> _latinDigits = <String>[
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
  ];
  static const List<String> _arabicDigits = <String>[
    '٠',
    '١',
    '٢',
    '٣',
    '٤',
    '٥',
    '٦',
    '٧',
    '٨',
    '٩',
  ];
  static const Set<int> _knownMadinanSurahs = <int>{
    2,
    3,
    4,
    5,
    8,
    9,
    13,
    22,
    24,
    33,
    47,
    48,
    49,
    55,
    57,
    58,
    59,
    60,
    61,
    62,
    63,
    64,
    65,
    66,
    76,
    98,
    99,
    110,
  };
  static const List<String> _surahNamePrefixes = <String>[
    'سورة ',
    'سُورَةُ ',
    'سُورَة ',
    'سوره ',
  ];
  static final Map<int, List<AyahModel>> _surahAyahsCache =
      <int, List<AyahModel>>{};
  static final Map<int, Map<int, AyahModel>> _ayahByNumberCache =
      <int, Map<int, AyahModel>>{};
  static final Map<int, Set<int>> _surahSajdahAyahsCache = <int, Set<int>>{};
  static final Map<int, List<AyahModel>> _pageAyahsCache =
      <int, List<AyahModel>>{};
  static final Map<int, int> _firstPageByJuzCache = <int, int>{};

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
    if (!_isValidSurah(surahNumber) || surahNumber > _surahs.length) {
      return '';
    }
    return _surahs[surahNumber - 1].arabicName;
  }

  static String normalizeSurahName(String raw) {
    final trimmed = raw.trim();
    for (final prefix in _surahNamePrefixes) {
      if (trimmed.startsWith(prefix)) {
        return trimmed.substring(prefix.length).trim();
      }
    }
    return trimmed;
  }

  static String getSurahNameArabicNormalized(int surahNumber) {
    return normalizeSurahName(getSurahNameArabic(surahNumber));
  }

  static String getSurahName(int surahNumber) {
    if (!_isValidSurah(surahNumber) || surahNumber > _surahs.length) {
      return '';
    }
    return _surahs[surahNumber - 1].englishName;
  }

  static int getVerseCount(int surahNumber) {
    if (!_isValidSurah(surahNumber) || surahNumber > _surahs.length) {
      return 0;
    }
    return _surahs[surahNumber - 1].ayahs.length;
  }

  static List<AyahModel> getSurahAyahs(int surahNumber) {
    if (!_isValidSurah(surahNumber) || surahNumber > _surahs.length) {
      return const <AyahModel>[];
    }
    final cached = _surahAyahsCache[surahNumber];
    if (cached != null) {
      return cached;
    }
    final ayahs = List<AyahModel>.unmodifiable(_surahs[surahNumber - 1].ayahs);
    _surahAyahsCache[surahNumber] = ayahs;

    final byNumber = <int, AyahModel>{};
    final sajdahSet = <int>{};
    for (final ayah in ayahs) {
      byNumber[ayah.ayahNumber] = ayah;
      if (_isAyahSajdah(ayah)) {
        sajdahSet.add(ayah.ayahNumber);
      }
    }
    _ayahByNumberCache[surahNumber] = byNumber;
    _surahSajdahAyahsCache[surahNumber] = sajdahSet;
    return ayahs;
  }

  static void preloadSurah(int surahNumber) {
    if (!_isValidSurah(surahNumber) || surahNumber > _surahs.length) {
      return;
    }
    final ayahs = getSurahAyahs(surahNumber);
    if (ayahs.isEmpty) return;
    final firstAyah = ayahs.first;
    final lastAyah = ayahs.last;
    try {
      _pageAyahsCache[firstAyah.page] ??= List<AyahModel>.unmodifiable(
        _ctrl.getPageAyahsByIndex(firstAyah.page - 1),
      );
      _pageAyahsCache[lastAyah.page] ??= List<AyahModel>.unmodifiable(
        _ctrl.getPageAyahsByIndex(lastAyah.page - 1),
      );
    } catch (_) {
      // Safe no-op: preload is best-effort only.
    }
  }

  static void preloadPage(int pageNumber) {
    getPageAyahs(pageNumber);
  }

  static String getPlaceOfRevelation(int surahNumber) {
    if (!_isValidSurah(surahNumber) || surahNumber > _surahs.length) {
      return '';
    }

    final revelationType = (_surahs[surahNumber - 1].revelationType ?? '')
        .trim()
        .toLowerCase();

    if (revelationType.contains('med') ||
        revelationType.contains('mad') ||
        revelationType.contains('مدن')) {
      return 'Madinah';
    }
    if (revelationType.contains('mak') ||
        revelationType.contains('mek') ||
        revelationType.contains('مك')) {
      return 'Makkah';
    }

    // Defensive fallback for datasets that omit revelationType.
    return _knownMadinanSurahs.contains(surahNumber) ? 'Madinah' : 'Makkah';
  }

  static String getVerse(
    int surahNumber,
    int ayahNumber, {
    bool verseEndSymbol = false,
  }) {
    final ayah = _getAyah(surahNumber, ayahNumber);
    if (ayah == null) {
      return '';
    }
    final text = ayah.text.trim();
    if (!verseEndSymbol) {
      return text;
    }
    return '$text ﴿${_toArabicDigits(ayahNumber)}﴾';
  }

  static int getPageNumber(int surahNumber, int ayahNumber) {
    final ayah = _getAyah(surahNumber, ayahNumber);
    if (ayah == null) {
      return 1;
    }
    return clampPage(ayah.page);
  }

  static int getJuzNumber(int surahNumber, int ayahNumber) {
    final ayah = _getAyah(surahNumber, ayahNumber);
    if (ayah == null) {
      return 1;
    }
    return ayah.juz;
  }

  static int clampPage(int pageNumber) {
    return pageNumber.clamp(1, totalPagesCount);
  }

  static List<AyahModel> getPageAyahs(int pageNumber) {
    final page = clampPage(pageNumber);
    final cached = _pageAyahsCache[page];
    if (cached != null) return cached;
    try {
      final ayahs = List<AyahModel>.unmodifiable(
        _ctrl.getPageAyahsByIndex(page - 1),
      );
      _pageAyahsCache[page] = ayahs;
      return ayahs;
    } catch (_) {
      return const <AyahModel>[];
    }
  }

  static int getFirstAyahNumberOnPage(int pageNumber) {
    final ayahs = getPageAyahs(pageNumber);
    if (ayahs.isEmpty) return 1;
    return ayahs.first.ayahNumber;
  }

  static int getSurahNumberFromPage(int pageNumber) {
    final ayahs = getPageAyahs(pageNumber);
    if (ayahs.isEmpty) return 1;
    final surah = ayahs.first.surahNumber;
    return (surah == null || surah <= 0) ? 1 : surah;
  }

  static int getJuzByPage(int pageNumber) {
    final ayahs = getPageAyahs(pageNumber);
    if (ayahs.isEmpty) return 1;
    return ayahs.first.juz;
  }

  static List<SurahModel> getSurahsByPage(int pageNumber) {
    final page = clampPage(pageNumber);
    try {
      return _ctrl.getSurahsByPageNumber(page);
    } catch (_) {
      return const <SurahModel>[];
    }
  }

  static String getPageTitle(int pageNumber) {
    final page = clampPage(pageNumber);
    final surahNumber = getSurahNumberFromPage(page);
    final normalizedName = getSurahNameArabicNormalized(surahNumber);
    if (normalizedName.isEmpty) {
      return 'الصفحة $page';
    }
    return normalizedName;
  }

  static int getFirstPageForJuz(int juzNumber) {
    final clampedJuz = juzNumber.clamp(1, 30);
    final cached = _firstPageByJuzCache[clampedJuz];
    if (cached != null) {
      return cached;
    }
    for (final ayah in _ctrl.state.allAyahs) {
      if (ayah.juz == clampedJuz) {
        final page = clampPage(ayah.page);
        _firstPageByJuzCache[clampedJuz] = page;
        return page;
      }
    }
    return 1;
  }

  static String getPageText(int pageNumber) {
    final ayahs = getPageAyahs(pageNumber);
    if (ayahs.isEmpty) return '';

    final buffer = StringBuffer();
    int? lastSurahNumber;
    for (final ayah in ayahs) {
      final currentSurah = ayah.surahNumber ?? 0;
      if (lastSurahNumber != null &&
          currentSurah != 0 &&
          currentSurah != lastSurahNumber) {
        buffer.write('  ۞  ');
      }
      buffer
        ..write(ayah.text.trim())
        ..write(' ﴿')
        ..write(_toArabicDigits(ayah.ayahNumber))
        ..write('﴾ ');
      lastSurahNumber = currentSurah;
    }
    return buffer.toString().trim();
  }

  static int getAyahUniqueNumber(int surahNumber, int ayahNumber) {
    final ayah = _getAyah(surahNumber, ayahNumber);
    if (ayah == null) {
      return 1;
    }
    return ayah.ayahUQNumber;
  }

  static bool isSajdahVerse(int surahNumber, int ayahNumber) {
    if (!_isValidAyah(surahNumber, ayahNumber)) {
      return false;
    }
    final set = _surahSajdahAyahsCache[surahNumber];
    if (set != null) {
      return set.contains(ayahNumber);
    }
    getSurahAyahs(surahNumber);
    return _surahSajdahAyahsCache[surahNumber]?.contains(ayahNumber) ?? false;
  }

  static bool surahHasSajdah(int surahNumber) {
    if (!_isValidSurah(surahNumber) || surahNumber > _surahs.length) {
      return false;
    }
    final set = _surahSajdahAyahsCache[surahNumber];
    if (set != null) return set.isNotEmpty;
    getSurahAyahs(surahNumber);
    return (_surahSajdahAyahsCache[surahNumber] ?? const <int>{}).isNotEmpty;
  }

  static AyahModel? _getAyah(int surahNumber, int ayahNumber) {
    if (!_isValidAyah(surahNumber, ayahNumber)) {
      return null;
    }
    final byNumber = _ayahByNumberCache[surahNumber];
    if (byNumber != null) {
      return byNumber[ayahNumber];
    }
    getSurahAyahs(surahNumber);
    return _ayahByNumberCache[surahNumber]?[ayahNumber];
  }

  static bool _isAyahSajdah(AyahModel ayah) {
    if (ayah.sajdaBool == true) {
      return true;
    }

    final dynamic sajda = ayah.sajda;
    if (sajda == null || sajda == false) {
      return false;
    }

    if (sajda is Map) {
      return sajda['recommended'] == true || sajda['obligatory'] == true;
    }

    if (sajda is bool) {
      return sajda;
    }

    return true;
  }

  static String _toArabicDigits(int value) {
    var input = value.toString();
    for (var i = 0; i < _latinDigits.length; i++) {
      input = input.replaceAll(_latinDigits[i], _arabicDigits[i]);
    }
    return input;
  }
}
