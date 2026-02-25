import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_library/quran_library.dart';

/// Colored bookmark categories
/// - Green (0xAA00CD00): للحفظ (For memorization)
/// - Yellow (0xAAFFD354): للمراجعة (For review)
/// - Red (0xAAF36077): للدراسة المعمقة (For deep study)
enum BookmarkColor {
  green(0xAA00CD00, 'الحفظ'),
  yellow(0xAAFFD354, 'المراجعة'),
  red(0xAAF36077, 'الدراسة');

  const BookmarkColor(this.colorCode, this.arabicName);
  final int colorCode;
  final String arabicName;
}

/// Provider to manage colored bookmarks using quran_library's BookmarksCtrl
class ColoredBookmarksNotifier extends Notifier<Map<int, List<BookmarkModel>>> {
  @override
  Map<int, List<BookmarkModel>> build() {
    // Initialize BookmarksCtrl on first build
    _initializeBookmarks();
    return BookmarksCtrl.instance.bookmarks;
  }

  void _initializeBookmarks() {
    // Initialize with default color categories
    BookmarksCtrl.instance.initBookmarks();
  }

  /// Add a bookmark to a specific color category
  Future<void> addBookmark({
    required String surahName,
    required int ayahId,
    required int ayahNumber,
    required int page,
    required BookmarkColor color,
  }) async {
    BookmarksCtrl.instance.saveBookmark(
      surahName: surahName,
      ayahId: ayahId,
      ayahNumber: ayahNumber,
      page: page,
      colorCode: color.colorCode,
    );
    state = BookmarksCtrl.instance.bookmarks;
  }

  /// Remove a bookmark by ID
  Future<void> removeBookmark(int bookmarkId) async {
    BookmarksCtrl.instance.removeBookmark(bookmarkId);
    state = BookmarksCtrl.instance.bookmarks;
  }

  /// Check if an ayah has a bookmark
  bool hasBookmark(int ayahId) {
    return BookmarksCtrl.instance.bookmarksAyahs.contains(ayahId);
  }

  /// Get the bookmark color for an ayah (if bookmarked)
  BookmarkColor? getBookmarkColor(int ayahId) {
    for (final entry in state.entries) {
      if (entry.value.any((b) => b.ayahId == ayahId)) {
        final colorCode = entry.key;
        return BookmarkColor.values
            .firstWhere((c) => c.colorCode == colorCode, orElse: () => BookmarkColor.green);
      }
    }
    return null;
  }

  /// Get all bookmarks for a specific color
  List<BookmarkModel> getBookmarksByColor(BookmarkColor color) {
    return state[color.colorCode] ?? [];
  }

  /// Get all bookmarks as a flat list
  List<BookmarkModel> getAllBookmarks() {
    return state.values.expand((list) => list).toList();
  }
}

/// Provider instance for colored bookmarks
final coloredBookmarksProvider =
    NotifierProvider<ColoredBookmarksNotifier, Map<int, List<BookmarkModel>>>(
  ColoredBookmarksNotifier.new,
);

/// Provider for bookmark IDs list (for quick lookup)
final bookmarkedAyahsProvider = Provider<List<int>>((ref) {
  final bookmarks = ref.watch(coloredBookmarksProvider);
  return bookmarks.values
      .expand((list) => list)
      .map((bookmark) => bookmark.ayahId)
      .toList();
});
