import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../core/services/pip_mode_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/arabic_utils.dart';
import '../../data/models/islamhouse_attachment.dart';
import 'round_control_button.dart';
import 'video_fullscreen_page.dart';

class InlineMediaPlayer extends StatefulWidget {
  const InlineMediaPlayer({
    required this.attachment,
    required this.title,
    super.key,
  });

  final IslamhouseAttachment attachment;
  final String title;

  @override
  State<InlineMediaPlayer> createState() => _InlineMediaPlayerState();
}

class _InlineMediaPlayerState extends State<InlineMediaPlayer> {
  VideoPlayerController? _videoController;
  AudioPlayer? _audioPlayer;

  StreamSubscription<Duration?>? _audioDurationSub;
  StreamSubscription<Duration>? _audioPositionSub;
  StreamSubscription<PlayerState>? _audioStateSub;

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _error;
  bool _isLoading = true;
  bool _isMuted = false;
  bool _supportsPip = false;
  bool _keepAwakeEnabled = false;
  DateTime _lastVideoUiTick = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastAudioUiTick = DateTime.fromMillisecondsSinceEpoch(0);
  Duration _lastAudioUiPosition = Duration.zero;

  bool get _isVideo => widget.attachment.isVideo;

  @override
  void initState() {
    super.initState();
    unawaited(_checkPipSupport());
    unawaited(_initialize());
  }

  @override
  void didUpdateWidget(covariant InlineMediaPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final changedUrl = oldWidget.attachment.url != widget.attachment.url;
    final changedType =
        oldWidget.attachment.normalizedType != widget.attachment.normalizedType;
    if (changedUrl || changedType) {
      unawaited(_disposePlayers());
      unawaited(_initialize());
    }
  }

  @override
  void dispose() {
    unawaited(_disableKeepAwake());
    _audioDurationSub?.cancel();
    _audioPositionSub?.cancel();
    _audioStateSub?.cancel();
    _videoController?.removeListener(_onVideoTick);
    _videoController?.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  Future<void> _checkPipSupport() async {
    final supported = await PipModeService.isSupported();
    if (!mounted) return;
    setState(() {
      _supportsPip = supported;
    });
  }

  Future<void> _initialize() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _duration = Duration.zero;
      _position = Duration.zero;
      _isMuted = false;
    });

    if (_isVideo) {
      await _initVideo();
    } else if (widget.attachment.isAudio) {
      await _initAudio();
    } else {
      _error = 'هذا النوع غير مدعوم داخل التطبيق';
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _initVideo() async {
    try {
      final uri = Uri.tryParse(widget.attachment.url);
      if (uri == null) {
        _error = 'رابط الفيديو غير صالح';
        return;
      }

      final controller = VideoPlayerController.networkUrl(
        uri,
        httpHeaders: const {'User-Agent': 'Mozilla/5.0', 'Accept': '*/*'},
      );
      await controller.initialize();
      await controller.setLooping(false);
      controller.addListener(_onVideoTick);

      if (!mounted) {
        controller.dispose();
        return;
      }

      _videoController = controller;
      _duration = controller.value.duration;
      _position = controller.value.position;
    } catch (_) {
      _error = 'تعذر تشغيل الفيديو';
    }
  }

  Future<void> _initAudio() async {
    try {
      final player = AudioPlayer();
      await player.setUrl(widget.attachment.url);

      _audioPlayer = player;
      _duration = player.duration ?? Duration.zero;

      _audioDurationSub = player.durationStream.listen((duration) {
        if (!mounted) return;
        setState(() {
          _duration = duration ?? Duration.zero;
        });
      });

      _audioPositionSub = player.positionStream.listen((position) {
        if (!mounted) return;
        final now = DateTime.now();
        final deltaMs = (position - _lastAudioUiPosition).inMilliseconds.abs();
        if (deltaMs < 120 &&
            now.difference(_lastAudioUiTick) <
                const Duration(milliseconds: 120)) {
          return;
        }
        _lastAudioUiTick = now;
        _lastAudioUiPosition = position;
        setState(() {
          _position = position;
        });
      });

      _audioStateSub = player.playerStateStream.listen((state) {
        if (!mounted) return;
        if (state.processingState == ProcessingState.completed) {
          player.seek(Duration.zero);
          player.pause();
        }
        setState(() {});
      });
    } catch (_) {
      _error = 'تعذر تشغيل الملف الصوتي';
    }
  }

  Future<void> _disposePlayers() async {
    _audioDurationSub?.cancel();
    _audioPositionSub?.cancel();
    _audioStateSub?.cancel();
    _audioDurationSub = null;
    _audioPositionSub = null;
    _audioStateSub = null;

    await _audioPlayer?.stop();
    await _audioPlayer?.dispose();
    _audioPlayer = null;

    _videoController?.removeListener(_onVideoTick);
    await _videoController?.pause();
    await _videoController?.dispose();
    _videoController = null;

    await _disableKeepAwake();
  }

  void _onVideoTick() {
    final controller = _videoController;
    if (controller == null || !mounted) return;

    final value = controller.value;

    if (value.hasError && _error == null) {
      setState(() {
        _error = 'تعذر تشغيل الفيديو';
      });
      return;
    }

    final shouldKeepAwake = value.isPlaying;
    if (shouldKeepAwake != _keepAwakeEnabled) {
      unawaited(shouldKeepAwake ? _enableKeepAwake() : _disableKeepAwake());
    }

    final now = DateTime.now();
    if (now.difference(_lastVideoUiTick) < const Duration(milliseconds: 80)) {
      return;
    }
    _lastVideoUiTick = now;

    setState(() {
      _duration = value.duration;
      _position = value.position;
    });
  }

  Future<void> _enableKeepAwake() async {
    if (_keepAwakeEnabled) return;
    _keepAwakeEnabled = true;
    await WakelockPlus.enable();
  }

  Future<void> _disableKeepAwake() async {
    if (!_keepAwakeEnabled) return;
    _keepAwakeEnabled = false;
    await WakelockPlus.disable();
  }

  Future<void> _togglePlayPause() async {
    if (_isVideo) {
      final controller = _videoController;
      if (controller == null || !controller.value.isInitialized) return;
      if (controller.value.isPlaying) {
        await controller.pause();
      } else {
        await controller.play();
      }
      return;
    }

    final player = _audioPlayer;
    if (player == null) return;
    if (player.playing) {
      await player.pause();
    } else {
      await player.play();
    }
  }

  Future<void> _stopPlayback() async {
    if (_isVideo) {
      final controller = _videoController;
      if (controller == null) return;
      await controller.pause();
      await controller.seekTo(Duration.zero);
      return;
    }

    final player = _audioPlayer;
    if (player == null) return;
    await player.pause();
    await player.seek(Duration.zero);
  }

  Future<void> _seekBy(Duration offset) async {
    final target = _position + offset;
    final safeTarget = target < Duration.zero
        ? Duration.zero
        : (target > _duration ? _duration : target);

    if (_isVideo) {
      final controller = _videoController;
      if (controller == null) return;
      await controller.seekTo(safeTarget);
      return;
    }

    final player = _audioPlayer;
    if (player == null) return;
    await player.seek(safeTarget);
  }

  Future<void> _seekToMs(double value) async {
    final durationMs = _duration.inMilliseconds;
    if (durationMs <= 0) return;

    final target = Duration(milliseconds: value.round());
    if (_isVideo) {
      final controller = _videoController;
      if (controller == null) return;
      await controller.seekTo(target);
      return;
    }

    final player = _audioPlayer;
    if (player == null) return;
    await player.seek(target);
  }

  Future<void> _toggleMute() async {
    final controller = _videoController;
    if (controller == null) return;

    final nextMuted = !_isMuted;
    await controller.setVolume(nextMuted ? 0 : 1);
    if (!mounted) return;
    setState(() {
      _isMuted = nextMuted;
    });
  }

  Future<void> _openFullscreen({bool autoEnterPip = false}) async {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VideoFullscreenPage(
          controller: controller,
          supportsPip: _supportsPip,
          onEnterPip: _enterPip,
          autoEnterPip: autoEnterPip,
        ),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openPipFromInline() => _openFullscreen(autoEnterPip: true);

  Future<void> _enterPip() async {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;

    final aspect = controller.value.aspectRatio;
    final denominator = 1000;
    final numerator = (aspect * denominator).round().clamp(1, 23939);

    final entered = await PipModeService.enterPipMode(
      aspectRatioNumerator: numerator,
      aspectRatioDenominator: denominator,
    );

    if (!mounted || entered) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تعذر تشغيل وضع النافذة العائمة على هذا الجهاز',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: _isLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              ),
            )
          : _error != null
          ? _buildError(context)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.tajawal(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 10),
                if (_isVideo) _buildVideoPlayer(context) else _buildAudioHero(),
                const SizedBox(height: 10),
                _buildProgress(context),
                const SizedBox(height: 8),
                _buildControls(context),
              ],
            ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _error!,
          style: GoogleFonts.tajawal(
            color: Colors.red.shade300,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: _initialize,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.black,
          ),
          icon: const Icon(Icons.refresh_rounded),
          label: Text(
            'إعادة المحاولة',
            style: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPlayer(BuildContext context) {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    final value = controller.value;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black,
      ),
      child: GestureDetector(
        onTap: _togglePlayPause,
        child: AspectRatio(
          aspectRatio: value.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(controller),
              IgnorePointer(
                ignoring: value.isPlaying,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: value.isPlaying ? 0 : 1,
                  child: Container(
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAudioHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.16),
            ),
            child: const Icon(
              Icons.graphic_eq_rounded,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'تشغيل صوتي',
            style: GoogleFonts.tajawal(
              color: AppColors.textSecondary(context),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress(BuildContext context) {
    final maxMs = _duration.inMilliseconds <= 0 ? 1 : _duration.inMilliseconds;
    final posMs = _position.inMilliseconds.clamp(0, maxMs);
    final playedFraction = (posMs / maxMs).clamp(0.0, 1.0);
    final bufferedFraction = _bufferedFraction();

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: [
          Container(
            height: 6,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: AppColors.surface(context),
            ),
            child: Stack(
              children: [
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: bufferedFraction,
                  child: Container(color: AppColors.border(context)),
                ),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: playedFraction,
                  child: Container(color: AppColors.primary),
                ),
              ],
            ),
          ),
          Slider(
            value: posMs.toDouble(),
            min: 0,
            max: maxMs.toDouble(),
            activeColor: AppColors.primary,
            inactiveColor: AppColors.border(context),
            thumbColor: AppColors.primary,
            onChanged: _seekToMs,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Text(
                  ArabicUtils.formatDuration(_position),
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const Spacer(),
                Text(
                  ArabicUtils.formatDuration(_duration),
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    final isPlaying = _isVideo
        ? (_videoController?.value.isPlaying ?? false)
        : (_audioPlayer?.playing ?? false);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        RoundControlButton(
          icon: Icons.replay_10_rounded,
          label: '-١٠',
          onTap: () => _seekBy(const Duration(seconds: -10)),
        ),
        RoundControlButton(
          icon: isPlaying
              ? Icons.pause_circle_filled_rounded
              : Icons.play_circle_fill_rounded,
          label: isPlaying ? 'إيقاف مؤقت' : 'تشغيل',
          size: 64,
          iconSize: 34,
          highlighted: true,
          onTap: _togglePlayPause,
        ),
        RoundControlButton(
          icon: Icons.forward_10_rounded,
          label: '+١٠',
          onTap: () => _seekBy(const Duration(seconds: 10)),
        ),
        RoundControlButton(
          icon: Icons.stop_circle_rounded,
          label: 'إيقاف',
          onTap: _stopPlayback,
        ),
        if (_isVideo)
          RoundControlButton(
            icon: _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
            label: _isMuted ? 'إلغاء الكتم' : 'كتم',
            onTap: _toggleMute,
          ),
        if (_isVideo)
          RoundControlButton(
            icon: Icons.fullscreen_rounded,
            label: 'ملء الشاشة',
            onTap: _openFullscreen,
          ),
        if (_isVideo && _supportsPip)
          RoundControlButton(
            icon: Icons.picture_in_picture_alt_rounded,
            label: 'نافذة',
            onTap: _openPipFromInline,
          ),
      ],
    );
  }

  double _bufferedFraction() {
    if (!_isVideo) return 0;
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return 0;
    final durationMs = controller.value.duration.inMilliseconds;
    if (durationMs <= 0) return 0;
    final buffered = controller.value.buffered;
    if (buffered.isEmpty) return 0;
    final endMs = buffered.last.end.inMilliseconds;
    return (endMs / durationMs).clamp(0.0, 1.0);
  }
}
