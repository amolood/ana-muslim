import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../../core/notifications/notifications_service.dart';
import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/prayer_utils.dart';
import '../../../prayer_times/presentation/providers/prayer_times_provider.dart';

/// QA Debug screen — only accessible in debug builds.
/// Reachable via route /debug
class DebugScreen extends ConsumerWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kDebugMode) {
      return const Scaffold(
        body: Center(child: Text('Debug screen unavailable in release builds.')),
      );
    }

    final prayerTimesAsync = ref.watch(prayerTimesProvider);
    final locationNameAsync = ref.watch(locationNameProvider);
    final calcMethod = ref.watch(calculationMethodProvider);
    final tafsirSource = ref.watch(tafsirSourceProvider);
    final adhanEnabled = ref.watch(adhanAlertsProvider);
    final hijriOffset = ref.watch(hijriOffsetProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '🔧 QA Debug',
          style: GoogleFonts.tajawal(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
            .copyWith(bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Prayer times ──────────────────────────────────────
            _Section(
              title: 'Prayer Times',
              child: prayerTimesAsync.when(
                data: (pt) {
                  final upcoming =
                      PrayerUtils.getUpcomingPrayer(pt, DateTime.now());
                  final fmt = DateFormat('hh:mm a');
                  return Column(
                    children: [
                      _Row('Fajr', fmt.format(pt.fajr.toLocal())),
                      _Row('Dhuhr', fmt.format(pt.dhuhr.toLocal())),
                      _Row('Asr', fmt.format(pt.asr.toLocal())),
                      _Row('Maghrib', fmt.format(pt.maghrib.toLocal())),
                      _Row('Isha', fmt.format(pt.isha.toLocal())),
                      const Divider(color: Colors.white12),
                      _Row(
                        'Next Prayer',
                        '${_prayerName(upcoming.prayer)} @ ${fmt.format(upcoming.time.toLocal())}',
                        valueColor: AppColors.primary,
                      ),
                    ],
                  );
                },
                loading: () => const LinearProgressIndicator(
                  color: AppColors.primary,
                ),
                error: (e, _) => Text(
                  'Error: $e',
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // ─── Location & method ─────────────────────────────────
            _Section(
              title: 'Location & Calculation',
              child: Column(
                children: [
                  locationNameAsync.when(
                    data: (name) => _Row('City', name),
                    loading: () => _Row('City', 'Loading…'),
                    error: (e, _) => _Row('City', 'Error: $e',
                        valueColor: Colors.redAccent),
                  ),
                  _Row('Calc Method', calcMethod),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // ─── Notifications ─────────────────────────────────────
            _Section(
              title: 'Notifications',
              child: Column(
                children: [
                  _Row(
                    'Global Enabled',
                    adhanEnabled.toString(),
                    valueColor:
                        adhanEnabled ? AppColors.primary : Colors.redAccent,
                  ),
                  _Row('Tafsir Source', tafsirSource),
                  _Row('Hijri Offset', '$hijriOffset days'),
                  const SizedBox(height: 8),
                  _PendingNotifWidget(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // ─── Per-prayer toggles ────────────────────────────────
            Consumer(
              builder: (context, ref, _) {
                final settings = ref.watch(prayerNotifSettingsProvider);
                return _Section(
                  title: 'Per-Prayer Notification Toggles',
                  child: Column(
                    children: [
                      for (final p in [
                        Prayer.fajr,
                        Prayer.dhuhr,
                        Prayer.asr,
                        Prayer.maghrib,
                        Prayer.isha,
                      ]) ...[
                        _Row(
                          _prayerName(p),
                          () {
                            final en = settings.isEnabled(p);
                            final off = settings.offsetFor(p);
                            return '${en ? "✓" : "✗"}  offset: ${off >= 0 ? "+$off" : "$off"} min';
                          }(),
                          valueColor: settings.isEnabled(p)
                              ? AppColors.primary
                              : Colors.white38,
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // ─── Debug actions ─────────────────────────────────────
            _Section(
              title: 'Actions',
              child: Column(
                children: [
                  _ActionButton(
                    label: 'Cancel All Notifications',
                    color: Colors.redAccent,
                    onTap: () async {
                      await NotificationsService.cancelAll();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('All notifications cancelled'),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  _ActionButton(
                    label: 'Show Test Notification',
                    color: AppColors.primary,
                    onTap: () {
                      NotificationsService.requestPermission().then((_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Permission requested'),
                            ),
                          );
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Build: ${kDebugMode ? "DEBUG" : "RELEASE"}\n'
                '${DateTime.now()}',
                style: GoogleFonts.tajawal(
                  color: Colors.white24,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _prayerName(Prayer p) => switch (p) {
        Prayer.fajr => 'Fajr',
        Prayer.dhuhr => 'Dhuhr',
        Prayer.asr => 'Asr',
        Prayer.maghrib => 'Maghrib',
        Prayer.isha => 'Isha',
        _ => p.name,
      };
}

// ─── Supporting widgets ────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.bug_report,
                    color: AppColors.primary, size: 14),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: GoogleFonts.tajawal(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.tajawal(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.tajawal(
                color: valueColor ?? Colors.white.withValues(alpha: 0.87),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withValues(alpha: 0.6)),
          foregroundColor: color,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(label, style: GoogleFonts.tajawal()),
      ),
    );
  }
}

class _PendingNotifWidget extends StatefulWidget {
  @override
  State<_PendingNotifWidget> createState() => _PendingNotifWidgetState();
}

class _PendingNotifWidgetState extends State<_PendingNotifWidget> {
  int? _count;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final pending = await NotificationsService.pendingNotifications();
    if (mounted) {
      setState(() => _count = pending.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Scheduled Notifications',
          style: GoogleFonts.tajawal(color: Colors.white54, fontSize: 13),
        ),
        Row(
          children: [
            Text(
              _count == null ? '...' : '$_count pending',
              style: GoogleFonts.tajawal(
                color: (_count ?? 0) > 0 ? AppColors.primary : Colors.white38,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: _load,
              child: const Icon(Icons.refresh,
                  size: 14, color: AppColors.primary),
            ),
          ],
        ),
      ],
    );
  }
}
