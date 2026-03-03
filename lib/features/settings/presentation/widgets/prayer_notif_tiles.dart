import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/arabic_utils.dart';
import '../notification_reschedule.dart';

// ─── Per-prayer toggle tile ────────────────────────────────────────────────

class PrayerNotifToggleTile extends ConsumerWidget {
  const PrayerNotifToggleTile({super.key, required this.prayer});

  final Prayer prayer;

  static const _names = {
    Prayer.fajr: 'الفجر',
    Prayer.dhuhr: 'الظهر',
    Prayer.asr: 'العصر',
    Prayer.maghrib: 'المغرب',
    Prayer.isha: 'العشاء',
  };

  static const _icons = {
    Prayer.fajr: Icons.wb_twilight,
    Prayer.dhuhr: Icons.wb_sunny,
    Prayer.asr: Icons.wb_cloudy,
    Prayer.maghrib: Icons.nights_stay_outlined,
    Prayer.isha: Icons.bedtime_outlined,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(prayerNotifSettingsProvider);
    final globalEnabled = ref.watch(adhanAlertsProvider);
    final enabled = settings.isEnabled(prayer);

    return Opacity(
      opacity: globalEnabled ? 1.0 : 0.5,
      child: Padding(
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
              child: Icon(
                _icons[prayer] ?? Icons.schedule,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _names[prayer] ?? '',
                style: GoogleFonts.tajawal(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Switch(
              value: enabled && globalEnabled,
              onChanged: globalEnabled
                  ? (val) async {
                      await ref
                          .read(prayerNotifSettingsProvider.notifier)
                          .setEnabled(prayer, val);
                      await reschedulePrayerNotifications(ref);
                    }
                  : null,
              activeThumbColor: AppColors.primary,
              inactiveTrackColor: AppColors.surfaceDarker,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Per-prayer offset tile ────────────────────────────────────────────────

class PrayerNotifOffsetTile extends ConsumerWidget {
  const PrayerNotifOffsetTile({super.key, required this.prayer});

  final Prayer prayer;

  static const _names = {
    Prayer.fajr: 'الفجر',
    Prayer.dhuhr: 'الظهر',
    Prayer.asr: 'العصر',
    Prayer.maghrib: 'المغرب',
    Prayer.isha: 'العشاء',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(prayerNotifSettingsProvider);
    final offset = settings.offsetFor(prayer);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _names[prayer] ?? '',
              style: GoogleFonts.tajawal(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.remove_circle_outline,
              color: AppColors.primary,
            ),
            onPressed: () async {
              await ref
                  .read(prayerNotifSettingsProvider.notifier)
                  .setOffset(prayer, offset - 5);
              await reschedulePrayerNotifications(ref);
            },
          ),
          SizedBox(
            width: 64,
            child: Text(
              offset == 0
                  ? '٠ د'
                  : offset > 0
                  ? '+${ArabicUtils.toArabicDigits(offset)} د'
                  : '${ArabicUtils.toArabicDigits(offset)} د',
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: offset == 0
                    ? AppColors.textSecondaryDark
                    : AppColors.primary,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline,
              color: AppColors.primary,
            ),
            onPressed: () async {
              await ref
                  .read(prayerNotifSettingsProvider.notifier)
                  .setOffset(prayer, offset + 5);
              await reschedulePrayerNotifications(ref);
            },
          ),
        ],
      ),
    );
  }
}
