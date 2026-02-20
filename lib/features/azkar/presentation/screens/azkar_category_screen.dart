import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/azkar_model.dart';
import '../providers/azkar_provider.dart';

class AzkarCategoryScreen extends ConsumerWidget {
  final String categoryTitle;
  final int chapterId;

  const AzkarCategoryScreen({
    super.key,
    required this.categoryTitle,
    required this.chapterId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the new chapter-ID based provider for correctness and speed
    final azkarAsync = ref.watch(azkarByChapterIdProvider(chapterId));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          categoryTitle,
          style: GoogleFonts.tajawal(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: azkarAsync.when(
        data: (azkarList) {
          if (azkarList.isEmpty) {
            return Center(
              child: Text(
                'لا توجد أذكار في هذا القسم',
                style: GoogleFonts.tajawal(color: Colors.white),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)
                .copyWith(bottom: 60),
            itemCount: azkarList.length,
            itemBuilder: (context, index) {
              final azkar = azkarList[index];
              return _AzkarCard(azkar: azkar);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            'تعذر التحميل: $error',
            style: GoogleFonts.tajawal(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _AzkarCard extends StatefulWidget {
  final AzkarItem azkar;

  const _AzkarCard({required this.azkar});

  @override
  State<_AzkarCard> createState() => _AzkarCardState();
}

class _AzkarCardState extends State<_AzkarCard> {
  int _currentCount = 0;

  void _incrementCount() {
    if (_currentCount < widget.azkar.count) {
      setState(() {
        _currentCount++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = _currentCount >= widget.azkar.count;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted ? AppColors.primary : Colors.white.withValues(alpha: 0.05),
          width: isCompleted ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isCompleted ? null : _incrementCount,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.azkar.zekr,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.tajawal(
                      fontSize: 22,
                      height: 1.8,
                      color: isCompleted
                          ? Colors.white.withValues(alpha: 0.5)
                          : Colors.white,
                    ),
                  ),
                  if (widget.azkar.description.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      widget.azkar.description,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: GoogleFonts.tajawal(
                        fontSize: 14,
                        color: isCompleted
                            ? AppColors.textSecondaryDark.withValues(alpha: 0.5)
                            : AppColors.primary,
                      ),
                    ),
                  ],
                  if (widget.azkar.reference.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.azkar.reference,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        color:
                            AppColors.textSecondaryDark.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : AppColors.backgroundDark,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: isCompleted
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'مكتمل',
                                  style: GoogleFonts.tajawal(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              '$_currentCount / ${widget.azkar.count}',
                              style: GoogleFonts.tajawal(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
