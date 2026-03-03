import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/notifications/notifications_service.dart';
import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/arabic_utils.dart';

// ─── Awake sala reminder tile (Android only) ────────────────────────────────

class AwakeSalaReminderTile extends ConsumerWidget {
  const AwakeSalaReminderTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return const SizedBox.shrink();
    }

    final enabled = ref.watch(salaOnProphetAwakeReminderProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.screen_lock_portrait_rounded,
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
                  'الصلاة على النبي أثناء اليقظة',
                  style: GoogleFonts.tajawal(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'عند فتح القفل/تشغيل الشاشة (بحد أقصى كل ١٥ دقيقة)',
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            onChanged: (val) =>
                ref.read(salaOnProphetAwakeReminderProvider.notifier).save(val),
            activeThumbColor: AppColors.primary,
            inactiveTrackColor: AppColors.surfaceDarker,
          ),
        ],
      ),
    );
  }
}

// ─── Generic daily reminder tile ────────────────────────────────────────────

class DailyReminderTile extends ConsumerStatefulWidget {
  const DailyReminderTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.reminderProvider,
    required this.baseId,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final NotifierProvider<dynamic, DailyReminderSettings> reminderProvider;
  final int baseId;

  @override
  ConsumerState<DailyReminderTile> createState() => _DailyReminderTileState();
}

class _DailyReminderTileState extends ConsumerState<DailyReminderTile> {
  Future<void> _toggleEnabled(DailyReminderSettings s, bool val) async {
    final updated = s.copyWith(enabled: val);
    await ref.read(widget.reminderProvider.notifier).save(updated);
    if (val) {
      await NotificationsService.scheduleDailyReminder(
        baseId: widget.baseId,
        title: widget.title,
        body: 'وقت ${widget.title}',
        hour: updated.hour,
        minute: updated.minute,
      );
    } else {
      await NotificationsService.cancelDailyReminder(widget.baseId);
    }
  }

  Future<void> _pickTime(DailyReminderSettings s) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: s.hour, minute: s.minute),
      builder: (ctx, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
    );
    if (picked == null || !mounted) return;
    final updated = s.copyWith(hour: picked.hour, minute: picked.minute);
    await ref.read(widget.reminderProvider.notifier).save(updated);
    if (updated.enabled) {
      await NotificationsService.cancelDailyReminder(widget.baseId);
      await NotificationsService.scheduleDailyReminder(
        baseId: widget.baseId,
        title: widget.title,
        body: 'وقت ${widget.title}',
        hour: updated.hour,
        minute: updated.minute,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(widget.reminderProvider);
    final timeLabel = ArabicUtils.toArabicDigitsFromText(
      '${s.hour.toString().padLeft(2, '0')}:${s.minute.toString().padLeft(2, '0')}',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(widget.icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: GoogleFonts.tajawal(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                GestureDetector(
                  onTap: s.enabled ? () => _pickTime(s) : null,
                  child: Text(
                    s.enabled ? 'الوقت: $timeLabel' : widget.subtitle,
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      color: s.enabled
                          ? AppColors.primary
                          : AppColors.textSecondaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: s.enabled,
            onChanged: (val) => _toggleEnabled(s, val),
            activeThumbColor: AppColors.primary,
            inactiveTrackColor: AppColors.surfaceDarker,
          ),
        ],
      ),
    );
  }
}
