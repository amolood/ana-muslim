import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../data/models/quran_api_font.dart';
import '../../data/services/quran_font_service.dart';
import '../providers/quran_api_font_providers.dart';

class QuranFontPickerScreen extends ConsumerStatefulWidget {
  const QuranFontPickerScreen({super.key});

  @override
  ConsumerState<QuranFontPickerScreen> createState() =>
      _QuranFontPickerScreenState();
}

class _QuranFontPickerScreenState
    extends ConsumerState<QuranFontPickerScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<QuranApiFont> _filtered(List<QuranApiFont> all) {
    if (_query.isEmpty) return all;
    final q = _query.toLowerCase();
    return all
        .where(
          (f) =>
              f.displayName.toLowerCase().contains(q) ||
              f.designer.toLowerCase().contains(q) ||
              f.name.contains(q),
        )
        .toList();
  }

  Future<void> _download(QuranApiFont font) async {
    ref.read(quranFontDownloadProgressProvider.notifier).set(font.key, 0.01);

    try {
      await QuranFontService.downloadFont(
        font.key,
        font.ttfUrl,
        onProgress: (p) {
          if (!mounted) return;
          ref.read(quranFontDownloadProgressProvider.notifier).set(font.key, p);
        },
      );
      await ref.read(downloadedQuranFontsProvider.notifier).markDownloaded(font.key);
      if (!mounted) return;

      // Auto-select after download
      await _select(font.key);

      ref.read(quranFontDownloadProgressProvider.notifier).remove(font.key);
    } catch (e) {
      if (!mounted) return;
      ref.read(quranFontDownloadProgressProvider.notifier).remove(font.key);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'فشل تحميل الخط: ${font.displayName}',
            style: GoogleFonts.tajawal(),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _select(String key) async {
    await ref.read(selectedQuranFontKeyProvider.notifier).select(key);
  }

  Future<void> _delete(QuranApiFont font) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('حذف الخط', style: GoogleFonts.tajawal()),
        content: Text(
          'هل تريد حذف "${font.displayName}" من الجهاز؟',
          style: GoogleFonts.tajawal(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('إلغاء', style: GoogleFonts.tajawal()),
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
    if (confirm != true) return;

    await QuranFontService.deleteFont(font.key);
    await ref.read(downloadedQuranFontsProvider.notifier).markDeleted(font.key);

    // If the deleted font was selected, reset to default
    if (ref.read(selectedQuranFontKeyProvider) == font.key) {
      await ref.read(selectedQuranFontKeyProvider.notifier).select(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fontsAsync = ref.watch(quranApiFontsProvider);
    final downloaded = ref.watch(downloadedQuranFontsProvider);
    final selectedKey = ref.watch(selectedQuranFontKeyProvider);
    final progressMap = ref.watch(quranFontDownloadProgressProvider);
    final registeredAsync = ref.watch(quranActiveFontFamilyProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'اختر خط القرآن',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.w800),
        ),
        actions: [
          if (selectedKey != null)
            TextButton(
              onPressed: () =>
                  ref.read(selectedQuranFontKeyProvider.notifier).select(null),
              child: Text(
                'إعادة التعيين',
                style: GoogleFonts.tajawal(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Search ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                hintText: 'بحث عن خط...',
                hintStyle: GoogleFonts.tajawal(color: colors.textSecondary),
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: colors.surfaceCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: colors.borderDefault),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: colors.borderDefault),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // ── Built-in Hafs (always first) ───────────────────────────────
          _BuiltinHafsTile(
            isSelected: selectedKey == null,
            onSelect: () =>
                ref.read(selectedQuranFontKeyProvider.notifier).select(null),
            previewFamily: selectedKey == null
                ? (registeredAsync.asData?.value)
                : null,
          ),

          const Divider(height: 1),

          // ── Font list ──────────────────────────────────────────────────
          Expanded(
            child: fontsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  'تعذّر تحميل قائمة الخطوط',
                  style: GoogleFonts.tajawal(color: colors.textSecondary),
                ),
              ),
              data: (all) {
                final list = _filtered(all);
                if (list.isEmpty) {
                  return Center(
                    child: Text(
                      'لا توجد نتائج',
                      style:
                          GoogleFonts.tajawal(color: colors.textSecondary),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final font = list[i];
                    final isDownloaded = downloaded.contains(font.key);
                    final isSelected = selectedKey == font.key;
                    final progress = progressMap[font.key];
                    final isDownloading = progress != null;

                    return _FontTile(
                      font: font,
                      isDownloaded: isDownloaded,
                      isSelected: isSelected,
                      isDownloading: isDownloading,
                      downloadProgress: progress ?? 0,
                      registeredFamily: isSelected && isDownloaded
                          ? (registeredAsync.asData?.value)
                          : null,
                      onTap: () {
                        if (isDownloading) return;
                        if (isDownloaded) {
                          _select(font.key);
                        } else {
                          _download(font);
                        }
                      },
                      onDelete: isDownloaded && !isDownloading
                          ? () => _delete(font)
                          : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Built-in Hafs tile ─────────────────────────────────────────────────────

class _BuiltinHafsTile extends StatelessWidget {
  const _BuiltinHafsTile({
    required this.isSelected,
    required this.onSelect,
    this.previewFamily,
  });

  final bool isSelected;
  final VoidCallback onSelect;
  final String? previewFamily;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ListTile(
      tileColor: isSelected
          ? AppColors.primary.withValues(alpha: 0.08)
          : Colors.transparent,
      onTap: onSelect,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.auto_awesome,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        'الخط الافتراضي (حفص)',
        style: GoogleFonts.tajawal(
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
      ),
      subtitle: Text(
        'خط المصحف الرسمي المضمّن في التطبيق',
        style: GoogleFonts.tajawal(fontSize: 12, color: colors.textSecondary),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
          : null,
    );
  }
}

// ── Individual font tile ────────────────────────────────────────────────────

class _FontTile extends StatelessWidget {
  const _FontTile({
    required this.font,
    required this.isDownloaded,
    required this.isSelected,
    required this.isDownloading,
    required this.downloadProgress,
    required this.onTap,
    this.registeredFamily,
    this.onDelete,
  });

  final QuranApiFont font;
  final bool isDownloaded;
  final bool isSelected;
  final bool isDownloading;
  final double downloadProgress;
  final String? registeredFamily;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ListTile(
      tileColor: isSelected
          ? AppColors.primary.withValues(alpha: 0.08)
          : Colors.transparent,
      onTap: onTap,
      onLongPress: onDelete,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isDownloaded
              ? AppColors.primary.withValues(alpha: 0.1)
              : colors.surfaceCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.5)
                : colors.borderDefault,
          ),
        ),
        child: isDownloaded && registeredFamily != null
            ? Center(
                child: Text(
                  'ب',
                  style: TextStyle(
                    fontFamily: registeredFamily,
                    fontSize: 24,
                    color: AppColors.primary,
                  ),
                ),
              )
            : Icon(
                isDownloaded
                    ? Icons.font_download_rounded
                    : Icons.font_download_off_outlined,
                size: 20,
                color: isDownloaded
                    ? AppColors.primary
                    : colors.iconSecondary,
              ),
      ),
      title: Text(
        font.displayName,
        style: GoogleFonts.tajawal(
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (font.designer.isNotEmpty)
            Text(
              font.designer,
              style: GoogleFonts.tajawal(
                fontSize: 11,
                color: colors.textSecondary,
              ),
            ),
          if (isDownloading) ...[
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: downloadProgress,
                backgroundColor: colors.borderDefault,
                color: AppColors.primary,
                minHeight: 4,
              ),
            ),
          ],
        ],
      ),
      trailing: _buildTrailing(colors),
    );
  }

  Widget _buildTrailing(AppSemanticColors colors) {
    if (isDownloading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          value: downloadProgress,
          strokeWidth: 2.5,
          color: AppColors.primary,
        ),
      );
    }

    if (isSelected) {
      return const Icon(Icons.check_circle_rounded, color: AppColors.primary);
    }

    if (isDownloaded) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.grey, size: 20),
          const SizedBox(width: 4),
          if (onDelete != null)
            GestureDetector(
              onTap: onDelete,
              child: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
            ),
        ],
      );
    }

    // Not downloaded
    return const Icon(
      Icons.download_rounded,
      color: AppColors.primary,
    );
  }
}
