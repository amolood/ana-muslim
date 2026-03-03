import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_library/quran_library.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/services/quran_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../providers/bookmark_provider.dart';

/// Widget to display all colored bookmarks organized by color
class BookmarksView extends ConsumerStatefulWidget {
  const BookmarksView({super.key});

  @override
  ConsumerState<BookmarksView> createState() => _BookmarksViewState();
}

class _BookmarksViewState extends ConsumerState<BookmarksView> {
  BookmarkColor? selectedColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bookmarks = ref.watch(coloredBookmarksProvider);
    final allBookmarks = bookmarks.values.expand((list) => list).toList()
      ..sort((a, b) => b.id.compareTo(a.id)); // Sort by newest first

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colors.surfaceCard,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: colors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'العلامات المرجعية',
          style: GoogleFonts.tajawal(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          // Color filter
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceCard,
              border: Border(
                bottom: BorderSide(color: colors.borderSubtle),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Color filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Row(
                    children: [
                      _buildColorFilter(
                        label: 'الكل',
                        color: null,
                        count: allBookmarks.length,
                        colors: colors,
                      ),
                      const SizedBox(width: 8),
                      ...BookmarkColor.values.map((bookmarkColor) {
                        final count = bookmarks[bookmarkColor.colorCode]?.length ?? 0;
                        return Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: _buildColorFilter(
                            label: bookmarkColor.arabicName,
                            color: bookmarkColor,
                            count: count,
                            colors: colors,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bookmarks list
          Expanded(
            child: _buildBookmarksList(
              allBookmarks: allBookmarks,
              bookmarks: bookmarks,
              colors: colors,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorFilter({
    required String label,
    required BookmarkColor? color,
    required int count,
    required AppSemanticColors colors,
  }) {
    final isSelected = selectedColor == color;

    return InkWell(
      onTap: () => setState(() => selectedColor = color),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (color != null
                  ? Color(color.colorCode).withValues(alpha: 0.2)
                  : AppColors.primary.withValues(alpha: 0.2))
              : colors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (color != null ? Color(color.colorCode) : AppColors.primary)
                : colors.borderSubtle,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (color != null) ...[
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Color(color.colorCode),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '($count)',
              style: GoogleFonts.tajawal(
                fontSize: 12,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookmarksList({
    required List<BookmarkModel> allBookmarks,
    required Map<int, List<BookmarkModel>> bookmarks,
    required AppSemanticColors colors,
  }) {
    // Filter bookmarks by selected color
    final filteredBookmarks = selectedColor == null
        ? allBookmarks
        : bookmarks[selectedColor!.colorCode] ?? [];

    if (filteredBookmarks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 64,
              color: colors.iconSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد علامات مرجعية',
              style: GoogleFonts.tajawal(
                fontSize: 16,
                color: colors.textSecondary,
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 8),
            Text(
              'اضغط مطولاً على زر الحفظ في القارئ لإضافة علامة',
              style: GoogleFonts.tajawal(
                fontSize: 14,
                color: colors.textTertiary,
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredBookmarks.length,
      itemBuilder: (context, index) {
        final bookmark = filteredBookmarks[index];
        return _buildBookmarkCard(
          bookmark: bookmark,
          colors: colors,
        );
      },
    );
  }

  Widget _buildBookmarkCard({
    required BookmarkModel bookmark,
    required AppSemanticColors colors,
  }) {
    final bookmarkColor = BookmarkColor.values
        .firstWhere((c) => c.colorCode == bookmark.colorCode, orElse: () => BookmarkColor.green);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Navigate to the bookmarked ayah
            final surahNumber = QuranService.getSurahNumberFromPage(bookmark.page);
            context.push(Routes.quranReader(surahNumber, ayah: bookmark.ayahNumber, page: bookmark.page));
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Color indicator
                Container(
                  width: 4,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Color(bookmark.colorCode),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bookmark.name,
                        style: GoogleFonts.tajawal(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'آية ${bookmark.ayahNumber} • صفحة ${bookmark.page}',
                        style: GoogleFonts.tajawal(
                          fontSize: 14,
                          color: colors.textSecondary,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Color(bookmark.colorCode).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          bookmarkColor.arabicName,
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            color: Color(bookmark.colorCode),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Delete button
                IconButton(
                  icon: Icon(Icons.delete_outline, color: colors.error),
                  onPressed: () {
                    _showDeleteDialog(bookmark);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(BookmarkModel bookmark) async {
    final colors = context.colors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surfaceCard,
        title: Text(
          'حذف العلامة المرجعية',
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
          textDirection: TextDirection.rtl,
        ),
        content: Text(
          'هل تريد حذف العلامة المرجعية من ${bookmark.name}؟',
          style: GoogleFonts.tajawal(color: colors.textSecondary),
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'إلغاء',
              style: GoogleFonts.tajawal(color: colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'حذف',
              style: GoogleFonts.tajawal(color: colors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(coloredBookmarksProvider.notifier).removeBookmark(bookmark.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم حذف العلامة المرجعية',
              style: GoogleFonts.tajawal(),
            ),
          ),
        );
      }
    }
  }
}
