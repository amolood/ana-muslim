import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/notifications/notifications_service.dart';
import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../notification_reschedule.dart';
import '../widgets/adhan_sound_selector_tile.dart';
import '../widgets/daily_reminder_tiles.dart';
import '../widgets/motivation_reminder_tile.dart';
import '../widgets/notification_permission_banner.dart';
import '../widgets/prayer_notif_tiles.dart';

// Notification base IDs for daily reminders
const _kSalaBaseId = 2001;
const _kWirdBaseId = 2031;

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  static const _prayers = [
    Prayer.fajr,
    Prayer.dhuhr,
    Prayer.asr,
    Prayer.maghrib,
    Prayer.isha,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalEnabled = ref.watch(adhanAlertsProvider);
    final manualExact = ref.watch(prayerManualExactSettingsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
        title: Text(
          'تنبيهات الصلاة',
          style: GoogleFonts.tajawal(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ).copyWith(bottom: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Permission banner ──────────────────────────────
            const NotificationPermissionBanner(),
            const SizedBox(height: 20),
            // ─── Global toggle ──────────────────────────────────
            _buildSection(
              children: [
                _buildSwitchTile(
                  icon: Icons.notifications_active,
                  title: 'تفعيل جميع التنبيهات',
                  subtitle: 'تشغيل أو إيقاف كل تنبيهات الصلاة دفعةً',
                  value: globalEnabled,
                  onChanged: (val) async {
                    if (val) {
                      final notificationsGranted =
                          await NotificationsService.requestPermission();
                      if (!notificationsGranted) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'يلزم السماح بالإشعارات لتفعيل الأذان',
                              style: GoogleFonts.tajawal(),
                            ),
                          ),
                        );
                        await ref
                            .read(adhanAlertsProvider.notifier)
                            .save(false);
                        return;
                      }

                      final canExact =
                          await NotificationsService.canScheduleExactAlarms();
                      if (!canExact) {
                        await NotificationsService.requestExactAlarmsPermission();
                      }

                      if (!kIsWeb &&
                          defaultTargetPlatform == TargetPlatform.android) {
                        final hasPolicy =
                            await NotificationsService.hasNotificationPolicyAccess();
                        if (!hasPolicy) {
                          await NotificationsService.requestNotificationPolicyAccess();
                        }
                        await NotificationsService.requestFullScreenIntentPermission();
                      }
                    }

                    await ref.read(adhanAlertsProvider.notifier).save(val);
                    await reschedulePrayerNotifications(ref);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            // ─── Per-prayer toggles ─────────────────────────────
            _buildSectionHeader('تنبيهات كل صلاة'),
            _buildSection(
              children: [
                for (int i = 0; i < _prayers.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.white.withValues(alpha: 0.05),
                      indent: 64,
                    ),
                  PrayerNotifToggleTile(prayer: _prayers[i]),
                ],
              ],
            ),
            const SizedBox(height: 24),
            // ─── Per-prayer offsets ─────────────────────────────
            _buildSectionHeader('تعديل وقت التنبيه (دقائق)'),
            if (manualExact.enabled)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'الوضع اليدوي الكامل مفعّل: سيتم اعتماد الأوقات اليدوية من شاشة ضبط المواقيت.',
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ),
            _buildSection(
              children: [
                for (int i = 0; i < _prayers.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.white.withValues(alpha: 0.05),
                      indent: 64,
                    ),
                  PrayerNotifOffsetTile(prayer: _prayers[i]),
                ],
              ],
            ),
            const SizedBox(height: 24),
            // ─── Daily reminders ────────────────────────────────
            _buildSectionHeader('التذكيرات اليومية'),
            _buildSection(
              children: [
                DailyReminderTile(
                  icon: Icons.star_rounded,
                  title: 'الصلاة على النبي ﷺ',
                  subtitle: 'تذكير يومي للصلاة على النبي',
                  reminderProvider: salaOnProphetReminderProvider,
                  baseId: _kSalaBaseId,
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.white.withValues(alpha: 0.05),
                  indent: 64,
                ),
                DailyReminderTile(
                  icon: Icons.menu_book_rounded,
                  title: 'الورد اليومي',
                  subtitle: 'تذكير يومي لقراءة الورد',
                  reminderProvider: dailyWirdReminderProvider,
                  baseId: _kWirdBaseId,
                ),
                if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.white.withValues(alpha: 0.05),
                    indent: 64,
                  ),
                const AwakeSalaReminderTile(),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('تحفيز العبادة خلال اليوم'),
            _buildSection(children: const [MotivationReminderTile()]),
            const SizedBox(height: 24),
            // ─── Adhan Sound Selection ──────────────────────────
            _buildSectionHeader('صوت الأذان'),
            _buildSection(
              children: const [AdhanSoundSelectorTile()],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 10, top: 4),
      child: Text(
        title,
        style: GoogleFonts.tajawal(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondaryDark,
        ),
      ),
    );
  }

  Widget _buildSection({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
            inactiveTrackColor: AppColors.surfaceDarker,
          ),
        ],
      ),
    );
  }
}
