import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/notifications/notifications_service.dart';
import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../prayer_times/presentation/providers/prayer_times_provider.dart';

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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'تنبيهات الصلاة',
          style: GoogleFonts.tajawal(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)
            .copyWith(bottom: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Permission banner ──────────────────────────────
            _PermissionBanner(),
            const SizedBox(height: 20),
            // ─── Global toggle ──────────────────────────────────
            _buildSection(children: [
              _buildSwitchTile(
                icon: Icons.notifications_active,
                title: 'تفعيل جميع التنبيهات',
                subtitle: 'تشغيل أو إيقاف كل تنبيهات الصلاة دفعةً',
                value: globalEnabled,
                onChanged: (val) async {
                  await ref.read(adhanAlertsProvider.notifier).save(val);
                  if (context.mounted) await _reschedule(ref, context);
                },
              ),
            ]),
            const SizedBox(height: 24),
            // ─── Per-prayer toggles ─────────────────────────────
            _buildSectionHeader('تنبيهات كل صلاة'),
            _buildSection(children: [
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
            ]),
            const SizedBox(height: 24),
            // ─── Per-prayer offsets ─────────────────────────────
            _buildSectionHeader('تعديل وقت التنبيه (دقائق)'),
            _buildSection(children: [
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
            ]),
            const SizedBox(height: 28),
            // ─── Reschedule button ──────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _reschedule(ref, context),
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

  Future<void> _reschedule(WidgetRef ref, BuildContext context) async {
    final locationResult = ref.read(locationProvider);
    final calcMethodStr = ref.read(calculationMethodProvider);
    final globalEnabled = ref.read(adhanAlertsProvider);
    final notifSettings = ref.read(prayerNotifSettingsProvider);

    locationResult.whenData((pos) {
      final coords = Coordinates(pos.latitude, pos.longitude);
      final params = _buildParams(calcMethodStr);

      final enabledMap = <Prayer, bool>{
        for (final p in [
          Prayer.fajr,
          Prayer.dhuhr,
          Prayer.asr,
          Prayer.maghrib,
          Prayer.isha,
        ])
          p: globalEnabled && notifSettings.isEnabled(p),
      };

      final offsetMap = <Prayer, int>{
        for (final p in [
          Prayer.fajr,
          Prayer.dhuhr,
          Prayer.asr,
          Prayer.maghrib,
          Prayer.isha,
        ])
          p: notifSettings.offsetFor(p),
      };

      NotificationsService.rescheduleAll(
        coordinates: coords,
        calcParams: params,
        enabledMap: enabledMap,
        offsetMinutes: offsetMap,
      ).then((_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تم إعادة جدولة تنبيهات الصلاة',
                style: GoogleFonts.tajawal(),
              ),
            ),
          );
        }
      });
    });
  }

  static CalculationParameters _buildParams(String method) => switch (method) {
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
    Prayer.fajr:    'الفجر',
    Prayer.dhuhr:   'الظهر',
    Prayer.asr:     'العصر',
    Prayer.maghrib: 'المغرب',
    Prayer.isha:    'العشاء',
  };

  static const _icons = {
    Prayer.fajr:    Icons.wb_twilight,
    Prayer.dhuhr:   Icons.wb_sunny,
    Prayer.asr:     Icons.wb_cloudy,
    Prayer.maghrib: Icons.nights_stay_outlined,
    Prayer.isha:    Icons.bedtime_outlined,
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
    Prayer.fajr:    'الفجر',
    Prayer.dhuhr:   'الظهر',
    Prayer.asr:     'العصر',
    Prayer.maghrib: 'المغرب',
    Prayer.isha:    'العشاء',
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
            icon: const Icon(Icons.remove_circle_outline,
                color: AppColors.primary),
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
                  ? '0 د'
                  : offset > 0
                      ? '+$offset د'
                      : '$offset د',
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
            icon:
                const Icon(Icons.add_circle_outline, color: AppColors.primary),
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
  bool? _granted;

  @override
  Widget build(BuildContext context) {
    if (_granted == true) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'تم منح إذن الإشعارات',
                style: GoogleFonts.tajawal(color: AppColors.primary),
              ),
            ),
          ],
        ),
      );
    }

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
              'اضغط للسماح بإشعارات الصلاة',
              style: GoogleFonts.tajawal(color: Colors.orange),
            ),
          ),
          TextButton(
            onPressed: () async {
              final ok = await NotificationsService.requestPermission();
              setState(() => _granted = ok);
            },
            child: Text(
              'السماح',
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
