import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../quran/data/models/reciter.dart';
import '../../../quran/presentation/providers/audio_providers.dart';

class DefaultReciterScreen extends ConsumerStatefulWidget {
  const DefaultReciterScreen({super.key});

  @override
  ConsumerState<DefaultReciterScreen> createState() =>
      _DefaultReciterScreenState();
}

class _DefaultReciterScreenState extends ConsumerState<DefaultReciterScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recitersAsync = ref.watch(recitersProvider);
    final defaultId = ref.watch(defaultReciterIdProvider);
    final favoriteReciterIds = ref.watch(favoriteReciterIdsProvider);
    final preferredMoshafMap = ref.watch(preferredReciterMoshafProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 20, 6),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.textPrimary(context),
                      size: 20,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'القارئ الافتراضي',
                          style: GoogleFonts.tajawal(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                        Text(
                          'اختر قارئًا افتراضيًا وأضف عدة قرّاء للمفضلة',
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (defaultId != null)
                    TextButton(
                      onPressed: () async {
                        await ref
                            .read(defaultReciterIdProvider.notifier)
                            .clear();
                        await ref
                            .read(defaultReciterNameProvider.notifier)
                            .clear();
                      },
                      child: Text(
                        'إلغاء',
                        style: GoogleFonts.tajawal(
                          fontSize: 13,
                          color: Colors.red.shade400,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(color: Color(0xFF2D5E57), height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchCtrl,
                textDirection: TextDirection.rtl,
                style: GoogleFonts.tajawal(color: Colors.white, fontSize: 14),
                onChanged: (value) => setState(() => _query = value.trim()),
                decoration: InputDecoration(
                  hintText: 'ابحث عن القارئ أو الرواية',
                  hintStyle: GoogleFonts.tajawal(
                    color: AppColors.textSecondaryDark,
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textSecondaryDark,
                  ),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          color: AppColors.textSecondaryDark,
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _query = '');
                          },
                        ),
                  filled: true,
                  fillColor: AppColors.surfaceDark,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2D5E57)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ),
            Expanded(
              child: recitersAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                ),
                error: (e, _) => Center(
                  child: Text(
                    'تعذّر تحميل القراء',
                    style: GoogleFonts.tajawal(
                      color: AppColors.textSecondaryDark,
                      fontSize: 14,
                    ),
                  ),
                ),
                data: (reciters) {
                  final filtered = _filterReciters(reciters, _query);
                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        'لا توجد نتائج مطابقة',
                        style: GoogleFonts.tajawal(
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                    );
                  }

                  final sorted = _sortReciters(
                    reciters: filtered,
                    defaultReciterId: defaultId,
                    favoriteReciterIds: favoriteReciterIds.toSet(),
                  );

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                    itemCount: sorted.length,
                    itemBuilder: (_, i) {
                      final reciter = sorted[i];
                      final isSelected = reciter.id == defaultId;
                      final isFavorite = favoriteReciterIds.contains(
                        reciter.id,
                      );
                      final selectedMoshaf = _selectedMoshafFor(
                        reciter,
                        preferredMoshafMap,
                      );

                      return _buildReciterTile(
                        context: context,
                        reciter: reciter,
                        isSelected: isSelected,
                        isFavorite: isFavorite,
                        selectedMoshaf: selectedMoshaf,
                        onTap: () async {
                          if (isSelected) {
                            await ref
                                .read(defaultReciterIdProvider.notifier)
                                .clear();
                            await ref
                                .read(defaultReciterNameProvider.notifier)
                                .clear();
                            return;
                          }

                          await ref
                              .read(defaultReciterIdProvider.notifier)
                              .save(reciter.id);
                          await ref
                              .read(defaultReciterNameProvider.notifier)
                              .save(reciter.name);

                          if (selectedMoshaf != null) {
                            await ref
                                .read(preferredReciterMoshafProvider.notifier)
                                .saveSelection(reciter.id, selectedMoshaf.id);
                          }

                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'تم تعيين ${reciter.name} كقارئ افتراضي',
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
                        },
                        onToggleFavorite: () async {
                          await ref
                              .read(favoriteReciterIdsProvider.notifier)
                              .toggle(reciter.id);
                        },
                        onPickRiwaya: reciter.moshaf.length > 1
                            ? () => _showRiwayaPicker(
                                context: context,
                                reciter: reciter,
                                selectedMoshafId: selectedMoshaf?.id,
                              )
                            : null,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Reciter> _filterReciters(List<Reciter> reciters, String query) {
    if (query.isEmpty) return reciters;

    final normalized = _normalizeArabic(query);
    return reciters.where((reciter) {
      if (_normalizeArabic(reciter.name).contains(normalized)) return true;
      return reciter.moshaf.any(
        (m) => _normalizeArabic(m.name).contains(normalized),
      );
    }).toList();
  }

  List<Reciter> _sortReciters({
    required List<Reciter> reciters,
    required int? defaultReciterId,
    required Set<int> favoriteReciterIds,
  }) {
    final defaultItems = reciters
        .where((reciter) => reciter.id == defaultReciterId)
        .toList();
    final favoriteItems = reciters
        .where(
          (reciter) =>
              reciter.id != defaultReciterId &&
              favoriteReciterIds.contains(reciter.id),
        )
        .toList();
    final regularItems = reciters
        .where(
          (reciter) =>
              reciter.id != defaultReciterId &&
              !favoriteReciterIds.contains(reciter.id),
        )
        .toList();

    return [...defaultItems, ...favoriteItems, ...regularItems];
  }

  Moshaf? _selectedMoshafFor(Reciter reciter, Map<int, int> preferred) {
    if (reciter.moshaf.isEmpty) return null;
    final preferredId = preferred[reciter.id];
    if (preferredId == null) return reciter.moshaf.first;
    for (final m in reciter.moshaf) {
      if (m.id == preferredId) return m;
    }
    return reciter.moshaf.first;
  }

  Widget _buildReciterTile({
    required BuildContext context,
    required Reciter reciter,
    required bool isSelected,
    required bool isFavorite,
    required Moshaf? selectedMoshaf,
    required Future<void> Function() onTap,
    required Future<void> Function() onToggleFavorite,
    required VoidCallback? onPickRiwaya,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.5)
                : const Color(0xFF2D5E57),
          ),
        ),
        child: Row(
          children: [
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
                child: Icon(
                  isSelected ? Icons.check_rounded : Icons.mic_none_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reciter.name,
                    style: GoogleFonts.tajawal(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primary : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${reciter.moshaf.length} رواية متاحة',
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  if (selectedMoshaf != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      'الرواية: ${selectedMoshaf.name}',
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (onPickRiwaya != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 44),
                        child: Material(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            onTap: onPickRiwaya,
                            borderRadius: BorderRadius.circular(10),
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
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
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
            ),
            if (isSelected)
              const Icon(
                Icons.verified_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            IconButton(
              icon: Icon(
                isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: isFavorite
                    ? Colors.redAccent
                    : AppColors.textSecondaryDark,
                size: 20,
              ),
              tooltip: isFavorite ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
              onPressed: onToggleFavorite,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRiwayaPicker({
    required BuildContext context,
    required Reciter reciter,
    required int? selectedMoshafId,
  }) async {
    final picked = await showModalBottomSheet<Moshaf>(
      context: context,
      backgroundColor: AppColors.surfaceDark,
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
                        color: Colors.white,
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
                        color: AppColors.textSecondaryDark,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: reciter.moshaf.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (_, index) {
                        final moshaf = reciter.moshaf[index];
                        final selected = moshaf.id == selectedMoshafId;
                        return Material(
                          color: selected
                              ? AppColors.primary.withValues(alpha: 0.14)
                              : const Color(0xFF0F2D28),
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
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: selected
                                                  ? FontWeight.w700
                                                  : FontWeight.w600,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            selected
                                                ? 'محددة الآن'
                                                : 'اضغط للاختيار',
                                            style: GoogleFonts.tajawal(
                                              color: selected
                                                  ? AppColors.primary
                                                  : AppColors.textSecondaryDark,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Icon(
                                      selected
                                          ? Icons.check_circle_rounded
                                          : Icons
                                                .radio_button_unchecked_rounded,
                                      color: selected
                                          ? AppColors.primary
                                          : AppColors.textSecondaryDark,
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

    if (picked == null) return;
    await ref
        .read(preferredReciterMoshafProvider.notifier)
        .saveSelection(reciter.id, picked.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم اختيار ${picked.name}',
          style: GoogleFonts.tajawal(),
          textDirection: TextDirection.rtl,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _normalizeArabic(String input) {
    return input
        .toLowerCase()
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .trim();
  }
}
