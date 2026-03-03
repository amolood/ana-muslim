import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/utils/arabic_utils.dart';
import '../../data/models/reciter.dart';
import '../providers/audio_providers.dart';
import 'quran_reciter_tile.dart';

/// Bottom sheet for selecting a Quran reciter and riwaya for audio playback.
class QuranAudioSheet extends ConsumerStatefulWidget {
  const QuranAudioSheet({super.key, required this.surahNumber});

  final int surahNumber;

  @override
  ConsumerState<QuranAudioSheet> createState() => _QuranAudioSheetState();
}

class _QuranAudioSheetState extends ConsumerState<QuranAudioSheet> {
  String _query = '';
  int _searchFieldVersion = 0;

  @override
  Widget build(BuildContext context) {
    final recitersAsync = ref.watch(recitersProvider);
    final audioPlaybackUi = ref.watch(
      quranAudioProvider.select(
        (state) => (
          isPlaying: state.isPlaying,
          isLoading: state.isLoading,
          surahNumber: state.surahNumber,
          reciterId: state.reciter?.id,
          moshafId: state.moshaf?.id,
        ),
      ),
    );
    final defaultReciterId = ref.watch(defaultReciterIdProvider);
    final favoriteReciterIds = ref.watch(favoriteReciterIdsProvider);
    final preferredMoshafMap = ref.watch(preferredReciterMoshafProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.78,
      maxChildSize: 0.94,
      minChildSize: 0.45,
      builder: (ctx, scrollCtrl) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'القراءة الصوتية',
                  style: GoogleFonts.tajawal(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  'اختر القارئ والرواية مرة واحدة، ثم التشغيل يصبح مباشرًا',
                  style: GoogleFonts.tajawal(
                    fontSize: 11,
                    color: context.colors.textSecondary.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: context.colors.borderDefault, height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: TextFormField(
              key: ValueKey(_searchFieldVersion),
              initialValue: _query,
              textDirection: TextDirection.rtl,
              style: GoogleFonts.tajawal(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
              ),
              onChanged: (value) => setState(() => _query = value.trim()),
              decoration: InputDecoration(
                hintText: 'ابحث عن القارئ أو الرواية',
                hintStyle: GoogleFonts.tajawal(
                  color: context.colors.textSecondary,
                  fontSize: 13,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: context.colors.iconSecondary,
                ),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        color: context.colors.iconSecondary,
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          setState(() {
                            _query = '';
                            _searchFieldVersion++;
                          });
                        },
                      ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.colors.borderDefault),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),
          Expanded(
            child: recitersAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              ),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.wifi_off,
                      color: context.colors.textSecondary,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'تعذّر تحميل القراء\nيرجى التحقق من الاتصال بالإنترنت',
                      style: GoogleFonts.tajawal(
                        color: context.colors.textSecondary,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              data: (reciters) {
                final available = reciters
                    .where(
                      (r) => r.moshafsForSurah(widget.surahNumber).isNotEmpty,
                    )
                    .toList();
                final filtered = _filterReciters(available, _query);

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'لا توجد نتائج مطابقة',
                      style: GoogleFonts.tajawal(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  );
                }

                final sorted = _sortReciters(
                  reciters: filtered,
                  defaultReciterId: defaultReciterId,
                  favoriteReciterIds: favoriteReciterIds.toSet(),
                );

                return ListView.builder(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                  itemCount: sorted.length,
                  itemBuilder: (_, i) => QuranReciterTile(
                    reciter: sorted[i],
                    surahNumber: widget.surahNumber,
                    isDefault: sorted[i].id == defaultReciterId,
                    isFavorite: favoriteReciterIds.contains(sorted[i].id),
                    audioIsPlaying: audioPlaybackUi.isPlaying,
                    audioIsLoading: audioPlaybackUi.isLoading,
                    currentAudioSurah: audioPlaybackUi.surahNumber,
                    currentAudioReciterId: audioPlaybackUi.reciterId,
                    currentAudioMoshafId: audioPlaybackUi.moshafId,
                    preferredMoshafId: preferredMoshafMap[sorted[i].id],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Reciter> _filterReciters(List<Reciter> reciters, String query) {
    if (query.isEmpty) return reciters;
    final normalized = ArabicUtils.normalizeArabic(query);
    return reciters.where((reciter) {
      if (ArabicUtils.normalizeArabic(reciter.name).contains(normalized)) {
        return true;
      }
      return reciter.moshaf.any(
        (m) => ArabicUtils.normalizeArabic(m.name).contains(normalized),
      );
    }).toList();
  }

  List<Reciter> _sortReciters({
    required List<Reciter> reciters,
    required int? defaultReciterId,
    required Set<int> favoriteReciterIds,
  }) {
    final defaultItems =
        reciters.where((r) => r.id == defaultReciterId).toList();
    final favoriteItems = reciters
        .where(
          (r) =>
              r.id != defaultReciterId && favoriteReciterIds.contains(r.id),
        )
        .toList();
    final regularItems = reciters
        .where(
          (r) =>
              r.id != defaultReciterId && !favoriteReciterIds.contains(r.id),
        )
        .toList();
    return [...defaultItems, ...favoriteItems, ...regularItems];
  }
}
