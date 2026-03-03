import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';

/// Grid picker showing actual decor pattern thumbnails from assets.
class DecorImagePicker extends StatelessWidget {
  const DecorImagePicker({
    super.key,
    required this.selected,
    required this.onSelected,
    this.tintColor,
  });

  /// Current selection: empty string = "none", otherwise "decor_1".."decor_11".
  final String selected;
  final ValueChanged<String> onSelected;

  /// Optional tint to apply over thumbnails (matches decor color setting).
  final Color? tintColor;

  static const _decorCount = 11;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.4,
      ),
      itemCount: _decorCount + 1,
      itemBuilder: (_, i) {
        final isNone = i == 0;
        final value = isNone ? '' : 'decor_$i';
        final isSelected = value == selected;

        return GestureDetector(
          onTap: () => onSelected(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isNone ? colors.surfaceCard : Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : colors.borderSubtle,
                width: isSelected ? 2.5 : 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            clipBehavior: Clip.antiAlias,
            child: isNone
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.block_rounded,
                          color: colors.textTertiary,
                          size: 20,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'بدون',
                          style: GoogleFonts.tajawal(
                            fontSize: 10,
                            color: colors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      // Actual decor pattern thumbnail
                      ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          tintColor ?? Colors.white.withValues(alpha: 0.8),
                          BlendMode.srcIn,
                        ),
                        child: Image.asset(
                          'assets/decor/decor_$i.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Center(
                            child: Text(
                              '$i',
                              style: GoogleFonts.tajawal(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white54,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Selection overlay
                      if (isSelected)
                        Container(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          child: const Center(
                            child: Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
