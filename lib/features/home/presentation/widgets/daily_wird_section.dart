import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_library/quran_library.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/services/quran_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../khatmah/presentation/providers/khatmah_controller.dart';
import '../../../quran/presentation/widgets/surah_title_text.dart';

/// قسم ورد اليوم — يعرض خطة الختمة إذا كانت نشطة، وإلا آية اليوم
class DailyWirdSection extends ConsumerWidget {
  const DailyWirdSection({super.key});

  // خطة الأوراد اليومية — تدور على مدار العام
  static const List<_DailyWird> _dailyWirdPlan = <_DailyWird>[
    _DailyWird(surah: 2, ayah: 255),
    _DailyWird(surah: 36, ayah: 58),
    _DailyWird(surah: 67, ayah: 1),
    _DailyWird(surah: 55, ayah: 13),
    _DailyWird(surah: 3, ayah: 8),
    _DailyWird(surah: 18, ayah: 10),
    _DailyWird(surah: 94, ayah: 5),
    _DailyWird(surah: 33, ayah: 56),
    _DailyWird(surah: 39, ayah: 53),
    _DailyWird(surah: 13, ayah: 28),
  ];

  static _DailyWird _dailyWirdForToday() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    return _dailyWirdPlan[dayOfYear % _dailyWirdPlan.length];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final khatmahAsync = ref.watch(khatmahControllerProvider);
    return khatmahAsync.maybeWhen(
      data: (viewState) {
        if (viewState.hasActivePlan && viewState.todayFromPage > 0) {
          return _buildKhatmahTodayCard(context, ref, viewState);
        }
        return _buildDailyVerseCard(context, ref);
      },
      orElse: () => _buildDailyVerseCard(context, ref),
    );
  }

  Widget _buildKhatmahTodayCard(
    BuildContext context,
    WidgetRef ref,
    KhatmahViewState viewState,
  ) {
    final colors = context.colors;
    final fromPage = viewState.todayFromPage;
    final toPage = viewState.todayToPage;
    final totalTodayPages = (toPage - fromPage + 1).clamp(0, 604);
    final completedToday = viewState.completedPagesToday.clamp(
      0,
      totalTodayPages,
    );
    final progress = totalTodayPages == 0
        ? 0.0
        : (completedToday / totalTodayPages).clamp(0.0, 1.0);

    final startSurah = QuranService.getSurahNameArabicNormalized(
      QuranService.getSurahNumberFromPage(fromPage),
    );
    final endSurah = QuranService.getSurahNameArabicNormalized(
      QuranService.getSurahNumberFromPage(toPage),
    );
    final rangeSurahText =
        startSurah == endSurah ? startSurah : '$startSurah - $endSurah';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ورد اليوم',
            style: GoogleFonts.tajawal(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colors.surfaceCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.borderDefault),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'خطة الختمة',
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'من صفحة $fromPage إلى $toPage',
                  style: GoogleFonts.tajawal(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                SurahTitleText(
                  rangeSurahText,
                  fontSize: 20,
                  maxLines: 1,
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 7,
                    value: progress,
                    backgroundColor: colors.surfaceVariant,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'أنجزت $completedToday من $totalTodayPages صفحة',
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final surah = QuranService.getSurahNumberFromPage(
                            fromPage,
                          );
                          QuranService.preloadSurah(surah);
                          QuranService.preloadPage(fromPage);
                          context.push(Routes.quranReader(surah, page: fromPage));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: context.colors.textOnPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text(
                          'ابدأ ورد اليوم',
                          style: GoogleFonts.tajawal(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final changed = await ref
                              .read(khatmahControllerProvider.notifier)
                              .markTodayCompletedManual();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              content: Text(
                                changed
                                    ? 'تم تعليم ورد اليوم كمكتمل'
                                    : 'لا يوجد ورد متاح لليوم',
                                style: GoogleFonts.tajawal(),
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.textPrimary,
                          side: BorderSide(color: colors.borderDefault),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'إكمال يدوي',
                          style: GoogleFonts.tajawal(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyVerseCard(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final wird = _dailyWirdForToday();
    final verse = QuranService.getVerse(
      wird.surah,
      wird.ayah,
      verseEndSymbol: false,
    );
    final surahName = QuranService.getSurahNameArabicNormalized(wird.surah);
    final favoriteSurahs = ref.watch(favoriteSurahsProvider);
    final isFavorite = favoriteSurahs.contains(wird.surah);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ورد اليوم',
                style: GoogleFonts.tajawal(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  QuranService.preloadSurah(wird.surah);
                  context
                      .push('/quran/reader/${wird.surah}?ayah=${wird.ayah}');
                },
                child: Text(
                  'عرض المزيد',
                  style: GoogleFonts.tajawal(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.surfaceCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colors.borderDefault),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"$verse"',
                  style: TextStyle(
                    fontFamily: 'KFGQPC Uthmanic Script',
                    fontFamilyFallback: const ['naskh'],
                    fontSize: 22,
                    color: colors.textPrimary,
                    height: 1.9,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$surahName - آية ${wird.ayah}',
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () async {
                        try {
                          await AudioCtrl.instance.stopRangePlayback();
                          if (!context.mounted) return;
                          await AudioCtrl.instance.playAyahRange(
                            context: context,
                            surahNumber: wird.surah,
                            startAyah: wird.ayah,
                            endAyah: wird.ayah,
                          );
                          if (context.mounted) {
                            QuranService.preloadSurah(wird.surah);
                            context.push(
                              Routes.quranReader(wird.surah, ayah: wird.ayah),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('حدث خطأ أثناء التشغيل'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.play_arrow,
                              color: colors.textOnPrimary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'اقرأ الآن',
                            style: GoogleFonts.tajawal(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            SharePlus.instance.share(
                              ShareParams(
                                text:
                                    '$verse\n\n$surahName - آية ${wird.ayah}\nمن تطبيق المسلم',
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.share,
                            color: colors.textSecondary,
                            size: 20,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            await ref
                                .read(favoriteSurahsProvider.notifier)
                                .toggle(wird.surah);
                          },
                          icon: Icon(
                            isFavorite
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: isFavorite
                                ? AppColors.primary
                                : colors.textSecondary,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyWird {
  const _DailyWird({required this.surah, required this.ayah});

  final int surah;
  final int ayah;
}
