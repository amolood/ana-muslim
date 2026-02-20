import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tafsir_library/tafsir_library.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/services/quran_service.dart';

// ─── Tafsir source definitions ────────────────────────────────────────────

/// Maps our internal key → display name (Arabic).
const _tafsirSources = {
  'saadi':      'تفسير السعدي',
  'ibnkatheer': 'تفسير ابن كثير',
  'tabari':     'تفسير الطبري',
  'qurtubi':    'تفسير القرطبي',
  'tafsir-jalalayn': 'تفسير الجلالين',
};

String _tafsirDisplayName(String key) =>
    _tafsirSources[key] ?? 'تفسير السعدي';

// ─── Cache ────────────────────────────────────────────────────────────────

/// Simple LRU-ish cache for tafsir results — keyed by (ayahUQNumber, source).
final _tafsirCache = <String, List<TafsirTableData>>{};
const _kCacheSize = 50;

String _cacheKey(int ayahUQ, String source) => '$ayahUQ|$source';

List<TafsirTableData>? _getCached(int ayahUQ, String source) =>
    _tafsirCache[_cacheKey(ayahUQ, source)];

void _putCache(int ayahUQ, String source, List<TafsirTableData> data) {
  if (_tafsirCache.length >= _kCacheSize) {
    _tafsirCache.remove(_tafsirCache.keys.first);
  }
  _tafsirCache[_cacheKey(ayahUQ, source)] = data;
}

// ─── Provider ─────────────────────────────────────────────────────────────

/// Tafsir data provider keyed by (surah, ayah, ayahUQNumber, source).
typedef TafsirKey = ({int surah, int ayah, int ayahUQ, String source});

final tafsirDataProvider =
    FutureProvider.family<List<TafsirTableData>, TafsirKey>((ref, key) async {
  final cached = _getCached(key.ayahUQ, key.source);
  if (cached != null) return cached;

  // Select the correct tafsir in the library before fetching.
  // Find the entry whose fileName matches our source key.
  final items = TafsirLibrary.tafsirAndTranslationsItems;
  final idx = items.indexWhere((e) => e.fileName == key.source);
  if (idx != -1) {
    TafsirLibrary.tafsirCtrl.radioValue.value = idx;
  }

  // Load the data (for bundled saadi this is instant; others need download).
  await TafsirLibrary.fetchData();

  final results =
      await TafsirLibrary.fetchTafsirAyah(key.ayahUQ);
  _putCache(key.ayahUQ, key.source, results);
  return results;
});

// ─── Sheet ────────────────────────────────────────────────────────────────

/// Opens the tafsir bottom sheet for a specific ayah.
Future<void> showTafsirSheet(
  BuildContext context, {
  required int surahNumber,
  required int ayahNumber,
  required int ayahUQNumber,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => TafsirBottomSheet(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      ayahUQNumber: ayahUQNumber,
    ),
  );
}

// ─── Widget ───────────────────────────────────────────────────────────────

class TafsirBottomSheet extends ConsumerWidget {
  const TafsirBottomSheet({
    super.key,
    required this.surahNumber,
    required this.ayahNumber,
    required this.ayahUQNumber,
  });

  final int surahNumber;
  final int ayahNumber;
  final int ayahUQNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tafsirSource = ref.watch(tafsirSourceProvider);
    final key = (
      surah: surahNumber,
      ayah: ayahNumber,
      ayahUQ: ayahUQNumber,
      source: tafsirSource,
    );
    final tafsirAsync = ref.watch(tafsirDataProvider(key));

    final surahName = QuranService.getSurahNameArabic(surahNumber);
    final ayahText = QuranService.getVerse(
      surahNumber,
      ayahNumber,
      verseEndSymbol: false,
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // ─── Handle bar ───────────────────────────────────────
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // ─── Header ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'سورة $surahName • آية $ayahNumber',
                            style: GoogleFonts.tajawal(
                              fontSize: 14,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _tafsirDisplayName(tafsirSource),
                            style: GoogleFonts.tajawal(
                              fontSize: 12,
                              color: AppColors.textSecondaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Change tafsir source button
                    IconButton(
                      icon: const Icon(Icons.tune, color: AppColors.primary),
                      tooltip: 'تغيير مصدر التفسير',
                      onPressed: () => _showSourcePicker(context, ref),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white12, height: 1),
              // ─── Content ──────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Ayah text
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundDark,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          ayahText,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: GoogleFonts.notoNaskhArabic(
                            fontSize: 22,
                            height: 2.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Tafsir text or loading
                      tafsirAsync.when(
                        data: (items) => _buildTafsirContent(items, tafsirSource),
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        error: (err, _) => _buildErrorState(context, ref, err, key),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTafsirContent(List<TafsirTableData> items, String source) {
    if (items.isEmpty) {
      return _buildEmptyState(source);
    }
    final tafsirText = items.first.tafsirText;
    if (tafsirText.isEmpty) {
      return _buildEmptyState(source);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'التفسير',
              style: GoogleFonts.tajawal(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          tafsirText,
          textAlign: TextAlign.justify,
          textDirection: TextDirection.rtl,
          style: GoogleFonts.tajawal(
            fontSize: 17,
            height: 2.0,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String source) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(Icons.menu_book, color: Colors.white24, size: 48),
          const SizedBox(height: 16),
          Text(
            'لا يوجد تفسير متاح لهذه الآية',
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(color: Colors.white38, fontSize: 15),
          ),
          if (source != 'saadi') ...[
            const SizedBox(height: 8),
            Text(
              'قد يتطلب هذا التفسير تحميلًا — جرّب تفسير السعدي',
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                color: AppColors.textSecondaryDark,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    Object err,
    TafsirKey key,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(Icons.cloud_off, color: Colors.white24, size: 48),
          const SizedBox(height: 16),
          Text(
            'تعذر تحميل التفسير',
            style: GoogleFonts.tajawal(color: Colors.white54, fontSize: 15),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => ref.invalidate(tafsirDataProvider(key)),
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            label: Text(
              'إعادة المحاولة',
              style: GoogleFonts.tajawal(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showSourcePicker(BuildContext context, WidgetRef ref) {
    final current = ref.read(tafsirSourceProvider);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'اختر مصدر التفسير',
                style: GoogleFonts.tajawal(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              ..._tafsirSources.entries.map(
                (entry) => ListTile(
                  title: Text(
                    entry.value,
                    style: GoogleFonts.tajawal(
                      color: entry.key == current
                          ? AppColors.primary
                          : Colors.white,
                      fontWeight: entry.key == current
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  trailing: entry.key == current
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () async {
                    await ref
                        .read(tafsirSourceProvider.notifier)
                        .save(entry.key);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
