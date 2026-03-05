/// Centralized route path constants and builders for GoRouter navigation.
///
/// Use static constants for simple paths and static methods for
/// parameterized paths (e.g., [quranReader]).
abstract final class Routes {
  // ─── Top-level routes ────────────────────────────────────────────────────

  static const splash = '/';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const quran = '/quran';
  static const qibla = '/qibla';
  static const prayerTimes = '/prayer-times';
  static const azkar = '/azkar';
  static const sebha = '/sebha';
  static const ramadan = '/ramadan';
  static const hadith = '/hadith';
  static const settings = '/settings';

  // ─── Quran sub-routes ────────────────────────────────────────────────────

  static const quranKhatmah = '/quran/khatmah';
  static const quranSearch = '/quran/search';
  static const quranBookmarks = '/quran/bookmarks';
  static const quranTahfeez = '/quran/tahfeez';
  static const quranFontPicker = '/quran/font-picker';

  /// Builds a path to the Quran reader for [surahNumber].
  ///
  /// Optionally scroll to [ayah] or [page] on arrival.
  static String quranReader(int surahNumber, {int? ayah, int? page}) {
    final base = '/quran/reader/$surahNumber';
    final params = <String>[];
    if (ayah != null) params.add('ayah=$ayah');
    if (page != null) params.add('page=$page');
    if (params.isEmpty) return base;
    return '$base?${params.join('&')}';
  }

  // ─── Home sub-routes ─────────────────────────────────────────────────────

  static const worshipStats = '/home/worship-stats';

  // ─── Hadith sub-routes ───────────────────────────────────────────────────

  static const hadithSearch = '/hadith/search';
  static const hadithBook = '/hadith/book';
  static const islamicContent = '/hadith/islamic-content';

  /// Builds a path to the Islamic content list for [type] (e.g. `'showall'`).
  ///
  /// Pass an already-encoded [title] for the query parameter.
  static String islamicContentType(String type, {String? title}) {
    final base = '/hadith/islamic-content/type/$type';
    if (title == null) return base;
    return '$base?title=$title';
  }

  static String islamicContentItem(int id) =>
      '/hadith/islamic-content/item/$id';

  // ─── Settings sub-routes ─────────────────────────────────────────────────

  static const settingsHijri = '/settings/hijri';
  static const settingsNotifications = '/settings/notifications';
  static const settingsPrayerAdjustment = '/settings/prayer-adjustment';
  static const settingsDefaultReciter = '/settings/default-reciter';
  static const settingsPrayerSilence = '/settings/prayer-silence';
  static const settingsWidgets = '/settings/widgets';
  static const settingsLibrary = '/settings/library';

  // ─── Hijri Calendar ───────────────────────────────────────────────────

  static const hijriCalendar = '/hijri-calendar';

  // ─── Asma Al-Husna ────────────────────────────────────────────────────

  static const asmaUlHusna = '/asma-ul-husna';

  // ─── Adhan player ──────────────────────────────────────────────────────

  static const adhanPlayer = '/adhan-player';
}
