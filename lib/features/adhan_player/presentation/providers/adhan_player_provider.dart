import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../core/providers/adhan_provider.dart';

// ─── State ────────────────────────────────────────────────────────────────────

enum AdhanPlaybackStatus { idle, loading, playing, paused, completed, error }

class AdhanPlaybackState {
  final AdhanPlaybackStatus status;
  final String prayerName;
  final Duration position;
  final Duration duration;
  final String? errorMessage;

  const AdhanPlaybackState({
    this.status = AdhanPlaybackStatus.idle,
    this.prayerName = '',
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.errorMessage,
  });

  AdhanPlaybackState copyWith({
    AdhanPlaybackStatus? status,
    String? prayerName,
    Duration? position,
    Duration? duration,
    String? errorMessage,
  }) =>
      AdhanPlaybackState(
        status: status ?? this.status,
        prayerName: prayerName ?? this.prayerName,
        position: position ?? this.position,
        duration: duration ?? this.duration,
        errorMessage: errorMessage,
      );

  @override
  bool operator ==(Object other) =>
      other is AdhanPlaybackState &&
      other.status == status &&
      other.prayerName == prayerName &&
      other.position == position &&
      other.duration == duration &&
      other.errorMessage == errorMessage;

  @override
  int get hashCode =>
      Object.hash(status, prayerName, position, duration, errorMessage);
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final adhanPlayerProvider =
    NotifierProvider<AdhanPlayerNotifier, AdhanPlaybackState>(
  AdhanPlayerNotifier.new,
);

class AdhanPlayerNotifier extends Notifier<AdhanPlaybackState> {
  AudioPlayer? _player;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<PlayerState>? _stateSub;

  @override
  AdhanPlaybackState build() {
    ref.onDispose(_dispose);
    return const AdhanPlaybackState();
  }

  Future<void> startAdhan(String prayerName) async {
    // Stop any existing playback
    await _disposePlayer();

    state = AdhanPlaybackState(
      status: AdhanPlaybackStatus.loading,
      prayerName: prayerName,
    );

    try {
      final player = AudioPlayer();
      _player = player;

      // Read adhan sound preference
      final option = ref.read(adhanSoundOptionProvider);
      if (option == AdhanSoundOption.custom) {
        final customPath = ref.read(customAdhanFilePathProvider);
        if (customPath != null && customPath.isNotEmpty) {
          await player.setFilePath(customPath);
        } else {
          await player.setAsset(AdhanSoundOption.classic.assetPath);
        }
      } else {
        await player.setAsset(option.assetPath);
      }

      // Listen to streams
      _durationSub = player.durationStream.listen((d) {
        state = state.copyWith(duration: d ?? Duration.zero);
      });

      _positionSub = player.positionStream.listen((p) {
        state = state.copyWith(position: p);
      });

      _stateSub = player.playerStateStream.listen((ps) {
        if (ps.processingState == ProcessingState.completed) {
          state = state.copyWith(status: AdhanPlaybackStatus.completed);
        } else if (ps.playing) {
          state = state.copyWith(status: AdhanPlaybackStatus.playing);
        }
      });

      state = state.copyWith(
        duration: player.duration ?? Duration.zero,
      );

      await player.play();
    } catch (e) {
      if (kDebugMode) debugPrint('[AdhanPlayer] error: $e');
      state = state.copyWith(
        status: AdhanPlaybackStatus.error,
        errorMessage: 'تعذر تشغيل الأذان',
      );
    }
  }

  void pause() {
    _player?.pause();
    state = state.copyWith(status: AdhanPlaybackStatus.paused);
  }

  void resume() {
    _player?.play();
    state = state.copyWith(status: AdhanPlaybackStatus.playing);
  }

  Future<void> stop() async {
    await _disposePlayer();
    state = const AdhanPlaybackState();
  }

  void seekTo(Duration position) {
    _player?.seek(position);
  }

  Future<void> _disposePlayer() async {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _stateSub?.cancel();
    _positionSub = null;
    _durationSub = null;
    _stateSub = null;
    await _player?.stop();
    await _player?.dispose();
    _player = null;
  }

  void _dispose() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _stateSub?.cancel();
    _player?.dispose();
  }
}
