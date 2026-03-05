import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_library/quran_library.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../providers/tahfeez_provider.dart';
import '../widgets/playback_controls.dart';
import '../widgets/progress_tracker.dart';
import '../widgets/quick_ranges_list.dart';
import '../widgets/range_selector_card.dart';

/// شاشة التحفيظ - تساعد على حفظ القرآن بطريقة منظمة
class TahfeezScreen extends ConsumerStatefulWidget {
  const TahfeezScreen({super.key});

  @override
  ConsumerState<TahfeezScreen> createState() => _TahfeezScreenState();
}

class _TahfeezScreenState extends ConsumerState<TahfeezScreen> {
  StreamSubscription<int>? _currentAyahUniqueSub;
  StreamSubscription<SequenceState>? _sequenceStateSub;
  StreamSubscription<PlayerState>? _playerStateSub;

  bool _isHandlingCycleCompletion = false;
  bool _isStoppingPlayback = false;
  bool _awaitingPlaybackStart = false;
  int? _pendingInitialAyah;
  bool _pendingResetSession = false;
  Timer? _playStartTimeout;

  @override
  void initState() {
    super.initState();
    _attachAudioListeners();
  }

  @override
  void dispose() {
    _currentAyahUniqueSub?.cancel();
    _sequenceStateSub?.cancel();
    _playerStateSub?.cancel();
    _playStartTimeout?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tahfeezState = ref.watch(tahfeezProvider);
    final isPlaybackActive = tahfeezState.isPlaying || _awaitingPlaybackStart;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  color: colors.textOnPrimary,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
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
                      color: colors.textOnPrimary.withValues(alpha: 0.9),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'احفظ القرآن بسهولة ويسر',
                      style: GoogleFonts.tajawal(
                        fontSize: 14,
                        color: colors.textOnPrimary.withValues(alpha: 0.9),
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
                  if (!tahfeezState.hasStarted) _buildWelcomeCard(context),

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
                      isPlaying: isPlaybackActive,
                      repeatCount: tahfeezState.repeatCount,
                      onPlay: () => _playRange(context),
                      onPause: _pausePlayback,
                      onStop: _stopPlayback,
                      onRepeatChange: (count) {
                        ref.read(tahfeezProvider.notifier).setRepeatCount(count);
                      },
                    ),

                  const SizedBox(height: 16),

                  // متتبع التقدم
                  if (tahfeezState.hasStarted)
                    ProgressTracker(
                      currentAyah: tahfeezState.currentAyah,
                      startAyah: tahfeezState.startAyah ?? 1,
                      totalAyahs: tahfeezState.totalAyahs,
                      currentAyahInRange: tahfeezState.currentAyahInRange,
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

  Widget _buildWelcomeCard(BuildContext context) {
    final colors = context.colors;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: colors.surfaceCard,
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
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildTip(context, '1️⃣', 'اختر النطاق الذي تريد حفظه'),
            _buildTip(context, '2️⃣', 'حدد عدد مرات التكرار المناسب لك'),
            _buildTip(context, '3️⃣', 'اضغط تشغيل واستمع وكرر'),
            _buildTip(context, '4️⃣', 'تابع تقدمك وأكمل حفظك بانتظام'),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(BuildContext context, String emoji, String text) {
    final colors = context.colors;

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
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _attachAudioListeners() {
    final audioCtrl = AudioCtrl.instance;

    _currentAyahUniqueSub =
        audioCtrl.state.currentAyahUniqueNumber.stream.listen((ayahUq) {
      final tahfeezState = ref.read(tahfeezProvider);
      if (!tahfeezState.hasRange) {
        return;
      }

      final ayah = QuranCtrl.instance.getAyahByUq(ayahUq);
      final ayahSurahNumber = ayah.surahNumber;
      final ayahNumber = ayah.ayahNumber;

      if (ayahSurahNumber == tahfeezState.surahNumber &&
          ayahNumber >= tahfeezState.startAyah! &&
          ayahNumber <= tahfeezState.endAyah!) {
        ref.read(tahfeezProvider.notifier).updateCurrentAyah(ayahNumber);
      }
    });

    _sequenceStateSub =
        audioCtrl.state.audioPlayer.sequenceStateStream.listen((sequenceState) {
      final tahfeezState = ref.read(tahfeezProvider);
      if (!tahfeezState.hasRange) {
        return;
      }

      final currentIndex = sequenceState.currentIndex;
      if (currentIndex == null || currentIndex < 0) {
        return;
      }

      final startAyah = tahfeezState.startAyah!;
      final endAyah = tahfeezState.endAyah!;
      final ayahNumber = startAyah + currentIndex;

      if (ayahNumber >= startAyah && ayahNumber <= endAyah) {
        ref.read(tahfeezProvider.notifier).updateCurrentAyah(ayahNumber);
      }
    });

    _playerStateSub =
        audioCtrl.state.audioPlayer.playerStateStream.listen((playerState) async {
      if (!mounted) {
        return;
      }

      if (_awaitingPlaybackStart && playerState.playing) {
        _confirmPendingPlaybackStart();
      }

      if (_isHandlingCycleCompletion ||
          _isStoppingPlayback ||
          playerState.processingState != ProcessingState.completed) {
        return;
      }

      final tahfeezState = ref.read(tahfeezProvider);
      if (!tahfeezState.hasStarted || !tahfeezState.hasRange) {
        return;
      }

      _isHandlingCycleCompletion = true;
      try {
        _clearPendingPlaybackStart();

        final notifier = ref.read(tahfeezProvider.notifier);
        final completed = notifier.completeCurrentCycle();

        if (completed >= tahfeezState.repeatCount) {
          await AudioCtrl.instance.stopRangePlayback();
          _showMessage('أحسنت! أتممت ${tahfeezState.repeatCount} تكرارات');
          return;
        }

        await _playCycle(
          resetSession: false,
          initialAyah: tahfeezState.startAyah,
        );
      } catch (_) {
        _showMessage('تعذر متابعة التكرار تلقائياً', isError: true);
      } finally {
        _isHandlingCycleCompletion = false;
      }
    });
  }

  Future<void> _playRange(BuildContext context) async {
    final state = ref.read(tahfeezProvider);

    if (!state.hasRange) {
      _showMessage('يرجى اختيار نطاق للحفظ أولاً');
      return;
    }

    if (_canResumeCurrentSession(state)) {
      await _resumePlayback();
      return;
    }

    await _playCycle(
      resetSession: true,
      initialAyah: state.startAyah,
      context: context,
    );
  }

  bool _canResumeCurrentSession(TahfeezState state) {
    final rangeInfo = AudioCtrl.instance.state.currentRangeInfo.value;
    if (rangeInfo == null) {
      return false;
    }

    return state.hasStarted &&
        !state.isPlaying &&
        rangeInfo.surahNumber == state.surahNumber &&
        rangeInfo.startAyah == state.startAyah &&
        rangeInfo.endAyah == state.endAyah;
  }

  Future<void> _resumePlayback() async {
    try {
      final state = ref.read(tahfeezProvider);
      _setPendingPlaybackStart(
        initialAyah: state.currentAyah > 0
            ? state.currentAyah
            : (state.startAyah ?? 1),
        resetSession: false,
      );

      await AudioCtrl.instance.state.audioPlayer.play();

      if (AudioCtrl.instance.state.audioPlayer.playing) {
        _confirmPendingPlaybackStart();
      }
    } catch (_) {
      _clearPendingPlaybackStart();
      _showMessage('تعذر استئناف التلاوة', isError: true);
    }
  }

  Future<void> _playCycle({
    required bool resetSession,
    int? initialAyah,
    BuildContext? context,
  }) async {
    final state = ref.read(tahfeezProvider);
    if (!state.hasRange) {
      return;
    }

    final startingAyah = initialAyah ?? state.startAyah!;

    try {
      _setPendingPlaybackStart(
        initialAyah: startingAyah,
        resetSession: resetSession,
      );

      await AudioCtrl.instance.playAyahRange(
        context: context ?? this.context,
        surahNumber: state.surahNumber!,
        startAyah: state.startAyah!,
        endAyah: state.endAyah!,
        loop: false,
        stopAtEnd: true,
      );

      if (AudioCtrl.instance.state.audioPlayer.playing) {
        _confirmPendingPlaybackStart();
      }
    } catch (_) {
      _clearPendingPlaybackStart();
      _showMessage('تعذر تشغيل التلاوة', isError: true);
    }
  }

  Future<void> _pausePlayback() async {
    _clearPendingPlaybackStart();
    try {
      await AudioCtrl.instance.pausePlayer();
      ref.read(tahfeezProvider.notifier).onPlaybackPaused();
    } catch (_) {
      _showMessage('تعذر إيقاف التلاوة مؤقتاً', isError: true);
    }
  }

  Future<void> _stopPlayback() async {
    _isStoppingPlayback = true;
    _clearPendingPlaybackStart();
    try {
      await AudioCtrl.instance.stopRangePlayback();
      ref.read(tahfeezProvider.notifier).stopSession();
      _showMessage('تم إيقاف الجلسة');
    } catch (_) {
      _showMessage('تعذر إيقاف الجلسة', isError: true);
    } finally {
      _isStoppingPlayback = false;
    }
  }

  void _setPendingPlaybackStart({
    required int initialAyah,
    required bool resetSession,
  }) {
    _playStartTimeout?.cancel();

    setState(() {
      _awaitingPlaybackStart = true;
      _pendingInitialAyah = initialAyah;
      _pendingResetSession = resetSession;
    });

    _playStartTimeout = Timer(const Duration(seconds: 8), () {
      if (!mounted || !_awaitingPlaybackStart) {
        return;
      }
      _clearPendingPlaybackStart();
      _showMessage('تأخر بدء التشغيل، حاول مرة أخرى', isError: true);
    });
  }

  void _confirmPendingPlaybackStart() {
    if (!_awaitingPlaybackStart) {
      return;
    }

    _playStartTimeout?.cancel();
    _playStartTimeout = null;

    final initialAyah = _pendingInitialAyah;
    final resetSession = _pendingResetSession;

    setState(() {
      _awaitingPlaybackStart = false;
      _pendingInitialAyah = null;
      _pendingResetSession = false;
    });

    if (initialAyah != null) {
      ref.read(tahfeezProvider.notifier).onPlaybackStarted(
            initialAyah: initialAyah,
            resetSession: resetSession,
          );
    }
  }

  void _clearPendingPlaybackStart() {
    _playStartTimeout?.cancel();
    _playStartTimeout = null;

    if (!mounted || !_awaitingPlaybackStart) {
      return;
    }

    setState(() {
      _awaitingPlaybackStart = false;
      _pendingInitialAyah = null;
      _pendingResetSession = false;
    });
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) {
      return;
    }

    final colors = context.colors;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.tajawal(color: colors.textOnPrimary),
        ),
        backgroundColor: isError ? colors.error : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
