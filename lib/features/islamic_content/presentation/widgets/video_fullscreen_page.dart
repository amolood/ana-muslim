import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/theme/app_colors.dart';

/// Full-screen landscape video player page.
///
/// Shares the same [VideoPlayerController] as the inline player so there
/// is no re-buffering when transitioning to and from fullscreen.
/// Tapping the video toggles the chrome overlay (top buttons + bottom bar).
class VideoFullscreenPage extends StatefulWidget {
  const VideoFullscreenPage({
    super.key,
    required this.controller,
    required this.supportsPip,
    required this.onEnterPip,
    required this.autoEnterPip,
  });

  final VideoPlayerController controller;
  final bool supportsPip;
  final Future<void> Function() onEnterPip;

  /// When true the page immediately calls [onEnterPip] after the first frame,
  /// used when the user taps the PIP button from the inline player.
  final bool autoEnterPip;

  @override
  State<VideoFullscreenPage> createState() => _VideoFullscreenPageState();
}

class _VideoFullscreenPageState extends State<VideoFullscreenPage> {
  bool _showChrome = true;
  DateTime _lastTickUi = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTick);
    if (widget.autoEnterPip) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_enterPipFromFullscreen());
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTick);
    super.dispose();
  }

  /// Throttled listener — rebuilds at most every 110 ms (220 ms when chrome
  /// is hidden so we avoid any visual jitter during PIP transition).
  void _onTick() {
    if (!mounted) return;
    final now = DateTime.now();
    if (!_showChrome &&
        now.difference(_lastTickUi) < const Duration(milliseconds: 220)) {
      return;
    }
    if (now.difference(_lastTickUi) < const Duration(milliseconds: 110)) {
      return;
    }
    _lastTickUi = now;
    setState(() {});
  }

  Future<void> _enterPipFromFullscreen() async {
    if (widget.autoEnterPip || _showChrome) {
      setState(() {
        _showChrome = false;
      });
    }
    await Future<void>.delayed(const Duration(milliseconds: 40));
    await widget.onEnterPip();
    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    setState(() {
      _showChrome = true;
    });
  }

  Future<void> _seekBy(Duration offset) async {
    final value = widget.controller.value;
    final duration = value.duration;
    if (duration <= Duration.zero) return;
    final target = value.position + offset;
    final safeTarget = target < Duration.zero
        ? Duration.zero
        : (target > duration ? duration : target);
    await widget.controller.seekTo(safeTarget);
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: widget.controller.value.isInitialized
                    ? widget.controller.value.aspectRatio
                    : 16 / 9,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _showChrome = !_showChrome;
                    });
                  },
                  child: VideoPlayer(widget.controller),
                ),
              ),
            ),
            if (_showChrome)
              Positioned(
                top: 14,
                right: 14,
                child: Row(
                  children: [
                    if (widget.supportsPip)
                      IconButton(
                        tooltip: 'نافذة عائمة',
                        onPressed: _enterPipFromFullscreen,
                        icon: const Icon(
                          Icons.picture_in_picture_alt_rounded,
                          color: Colors.white,
                        ),
                      ),
                    IconButton(
                      tooltip: 'إغلاق',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            if (_showChrome)
              Positioned(
                right: 16,
                left: 16,
                bottom: 18,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'رجوع ١٠ ثواني',
                        onPressed: () => _seekBy(const Duration(seconds: -10)),
                        icon: const Icon(
                          Icons.replay_10_rounded,
                          color: Colors.white70,
                          size: 24,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          if (widget.controller.value.isPlaying) {
                            await widget.controller.pause();
                          } else {
                            await widget.controller.play();
                          }
                          if (!mounted) return;
                          setState(() {});
                        },
                        icon: Icon(
                          widget.controller.value.isPlaying
                              ? Icons.pause_circle_filled_rounded
                              : Icons.play_circle_fill_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: VideoProgressIndicator(
                            widget.controller,
                            allowScrubbing: true,
                            colors: VideoProgressColors(
                              playedColor: AppColors.primary,
                              bufferedColor: AppColors.primary.withValues(
                                alpha: 0.4,
                              ),
                              backgroundColor: Colors.white24,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        tooltip: 'تقديم ١٠ ثواني',
                        onPressed: () => _seekBy(const Duration(seconds: 10)),
                        icon: const Icon(
                          Icons.forward_10_rounded,
                          color: Colors.white70,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
