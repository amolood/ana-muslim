import 'package:flutter/material.dart';

/// Horizontal scrollable row of color circles with checkmark on selected.
class ColorPalettePicker extends StatelessWidget {
  const ColorPalettePicker({
    super.key,
    required this.selectedHex,
    required this.onSelected,
    this.colors = defaultColors,
  });

  final String selectedHex;
  final ValueChanged<String> onSelected;
  final List<String> colors;

  /// Default 12-color palette (AARRGGBB hex strings).
  static const defaultColors = [
    'FFFFFFFF', // white
    'FFB0BEC5', // light gray
    'FFF4D03F', // gold
    'FFFFD700', // bright gold
    'FF11D4B4', // teal (primary)
    'FF4CAF50', // green
    'FF2196F3', // blue
    'FF9C27B0', // purple
    'FFF44336', // red
    'FFFFC107', // amber
    'FFFF7043', // coral
    'FF000000', // black
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: colors.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final hex = colors[i];
          final isSelected = hex == selectedHex;
          final color = Color(int.parse(hex, radix: 16));
          final isBright = ThemeData.estimateBrightnessForColor(color) ==
              Brightness.light;

          return GestureDetector(
            onTap: () => onSelected(hex),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white.withValues(alpha: 0.2),
                  width: isSelected ? 3 : 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 20,
                      color: isBright ? Colors.black87 : Colors.white,
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
