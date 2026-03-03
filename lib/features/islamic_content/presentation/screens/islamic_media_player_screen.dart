import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/arabic_utils.dart';

class IslamicMediaPlayerScreen extends StatefulWidget {
  const IslamicMediaPlayerScreen({
    required this.url,
    required this.title,
    required this.isVideo,
    super.key,
  });

  final String url;
  final String title;
  final bool isVideo;

  @override
  State<IslamicMediaPlayerScreen> createState() =>
      _IslamicMediaPlayerScreenState();
}

class _IslamicMediaPlayerScreenState extends State<IslamicMediaPlayerScreen> {
  VideoPlayerController? _videoController;
  AudioPlayer? _audioPlayer;
  Duration _audioDuration = Duration.zero;
  Duration _audioPosition = Duration.zero;
  String? _error;
  bool _loading = true;

  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<PlayerState>? _playerStateSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  @override
  void dispose() {
    _durationSub?.cancel();
    _positionSub?.cancel();
    _playerStateSub?.cancel();
    _videoController?.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    if (widget.isVideo) {
      await _initVideo();
    } else {
      await _initAudio();
    }

    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _initVideo() async {
    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.url),
        httpHeaders: const {'User-Agent': 'Mozilla/5.0', 'Accept': '*/*'},
      );
      await controller.initialize();
      await controller.setLooping(false);
      controller.addListener(() {
        if (!mounted) return;
        if (controller.value.hasError && _error == null) {
          setState(() {
            _error = 'تعذر تشغيل الفيديو على هذا الجهاز';
          });
        }
      });
      _videoController = controller;
    } catch (e) {
      _error = 'تعذر تشغيل الفيديو';
    }
  }

  Future<void> _initAudio() async {
    try {
      final player = AudioPlayer();
      await player.setUrl(widget.url);
      _audioPlayer = player;

      _durationSub = player.durationStream.listen((duration) {
        if (!mounted) return;
        setState(() {
          _audioDuration = duration ?? Duration.zero;
        });
      });

      _positionSub = player.positionStream.listen((position) {
        if (!mounted) return;
        setState(() {
          _audioPosition = position;
        });
      });

      _playerStateSub = player.playerStateStream.listen((state) {
        if (!mounted) return;
        if (state.processingState == ProcessingState.completed) {
          player.seek(Duration.zero);
        }
        setState(() {});
      });
    } catch (e) {
      _error = 'تعذر تشغيل الملف الصوتي';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.isVideo ? 'تشغيل الفيديو' : 'تشغيل الصوت',
          style: GoogleFonts.tajawal(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary(context),
          ),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              )
            : _error != null
            ? _ErrorView(message: _error!, onRetry: _init)
            : widget.isVideo
            ? _buildVideo(context)
            : _buildAudio(context),
      ),
    );
  }

  Widget _buildVideo(BuildContext context) {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) {
      return _ErrorView(message: 'الفيديو غير متاح للتشغيل', onRetry: _init);
    }

    final isPlaying = controller.value.isPlaying;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        Text(
          widget.title,
          style: GoogleFonts.tajawal(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary(context),
            height: 1.35,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border(context)),
          ),
          clipBehavior: Clip.antiAlias,
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(controller),
                IconButton(
                  onPressed: () {
                    if (controller.value.isPlaying) {
                      controller.pause();
                    } else {
                      controller.play();
                    }
                    setState(() {});
                  },
                  iconSize: 64,
                  color: Colors.white,
                  icon: Icon(
                    isPlaying
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_fill_rounded,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        VideoProgressIndicator(
          controller,
          allowScrubbing: true,
          colors: VideoProgressColors(
            playedColor: AppColors.primary,
            bufferedColor: AppColors.primary.withValues(alpha: 0.35),
            backgroundColor: AppColors.surfaceElevated(context),
          ),
        ),
      ],
    );
  }

  Widget _buildAudio(BuildContext context) {
    final player = _audioPlayer;
    if (player == null) {
      return _ErrorView(message: 'الصوت غير متاح للتشغيل', onRetry: _init);
    }

    final isPlaying = player.playing;
    final maxMs = _audioDuration.inMilliseconds <= 0
        ? 1
        : _audioDuration.inMilliseconds;
    final valueMs = _audioPosition.inMilliseconds.clamp(0, maxMs);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Column(
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.14),
                ),
                child: const Icon(
                  Icons.graphic_eq_rounded,
                  color: AppColors.primary,
                  size: 38,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.tajawal(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary(context),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              Slider(
                value: valueMs.toDouble(),
                min: 0,
                max: maxMs.toDouble(),
                activeColor: AppColors.primary,
                inactiveColor: AppColors.surfaceElevated(context),
                onChanged: (value) {
                  player.seek(Duration(milliseconds: value.round()));
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ArabicUtils.formatDuration(_audioPosition),
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                    Text(
                      ArabicUtils.formatDuration(_audioDuration),
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 56,
                    color: AppColors.primary,
                    onPressed: () async {
                      if (isPlaying) {
                        await player.pause();
                      } else {
                        await player.play();
                      }
                      if (!mounted) return;
                      setState(() {});
                    },
                    icon: Icon(
                      isPlaying
                          ? Icons.pause_circle_filled_rounded
                          : Icons.play_circle_fill_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    iconSize: 38,
                    color: AppColors.textSecondary(context),
                    onPressed: () async {
                      await player.stop();
                      await player.seek(Duration.zero);
                      if (!mounted) return;
                      setState(() {});
                    },
                    icon: const Icon(Icons.stop_circle_rounded),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
          ),
          child: Text(
            message,
            style: GoogleFonts.tajawal(
              fontSize: 13,
              color: Colors.red.shade300,
            ),
          ),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: onRetry,
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
}
