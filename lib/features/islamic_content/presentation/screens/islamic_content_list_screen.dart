import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/arabic_utils.dart';
import '../../data/models/islamhouse_item.dart';
import '../providers/islamic_content_providers.dart';

class IslamicContentListScreen extends ConsumerStatefulWidget {
  const IslamicContentListScreen({
    required this.type,
    required this.title,
    super.key,
  });

  final String type;
  final String title;

  @override
  ConsumerState<IslamicContentListScreen> createState() =>
      _IslamicContentListScreenState();
}

class _IslamicContentListScreenState
    extends ConsumerState<IslamicContentListScreen> {
  static const List<String> _typeOrder = <String>[
    'audios',
    'videos',
    'books',
    'fatwa',
    'khotab',
    'articles',
  ];
  static const Set<String> _typeOrderSet = <String>{
    'audios',
    'videos',
    'books',
    'fatwa',
    'khotab',
    'articles',
  };

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<IslamhouseItem> _items = [];
  List<IslamhouseItem> _filteredItems = [];
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  bool _isInitialLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  String _query = '';

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
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasMore => _currentPage < _totalPages;
  bool get _isShowAllMode {
    final selectedType = IslamhouseItem.normalizeTypeKey(widget.type);
    return selectedType.isEmpty || selectedType == 'showall';
  }

  bool _matchesSelectedType(IslamhouseItem item) {
    final selectedType = IslamhouseItem.normalizeTypeKey(widget.type);
    if (selectedType.isEmpty || selectedType == 'showall') {
      return true;
    }
    return item.normalizedType == selectedType;
  }

  List<IslamhouseItem> _computeFilteredItems() {
    final visible = _items.where(_matchesSelectedType).toList();
    final query = IslamhouseItem.normalizeForSearch(_query);
    if (query.isEmpty) return visible;
    return visible.where((item) => item.searchIndex.contains(query)).toList();
  }

  List<_SectionedListRow> _buildSectionRows(List<IslamhouseItem> items) {
    final grouped = <String, List<IslamhouseItem>>{
      for (final key in _typeOrder) key: <IslamhouseItem>[],
    };

    for (final item in items) {
      final key = item.normalizedType;
      if (!_typeOrderSet.contains(key)) continue;
      grouped[key]!.add(item);
    }

    final rows = <_SectionedListRow>[];
    for (final key in _typeOrder) {
      final bucket = grouped[key]!;
      if (bucket.isEmpty) continue;
      rows.add(_SectionHeaderRow(typeKey: key, count: bucket.length));
      for (final item in bucket) {
        rows.add(_SectionItemRow(item: item));
      }
    }
    return rows;
  }

  Future<void> _loadInitial({bool forceRefresh = false}) async {
    setState(() {
      _isInitialLoading = true;
      _error = null;
      if (forceRefresh) {
        _items = [];
        _currentPage = 1;
        _totalPages = 1;
        _totalItems = 0;
      }
    });

    try {
      final repo = ref.read(islamhouseRepositoryProvider);
      final page = await repo.fetchItemsByType(
        type: widget.type,
        page: 1,
        limit: 20,
        forceRefresh: forceRefresh,
      );

      if (!mounted) return;
      setState(() {
        _items = page.items
            .where(_matchesSelectedType)
            .toList();
        _currentPage = page.currentPage;
        _totalPages = page.totalPages;
        _totalItems = _items.length;
        _isInitialLoading = false;
        _filteredItems = _computeFilteredItems();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isInitialLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore || _isInitialLoading) return;

    setState(() {
      _isLoadingMore = true;
      _error = null;
    });

    try {
      final repo = ref.read(islamhouseRepositoryProvider);
      final page = await repo.fetchItemsByType(
        type: widget.type,
        page: _currentPage + 1,
        limit: 20,
      );

      if (!mounted) return;
      setState(() {
        _items = [
          ..._items,
          ...page.items.where(_matchesSelectedType),
        ];
        _currentPage = page.currentPage;
        _totalPages = page.totalPages;
        _totalItems = _items.length;
        _isLoadingMore = false;
        _filteredItems = _computeFilteredItems();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoadingMore = false;
      });
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.maxScrollExtent <= 0) return;

    if (position.pixels >= position.maxScrollExtent - 220) {
      _loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;  // reads cached field, never recomputes
    final sectionRows = _isShowAllMode
        ? _buildSectionRows(filtered)
        : const <_SectionedListRow>[];
    final visibleCount = _isShowAllMode
        ? sectionRows.whereType<_SectionItemRow>().length
        : filtered.length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.title,
          style: GoogleFonts.tajawal(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary(context),
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => _loadInitial(forceRefresh: true),
          child: _isInitialLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                )
              : _error != null && _items.isEmpty
              ? ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _ErrorBanner(
                      message: _error!,
                      onRetry: () => _loadInitial(forceRefresh: true),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        border: Border(
                          bottom: BorderSide(color: AppColors.border(context)),
                        ),
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _searchController,
                            onChanged: (value) => setState(() {
                              _query = value;
                              _filteredItems = _computeFilteredItems();
                            }),
                            style: GoogleFonts.tajawal(
                              fontSize: 14,
                              color: AppColors.textPrimary(context),
                            ),
                            decoration: InputDecoration(
                              hintText: 'ابحث داخل النتائج الحالية',
                              hintStyle: GoogleFonts.tajawal(
                                color: AppColors.textSecondary(context),
                              ),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: AppColors.textSecondaryDark,
                              ),
                              suffixIcon: _query.isEmpty
                                  ? null
                                  : IconButton(
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _query = '';
                                          _filteredItems = _computeFilteredItems();
                                        });
                                      },
                                      icon: const Icon(Icons.close_rounded),
                                      color: AppColors.textSecondaryDark,
                                    ),
                              filled: true,
                              fillColor: AppColors.surface(context),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.border(context),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.border(context),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 4,
                              children: [
                                Text(
                                  'المعروض: ${_toArabicDigits(visibleCount)}',
                                  style: GoogleFonts.tajawal(
                                    fontSize: 12,
                                    color: AppColors.textSecondary(context),
                                  ),
                                ),
                                if (_totalItems > 0)
                                  Text(
                                    'إجمالي النتائج: ${_toArabicDigits(_totalItems)}',
                                    style: GoogleFonts.tajawal(
                                      fontSize: 12,
                                      color: AppColors.textSecondary(context),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _isShowAllMode
                          ? _buildSectionedContent(sectionRows)
                          : _buildFlatContent(filtered),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildFlatContent(List<IslamhouseItem> filtered) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 26),
      itemCount: filtered.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= filtered.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          );
        }

        final item = filtered[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _ListTile(item: item),
        );
      },
    );
  }

  Widget _buildSectionedContent(List<_SectionedListRow> rows) {
    if (rows.isEmpty) {
      return ListView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 26),
        children: const [
          _EmptySectionCard(message: 'لا توجد عناصر ضمن التصنيفات المعتمدة'),
        ],
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 26),
      itemCount: rows.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= rows.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          );
        }

        final row = rows[index];
        if (row is _SectionHeaderRow) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(0, 6, 0, 8),
            child: _CategorySectionHeader(
              title: _typeLabel(row.typeKey),
              count: row.count,
              icon: _iconForType(row.typeKey),
            ),
          );
        }

        final itemRow = row as _SectionItemRow;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _ListTile(item: itemRow.item),
        );
      },
    );
  }
}

sealed class _SectionedListRow {
  const _SectionedListRow();
}

class _SectionHeaderRow extends _SectionedListRow {
  const _SectionHeaderRow({required this.typeKey, required this.count});

  final String typeKey;
  final int count;
}

class _SectionItemRow extends _SectionedListRow {
  const _SectionItemRow({required this.item});

  final IslamhouseItem item;
}

class _ListTile extends StatelessWidget {
  const _ListTile({required this.item});

  final IslamhouseItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => context.push(Routes.islamicContentItem(item.id)),
      child: Ink(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.tajawal(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(context),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.primaryDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      color: AppColors.textSecondary(context),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _MetaPill(label: item.displayType),
                      if (item.hasAttachments)
                        _MetaPill(
                          label:
                              'مرفقات: ${_toArabicDigits(item.attachments.length)}',
                        ),
                      if (item.addDate > 0)
                        _MetaPill(label: _formatUnixDate(item.addDate)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_left, color: AppColors.textSecondaryDark),
          ],
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.border(context).withValues(alpha: 0.7),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.tajawal(
          fontSize: 11,
          color: AppColors.textSecondary(context),
        ),
      ),
    );
  }
}

class _CategorySectionHeader extends StatelessWidget {
  const _CategorySectionHeader({
    required this.title,
    required this.count,
    required this.icon,
  });

  final String title;
  final int count;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 17),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.tajawal(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
          Text(
            ArabicUtils.toArabicDigits(count),
            style: GoogleFonts.tajawal(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySectionCard extends StatelessWidget {
  const _EmptySectionCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Text(
        message,
        style: GoogleFonts.tajawal(
          fontSize: 13,
          color: AppColors.textSecondary(context),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            message,
            style: GoogleFonts.tajawal(
              fontSize: 13,
              color: Colors.red.shade300,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                'إعادة المحاولة',
                style: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final Map<int, String> _dateLabelCache = <int, String>{};

String _formatUnixDate(int unixSeconds) {
  if (unixSeconds <= 0) return 'غير معروف';
  final cached = _dateLabelCache[unixSeconds];
  if (cached != null) return cached;

  final date = DateTime.fromMillisecondsSinceEpoch(unixSeconds * 1000);
  const monthNames = <int, String>{
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
  final label =
      '${_toArabicDigits(date.day)} ${monthNames[date.month] ?? ''} ${_toArabicDigits(date.year)}';

  if (_dateLabelCache.length > 1000) {
    _dateLabelCache.clear();
  }
  _dateLabelCache[unixSeconds] = label;
  return label;
}

String _toArabicDigits(int number) {
  return ArabicUtils.toArabicDigits(number);
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

String _typeLabel(String type) =>
    switch (IslamhouseItem.normalizeTypeKey(type)) {
      'audios' => 'الصوتيات',
      'videos' => 'الفيديو',
      'books' => 'الكتب',
      'fatwa' => 'الفتاوى',
      'khotab' => 'خطب الجمعة',
      'articles' => 'المقالات',
      _ => 'محتوى',
    };
