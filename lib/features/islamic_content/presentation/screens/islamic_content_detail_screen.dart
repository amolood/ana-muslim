import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/arabic_utils.dart';
import '../../data/models/islamhouse_attachment.dart';
import '../../data/models/islamhouse_item.dart';
import '../providers/islamic_content_providers.dart';
import '../widgets/inline_media_player.dart';
import 'islamic_pdf_viewer_screen.dart';

class IslamicContentDetailScreen extends ConsumerStatefulWidget {
  const IslamicContentDetailScreen({required this.itemId, super.key});

  final int itemId;

  @override
  ConsumerState<IslamicContentDetailScreen> createState() =>
      _IslamicContentDetailScreenState();
}

class _IslamicContentDetailScreenState
    extends ConsumerState<IslamicContentDetailScreen> {
  static const Set<String> _inlineMediaTypes = <String>{
    'videos',
    'video',
    'audios',
    'audio',
    'khotab',
    'khotba',
    'khotbah',
    'khutbah',
  };

  bool _showFullText = false;
  String? _selectedMediaUrl;

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(
      islamhouseItemDetailsProvider(widget.itemId),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'تفاصيل المحتوى',
          style: GoogleFonts.tajawal(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary(context),
          ),
        ),
      ),
      body: SafeArea(
        child: detailsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          ),
          error: (error, _) => _ErrorView(
            message: 'تعذر تحميل تفاصيل المحتوى',
            onRetry: () {
              ref.invalidate(islamhouseItemDetailsProvider(widget.itemId));
            },
          ),
          data: (item) => _buildContent(context, item),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, IslamhouseItem item) {
    final description = _contentText(item);
    final hasDescription = description.trim().isNotEmpty;
    final isLong = description.length > 1600;
    final visibleText = isLong && !_showFullText
        ? '${description.substring(0, 1600)}...'
        : description;

    final normalizedType = item.normalizedType;
    final canRenderInlineMedia = _inlineMediaTypes.contains(normalizedType);
    final isArticleType =
        normalizedType == 'articles' || normalizedType == 'article';

    final mediaAttachments = canRenderInlineMedia
        ? item.attachments
              .where((attachment) => attachment.isAudio || attachment.isVideo)
              .toList(growable: false)
        : const <IslamhouseAttachment>[];
    final pdfAttachments = item.attachments
        .where((attachment) => attachment.isPdf)
        .toList(growable: false);

    final hasAttachmentMeta =
        mediaAttachments.isNotEmpty || pdfAttachments.isNotEmpty;

    final selectedMedia = mediaAttachments.isEmpty
        ? null
        : mediaAttachments.firstWhere(
            (attachment) => attachment.url == _selectedMediaUrl,
            orElse: () => mediaAttachments.first,
          );
    final selectedMediaUrl = selectedMedia?.url;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
      children: [
        _HeroHeader(item: item),
        const SizedBox(height: 12),
        _QuickInfoSection(item: item, hasAttachmentMeta: hasAttachmentMeta),
        if (selectedMedia != null) ...[
          const SizedBox(height: 12),
          _SectionCard(
            title: 'المشغّل',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (mediaAttachments.length > 1)
                  _PartsSelector(
                    attachments: mediaAttachments,
                    selectedUrl: _selectedMediaUrl ?? selectedMediaUrl,
                    onSelected: (attachmentUrl) {
                      setState(() {
                        _selectedMediaUrl = attachmentUrl;
                      });
                    },
                  ),
                if (mediaAttachments.length > 1) const SizedBox(height: 10),
                InlineMediaPlayer(attachment: selectedMedia, title: item.title),
              ],
            ),
          ),
        ],
        if (pdfAttachments.isNotEmpty) ...[
          const SizedBox(height: 12),
          _SectionCard(
            title: isArticleType ? 'المقال الكامل' : 'الكتب والملفات',
            child: Column(
              children: [
                for (final attachment in pdfAttachments) ...[
                  _PdfAttachmentTile(title: item.title, attachment: attachment),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ],
        if (hasDescription) ...[
          const SizedBox(height: 12),
          _SectionCard(
            title: 'محتوى',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  visibleText,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.tajawal(
                    fontSize: 14,
                    height: 1.7,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                if (isLong)
                  TextButton.icon(
                    onPressed: () {
                      setState(() => _showFullText = !_showFullText);
                    },
                    icon: Icon(
                      _showFullText
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                    ),
                    label: Text(
                      _showFullText ? 'عرض أقل' : 'عرض المزيد',
                      style: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
          ),
        ],
        if (!hasDescription &&
            selectedMedia == null &&
            pdfAttachments.isEmpty) ...[
          const SizedBox(height: 12),
          _SectionCard(
            title: 'محتوى',
            child: Text(
              'لا توجد مادة نصية إضافية لهذا العنصر.',
              style: GoogleFonts.tajawal(
                fontSize: 13,
                color: AppColors.textSecondary(context),
                height: 1.55,
              ),
            ),
          ),
        ],
        if (item.contributors.isNotEmpty) ...[
          const SizedBox(height: 12),
          _SectionCard(
            title: 'إعداد / نشر',
            child: Column(
              children: item.contributors
                  .map((c) => _ContributorTile(contributor: c))
                  .toList(growable: false),
            ),
          ),
        ],
      ],
    );
  }

  String _contentText(IslamhouseItem item) {
    final full = IslamhouseItem.stripHtml(item.fullDescription ?? '');
    if (full.isNotEmpty) return full;

    final rich = IslamhouseItem.stripHtml(item.content ?? '');
    if (rich.isNotEmpty) return rich;

    final desc = IslamhouseItem.stripHtml(item.description ?? '');
    return desc;
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.item});

  final IslamhouseItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_iconForType(item.type), color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.tajawal(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary(context),
                    height: 1.35,
                  ),
                ),
                if (item.primaryDescription.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    item.primaryDescription,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      color: AppColors.textSecondary(context),
                      height: 1.45,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickInfoSection extends StatelessWidget {
  const _QuickInfoSection({
    required this.item,
    required this.hasAttachmentMeta,
  });

  final IslamhouseItem item;
  final bool hasAttachmentMeta;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      _InfoChip(label: item.displayType, icon: _iconForType(item.type)),
      if (item.addDate > 0)
        _InfoChip(
          label: _formatUnixDate(item.addDate),
          icon: Icons.calendar_month_outlined,
        ),
      if (hasAttachmentMeta)
        _InfoChip(
          label:
              'المرفقات ${ArabicUtils.toArabicDigits(item.attachments.length)}',
          icon: Icons.attachment_rounded,
        ),
    ];

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return _SectionCard(
      title: 'معلومات سريعة',
      child: Wrap(spacing: 8, runSpacing: 8, children: chips),
    );
  }
}

class _AttachmentSelectorChip extends StatelessWidget {
  const _AttachmentSelectorChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.2)
              : AppColors.surface(context),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border(context),
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.tajawal(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected
                ? AppColors.primary
                : AppColors.textSecondary(context),
          ),
        ),
      ),
    );
  }
}

class _PdfAttachmentTile extends StatelessWidget {
  const _PdfAttachmentTile({required this.title, required this.attachment});

  final String title;
  final IslamhouseAttachment attachment;

  @override
  Widget build(BuildContext context) {
    final label = attachment.description.trim().isNotEmpty
        ? attachment.description.trim()
        : 'ملف PDF';

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border(context).withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.tajawal(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            attachment.size.trim().isEmpty
                ? 'PDF'
                : 'PDF • ${ArabicUtils.toArabicDigitsFromText(attachment.size)}',
            style: GoogleFonts.tajawal(
              fontSize: 11,
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      IslamicPdfViewerScreen(url: attachment.url, title: title),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              minimumSize: const Size.fromHeight(42),
            ),
            icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
            label: Text(
              'عرض PDF',
              style: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _PartsSelector extends StatelessWidget {
  const _PartsSelector({
    required this.attachments,
    required this.selectedUrl,
    required this.onSelected,
  });

  final List<IslamhouseAttachment> attachments;
  final String? selectedUrl;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الأجزاء ${ArabicUtils.toArabicDigits(attachments.length)}',
          style: GoogleFonts.tajawal(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary(context),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: attachments.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final attachment = attachments[index];
              final label = _attachmentPartLabel(
                attachment: attachment,
                index: index,
              );
              return _AttachmentSelectorChip(
                label: label,
                selected: attachment.url == selectedUrl,
                onTap: () => onSelected(attachment.url),
              );
            },
          ),
        ),
      ],
    );
  }

  static String _attachmentPartLabel({
    required IslamhouseAttachment attachment,
    required int index,
  }) {
    final description = attachment.description.trim();
    if (description.isNotEmpty) {
      return ArabicUtils.toArabicDigitsFromText(description);
    }
    final part = ArabicUtils.toArabicDigits(index + 1);
    if (attachment.isVideo) return 'فيديو $part';
    if (attachment.isAudio) return 'صوت $part';
    if (attachment.isPdf) return 'PDF $part';
    return 'ملف $part';
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.tajawal(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _ContributorTile extends StatelessWidget {
  const _ContributorTile({required this.contributor});

  final IslamhouseContributor contributor;

  @override
  Widget build(BuildContext context) {
    final isAuthor = contributor.kind == 'author';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          Icon(
            isAuthor ? Icons.person_rounded : Icons.account_balance_rounded,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              contributor.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.tajawal(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.primary),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 210),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.tajawal(
                fontSize: 12,
                color: AppColors.textSecondary(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
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

String _formatUnixDate(int unixSeconds) {
  if (unixSeconds <= 0) return 'غير معروف';
  final date = DateTime.fromMillisecondsSinceEpoch(unixSeconds * 1000);
  final monthNames = <int, String>{
    1: 'يناير',
    2: 'فبراير',
    3: 'مارس',
    4: 'أبريل',
    5: 'مايو',
    6: 'يونيو',
    7: 'يوليو',
    8: 'أغسطس',
    9: 'سبتمبر',
    10: 'أكتوبر',
    11: 'نوفمبر',
    12: 'ديسمبر',
  };
  return '${ArabicUtils.toArabicDigits(date.day)} ${monthNames[date.month] ?? ''} ${ArabicUtils.toArabicDigits(date.year)}';
}

IconData _iconForType(String type) => switch (type) {
  'books' => FlutterIslamicIcons.solidQuran2,
  'articles' => FlutterIslamicIcons.islam,
  'audios' => Icons.headphones_rounded,
  'videos' => Icons.ondemand_video_rounded,
  'khotab' => FlutterIslamicIcons.solidMosque,
  'fatwa' => FlutterIslamicIcons.allah99,
  'quran' => FlutterIslamicIcons.solidQuran,
  'poster' => Icons.image_rounded,
  'apps' => Icons.apps_rounded,
  _ => FlutterIslamicIcons.quran2,
};
