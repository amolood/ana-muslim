import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/arabic_utils.dart';
import '../../data/models/islamhouse_content_type.dart';
import '../../data/models/islamhouse_item.dart';
import '../providers/islamic_content_providers.dart';

class IslamicContentHubScreen extends ConsumerWidget {
  const IslamicContentHubScreen({super.key});

  static const List<String> _pinnedTypeOrder = <String>[
    'audios',
    'videos',
    'books',
    'fatwa',
    'khotab',
    'articles',
  ];
  static const Set<String> _pinnedTypeSet = <String>{
    'audios',
    'videos',
    'books',
    'fatwa',
    'khotab',
    'articles',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typesAsync = ref.watch(islamhouseTypesProvider);
    final latestAsync = ref.watch(islamhouseLatestProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(islamhouseTypesProvider);
            ref.invalidate(islamhouseLatestProvider);
            try {
              await Future.wait([
                ref.read(islamhouseTypesProvider.future),
                ref.read(islamhouseLatestProvider.future),
              ]);
            } catch (_) {
              // Providers expose their own error states in the UI;
              // swallow here so the refresh indicator dismisses cleanly.
            }
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              SliverToBoxAdapter(
                child: _buildTypesSection(context, typesAsync),
              ),
              SliverToBoxAdapter(
                child: _buildLatestSection(context, latestAsync),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 28)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border(context)),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              AppColors.primary.withValues(alpha: 0.18),
              AppColors.surface(context),
            ],
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                FlutterIslamicIcons.solidQuran2,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'محتوى إسلامي مميز',
                    style: GoogleFonts.tajawal(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'كتب، مقالات، صوتيات، فيديوهات وفتاوى من مصدر موثوق ومحدّث.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.tajawal(
                      fontSize: 13,
                      color: AppColors.textSecondary(context),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypesSection(
    BuildContext context,
    AsyncValue<List<IslamhouseContentType>> async,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'تصفح حسب المحتوى'),
          const SizedBox(height: 10),
          async.when(
            loading: () => const SizedBox(
              height: 56,
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              ),
            ),
            error: (error, _) => _ErrorCard(message: 'تعذر تحميل البيانات'),
            data: (types) {
              if (types.isEmpty) {
                return _EmptyCard(message: 'لا توجد أنواع متاحة حاليًا');
              }
              final typesByKey = <String, IslamhouseContentType>{
                for (final type in types) type.normalizedBlockName: type,
              };
              final pinned = _pinnedTypeOrder
                  .map(
                    (key) => _PinnedTypeTileData(
                      blockName: key,
                      label: _preferredTypeLabel(key),
                      itemsCount: typesByKey[key]?.itemsCount ?? 0,
                    ),
                  )
                  .toList(growable: false);
              final totalItems = pinned.fold<int>(
                0,
                (sum, tile) => sum + tile.itemsCount,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TypesOverviewCard(
                    typesCount: pinned.length,
                    itemsCount: totalItems,
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    itemCount: pinned.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 210,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          mainAxisExtent: 110,
                        ),
                    itemBuilder: (context, index) {
                      final tile = pinned[index];
                      return _TypeCard(
                        blockName: tile.blockName,
                        label: tile.label,
                        itemsCount: tile.itemsCount,
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLatestSection(
    BuildContext context,
    AsyncValue<List<IslamhouseItem>> async,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'آخر الإضافات'),
          const SizedBox(height: 10),
          async.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              ),
            ),
            error: (error, _) => _ErrorCard(message: 'تعذر تحميل البيانات'),
            data: (items) {
              final grouped = _groupItemsByPinnedType(
                items.take(16).toList(growable: false),
              );
              if (grouped.isEmpty) {
                return _EmptyCard(message: 'لا توجد إضافات حديثة الآن');
              }

              return Column(
                children: [
                  for (final key in _pinnedTypeOrder)
                    if ((grouped[key] ?? const <IslamhouseItem>[])
                        .isNotEmpty) ...[
                      _TypeSubHeader(
                        title: _preferredTypeLabel(key),
                        count: grouped[key]!.length,
                      ),
                      const SizedBox(height: 8),
                      for (final item in grouped[key]!) ...[
                        _LatestTile(item: item),
                        const SizedBox(height: 8),
                      ],
                      const SizedBox(height: 4),
                    ],
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => context.push(
                        Routes.islamicContentType('showall', title: 'كل المحتوى'),
                      ),
                      icon: const Icon(Icons.travel_explore_rounded),
                      label: Text(
                        'استعراض المزيد',
                        style: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.45),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Map<String, List<IslamhouseItem>> _groupItemsByPinnedType(
    List<IslamhouseItem> items,
  ) {
    final grouped = <String, List<IslamhouseItem>>{
      for (final key in _pinnedTypeOrder) key: <IslamhouseItem>[],
    };

    for (final item in items) {
      final key = item.normalizedType;
      if (!_pinnedTypeSet.contains(key)) continue;
      grouped[key]!.add(item);
    }

    grouped.removeWhere((key, value) => value.isEmpty);
    return grouped;
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.tajawal(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary(context),
      ),
    );
  }
}

class _TypeSubHeader extends StatelessWidget {
  const _TypeSubHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.tajawal(
              fontSize: 14,
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
    );
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.blockName,
    required this.label,
    required this.itemsCount,
  });

  final String blockName;
  final String label;
  final int itemsCount;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        final encodedTitle = Uri.encodeComponent(label);
        context.push(
          Routes.islamicContentType(blockName, title: encodedTitle),
        );
      },
      child: Ink(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_iconForType(blockName), color: AppColors.primary),
                const Spacer(),
                Icon(
                  Icons.chevron_left_rounded,
                  color: AppColors.textSecondary(context),
                  size: 18,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.tajawal(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${ArabicUtils.toArabicDigits(itemsCount)} عنصر',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.tajawal(
                fontSize: 11,
                color: AppColors.textSecondary(context),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'تصفح',
                style: GoogleFonts.tajawal(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PinnedTypeTileData {
  const _PinnedTypeTileData({
    required this.blockName,
    required this.label,
    required this.itemsCount,
  });

  final String blockName;
  final String label;
  final int itemsCount;
}

class _TypesOverviewCard extends StatelessWidget {
  const _TypesOverviewCard({
    required this.typesCount,
    required this.itemsCount,
  });

  final int typesCount;
  final int itemsCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.primary.withValues(alpha: 0.18),
            AppColors.surface(context),
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _OverviewMetric(
              label: 'الأنواع',
              value: ArabicUtils.toArabicDigits(typesCount),
            ),
          ),
          Container(width: 1, height: 32, color: AppColors.border(context)),
          Expanded(
            child: _OverviewMetric(
              label: 'إجمالي المواد',
              value: ArabicUtils.toArabicDigits(itemsCount),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewMetric extends StatelessWidget {
  const _OverviewMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.manrope(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    );
  }
}

class _LatestTile extends StatelessWidget {
  const _LatestTile({required this.item});

  final IslamhouseItem item;

  @override
  Widget build(BuildContext context) {
    final date = _formatUnixDate(item.addDate);

    return InkWell(
      onTap: () => context.push(Routes.islamicContentItem(item.id)),
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.tajawal(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${item.displayType} • $date',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_left, color: AppColors.textSecondaryDark),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Text(
        message,
        style: GoogleFonts.tajawal(fontSize: 13, color: Colors.red.shade300),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
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
  return '${_toArabicDigits(date.day)} ${monthNames[date.month] ?? ''} ${_toArabicDigits(date.year)}';
}

String _toArabicDigits(int number) {
  return ArabicUtils.toArabicDigits(number);
}

String _preferredTypeLabel(String key) => switch (key) {
  'audios' => 'الصوتيات',
  'videos' => 'الفيديو',
  'books' => 'الكتب',
  'fatwa' => 'الفتاوى',
  'khotab' => 'خطب الجمعة',
  'articles' => 'المقالات',
  _ => key,
};

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
