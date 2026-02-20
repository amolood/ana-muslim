import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/azkar_provider.dart';
import 'azkar_category_screen.dart';

class AzkarScreen extends ConsumerWidget {
  const AzkarScreen({super.key});

  IconData _getIconForCategory(String title) {
    if (title.contains('الصباح')) return Icons.wb_sunny_outlined;
    if (title.contains('المساء')) return Icons.nights_stay_outlined;
    if (title.contains('الصلاة')) return Icons.mosque_outlined;
    if (title.contains('النوم')) return Icons.bedtime_outlined;
    if (title.contains('الاستيقاظ')) return Icons.wb_twilight;
    if (title.contains('المسجد')) return Icons.account_balance_outlined;
    if (title.contains('الوضوء')) return Icons.water_drop_outlined;
    if (title.contains('آذان')) return Icons.volume_up_outlined;
    if (title.contains('سفر')) return Icons.flight_takeoff_outlined;
    if (title.contains('طعام') || title.contains('أكل')) return Icons.restaurant_outlined;
    if (title.contains('أسماء')) return Icons.auto_stories_outlined;
    if (title.contains('حصن')) return Icons.shield_outlined;
    return Icons.book_outlined;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(azkarCategoriesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: categoriesAsync.when(
                data: (categories) {
                  if (categories.isEmpty) {
                    return Center(
                      child: Text(
                        'لا توجد بيانات',
                        style: GoogleFonts.tajawal(color: Colors.white),
                      ),
                    );
                  }
                  final categoryList = categories.entries.toList();
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)
                        .copyWith(bottom: 100),
                    itemCount: categoryList.length,
                    itemBuilder: (context, index) {
                      final entry = categoryList[index];
                      // entry.key = chapter name, entry.value = chapter ID
                      return _buildAzkarCard(
                        context: context,
                        title: entry.key,
                        chapterId: entry.value,
                        icon: _getIconForCategory(entry.key),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'تعذر تحميل الأذكار\n$error',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.tajawal(color: Colors.white70),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceDark.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.menu, color: Colors.grey[300], size: 20),
          ),
          Text(
            'الأذكار',
            style: GoogleFonts.tajawal(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 40), // balance header
        ],
      ),
    );
  }

  Widget _buildAzkarCard({
    required BuildContext context,
    required String title,
    required int chapterId,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => AzkarCategoryScreen(
                categoryTitle: title,
                chapterId: chapterId,
              ),
            ));
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.tajawal(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
