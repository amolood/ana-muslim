import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/utils/arabic_utils.dart';
import '../../data/models/asma_name.dart';
import '../providers/asma_provider.dart';
import 'asma_detail_screen.dart';

// ── Gold palette shared across widgets ────────────────────────────────────
const _gold = AppColors.accentAsma;
const _goldDim = Color(0xFFB8951E);

class AsmaUlHusnaScreen extends ConsumerStatefulWidget {
  const AsmaUlHusnaScreen({super.key});

  @override
  ConsumerState<AsmaUlHusnaScreen> createState() => _AsmaUlHusnaScreenState();
}

class _AsmaUlHusnaScreenState extends ConsumerState<AsmaUlHusnaScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final _searchCtrl = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchCtrl.clear();
    ref.read(asmaSearchQueryProvider.notifier).update('');
    setState(() => _showSearch = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(
              showSearch: _showSearch,
              searchCtrl: _searchCtrl,
              isDark: isDark,
              colors: colors,
              tab: _tab,
              onSearchToggle: () {
                setState(() => _showSearch = !_showSearch);
                if (!_showSearch) {
                  _searchCtrl.clear();
                  ref.read(asmaSearchQueryProvider.notifier).update('');
                }
              },
              onSearchChanged: (q) =>
                  ref.read(asmaSearchQueryProvider.notifier).update(q),
              onClear: _clearSearch,
            ),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: const [
                  _AllNamesTab(),
                  _FavoritesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.showSearch,
    required this.searchCtrl,
    required this.isDark,
    required this.colors,
    required this.tab,
    required this.onSearchToggle,
    required this.onSearchChanged,
    required this.onClear,
  });

  final bool showSearch;
  final TextEditingController searchCtrl;
  final bool isDark;
  final AppSemanticColors colors;
  final TabController tab;
  final VoidCallback onSearchToggle;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Title row ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              // Decorative ornament
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      _gold.withValues(alpha: 0.25),
                      _gold.withValues(alpha: 0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _gold.withValues(alpha: 0.4),
                  ),
                ),
                child: const Center(
                  child: Text(
                    '﷽',
                    style: TextStyle(
                      fontSize: 14,
                      color: _gold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أسماء الله الحسنى',
                      style: GoogleFonts.tajawal(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: colors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      'تسعة وتسعون اسماً',
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        color: _gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Search toggle
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: onSearchToggle,
                  child: Ink(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: showSearch
                          ? _gold.withValues(alpha: 0.15)
                          : colors.surfaceCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: showSearch
                            ? _gold.withValues(alpha: 0.5)
                            : colors.borderDefault,
                      ),
                    ),
                    child: Icon(
                      showSearch ? Icons.search_off_rounded : Icons.search,
                      color: showSearch ? _gold : colors.iconSecondary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // ── Search bar ─────────────────────────────────────────────────
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: showSearch
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                  child: TextField(
                    controller: searchCtrl,
                    autofocus: true,
                    onChanged: onSearchChanged,
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.tajawal(
                      fontSize: 15,
                      color: colors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'ابحث باسم أو معنى...',
                      hintStyle: GoogleFonts.tajawal(
                        color: colors.textSecondary,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(Icons.search, color: _gold, size: 20),
                      suffixIcon: searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: colors.iconSecondary,
                                size: 18,
                              ),
                              onPressed: onClear,
                            )
                          : null,
                      filled: true,
                      fillColor: colors.surfaceCard,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: _gold.withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: _gold.withValues(alpha: 0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: _gold,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        // ── Tabs ───────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: colors.surfaceCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: tab,
              indicator: BoxDecoration(
                color: _gold,
                borderRadius: BorderRadius.circular(9),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: const Color(0xFF1A0A00),
              unselectedLabelColor: colors.textSecondary,
              labelStyle: GoogleFonts.tajawal(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: GoogleFonts.tajawal(fontSize: 13),
              tabs: const [
                Tab(text: 'كل الأسماء'),
                Tab(text: 'المفضلة ♥'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── All Names Tab ─────────────────────────────────────────────────────────

class _AllNamesTab extends ConsumerWidget {
  const _AllNamesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final names = ref.watch(asmaFilteredProvider);
    final query = ref.watch(asmaSearchQueryProvider);

    if (names.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, color: _goldDim, size: 48),
            const SizedBox(height: 12),
            Text(
              'لا نتائج لـ "$query"',
              style: GoogleFonts.tajawal(
                color: context.colors.textSecondary,
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        mainAxisExtent: 148,
      ),
      itemCount: names.length,
      itemBuilder: (_, i) => _AsmaCard(name: names[i]),
    );
  }
}

// ── Favorites Tab ─────────────────────────────────────────────────────────

class _FavoritesTab extends ConsumerWidget {
  const _FavoritesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(asmaFavoriteNamesProvider);

    if (favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_border_rounded,
              color: _goldDim,
              size: 52,
            ),
            const SizedBox(height: 12),
            Text(
              'لا يوجد أسماء مفضلة بعد',
              style: GoogleFonts.tajawal(
                color: context.colors.textSecondary,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'اضغط ♥ على أي اسم لإضافته',
              style: GoogleFonts.tajawal(
                color: context.colors.textTertiary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        mainAxisExtent: 148,
      ),
      itemCount: favorites.length,
      itemBuilder: (_, i) => _AsmaCard(name: favorites[i]),
    );
  }
}

// ── Name card ─────────────────────────────────────────────────────────────

class _AsmaCard extends ConsumerWidget {
  const _AsmaCard({required this.name});
  final AsmaName name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isFav = ref.watch(
      asmaFavoritesProvider.select((s) => s.contains(name.number)),
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => AsmaDetailScreen(name: name),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: colors.surfaceCard,
            border: Border.all(
              color: _gold.withValues(alpha: 0.25),
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: _gold.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 12, 10, 8),
            child: Column(
              children: [
                // Number badge
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        _gold.withValues(alpha: 0.22),
                        _gold.withValues(alpha: 0.06),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _gold.withValues(alpha: 0.5),
                      width: 1.2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      ArabicUtils.toArabicDigits(name.number),
                      style: GoogleFonts.tajawal(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: _gold,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Arabic name
                Text(
                  name.arabic,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.tajawal(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: colors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                // Transliteration
                Text(
                  name.transliteration,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.tajawal(
                    fontSize: 10.5,
                    color: _gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                // Favorite + divider
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => ref
                          .read(asmaFavoritesProvider.notifier)
                          .toggle(name.number),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          isFav
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          key: ValueKey(isFav),
                          color: isFav
                              ? Colors.redAccent
                              : colors.iconSecondary,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
