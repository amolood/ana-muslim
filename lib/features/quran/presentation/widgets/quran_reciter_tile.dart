import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../data/models/reciter.dart';
import '../../data/repositories/audio_download_service.dart';
import '../providers/audio_providers.dart';

/// A single row in the reciter selection list inside [QuranAudioSheet].
///
/// Displays the reciter name, active riwaya, play/pause avatar, download state,
/// favorite toggle, and default-reciter toggle. When the reciter has more than
/// one riwaya available for the current surah, a "تغيير الرواية" button opens
/// a secondary picker sheet.
class QuranReciterTile extends ConsumerStatefulWidget {
  const QuranReciterTile({
    super.key,
    required this.reciter,
    required this.surahNumber,
    required this.isDefault,
    required this.isFavorite,
    required this.audioIsPlaying,
    required this.audioIsLoading,
    required this.currentAudioSurah,
    required this.currentAudioReciterId,
    required this.currentAudioMoshafId,
    required this.preferredMoshafId,
  });

  final Reciter reciter;
  final int surahNumber;
  final bool isDefault;
  final bool isFavorite;
  final bool audioIsPlaying;
  final bool audioIsLoading;
  final int? currentAudioSurah;
  final int? currentAudioReciterId;
  final int? currentAudioMoshafId;
  final int? preferredMoshafId;

  @override
  ConsumerState<QuranReciterTile> createState() => _QuranReciterTileState();
}

class _QuranReciterTileState extends ConsumerState<QuranReciterTile> {
  late Moshaf _selectedMoshaf;

  @override
  void initState() {
    super.initState();
    _selectedMoshaf = _resolveSelectedMoshaf();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(moshafDownloadProvider.notifier)
          .checkDownloaded(_selectedMoshaf);
    });
  }

  @override
  void didUpdateWidget(covariant QuranReciterTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.preferredMoshafId == widget.preferredMoshafId) return;

    final next = _resolveSelectedMoshaf();
    if (next.id == _selectedMoshaf.id) return;

    _selectedMoshaf = next;
    ref.read(moshafDownloadProvider.notifier).checkDownloaded(_selectedMoshaf);
  }

  Moshaf _resolveSelectedMoshaf() {
    return widget.reciter.preferredMoshafForSurah(
          widget.surahNumber,
          preferredMoshafId: widget.preferredMoshafId,
        ) ??
        widget.reciter.moshafForSurah(widget.surahNumber)!;
  }

  @override
  Widget build(BuildContext context) {
    final moshafsForSurah = widget.reciter.moshafsForSurah(widget.surahNumber);
    final dlState =
        ref.watch(moshafDownloadProvider)[_selectedMoshaf.id] ??
        const MoshafDownloadState();
    final isSelected =
        widget.currentAudioReciterId == widget.reciter.id &&
        widget.currentAudioSurah == widget.surahNumber &&
        widget.currentAudioMoshafId == _selectedMoshaf.id;
    final isPlaying = widget.audioIsPlaying && isSelected;
    final isLoading = widget.audioIsLoading && isSelected;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.1)
            : Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.5)
              : context.colors.borderDefault,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: dlState.isDownloading
                ? const BorderRadius.vertical(top: Radius.circular(14))
                : BorderRadius.circular(14),
            onTap: () async {
              final notifier = ref.read(quranAudioProvider.notifier);
              // Capture before any await to satisfy use_build_context_synchronously
              final messenger = ScaffoldMessenger.of(context);
              if (isSelected) {
                await notifier.togglePlayPause();
              } else {
                await notifier.play(
                  widget.reciter,
                  _selectedMoshaf,
                  widget.surahNumber,
                );
                // Suggest offline download if the reciter has no local files
                _suggestDownloadIfNeeded(messenger);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Row(
                children: [
                  // ── Play/pause avatar ───────────────────────────
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Center(
                      child: isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // ── Reciter info ────────────────────────────────
                  _buildReciterInfo(
                    context,
                    isSelected: isSelected,
                    moshafsForSurah: moshafsForSurah,
                    dlState: dlState,
                  ),
                  _buildDownloadButton(context, _selectedMoshaf, dlState),
                  // ── Favorite toggle ─────────────────────────────
                  IconButton(
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    tooltip: widget.isFavorite
                        ? 'إزالة من المفضلة'
                        : 'إضافة إلى المفضلة',
                    icon: Icon(
                      widget.isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: widget.isFavorite
                          ? Colors.redAccent
                          : context.colors.iconSecondary,
                      size: 20,
                    ),
                    onPressed: () async {
                      final adding = !widget.isFavorite;
                      await ref
                          .read(favoriteReciterIdsProvider.notifier)
                          .toggle(widget.reciter.id);

                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            adding
                                ? 'تمت إضافة ${widget.reciter.name} إلى المفضلة'
                                : 'تمت إزالة ${widget.reciter.name} من المفضلة',
                            style: GoogleFonts.tajawal(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: AppColors.primary,
                          duration: const Duration(milliseconds: 1500),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                  ),
                  // ── Default reciter toggle ──────────────────────
                  IconButton(
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    tooltip: widget.isDefault
                        ? 'إلغاء القارئ الافتراضي'
                        : 'تعيين كقارئ افتراضي',
                    icon: Icon(
                      widget.isDefault
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: widget.isDefault
                          ? AppColors.primary
                          : context.colors.iconSecondary,
                      size: 20,
                    ),
                    onPressed: () async {
                      if (widget.isDefault) {
                        await ref
                            .read(defaultReciterIdProvider.notifier)
                            .clear();
                        await ref
                            .read(defaultReciterNameProvider.notifier)
                            .clear();
                      } else {
                        await ref
                            .read(defaultReciterIdProvider.notifier)
                            .save(widget.reciter.id);
                        await ref
                            .read(defaultReciterNameProvider.notifier)
                            .save(widget.reciter.name);
                        await ref
                            .read(preferredReciterMoshafProvider.notifier)
                            .saveSelection(
                              widget.reciter.id,
                              _selectedMoshaf.id,
                            );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'تم تعيين ${widget.reciter.name} كقارئ افتراضي',
                              style: GoogleFonts.tajawal(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: AppColors.primary,
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          if (dlState.isDownloading)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: dlState.progress > 0 ? dlState.progress : null,
                    backgroundColor: context.colors.borderSubtle,
                    color: AppColors.primary,
                    minHeight: 3,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dlState.status.isNotEmpty
                        ? dlState.status
                        : 'جاري التحميل… ${(dlState.progress * 100).toInt()}%'
                              ' (${dlState.downloadedCount}/${dlState.totalCount})',
                    style: GoogleFonts.tajawal(
                      fontSize: 11,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReciterInfo(
    BuildContext context, {
    required bool isSelected,
    required List<Moshaf> moshafsForSurah,
    required MoshafDownloadState dlState,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (widget.isDefault) ...[
                const Icon(
                  Icons.star_rounded,
                  color: AppColors.primary,
                  size: 13,
                ),
                const SizedBox(width: 4),
              ],
              if (widget.isFavorite) ...[
                const Icon(
                  Icons.favorite_rounded,
                  color: Colors.redAccent,
                  size: 12,
                ),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  widget.reciter.name,
                  style: GoogleFonts.tajawal(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? AppColors.primary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Row(
            children: [
              if (dlState.isFullyDownloaded) ...[
                const Icon(
                  Icons.offline_bolt_rounded,
                  color: AppColors.primary,
                  size: 11,
                ),
                const SizedBox(width: 3),
              ],
              Expanded(
                child: Text(
                  _selectedMoshaf.name,
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    color: context.colors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (moshafsForSurah.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44),
                child: Material(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _openRiwayaPicker(
                      context,
                      availableMoshafs: moshafsForSurah,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.menu_book_rounded,
                            color: AppColors.primary,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'تغيير الرواية بسهولة',
                              style: GoogleFonts.tajawal(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openRiwayaPicker(
    BuildContext context, {
    required List<Moshaf> availableMoshafs,
  }) async {
    final selected = await showModalBottomSheet<Moshaf>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.62,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'اختيار الرواية',
                      style: GoogleFonts.tajawal(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      'اضغط على الرواية المطلوبة',
                      style: GoogleFonts.tajawal(
                        color: context.colors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: availableMoshafs.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (_, index) {
                        final moshaf = availableMoshafs[index];
                        final isSelected = moshaf.id == _selectedMoshaf.id;
                        return Material(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.14)
                              : Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => Navigator.of(ctx).pop(moshaf),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 58),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            moshaf.name,
                                            style: GoogleFonts.tajawal(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                              fontSize: 14,
                                              fontWeight: isSelected
                                                  ? FontWeight.w700
                                                  : FontWeight.w600,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            isSelected
                                                ? 'محددة الآن'
                                                : 'اضغط للاختيار',
                                            style: GoogleFonts.tajawal(
                                              color: isSelected
                                                  ? AppColors.primary
                                                  : context.colors.textSecondary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Icon(
                                      isSelected
                                          ? Icons.check_circle_rounded
                                          : Icons.radio_button_unchecked_rounded,
                                      color: isSelected
                                          ? AppColors.primary
                                          : context.colors.iconSecondary,
                                      size: 22,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (selected == null || selected.id == _selectedMoshaf.id) return;

    setState(() {
      _selectedMoshaf = selected;
    });

    await ref
        .read(preferredReciterMoshafProvider.notifier)
        .saveSelection(widget.reciter.id, selected.id);
    await ref
        .read(moshafDownloadProvider.notifier)
        .checkDownloaded(selected);

    if (!mounted) return;

    final currentState = ref.read(quranAudioProvider);
    if (currentState.reciter?.id == widget.reciter.id &&
        currentState.surahNumber == widget.surahNumber) {
      await ref
          .read(quranAudioProvider.notifier)
          .play(widget.reciter, selected, widget.surahNumber);
    }
  }

  Widget _buildDownloadButton(
    BuildContext context,
    Moshaf moshaf,
    MoshafDownloadState dlState,
  ) {
    if (dlState.isDownloading) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            value: dlState.progress > 0 ? dlState.progress : null,
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (dlState.isFullyDownloaded) {
      return IconButton(
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        icon: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.redAccent,
          size: 20,
        ),
        tooltip: 'حذف النسخة المحلية',
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              title: Text(
                'حذف التحميل',
                style: GoogleFonts.tajawal(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              content: Text(
                'سيتم حذف القرآن المحمّل لهذه النسخة.',
                style: GoogleFonts.tajawal(
                  color: context.colors.textSecondary,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(
                    'إلغاء',
                    style: GoogleFonts.tajawal(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(
                    'حذف',
                    style: GoogleFonts.tajawal(color: Colors.redAccent),
                  ),
                ),
              ],
            ),
          );
          if (confirmed == true && mounted) {
            await ref.read(moshafDownloadProvider.notifier).delete(moshaf);
          }
        },
      );
    }

    return IconButton(
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      icon: const Icon(
        Icons.download_outlined,
        color: AppColors.textSecondaryDark,
        size: 20,
      ),
      tooltip: 'تحميل للاستماع بدون إنترنت',
      onPressed: () {
        ref.read(moshafDownloadProvider.notifier).startDownload(moshaf);
      },
    );
  }

  /// After selecting a new reciter, check if anything is downloaded.
  /// If nothing is cached locally, show a SnackBar that prompts download.
  void _suggestDownloadIfNeeded(ScaffoldMessengerState messenger) {
    AudioDownloadService.downloadedCount(_selectedMoshaf).then((count) {
      if (count > 0) return; // already has local files — no suggestion needed
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          content: Text(
            '⬇ تحميل ${widget.reciter.name} للاستماع بدون إنترنت',
            style: GoogleFonts.tajawal(fontSize: 13),
          ),
          action: SnackBarAction(
            label: 'تحميل',
            textColor: AppColors.primary,
            onPressed: () {
              // Trigger download for the selected moshaf
              ref
                  .read(moshafDownloadProvider.notifier)
                  .startDownload(_selectedMoshaf);
            },
          ),
        ),
      );
    });
  }
}
