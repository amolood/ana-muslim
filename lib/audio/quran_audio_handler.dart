import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Metadata required to start a new Surah playback session.
/// The notifier resolves the final [audioUrl] (local file:// or remote https://)
/// before handing it here; the handler never touches the network.
class QuranMediaItem {
  final int surahNumber;
  final String surahName;   // Arabic, e.g. "الرحمن"
  final String reciterName; // Arabic, e.g. "مشاري العفاسي"
  final String audioUrl;    // file:// path or https:// URL

  const QuranMediaItem({
    required this.surahNumber,
    required this.surahName,
    required this.reciterName,
    required this.audioUrl,
  });
}

/// [QuranAudioHandler] integrates [just_audio] with [audio_service] to deliver:
///
///  - A persistent **MediaStyle** notification on Android with Surah title,
///    reciter name, and PLAY/PAUSE + STOP controls.
///  - Lock-screen and Bluetooth headset control support via MediaSession.
///  - Correct **foreground-service lifecycle** per Google Play policy:
///    `startForeground` only during audible playback; service stops on pause
///    (notification stays but is dismissible) and is removed entirely on stop.
///
/// This handler is the *sole* owner of the [AudioPlayer] instance.
/// All playback calls from the Riverpod layer must go through this class.
class QuranAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  // Broadcast stream that fires when the user taps "skip to next" in the
  // notification or on a Bluetooth headset. The Riverpod notifier subscribes
  // to this and decides which Surah to play next — the handler intentionally
  // knows nothing about the Surah list.
  final _skipNextController = StreamController<void>.broadcast();

  QuranAudioHandler() {
    // Forward every just_audio playback event into audio_service's playbackState
    // stream so the notification reflects the current player state in real time.
    _player.playbackEventStream.listen(
      _broadcastState,
      onError: (Object e, StackTrace st) {
        if (kDebugMode) {
          debugPrint('[QuranAudioHandler] playbackEvent error: $e\n$st');
        }
      },
    );

    // NOTE: We intentionally do NOT listen to processingStateStream and call
    // stop() on completion. playbackEventStream already broadcasts the
    // AudioProcessingState.completed state to the notification and to the
    // Riverpod notifier, which handles auto-advance to the next Surah.
    // Calling stop() here would dismiss the notification before the next Surah
    // starts, causing a visible flicker.
  }

  // ── Streams exposed to the Riverpod layer ─────────────────────────────────

  /// Real-time position stream (~200 ms cadence) for UI progress bars.
  Stream<Duration> get positionStream => _player.positionStream;

  /// Duration stream — emits once the media is loaded and duration is known.
  Stream<Duration?> get durationStream => _player.durationStream;

  /// Fires a void event whenever the user requests "next Surah" — via the
  /// notification button, a Bluetooth headset, or Android Auto.
  Stream<void> get skipToNextRequested => _skipNextController.stream;

  // ── App-facing playback API ───────────────────────────────────────────────

  /// Load [item] into the player and begin playback immediately.
  ///
  /// - Publishes a [MediaItem] so the notification shows the correct title/artist.
  /// - Calls [AudioPlayer.setUrl] then [AudioPlayer.play]; duration is updated
  ///   in the MediaItem once it becomes available.
  Future<void> playSurah(QuranMediaItem item) async {
    // Publish metadata → drives notification title (Surah name) and subtitle
    // (reciter). The 'id' field must be a unique string; we use the audio URL.
    mediaItem.add(MediaItem(
      id: item.audioUrl,
      title: item.surahName,
      artist: item.reciterName,
      extras: {'surahNumber': item.surahNumber},
    ));

    try {
      await _player.stop();
      await _player.setUrl(item.audioUrl);

      // Update duration in the MediaItem now that just_audio has parsed the
      // stream headers. This enables the notification's seek bar (if shown).
      final knownDuration = _player.duration;
      if (knownDuration != null) {
        mediaItem.add(mediaItem.value!.copyWith(duration: knownDuration));
      }

      await _player.play();
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[QuranAudioHandler] playSurah failed: $e\n$st');
      }
      await stop();
      rethrow; // let the notifier surface the error to the UI
    }
  }

  // ── BaseAudioHandler overrides (called by notification buttons / headsets) ─

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  /// Stop playback and remove the notification.
  ///
  /// Clearing the [mediaItem] before calling [super.stop()] ensures that
  /// audio_service removes the notification channel content before tearing
  /// down the foreground service — prevents a brief "empty" notification flash.
  @override
  Future<void> stop() async {
    await _player.stop();
    mediaItem.add(null); // clear notification content
    await super.stop();  // stop foreground service → dismiss notification
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  /// Called when the user taps the "⏭ Next" button in the notification or
  /// presses the "next track" button on a Bluetooth headset / Android Auto.
  /// We emit on [skipToNextRequested]; the Riverpod notifier handles logic.
  @override
  Future<void> skipToNext() async {
    _skipNextController.add(null);
  }

  /// Called when the user swipes the app from the Recent Apps list.
  ///
  /// If audio is actively playing we let it continue — the foreground service
  /// keeps the process alive and the notification remains visible with controls.
  /// If audio is already paused (no foreground lock), we clean up so the
  /// notification does not linger as a stale entry.
  @override
  Future<void> onTaskRemoved() async {
    if (!_player.playing) {
      await stop();
    }
    // While playing: do nothing — foreground service keeps the process alive.
  }

  // ── Internal state broadcasting ───────────────────────────────────────────

  /// Translates a [PlaybackEvent] from [just_audio] into an [audio_service]
  /// [PlaybackState] and pushes it to the BehaviorSubject that drives the
  /// Android MediaStyle notification.
  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;
    final ps = _player.processingState;

    // Lazily update MediaItem duration once just_audio resolves it from the
    // file/network headers. This is the earliest reliable point to know it.
    final knownDuration = _player.duration;
    final currentItem = mediaItem.value;
    if (currentItem != null &&
        knownDuration != null &&
        currentItem.duration != knownDuration) {
      mediaItem.add(currentItem.copyWith(duration: knownDuration));
    }

    playbackState.add(
      PlaybackState(
        // Notification action buttons (shown in order in the expanded view):
        //   Index 0 — PAUSE when playing, PLAY when paused (toggle)
        //   Index 1 — STOP  (always present)
        //   Index 2 — SKIP TO NEXT (always present)
        controls: [
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],

        // System-level actions exposed to lock screen, Android Auto, and
        // Bluetooth headsets. skipToNext maps to the headset "next track" button.
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
          MediaAction.skipToNext,
        },

        // Compact notification (condensed shade) shows play/pause + skip-next.
        // STOP is still reachable from the expanded view.
        androidCompactActionIndices: const [0, 2],

        // Map just_audio ProcessingState → audio_service AudioProcessingState.
        // The notification uses this to decide when to show the loading spinner.
        processingState: const {
          ProcessingState.idle:      AudioProcessingState.idle,
          ProcessingState.loading:   AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready:     AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[ps] ?? AudioProcessingState.idle,

        playing: playing,
        // Position reported to the notification's seek bar.
        updatePosition: _player.position,
        bufferedPosition: event.bufferedPosition,
        speed: _player.speed,
      ),
    );
  }
}
