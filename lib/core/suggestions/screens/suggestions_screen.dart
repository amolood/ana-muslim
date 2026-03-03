import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_semantic_colors.dart';
import '../providers/suggestions_provider.dart';
import '../widgets/suggestion_card.dart';

/// شاشة عرض جميع الاقتراحات
class SuggestionsScreen extends ConsumerWidget {
  const SuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestions = ref.watch(suggestionsProvider);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: colors.textPrimary,
        ),
        title: Text(
          'الاقتراحات الذكية',
          style: GoogleFonts.tajawal(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await ref.read(suggestionsProvider.notifier).refresh();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم تحديث الاقتراحات',
                      style: GoogleFonts.tajawal(),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: suggestions.isEmpty
          ? _buildEmptyState(colors)
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(suggestionsProvider.notifier).refresh(),
              child: ListView.builder(
                padding: const EdgeInsets.only(
                  top: 16,
                  bottom: 100,
                ),
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = suggestions[index];
                  return SuggestionCard(
                    suggestion: suggestion,
                    onDismiss: () {
                      ref
                          .read(suggestionsProvider.notifier)
                          .dismissSuggestion(suggestion.id);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم إخفاء الاقتراح',
                            style: GoogleFonts.tajawal(),
                          ),
                          action: SnackBarAction(
                            label: 'تراجع',
                            onPressed: () {
                              ref
                                  .read(suggestionsProvider.notifier)
                                  .addSuggestion(suggestion);
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState(AppSemanticColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 50,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد اقتراحات حالياً',
              style: GoogleFonts.tajawal(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'سنقترح عليك الأذكار والعبادات\nفي الأوقات المناسبة',
              style: GoogleFonts.tajawal(
                fontSize: 15,
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildFeatureInfo(
              icon: Icons.access_time,
              title: 'مرتبطة بالوقت',
              subtitle: 'اقتراحات الأذكار حسب وقت اليوم',
              colors: colors,
            ),
            const SizedBox(height: 16),
            _buildFeatureInfo(
              icon: Icons.psychology,
              title: 'ذكية وشخصية',
              subtitle: 'تتكيف مع سلوكك وعاداتك',
              colors: colors,
            ),
            const SizedBox(height: 16),
            _buildFeatureInfo(
              icon: Icons.notifications_off,
              title: 'غير مزعجة',
              subtitle: 'يمكنك إخفاء أي اقتراح',
              colors: colors,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureInfo({
    required IconData icon,
    required String title,
    required String subtitle,
    required AppSemanticColors colors,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.tajawal(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.tajawal(
                  fontSize: 13,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
