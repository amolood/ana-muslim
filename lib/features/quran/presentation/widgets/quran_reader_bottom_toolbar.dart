import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/utils/arabic_utils.dart';
import '../providers/audio_providers.dart';

/// Floating bottom toolbar shown in the Quran reader.
/// Displays audio controls, bookmarks, tafsir, share and page navigation.
class QuranReaderBottomToolbar extends StatelessWidget {
  const QuranReaderBottomToolbar({
    super.key,
    required this.isPageMode,
    required this.isFavorite,
    required this.isListenActive,
    required this.audioState,
    required this.currentPage,
    required this.totalPages,
    required this.onFontSize,
    required this.onBookmark,
    required this.onLongPressBookmark,
    required this.onTafsir,
    required this.onWordInfo,
    required this.onListen,
    required this.onLongPressListen,
    required this.onShare,
    required this.onTogglePlayPause,
    required this.onStop,
    required this.onAudioSettings,
    required this.onPrevPage,
    required this.onNextPage,
    required this.onJumpPage,
  });

  final bool isPageMode;
  final bool isFavorite;
  final bool isListenActive;
  final QuranAudioState audioState;
  final int currentPage;
  final int totalPages;

  // Toolbar actions
  final VoidCallback onFontSize;
  final VoidCallback onBookmark;
  final VoidCallback onLongPressBookmark;
  final VoidCallback onTafsir;
  final VoidCallback onWordInfo;
  final VoidCallback onListen;
  final VoidCallback onLongPressListen;
  final VoidCallback onShare;

  // Audio bar actions
  final VoidCallback onTogglePlayPause;
  final VoidCallback onStop;
  final VoidCallback onAudioSettings;

  // Page navigator actions
  final VoidCallback? onPrevPage;
  final VoidCallback? onNextPage;
  final VoidCallback onJumpPage;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (audioState.hasAudio)
          _QuranAudioBar(
            audioState: audioState,
            onTogglePlayPause: onTogglePlayPause,
            onStop: onStop,
            onSettings: onAudioSettings,
          ),
        if (isPageMode)
          _QuranPageNavigator(
            currentPage: currentPage,
            totalPages: totalPages,
            onPrevPage: onPrevPage,
            onNextPage: onNextPage,
            onJumpPage: onJumpPage,
          ),
        Container(
          height: 64,
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: context.colors.borderSubtle),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ToolbarItem(
                icon: Icons.text_fields,
                label: 'الخط',
                onTap: onFontSize,
              ),
              _Divider(),
              _ToolbarItem(
                icon: isFavorite ? Icons.bookmark : Icons.bookmark_border,
                label: 'حفظ',
                isActive: isFavorite,
                onTap: onBookmark,
                onLongPress: onLongPressBookmark,
              ),
              _Divider(),
              _ToolbarItem(
                icon: Icons.menu_book,
                label: 'تفسير',
                onTap: onTafsir,
              ),
              _Divider(),
              _ToolbarItem(
                icon: Icons.info_outline,
                label: 'كلمة',
                onTap: onWordInfo,
              ),
              _Divider(),
              _ToolbarItem(
                icon: Icons.headphones_outlined,
                label: 'استماع',
                isActive: isListenActive,
                onTap: onListen,
                onLongPress: onLongPressListen,
              ),
              _Divider(),
              _ToolbarItem(
                icon: Icons.ios_share,
                label: 'نشر',
                onTap: onShare,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Collapsed hint shown when the toolbar is hidden.
class QuranReaderControlsHint extends StatelessWidget {
  const QuranReaderControlsHint({super.key, required this.onShow});

  final VoidCallback onShow;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onShow,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: context.colors.borderSubtle),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.keyboard_arrow_up_rounded,
                  color: context.colors.iconSecondary,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  'إظهار الأدوات',
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Internal sub-widgets ──────────────────────────────────────────────────────

class _QuranAudioBar extends StatelessWidget {
  const _QuranAudioBar({
    required this.audioState,
    required this.onTogglePlayPause,
    required this.onStop,
    required this.onSettings,
  });

  final QuranAudioState audioState;
  final VoidCallback onTogglePlayPause;
  final VoidCallback onStop;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final duration = audioState.duration;
    final hasDuration = duration != null && duration.inMilliseconds > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _AudioControlButton(
                icon: audioState.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                label: audioState.isPlaying ? 'مؤقت' : 'تشغيل',
                isLoading: audioState.isLoading,
                onTap: onTogglePlayPause,
              ),
              const SizedBox(width: 8),
              _AudioControlButton(
                icon: Icons.stop_rounded,
                label: 'إيقاف',
                onTap: onStop,
              ),
              const SizedBox(width: 8),
              _AudioControlButton(
                icon: Icons.tune_rounded,
                label: 'اختيار',
                onTap: onSettings,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      audioState.reciter?.name ?? '',
                      style: GoogleFonts.tajawal(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color:
                            Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (audioState.moshaf != null)
                      Text(
                        audioState.moshaf!.name,
                        style: GoogleFonts.tajawal(
                          fontSize: 11,
                          color: context.colors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (hasDuration) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 4,
                value: audioState.progress,
                backgroundColor: context.colors.borderSubtle,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ArabicUtils.formatDuration(audioState.position),
                  style: GoogleFonts.tajawal(
                    fontSize: 11,
                    color: context.colors.textSecondary,
                  ),
                ),
                Text(
                  ArabicUtils.formatDuration(duration),
                  style: GoogleFonts.tajawal(
                    fontSize: 11,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

}

class _AudioControlButton extends StatelessWidget {
  const _AudioControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          width: 54,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: isLoading
                    ? const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      )
                    : Icon(icon, color: AppColors.primary, size: 19),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.tajawal(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuranPageNavigator extends StatelessWidget {
  const _QuranPageNavigator({
    required this.currentPage,
    required this.totalPages,
    required this.onPrevPage,
    required this.onNextPage,
    required this.onJumpPage,
  });

  final int currentPage;
  final int totalPages;
  final VoidCallback? onPrevPage;
  final VoidCallback? onNextPage;
  final VoidCallback onJumpPage;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.borderSubtle),
      ),
      child: Row(
        children: [
          Expanded(
            child: _PageNavButton(
              label: 'السابق',
              icon: Icons.arrow_back_ios_new_rounded,
              onPressed: onPrevPage,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _PageNavButton(
              label: 'التالي',
              icon: Icons.arrow_forward_ios_rounded,
              onPressed: onNextPage,
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: onJumpPage,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  'صفحة',
                  style: GoogleFonts.tajawal(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageNavButton extends StatelessWidget {
  const _PageNavButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        side: BorderSide(color: context.colors.borderDefault),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.tajawal(
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolbarItem extends StatelessWidget {
  const _ToolbarItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.onLongPress,
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isActive
                    ? AppColors.primary
                    : Theme.of(context).colorScheme.onSurface,
                size: 22,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: GoogleFonts.tajawal(
                  fontSize: 10,
                  color: isActive
                      ? AppColors.primary
                      : context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      color: context.colors.borderSubtle,
    );
  }
}
