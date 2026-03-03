import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/quran_service.dart';
import '../../../../core/utils/arabic_utils.dart';

/// A single Quran search result (ayah match).
class QuranSearchResult {
  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final String ayahText;
  final int page;
  final int juz;

  const QuranSearchResult({
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.ayahText,
    required this.page,
    required this.juz,
  });
}

/// Current search query driving [quranSearchProvider].
class _QuranSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void update(String v) => state = v;
}

final quranSearchQueryProvider =
    NotifierProvider<_QuranSearchQueryNotifier, String>(
      _QuranSearchQueryNotifier.new,
    );

/// Full-text search across all 6 236 Quran ayahs, keyed by query string.
///
/// Results are memoized by Riverpod — the same query never re-scans the
/// Quran twice within the same provider lifetime.
final quranSearchProvider = FutureProvider.family<List<QuranSearchResult>, String>((
  ref,
  query,
) async {
  final q = query.trim();
  if (q.length < 2) return const [];

  final normalizedQuery = ArabicUtils.normalizeArabic(q);
  final results = <QuranSearchResult>[];

  for (int surahNum = 1; surahNum <= 114; surahNum++) {
    final verseCount = QuranService.getVerseCount(surahNum);
    for (int verseNum = 1; verseNum <= verseCount; verseNum++) {
      final verseText = QuranService.getVerse(
        surahNum,
        verseNum,
        verseEndSymbol: false,
      );
      if (ArabicUtils.normalizeArabic(verseText).contains(normalizedQuery)) {
        results.add(
          QuranSearchResult(
            surahNumber: surahNum,
            surahName: QuranService.getSurahNameArabicNormalized(surahNum),
            ayahNumber: verseNum,
            ayahText: verseText,
            page: QuranService.getPageNumber(surahNum, verseNum),
            juz: QuranService.getJuzNumber(surahNum, verseNum),
          ),
        );
      }
    }
  }

  return results;
});
