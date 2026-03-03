import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/services/quran_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../quran/presentation/providers/audio_providers.dart';
import '../../../quran/presentation/widgets/surah_title_text.dart';

/// بطاقة الصوت الجاري تشغيله — تظهر فقط عند وجود صوت نشط
class NowPlayingCard extends ConsumerWidget {
  const NowPlayingCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(quranAudioProvider);
    if (!audioState.hasAudio) return const SizedBox.shrink();

    final surahNumber = audioState.surahNumber ?? 1;
    final surahName = QuranService.getSurahNameArabicNormalized(surahNumber);
    final page = QuranService.getPageNumber(surahNumber, 1);
    final hasDuration =
        audioState.duration != null && audioState.duration!.inSeconds > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () {
          QuranService.preloadSurah(surahNumber);
          QuranService.preloadPage(page);
          context.push(Routes.quranReader(surahNumber, page: page));
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.graphic_eq_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'يعمل الآن',
                          style: GoogleFonts.tajawal(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SurahTitleText(
                          surahName,
                          fontSize: 21,
                          maxLines: 1,
                          textAlign: TextAlign.start,
                        ),
                        Text(
                          audioState.reciter?.name ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: audioState.isLoading
                        ? null
                        : () async {
                            final notifier =
                                ref.read(quranAudioProvider.notifier);
                            if (audioState.isPlaying) {
                              await notifier.pause();
                            } else {
                              await notifier.resume();
                            }
                          },
                    tooltip: audioState.isPlaying ? 'إيقاف مؤقت' : 'تشغيل',
                    icon: Icon(
                      audioState.isPlaying
                          ? Icons.pause_circle_filled_rounded
                          : Icons.play_circle_fill_rounded,
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        ref.read(quranAudioProvider.notifier).stop(),
                    tooltip: 'إيقاف',
                    icon: Icon(
                      Icons.stop_circle_rounded,
                      color: AppColors.textSecondary(context),
                      size: 28,
                    ),
                  ),
                ],
              ),
              if (hasDuration) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 4,
                    value: audioState.progress,
                    backgroundColor: AppColors.surfaceElevated(context),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
