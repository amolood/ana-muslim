import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';

/// A circular icon button with a small label underneath, used in the
/// media player controls row (play, pause, seek, mute, fullscreen, PIP).
class RoundControlButton extends StatelessWidget {
  const RoundControlButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.size = 52,
    this.iconSize = 26,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  /// When true, the button renders with a solid primary-color background
  /// (used for the main play/pause button to give it visual prominence).
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final bgColor = highlighted
        ? AppColors.primary
        : AppColors.primary.withValues(alpha: 0.12);
    final iconColor = highlighted ? Colors.black : AppColors.primary;
    final textColor = highlighted
        ? AppColors.textPrimary(context)
        : AppColors.textSecondary(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(size / 2),
          onTap: onTap,
          child: Ink(
            width: size,
            height: size,
            decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
            child: Icon(icon, size: iconSize, color: iconColor),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: highlighted ? 11 : 10,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
