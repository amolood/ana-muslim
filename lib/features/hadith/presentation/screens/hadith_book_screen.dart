import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hadith/hadith.dart';

import '../../../../core/constants/ui_strings.dart';
import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/hadith_repository.dart';
import '../widgets/hadith_tile.dart';

// ── Args passed from HadithScreen via GoRouter extra ──────────────────────
class HadithBookArgs {
  final String collectionSlug;
  final String bookNumber;
  final String title;
  final String collectionName;

  const HadithBookArgs({
    required this.collectionSlug,
    required this.bookNumber,
    required this.title,
    required this.collectionName,
  });
}

class HadithBookScreen extends ConsumerStatefulWidget {
  final HadithBookArgs args;
  const HadithBookScreen({super.key, required this.args});

  @override
  ConsumerState<HadithBookScreen> createState() => _HadithBookScreenState();
}

class _HadithBookScreenState extends ConsumerState<HadithBookScreen> {
  static const int _pageSize = 40;

  final ScrollController _scrollController = ScrollController();
  final List<Hadith> _hadiths = <Hadith>[];
  bool _isInitialLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _initialError;
  String? _loadMoreError;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitial();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(context, ref),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients ||
        _isInitialLoading ||
        _isLoadingMore ||
        !_hasMore) {
      return;
    }

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 260) {
      _loadMore();
    }
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isInitialLoading = true;
      _isLoadingMore = false;
      _hasMore = true;
      _initialError = null;
      _loadMoreError = null;
      _hadiths.clear();
    });

    try {
      final page = await HadithRepository.getHadithsForBookPage(
        widget.args.collectionSlug,
        widget.args.bookNumber,
        offset: 0,
        limit: _pageSize,
      );

      if (!mounted) return;
      setState(() {
        _hadiths.addAll(page.hadiths);
        _hasMore = page.hasMore;
        _isInitialLoading = false;
      });
      _ensureViewportFilled();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isInitialLoading = false;
        _initialError = UiStrings.hadithError;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _isInitialLoading || !_hasMore) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
      _loadMoreError = null;
    });

    try {
      final page = await HadithRepository.getHadithsForBookPage(
        widget.args.collectionSlug,
        widget.args.bookNumber,
        offset: _hadiths.length,
        limit: _pageSize,
      );

      if (!mounted) return;
      setState(() {
        _hadiths.addAll(page.hadiths);
        _hasMore = page.hasMore;
        _isLoadingMore = false;
      });
      _ensureViewportFilled();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
        _loadMoreError = 'تعذر تحميل المزيد من الأحاديث';
      });
    }
  }

  void _ensureViewportFilled() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          !_scrollController.hasClients ||
          _isInitialLoading ||
          _isLoadingMore ||
          !_hasMore) {
        return;
      }

      if (_scrollController.position.maxScrollExtent <= 0) {
        _loadMore();
      }
    });
  }

  // ── Header ──────────────────────────────────────────────────────────────
  Widget _header(BuildContext context, WidgetRef ref) => Padding(
    padding: const EdgeInsets.fromLTRB(8, 8, 20, 4),
    child: Row(
      children: [
        IconButton(
          icon: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.args.title,
                style: GoogleFonts.tajawal(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                widget.args.collectionName,
                style: GoogleFonts.tajawal(
                  fontSize: 12,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.text_increase, color: Colors.white, size: 22),
          onPressed: () => _showFontSizeSheet(context, ref),
        ),
      ],
    ),
  );

  Future<void> _showFontSizeSheet(BuildContext context, WidgetRef ref) async {
    final current = ref.read(hadithFontSizeProvider);
    double temp = current;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'حجم خط الحديث',
                    style: GoogleFonts.tajawal(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: temp,
                    min: 14,
                    max: 40,
                    divisions: 26,
                    activeColor: AppColors.primary,
                    label: temp.toStringAsFixed(0),
                    onChanged: (value) {
                      setModalState(() => temp = value);
                    },
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'الحجم: ${temp.toStringAsFixed(0)}',
                      style: GoogleFonts.tajawal(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await ref
                            .read(hadithFontSizeProvider.notifier)
                            .save(temp);
                        if (!context.mounted) {
                          return;
                        }
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.backgroundDark,
                      ),
                      child: Text(
                        UiStrings.save,
                        style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isInitialLoading) {
      return _loading();
    }

    if (_initialError != null && _hadiths.isEmpty) {
      return _error();
    }

    return _list(context);
  }

  // ── Loading ──────────────────────────────────────────────────────────────
  Widget _loading() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
        const SizedBox(height: 16),
        Text(
          UiStrings.hadithLoading,
          style: GoogleFonts.tajawal(
            color: AppColors.textSecondaryDark,
            fontSize: 14,
          ),
        ),
      ],
    ),
  );

  // ── Error ────────────────────────────────────────────────────────────────
  Widget _error() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _initialError ?? UiStrings.hadithError,
          style: GoogleFonts.tajawal(color: Colors.white54, fontSize: 15),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _loadInitial,
          child: Text(
            UiStrings.retry,
            style: GoogleFonts.tajawal(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );

  // ── List ─────────────────────────────────────────────────────────────────
  Widget _list(BuildContext context) {
    if (_hadiths.isEmpty) {
      return Center(
        child: Text(
          'لا توجد أحاديث في هذا الكتاب',
          style: GoogleFonts.tajawal(color: Colors.white54, fontSize: 15),
        ),
      );
    }

    final rows = _buildRows(_hadiths);
    final showFooter = _isLoadingMore || _hasMore || _loadMoreError != null;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: rows.length + (showFooter ? 1 : 0),
      itemBuilder: (ctx, i) {
        if (showFooter && i == rows.length) {
          return _buildPaginationFooter();
        }

        final row = rows[i];
        if (row.isHeader) {
          return HadithChapterHeader(
            title: row.chapterTitle,
            count: row.chapterCount,
          );
        }
        return HadithTile(
          hadith: row.hadith!,
          index: row.hadithIndex,
          collectionName: widget.args.collectionName,
        );
      },
    );
  }

  Widget _buildPaginationFooter() {
    if (_loadMoreError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: TextButton(
            onPressed: _loadMore,
            child: Text(
              'تعذر تحميل المزيد، اضغط لإعادة المحاولة',
              style: GoogleFonts.tajawal(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    if (_isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    if (_hasMore) {
      return const SizedBox(height: 40);
    }

    return const SizedBox.shrink();
  }

  List<_HadithRow> _buildRows(List<Hadith> hadiths) {
    final chapterCounts = <String, int>{};
    final chapterTitles = <String, String>{};

    for (final hadith in hadiths) {
      final key = _chapterKey(hadith);
      chapterCounts[key] = (chapterCounts[key] ?? 0) + 1;
      chapterTitles.putIfAbsent(key, () => _chapterTitle(hadith));
    }

    final rows = <_HadithRow>[];
    String? currentKey;
    var globalIndex = 0;

    for (final hadith in hadiths) {
      final key = _chapterKey(hadith);
      if (key != currentKey) {
        rows.add(
          _HadithRow.header(
            chapterTitle: chapterTitles[key] ?? 'باب',
            chapterCount: chapterCounts[key] ?? 0,
          ),
        );
        currentKey = key;
      }
      globalIndex += 1;
      rows.add(_HadithRow.hadith(hadith: hadith, hadithIndex: globalIndex));
    }

    return rows;
  }

  String _chapterKey(Hadith hadith) {
    final chapterId = hadith.chapterId.trim();
    final title = _chapterTitle(hadith);
    return '$chapterId|$title';
  }

  String _chapterTitle(Hadith hadith) {
    final title = HadithRepository.chapterTitle(hadith).trim();
    if (title.isEmpty) {
      return 'باب غير مسمى';
    }
    return title;
  }
}

class _HadithRow {
  final String chapterTitle;
  final int chapterCount;
  final Hadith? hadith;
  final int hadithIndex;
  final bool isHeader;

  const _HadithRow._({
    required this.chapterTitle,
    required this.chapterCount,
    required this.hadith,
    required this.hadithIndex,
    required this.isHeader,
  });

  factory _HadithRow.header({
    required String chapterTitle,
    required int chapterCount,
  }) {
    return _HadithRow._(
      chapterTitle: chapterTitle,
      chapterCount: chapterCount,
      hadith: null,
      hadithIndex: 0,
      isHeader: true,
    );
  }

  factory _HadithRow.hadith({
    required Hadith hadith,
    required int hadithIndex,
  }) {
    return _HadithRow._(
      chapterTitle: '',
      chapterCount: 0,
      hadith: hadith,
      hadithIndex: hadithIndex,
      isHeader: false,
    );
  }
}

