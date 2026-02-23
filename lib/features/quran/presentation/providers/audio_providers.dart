import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../data/models/reciter.dart';
import '../../data/repositories/audio_download_service.dart';
import '../../data/repositories/audio_repository.dart';

// ── Reciters list (Arabic only) ───────────────────────────────────────────────
final recitersProvider = FutureProvider<List<Reciter>>(
  (ref) => AudioRepository.getReciters('ar'),
);

// ── Audio player singleton ────────────────────────────────────────────────────
final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(player.dispose);
  return player;
});

// ── Playback state notifier ───────────────────────────────────────────────────
class QuranAudioNotifier extends Notifier<QuranAudioState> {
  static const Duration _positionUiThrottle = Duration(milliseconds: 180);
  static const Duration _positionDeltaThreshold = Duration(milliseconds: 140);

  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<PlaybackEvent>? _playbackEventSub;
  DateTime _lastPositionEmitAt = DateTime.fromMillisecondsSinceEpoch(0);
  Duration _lastPositionEmitted = Duration.zero;
  bool _isRecoveringFromPlaybackError = false;
  bool _isSwitchingSource = false;

  @override
  QuranAudioState build() {
    _bindPlayerStreams();
    ref.onDispose(() async {
      await _playerStateSub?.cancel();
      await _positionSub?.cancel();
      await _durationSub?.cancel();
      await _playbackEventSub?.cancel();
    });
    return const QuranAudioState();
  }

  AudioPlayer get _player => ref.read(audioPlayerProvider);

  bool _isSslLikeError(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('ssl') ||
        message.contains('certificate') ||
        message.contains('handshake') ||
        message.contains('chain validation');
  }

  bool _isRemoteUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return uri.isScheme('http') || uri.isScheme('https');
  }

  void _bindPlayerStreams() {
    _playerStateSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playbackEventSub?.cancel();

    _playerStateSub = _player.playerStateStream.listen(_syncPlayerState);
    _positionSub = _player.positionStream.listen((position) {
      if (!state.hasAudio) return;
      final max = state.duration ?? position;
      final normalized = position > max ? max : position;
      if (!_shouldEmitPosition(normalized)) return;
      state = state.copyWith(position: normalized);
    });
    _durationSub = _player.durationStream.listen((duration) {
      if (!state.hasAudio) return;
      state = state.copyWith(duration: duration);
    });
    _playbackEventSub = _player.playbackEventStream.listen(
      (_) {},
      onError: _handlePlaybackError,
    );
  }

  Future<void> _handlePlaybackError(Object error, [StackTrace? _]) async {
    if (!state.hasAudio ||
        _isRecoveringFromPlaybackError ||
        _isSwitchingSource) {
      return;
    }
    final currentUrl = state.url;
    if (currentUrl == null || currentUrl.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        isPlaying: false,
        error: 'فشل تحميل الصوت',
      );
      return;
    }

    if (!_isSslLikeError(error) || !_isRemoteUrl(currentUrl)) {
      state = state.copyWith(
        isLoading: false,
        isPlaying: false,
        error: 'فشل تحميل الصوت',
      );
      return;
    }

    final currentMoshaf = state.moshaf;
    final currentSurah = state.surahNumber;
    if (currentMoshaf == null || currentSurah == null) {
      state = state.copyWith(
        isLoading: false,
        isPlaying: false,
        error: 'فشل تحميل الصوت',
      );
      return;
    }

    _isRecoveringFromPlaybackError = true;
    try {
      final localPath = await AudioDownloadService.ensureLocalPlaybackFile(
        currentMoshaf,
        currentSurah,
      );
      final localUrl = 'file://$localPath';
      await _player.stop();
      await _player.setUrl(localUrl);
      await _player.play();
      state = state.copyWith(
        isLoading: false,
        isPlaying: true,
        isCompleted: false,
        url: localUrl,
        duration: _player.duration,
        error: null,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        isPlaying: false,
        error: 'فشل تحميل الصوت',
      );
    } finally {
      _isRecoveringFromPlaybackError = false;
    }
  }

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

  void _syncPlayerState(PlayerState playerState) {
    if (!state.hasAudio) return;

    final processing = playerState.processingState;
    final isLoading =
        processing == ProcessingState.loading ||
        processing == ProcessingState.buffering;
    final isCompleted = processing == ProcessingState.completed;
    final isPlaying = playerState.playing && !isCompleted;

    state = state.copyWith(
      isLoading: isLoading,
      isPlaying: isPlaying,
      isCompleted: isCompleted,
      position: isCompleted
          ? (state.duration ?? state.position)
          : state.position,
    );
  }

  Future<void> play(Reciter reciter, Moshaf moshaf, int surahNumber) async {
    if (!moshaf.hasSurah(surahNumber)) {
      state = state.copyWith(error: 'هذا الشيخ لا يتوفر لهذه السورة');
      return;
    }
    if (_isSwitchingSource) return;
    _isSwitchingSource = true;

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
      final originalUrl = await AudioDownloadService.getPlaybackUrl(
        moshaf,
        surahNumber,
      );
      await _player.stop();
      final resolvedUrl = _isRemoteUrl(originalUrl)
          ? 'file://${await AudioDownloadService.ensureLocalPlaybackFile(moshaf, surahNumber)}'
          : originalUrl;
      await _player.setUrl(resolvedUrl);
      await _player.play();
      state = state.copyWith(
        isLoading: false,
        isPlaying: true,
        isCompleted: false,
        url: resolvedUrl,
        duration: _player.duration,
        position: Duration.zero,
        error: null,
      );
    } catch (_) {
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
    if (!_player.playing) return;
    await _player.pause();
    state = state.copyWith(isPlaying: false);
  }

  Future<void> resume() async {
    if (!state.hasAudio || _player.playing) return;
    if (state.isCompleted) {
      await _player.seek(Duration.zero);
      state = state.copyWith(position: Duration.zero, isCompleted: false);
    }
    await _player.play();
    state = state.copyWith(isPlaying: true, isCompleted: false);
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await pause();
    } else {
      await resume();
    }
  }

  Future<void> stop() async {
    await _player.stop();
    _lastPositionEmitted = Duration.zero;
    _lastPositionEmitAt = DateTime.fromMillisecondsSinceEpoch(0);
    state = const QuranAudioState();
  }

  Future<void> seekTo(Duration position) async {
    if (!state.hasAudio) return;
    final max = state.duration;
    final normalized = max != null && position > max ? max : position;
    await _player.seek(normalized);
    _lastPositionEmitted = normalized;
    _lastPositionEmitAt = DateTime.now();
    state = state.copyWith(position: normalized, isCompleted: false);
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

// ── Playback state ────────────────────────────────────────────────────────────
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
