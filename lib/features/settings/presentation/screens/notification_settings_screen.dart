import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/notifications/notifications_service.dart';
import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/arabic_utils.dart';
import '../../../prayer_times/presentation/providers/prayer_times_provider.dart';

// Notification base IDs for daily reminders
const _kSalaBaseId = 2001;
const _kWirdBaseId = 2031;

Future<void> _reschedulePrayerNotifications(
  WidgetRef ref, {
  BuildContext? context,
  bool showSuccessMessage = false,
}) async {
  try {
    final globalEnabled = ref.read(adhanAlertsProvider);
    final notifSettings = ref.read(prayerNotifSettingsProvider);
    final manualExact = ref.read(prayerManualExactSettingsProvider);

    final prayers = const [
      Prayer.fajr,
      Prayer.dhuhr,
      Prayer.asr,
      Prayer.maghrib,
      Prayer.isha,
    ];
    final enabledMap = <Prayer, bool>{
      for (final p in prayers) p: globalEnabled && notifSettings.isEnabled(p),
    };
    final offsetMap = <Prayer, int>{
      for (final p in prayers) p: notifSettings.offsetFor(p),
    };

    if (manualExact.enabled) {
      final now = DateTime.now();
      await NotificationsService.rescheduleManualPrayerTimes(
        enabledMap: enabledMap,
        manualTimes: <Prayer, DateTime>{
          Prayer.fajr: manualExact.dateTimeFor(Prayer.fajr, now),
          Prayer.dhuhr: manualExact.dateTimeFor(Prayer.dhuhr, now),
          Prayer.asr: manualExact.dateTimeFor(Prayer.asr, now),
          Prayer.maghrib: manualExact.dateTimeFor(Prayer.maghrib, now),
          Prayer.isha: manualExact.dateTimeFor(Prayer.isha, now),
        },
        offsetMinutes: offsetMap,
      );
    } else {
      final position = await ref.read(locationProvider.future);
      final calcMethodStr = ref.read(calculationMethodProvider);
      final coords = Coordinates(position.latitude, position.longitude);
      final params = NotificationSettingsScreen.buildParams(calcMethodStr);
      final prayerAdjust = ref.read(prayerManualOffsetsProvider);

      await NotificationsService.rescheduleAll(
        coordinates: coords,
        calcParams: params,
        enabledMap: enabledMap,
        prayerAdjustMinutes: <Prayer, int>{
          Prayer.fajr: prayerAdjust.fajr,
          Prayer.dhuhr: prayerAdjust.dhuhr,
          Prayer.asr: prayerAdjust.asr,
          Prayer.maghrib: prayerAdjust.maghrib,
          Prayer.isha: prayerAdjust.isha,
        },
        offsetMinutes: offsetMap,
      );
    }

    if (showSuccessMessage && context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تمت إعادة جدولة تنبيهات الصلاة',
            style: GoogleFonts.tajawal(),
          ),
        ),
      );
    }
  } catch (e) {
    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذّر إعادة الجدولة: $e',
            style: GoogleFonts.tajawal(),
          ),
        ),
      );
    }
  }
}

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
            _PermissionBanner(),
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
                    await _reschedulePrayerNotifications(ref);
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
                  _PrayerToggleTile(prayer: _prayers[i]),
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
                  _PrayerOffsetTile(prayer: _prayers[i]),
                ],
              ],
            ),
            const SizedBox(height: 24),
            // ─── Daily reminders ────────────────────────────────
            _buildSectionHeader('التذكيرات اليومية'),
            _buildSection(
              children: [
                _DailyReminderTile(
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
                _DailyReminderTile(
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
                if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
                  const _AwakeSalaReminderTile(),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('تحفيز العبادة خلال اليوم'),
            _buildSection(children: const [_MotivationReminderTile()]),
            const SizedBox(height: 28),
            // ─── Reschedule button ──────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _reschedulePrayerNotifications(
                  ref,
                  context: context,
                  showSuccessMessage: true,
                ),
                icon: const Icon(Icons.refresh, size: 20),
                label: Text(
                  'إعادة جدولة التنبيهات',
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.backgroundDark,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'يتم جدولة التنبيهات تلقائيًا عند فتح التطبيق',
                style: GoogleFonts.tajawal(
                  fontSize: 12,
                  color: AppColors.textSecondaryDark,
                ),
                textAlign: TextAlign.center,
              ),
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

  static CalculationParameters buildParams(String method) => switch (method) {
    'رابطة العالم الإسلامي' =>
      CalculationMethod.muslim_world_league.getParameters(),
    'الهيئة العامة للمساحة المصرية' =>
      CalculationMethod.egyptian.getParameters(),
    'جامعة العلوم الإسلامية بكراتشي' =>
      CalculationMethod.karachi.getParameters(),
    'الجمعية الإسلامية لأمريكا الشمالية' =>
      CalculationMethod.north_america.getParameters(),
    _ => CalculationMethod.umm_al_qura.getParameters(),
  };
}

// ─── Per-prayer toggle tile ────────────────────────────────────────────────

class _PrayerToggleTile extends ConsumerWidget {
  const _PrayerToggleTile({required this.prayer});

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

class _PrayerOffsetTile extends ConsumerWidget {
  const _PrayerOffsetTile({required this.prayer});

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
            },
          ),
        ],
      ),
    );
  }
}

// ─── Permission banner ─────────────────────────────────────────────────────

class _PermissionBanner extends StatefulWidget {
  @override
  State<_PermissionBanner> createState() => _PermissionBannerState();
}

class _PermissionBannerState extends State<_PermissionBanner> {
  bool? _notificationsGranted;
  bool? _exactAlarmsGranted;
  bool? _policyAccessGranted;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final notificationsGranted =
        await NotificationsService.areNotificationsEnabled();
    final exactAlarmsGranted =
        await NotificationsService.canScheduleExactAlarms();
    final policyAccessGranted =
        await NotificationsService.hasNotificationPolicyAccess();
    if (!mounted) return;
    setState(() {
      _notificationsGranted = notificationsGranted;
      _exactAlarmsGranted = exactAlarmsGranted;
      _policyAccessGranted = policyAccessGranted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final needsPolicyAccess =
        !kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android &&
        _policyAccessGranted != true;

    if (_notificationsGranted == true &&
        _exactAlarmsGranted == true &&
        !needsPolicyAccess) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'تم ضبط أذونات الأذان بالكامل (إشعارات + إنذارات دقيقة)',
                style: GoogleFonts.tajawal(color: AppColors.primary),
              ),
            ),
          ],
        ),
      );
    }

    final needsNotifications = _notificationsGranted != true;
    final needsExact = !needsNotifications && (_exactAlarmsGranted != true);
    final needsPolicy = !needsNotifications && !needsExact && needsPolicyAccess;
    final message = needsNotifications
        ? 'اضغط للسماح بإشعارات الصلاة'
        : needsExact
        ? 'فعّل الإنذارات الدقيقة لتحسين دقة الأذان'
        : 'فعّل تجاوز وضع عدم الإزعاج لضمان سماع الأذان';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.tajawal(color: Colors.orange),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (needsNotifications) {
                await NotificationsService.requestPermission();
              } else if (needsExact) {
                await NotificationsService.requestExactAlarmsPermission();
              } else if (needsPolicy) {
                await NotificationsService.requestNotificationPolicyAccess();
                await NotificationsService.requestFullScreenIntentPermission();
              }
              await _checkPermission();
            },
            child: Text(
              needsNotifications
                  ? 'السماح'
                  : needsExact
                  ? 'تفعيل'
                  : 'فتح الإعدادات',
              style: GoogleFonts.tajawal(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AwakeSalaReminderTile extends ConsumerWidget {
  const _AwakeSalaReminderTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            onChanged: (val) async {
              await ref
                  .read(salaOnProphetAwakeReminderProvider.notifier)
                  .save(val);
            },
            activeThumbColor: AppColors.primary,
            inactiveTrackColor: AppColors.surfaceDarker,
          ),
        ],
      ),
    );
  }
}

// ─── Daily reminder tile ────────────────────────────────────────────────────

class _DailyReminderTile extends ConsumerStatefulWidget {
  const _DailyReminderTile({
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
  ConsumerState<_DailyReminderTile> createState() => _DailyReminderTileState();
}

class _DailyReminderTileState extends ConsumerState<_DailyReminderTile> {
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

class _MotivationReminderTile extends ConsumerStatefulWidget {
  const _MotivationReminderTile();

  @override
  ConsumerState<_MotivationReminderTile> createState() =>
      _MotivationReminderTileState();
}

class _MotivationReminderTileState
    extends ConsumerState<_MotivationReminderTile> {
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
            const _MotivationCountStepper(),
          ],
        ],
      ),
    );
  }
}

class _MotivationCountStepper extends ConsumerWidget {
  const _MotivationCountStepper();

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
