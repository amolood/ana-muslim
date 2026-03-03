import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_library/quran_library.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/tahfeez_provider.dart';
import '../widgets/range_selector_card.dart';
import '../widgets/quick_ranges_list.dart';
import '../widgets/playback_controls.dart';
import '../widgets/progress_tracker.dart';

/// شاشة التحفيظ - تساعد على حفظ القرآن بطريقة منظمة
class TahfeezScreen extends ConsumerStatefulWidget {
  const TahfeezScreen({super.key});

  @override
  ConsumerState<TahfeezScreen> createState() => _TahfeezScreenState();
}

class _TahfeezScreenState extends ConsumerState<TahfeezScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tahfeezState = ref.watch(tahfeezProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDeepDark : Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // App Bar مخصص
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'التحفيظ',
                style: GoogleFonts.tajawal(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha:0.8),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Icon(
                      Icons.school_outlined,
                      size: 60,
                      color: Colors.white.withValues(alpha:0.9),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'احفظ القرآن بسهولة ويسر',
                      style: GoogleFonts.tajawal(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha:0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // المحتوى
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // رسالة ترحيبية
                  if (!tahfeezState.hasStarted)
                    _buildWelcomeCard(isDark),

                  const SizedBox(height: 16),

                  // بطاقة اختيار النطاق
                  RangeSelectorCard(
                    onRangeSelected: (surah, start, end) {
                      ref.read(tahfeezProvider.notifier).setRange(
                            surah,
                            start,
                            end,
                          );
                    },
                  ),

                  const SizedBox(height: 16),

                  // نطاقات سريعة جاهزة
                  QuickRangesList(
                    onRangeSelected: (range) {
                      ref.read(tahfeezProvider.notifier).setQuickRange(range);
                    },
                  ),

                  const SizedBox(height: 16),

                  // التحكم في التشغيل
                  if (tahfeezState.hasRange)
                    PlaybackControls(
                      isPlaying: tahfeezState.isPlaying,
                      repeatCount: tahfeezState.repeatCount,
                      onPlay: () => _playRange(context),
                      onPause: _pausePlayback,
                      onStop: _stopPlayback,
                      onRepeatChange: (count) {
                        ref
                            .read(tahfeezProvider.notifier)
                            .setRepeatCount(count);
                      },
                    ),

                  const SizedBox(height: 16),

                  // متتبع التقدم
                  if (tahfeezState.hasStarted)
                    ProgressTracker(
                      currentAyah: tahfeezState.currentAyah,
                      totalAyahs: tahfeezState.totalAyahs,
                      sessionTime: tahfeezState.sessionDuration,
                      repeatsDone: tahfeezState.completedRepeats,
                    ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(bool isDark) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? AppColors.cardDark : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'كيف تستخدم التحفيظ؟',
              style: GoogleFonts.tajawal(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildTip('1️⃣', 'اختر النطاق الذي تريد حفظه', isDark),
            _buildTip('2️⃣', 'حدد عدد مرات التكرار المناسب لك', isDark),
            _buildTip('3️⃣', 'اضغط تشغيل واستمع وكرر', isDark),
            _buildTip('4️⃣', 'تابع تقدمك وأكمل حفظك بانتظام', isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String emoji, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.tajawal(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _playRange(BuildContext context) async {
    final state = ref.read(tahfeezProvider);

    if (!state.hasRange) {
      _showMessage('يرجى اختيار نطاق للحفظ أولاً');
      return;
    }

    try {
      // بدء الجلسة
      ref.read(tahfeezProvider.notifier).startSession();

      // تشغيل النطاق
      await AudioCtrl.instance.playAyahRange(
        context: context,
        surahNumber: state.surahNumber!,
        startAyah: state.startAyah!,
        endAyah: state.endAyah!,
        loop: true, // دائماً مع التكرار للحفظ
        stopAtEnd: false,
      );

      ref.read(tahfeezProvider.notifier).setPlaying(true);

      // تتبع الآية الحالية
      _listenToCurrentAyah();
    } catch (e) {
      _showMessage('تعذر تشغيل التلاوة', isError: true);
      ref.read(tahfeezProvider.notifier).setPlaying(false);
    }
  }

  void _listenToCurrentAyah() {
    // يمكن إضافة listener هنا لتحديث الآية الحالية
    // بناءً على state.currentAyahUniqueNumber
  }

  Future<void> _pausePlayback() async {
    try {
      await AudioCtrl.instance.pausePlayer();
      ref.read(tahfeezProvider.notifier).setPlaying(false);
    } catch (e) {
      _showMessage('تعذر إيقاف التلاوة مؤقتاً', isError: true);
    }
  }

  Future<void> _stopPlayback() async {
    try {
      await AudioCtrl.instance.stopRangePlayback();
      ref.read(tahfeezProvider.notifier).stopSession();
      _showMessage('تم إيقاف الجلسة');
    } catch (e) {
      _showMessage('تعذر إيقاف الجلسة', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.tajawal(),
        ),
        backgroundColor: isError ? Colors.red : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
