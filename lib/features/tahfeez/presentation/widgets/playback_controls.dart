import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

/// عناصر التحكم في التشغيل
class PlaybackControls extends StatelessWidget {
  final bool isPlaying;
  final int repeatCount;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onStop;
  final Function(int) onRepeatChange;

  const PlaybackControls({
    super.key,
    required this.isPlaying,
    required this.repeatCount,
    required this.onPlay,
    required this.onPause,
    required this.onStop,
    required this.onRepeatChange,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // عدد مرات التكرار
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'عدد مرات التكرار',
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: repeatCount > 1
                          ? () => onRepeatChange(repeatCount - 1)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                      color: AppColors.primary,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$repeatCount',
                        style: GoogleFonts.tajawal(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: repeatCount < 20
                          ? () => onRepeatChange(repeatCount + 1)
                          : null,
                      icon: const Icon(Icons.add_circle_outline),
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // أزرار التحكم
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                // زر الإيقاف
                if (isPlaying)
                  _ControlButton(
                    icon: Icons.stop,
                    label: 'إيقاف',
                    color: Colors.red,
                    onPressed: onStop,
                  ),

                // زر التشغيل/الإيقاف المؤقت
                _ControlButton(
                  icon: isPlaying ? Icons.pause : Icons.play_arrow,
                  label: isPlaying ? 'إيقاف مؤقت' : 'تشغيل',
                  color: isPlaying ? Colors.orange : Colors.green,
                  onPressed: isPlaying ? onPause : onPlay,
                  isPrimary: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: isPrimary ? 24 : 20),
      label: Text(
        label,
        style: GoogleFonts.tajawal(
          fontSize: isPrimary ? 16 : 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: isPrimary ? 24 : 16,
          vertical: isPrimary ? 12 : 10,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: isPrimary ? 4 : 2,
      ),
    );
  }
}
