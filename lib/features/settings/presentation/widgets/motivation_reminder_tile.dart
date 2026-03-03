import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/arabic_utils.dart';

// ─── Motivation reminder tile ────────────────────────────────────────────────

class MotivationReminderTile extends ConsumerStatefulWidget {
  const MotivationReminderTile({super.key});

  @override
  ConsumerState<MotivationReminderTile> createState() =>
      _MotivationReminderTileState();
}

class _MotivationReminderTileState
    extends ConsumerState<MotivationReminderTile> {
  Future<void> _saveSettings(MotivationReminderSettings settings) async {
    await ref.read(motivationReminderProvider.notifier).save(settings);
  }

  Future<void> _pickHour({
    required MotivationReminderSettings current,
    required bool isStart,
  }) async {
    final initial = TimeOfDay(
      hour: isStart ? current.startHour : current.endHour,
      minute: 0,
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
    );
    if (picked == null || !mounted) return;
    final updated = isStart
        ? current.copyWith(startHour: picked.hour)
        : current.copyWith(endHour: picked.hour);
    await _saveSettings(updated);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(motivationReminderProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تذكيرات تحفيزية',
                      style: GoogleFonts.tajawal(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'رسائل تشجيع للذكر والقرآن خلال اليوم',
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: settings.enabled,
                onChanged: (enabled) async {
                  await _saveSettings(settings.copyWith(enabled: enabled));
                },
                activeThumbColor: AppColors.primary,
                inactiveTrackColor: AppColors.surfaceDarker,
              ),
            ],
          ),
          if (settings.enabled) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _pickHour(current: settings, isStart: true),
                    icon: const Icon(Icons.wb_sunny_outlined, size: 18),
                    label: Text(
                      'من ${ArabicUtils.toArabicDigitsFromText('${settings.startHour.toString().padLeft(2, '0')}:00')}',
                      style: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _pickHour(current: settings, isStart: false),
                    icon: const Icon(Icons.nights_stay_outlined, size: 18),
                    label: Text(
                      'إلى ${ArabicUtils.toArabicDigitsFromText('${settings.endHour.toString().padLeft(2, '0')}:00')}',
                      style: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'عدد التذكيرات يوميًا',
                style: GoogleFonts.tajawal(
                  fontSize: 12,
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const MotivationCountStepper(),
          ],
        ],
      ),
    );
  }
}

// ─── Motivation count stepper ────────────────────────────────────────────────

class MotivationCountStepper extends ConsumerWidget {
  const MotivationCountStepper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(motivationReminderProvider);
    final count = settings.remindersPerDay;

    Future<void> updateCount(int next) async {
      final normalized = next.clamp(0, 60);
      final updated = settings.copyWith(remindersPerDay: normalized);
      await ref.read(motivationReminderProvider.notifier).save(updated);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceDarker,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: count <= 0 ? null : () => updateCount(count - 1),
            icon: const Icon(Icons.remove_circle_outline_rounded),
            color: AppColors.primary,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  ArabicUtils.toArabicDigits(count),
                  style: GoogleFonts.tajawal(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'تذكير',
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: count >= 60 ? null : () => updateCount(count + 1),
            icon: const Icon(Icons.add_circle_outline_rounded),
            color: AppColors.primary,
          ),
          TextButton(
            onPressed: count == 0 ? null : () => updateCount(0),
            child: Text(
              'صفر',
              style: GoogleFonts.tajawal(
                fontWeight: FontWeight.w700,
                color: count == 0
                    ? AppColors.textSecondaryDark
                    : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
