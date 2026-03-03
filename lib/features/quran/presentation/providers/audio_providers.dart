import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_library/quran_library.dart'; // also re-exports audio_service types

import '../../../../../audio/quran_audio_handler.dart';
import '../../data/models/reciter.dart';
import '../../data/repositories/audio_download_service.dart';
import '../../data/repositories/audio_repository.dart';

// ── Handler provider ──────────────────────────────────────────────────────────
// Overridden in main() with the singleton returned by initAudioService().
// Throwing here makes misconfiguration obvious rather than silent.
final quranAudioHandlerProvider = Provider<QuranAudioHandler>(
  (ref) => throw UnimplementedError(
    'quranAudioHandlerProvider must be overridden in ProviderScope',
  ),
);

// ── Reciters list (Arabic only) ───────────────────────────────────────────────
final recitersProvider = FutureProvider<List<Reciter>>(
  (ref) => AudioRepository.getReciters('ar'),
);

/// Current search query used by the default-reciter picker screen.
class _ReciterSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void update(String v) => state = v;
}

final reciterSearchQueryProvider =
    NotifierProvider<_ReciterSearchQueryNotifier, String>(
      _ReciterSearchQueryNotifier.new,
    );

// ── Playback state notifier ───────────────────────────────────────────────────
//
// [QuranAudioNotifier] is the Riverpod bridge between the app's domain model
// (Reciter, Moshaf, surah number) and [QuranAudioHandler].
//
// Responsibility split:
//   • Handler  — owns AudioPlayer, MediaSession, notification lifecycle.
//   • Notifier — resolves download URLs, holds domain state (Reciter/Moshaf),
//                throttles position updates, and surfaces errors to the UI.
class QuranAudioNotifier extends Notifier<QuranAudioState> {
  // Position update throttle to avoid excessive UI rebuilds during playback.
  static const Duration _positionUiThrottle = Duration(milliseconds: 180);
  static const Duration _positionDeltaThreshold = Duration(milliseconds: 140);

  StreamSubscription<PlaybackState>? _playbackStateSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<void>? _skipNextSub;

  DateTime _lastPositionEmitAt = DateTime.fromMillisecondsSinceEpoch(0);
  Duration _lastPositionEmitted = Duration.zero;

  // Guards against concurrent play() calls (e.g. rapid surah switching).
  bool _isSwitchingSource = false;

  // Tracks the previous completion flag so we fire auto-advance exactly once
  // on the 0→1 edge (not repeatedly while the player stays in completed state).
  bool _wasCompleted = false;

  @override
  QuranAudioState build() {
    _bindHandlerStreams();
    ref.onDispose(() async {
      await _playbackStateSub?.cancel();
      await _positionSub?.cancel();
      await _durationSub?.cancel();
      await _skipNextSub?.cancel();
    });
    return const QuranAudioState();
  }

  QuranAudioHandler get _handler => ref.read(quranAudioHandlerProvider);

  // ── Stream binding ─────────────────────────────────────────────────────────

  void _bindHandlerStreams() {
    _playbackStateSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _skipNextSub?.cancel();

    // audio_service's PlaybackState stream drives isLoading / isPlaying /
    // isCompleted — the single source of truth for the player's processing state.
    _playbackStateSub = _handler.playbackState.stream.listen(
      _syncFromPlaybackState,
    );

    // Position stream fires at ~200 ms cadence during playback. We throttle it
    // here to avoid rebuilding the progress bar on every tick.
    _positionSub = _handler.positionStream.listen((position) {
      if (!state.hasAudio) return;
      final max = state.duration ?? position;
      final normalized = position > max ? max : position;
      if (!_shouldEmitPosition(normalized)) return;
      state = state.copyWith(position: normalized);
    });

    // Duration becomes available once the media headers are parsed.
    _durationSub = _handler.durationStream.listen((duration) {
      if (!state.hasAudio) return;
      state = state.copyWith(duration: duration);
    });

    // "Skip to next" events from the notification button or Bluetooth headset.
    _skipNextSub = _handler.skipToNextRequested.listen((_) {
      _advanceToNextSurah();
    });
  }

  void _syncFromPlaybackState(PlaybackState ps) {
    if (!state.hasAudio) return;

    final isLoading =
        ps.processingState == AudioProcessingState.loading ||
        ps.processingState == AudioProcessingState.buffering;
    final isCompleted = ps.processingState == AudioProcessingState.completed;
    final isPlaying = ps.playing && !isCompleted;

    state = state.copyWith(
      isLoading: isLoading,
      isPlaying: isPlaying,
      isCompleted: isCompleted,
      // Snap position to end-of-track when completed so the UI slider is at 100%.
      position: isCompleted
          ? (state.duration ?? state.position)
          : state.position,
    );

    // Auto-advance: fire exactly once on the false→true completion edge.
    // Using Future.microtask keeps this out of the synchronous state-update
    // cycle, preventing potential state-mutation-while-building issues.
    if (isCompleted && !_wasCompleted) {
      Future.microtask(_advanceToNextSurah);
    }
    _wasCompleted = isCompleted;
  }

  // ── Continuous playback ────────────────────────────────────────────────────

  /// Plays the Surah immediately after the current one.
  ///
  /// Rules:
  ///  • Surah 114 (An-Nas) is the last — stop gracefully after it finishes.
  ///  • If the current moshaf skips a Surah number, skip to the first
  ///    available one that is > current (handles incomplete moshafs).
  ///  • If none is found (moshaf ends), stop and dismiss the notification.
  void _advanceToNextSurah() {
    if (_isSwitchingSource) return;
    final reciter = state.reciter;
    final moshaf = state.moshaf;
    final currentSurah = state.surahNumber;
    if (reciter == null || moshaf == null || currentSurah == null) return;

    // Find the next available surah in this moshaf (handles gaps in surahList).
    final nextSurah = moshaf.surahList
        .where((n) => n > currentSurah)
        .fold<int?>(null, (best, n) => best == null || n < best ? n : best);

    if (nextSurah == null) {
      // No more surahs in this moshaf — end of playlist.
      stop();
      return;
    }

    play(reciter, moshaf, nextSurah);
  }

  // ── Position throttle ──────────────────────────────────────────────────────

  bool _shouldEmitPosition(Duration next) {
    if (next == state.position) return false;

    final now = DateTime.now();
    final deltaMs = (next - _lastPositionEmitted).inMilliseconds.abs();
    final nearEnd =
        state.duration != null &&
        (state.duration! - next).inMilliseconds.abs() <=
            _positionDeltaThreshold.inMilliseconds;
    final passedTime = now.difference(_lastPositionEmitAt);

    if (!nearEnd &&
        deltaMs < _positionDeltaThreshold.inMilliseconds &&
        passedTime < _positionUiThrottle) {
      return false;
    }

    _lastPositionEmitAt = now;
    _lastPositionEmitted = next;
    return true;
  }

  // ── Public playback API ────────────────────────────────────────────────────

  /// Load [surahNumber] from [moshaf] recited by [reciter] and begin playback.
  ///
  /// The URL is resolved to a local file if already downloaded; otherwise the
  /// file is downloaded first (SSL-fallback included in [AudioDownloadService]).
  /// The resolved path is then handed to [QuranAudioHandler.playSurah] which
  /// drives the MediaSession and MediaStyle notification.
  Future<void> play(Reciter reciter, Moshaf moshaf, int surahNumber) async {
    if (!moshaf.hasSurah(surahNumber)) {
      state = state.copyWith(error: 'هذا الشيخ لا يتوفر لهذه السورة');
      return;
    }
    if (_isSwitchingSource) return;
    _isSwitchingSource = true;

    // Resolve Arabic Surah name for the MediaItem title.
    final surahName = _resolveSurahName(surahNumber);

    // Immediately show loading state so the UI reacts without waiting for
    // the download to finish.
    state = QuranAudioState(
      isLoading: true,
      reciter: reciter,
      moshaf: moshaf,
      surahNumber: surahNumber,
      position: Duration.zero,
    );
    _lastPositionEmitted = Duration.zero;
    _lastPositionEmitAt = DateTime.fromMillisecondsSinceEpoch(0);

    try {
      // getPlaybackUrl returns a local file:// path if already cached, else
      // the remote URL. If remote, we download locally (with SSL fallback)
      // before playing to avoid mid-stream SSL errors.
      final originalUrl = await AudioDownloadService.getPlaybackUrl(
        moshaf,
        surahNumber,
      );
      final resolvedUrl = _isRemoteUrl(originalUrl)
          ? 'file://${await AudioDownloadService.ensureLocalPlaybackFile(moshaf, surahNumber)}'
          : originalUrl;

      // Hand off to the handler — this triggers MediaSession + notification.
      await _handler.playSurah(QuranMediaItem(
        surahNumber: surahNumber,
        surahName: surahName,
        reciterName: reciter.name,
        audioUrl: resolvedUrl,
      ));

      state = state.copyWith(
        isLoading: false,
        isPlaying: true,
        isCompleted: false,
        url: resolvedUrl,
        duration: null, // populated asynchronously via _durationSub
        position: Duration.zero,
        error: null,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[QuranAudioNotifier] play error: $e');
      state = state.copyWith(
        isLoading: false,
        isPlaying: false,
        error: 'فشل تحميل الصوت',
      );
    } finally {
      _isSwitchingSource = false;
    }
  }

  Future<void> pause() async {
    await _handler.pause();
    state = state.copyWith(isPlaying: false);
  }

  Future<void> resume() async {
    if (!state.hasAudio || state.isPlaying) return;
    if (state.isCompleted) {
      await _handler.seek(Duration.zero);
      state = state.copyWith(position: Duration.zero, isCompleted: false);
    }
    await _handler.play();
    state = state.copyWith(isPlaying: true, isCompleted: false);
  }

  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await pause();
    } else {
      await resume();
    }
  }

  /// Stop playback and dismiss the notification.
  Future<void> stop() async {
    await _handler.stop();
    _lastPositionEmitted = Duration.zero;
    _lastPositionEmitAt = DateTime.fromMillisecondsSinceEpoch(0);
    state = const QuranAudioState();
  }

  Future<void> seekTo(Duration position) async {
    if (!state.hasAudio) return;
    final max = state.duration;
    final normalized = max != null && position > max ? max : position;
    await _handler.seek(normalized);
    _lastPositionEmitted = normalized;
    _lastPositionEmitAt = DateTime.now();
    state = state.copyWith(position: normalized, isCompleted: false);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static String _resolveSurahName(int surahNumber) {
    try {
      return QuranLibrary().getSurahInfo(surahNumber: surahNumber).name;
    } catch (_) {
      return 'سورة $surahNumber';
    }
  }

  static bool _isRemoteUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return uri.isScheme('http') || uri.isScheme('https');
  }
}

final quranAudioProvider =
    NotifierProvider<QuranAudioNotifier, QuranAudioState>(
      QuranAudioNotifier.new,
    );

// ── Download state for a moshaf ───────────────────────────────────────────────
class MoshafDownloadState {
  final bool isDownloading;
  final double progress; // 0.0 – 1.0
  final String status;
  final int downloadedCount;
  final int totalCount;

  const MoshafDownloadState({
    this.isDownloading = false,
    this.progress = 0,
    this.status = '',
    this.downloadedCount = 0,
    this.totalCount = 0,
  });

  MoshafDownloadState copyWith({
    bool? isDownloading,
    double? progress,
    String? status,
    int? downloadedCount,
    int? totalCount,
  }) => MoshafDownloadState(
    isDownloading: isDownloading ?? this.isDownloading,
    progress: progress ?? this.progress,
    status: status ?? this.status,
    downloadedCount: downloadedCount ?? this.downloadedCount,
    totalCount: totalCount ?? this.totalCount,
  );

  bool get isFullyDownloaded => totalCount > 0 && downloadedCount >= totalCount;
}

class MoshafDownloadNotifier extends Notifier<Map<int, MoshafDownloadState>> {
  @override
  Map<int, MoshafDownloadState> build() => {};

  Future<void> checkDownloaded(Moshaf moshaf) async {
    final count = await AudioDownloadService.downloadedCount(moshaf);
    state = {
      ...state,
      moshaf.id: MoshafDownloadState(
        downloadedCount: count,
        totalCount: moshaf.surahTotal,
      ),
    };
  }

  Future<void> startDownload(Moshaf moshaf) async {
    state = {
      ...state,
      moshaf.id: MoshafDownloadState(
        isDownloading: true,
        totalCount: moshaf.surahTotal,
      ),
    };

    await AudioDownloadService.downloadMoshaf(
      moshaf,
      onProgress: (p) {
        final current = state[moshaf.id] ?? const MoshafDownloadState();
        state = {
          ...state,
          moshaf.id: current.copyWith(
            progress: p,
            isDownloading: p < 1.0,
            downloadedCount: (p * moshaf.surahTotal).round(),
          ),
        };
      },
      onStatus: (s) {
        final current = state[moshaf.id] ?? const MoshafDownloadState();
        state = {...state, moshaf.id: current.copyWith(status: s)};
      },
    );

    final count = await AudioDownloadService.downloadedCount(moshaf);
    state = {
      ...state,
      moshaf.id: MoshafDownloadState(
        isDownloading: false,
        progress: 1.0,
        downloadedCount: count,
        totalCount: moshaf.surahTotal,
      ),
    };
  }

  Future<void> delete(Moshaf moshaf) async {
    await AudioDownloadService.deleteMoshaf(moshaf);
    state = {...state, moshaf.id: const MoshafDownloadState()};
  }
}

final moshafDownloadProvider =
    NotifierProvider<MoshafDownloadNotifier, Map<int, MoshafDownloadState>>(
      MoshafDownloadNotifier.new,
    );

// ── Playback state model ──────────────────────────────────────────────────────
class QuranAudioState {
  static const Object _sentinel = Object();

  final bool isLoading;
  final bool isPlaying;
  final bool isCompleted;
  final Reciter? reciter;
  final Moshaf? moshaf;
  final int? surahNumber;
  final String? url;
  final String? error;
  final Duration? duration;
  final Duration position;

  const QuranAudioState({
    this.isLoading = false,
    this.isPlaying = false,
    this.isCompleted = false,
    this.reciter,
    this.moshaf,
    this.surahNumber,
    this.url,
    this.error,
    this.duration,
    this.position = Duration.zero,
  });

  bool get hasAudio => reciter != null;

  double get progress {
    final d = duration;
    if (d == null || d.inMilliseconds <= 0) return 0;
    return (position.inMilliseconds / d.inMilliseconds).clamp(0, 1);
  }

  QuranAudioState copyWith({
    bool? isLoading,
    bool? isPlaying,
    bool? isCompleted,
    Object? reciter = _sentinel,
    Object? moshaf = _sentinel,
    Object? surahNumber = _sentinel,
    Object? url = _sentinel,
    Object? error = _sentinel,
    Object? duration = _sentinel,
    Object? position = _sentinel,
  }) => QuranAudioState(
    isLoading: isLoading ?? this.isLoading,
    isPlaying: isPlaying ?? this.isPlaying,
    isCompleted: isCompleted ?? this.isCompleted,
    reciter: identical(reciter, _sentinel) ? this.reciter : reciter as Reciter?,
    moshaf: identical(moshaf, _sentinel) ? this.moshaf : moshaf as Moshaf?,
    surahNumber: identical(surahNumber, _sentinel)
        ? this.surahNumber
        : surahNumber as int?,
    url: identical(url, _sentinel) ? this.url : url as String?,
    error: identical(error, _sentinel) ? this.error : error as String?,
    duration: identical(duration, _sentinel)
        ? this.duration
        : duration as Duration?,
    position: identical(position, _sentinel)
        ? this.position
        : position as Duration,
  );
}
