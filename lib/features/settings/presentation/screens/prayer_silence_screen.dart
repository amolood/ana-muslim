import 'dart:io';

import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/providers/prayer_silence_provider.dart';
import '../../../../core/services/prayer_silence_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../reschedule_prayer_silence.dart';

class PrayerSilenceScreen extends ConsumerStatefulWidget {
  const PrayerSilenceScreen({super.key});

  @override
  ConsumerState<PrayerSilenceScreen> createState() =>
      _PrayerSilenceScreenState();
}

class _PrayerSilenceScreenState extends ConsumerState<PrayerSilenceScreen> {
  bool? _hasDndPermission;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkPermission());
  }

  Future<void> _checkPermission() async {
    final has = await PrayerSilenceService.hasDndPermission();
    if (!mounted) return;
    setState(() => _hasDndPermission = has);
  }

  /// Schedules windows in the background; shows a snackbar only on failure.
  Future<void> _reschedule() async {
    final ok = await reschedulePrayerSilence(ref);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.psRescheduleFailed)),
      );
    }
  }

  // ── UI helpers ─────────────────────────────────────────────────────────────

  Widget _section(AppSemanticColors colors, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4, bottom: 8),
          child: Text(
            title,
            style: GoogleFonts.tajawal(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 0.3,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colors.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.borderSubtle, width: 0.5),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _divider(AppSemanticColors colors) => Divider(
        height: 1,
        indent: 16,
        endIndent: 16,
        color: colors.borderSubtle,
      );

  static String _prayerName(Prayer p) => switch (p) {
    Prayer.fajr    => 'الفجر',
    Prayer.dhuhr   => 'الظهر',
    Prayer.asr     => 'العصر',
    Prayer.maghrib => 'المغرب',
    Prayer.isha    => 'العشاء',
    _              => '',
  };

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final settings = ref.watch(prayerSilenceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.prayerSilenceTitle,
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Platform.isIOS
          ? _buildIosUnsupported(l10n, colors)
          : _buildAndroid(l10n, colors, settings),
    );
  }

  // ── iOS unsupported ────────────────────────────────────────────────────────

  Widget _buildIosUnsupported(AppLocalizations l10n, AppSemanticColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.phone_iphone, size: 64, color: colors.textSecondary),
            const SizedBox(height: 16),
            Text(
              l10n.psIosTitle,
              style: GoogleFonts.tajawal(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.psIosBody,
              style: GoogleFonts.tajawal(
                fontSize: 14,
                color: colors.textSecondary,
                height: 1.7,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Android content ────────────────────────────────────────────────────────

  Widget _buildAndroid(
    AppLocalizations l10n,
    AppSemanticColors colors,
    PrayerSilenceSettings settings,
  ) {
    final showPermBanner = settings.enabled &&
        settings.mode != PrayerSilenceMode.vibrate &&
        _hasDndPermission == false;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        // Enable toggle
        _buildEnableToggle(l10n, colors, settings),
        const SizedBox(height: 20),

        // Permission banner (only when DND/silent mode and no permission)
        if (showPermBanner) ...[
          _buildPermissionBanner(l10n, colors),
          const SizedBox(height: 20),
        ],

        if (settings.enabled) ...[
          // Prayers
          _section(colors, l10n.psSectionPrayers,
              _buildPrayerCheckboxes(colors, settings)),
          const SizedBox(height: 20),

          // Timing
          _section(colors, l10n.psSectionTiming,
              _buildTimingRows(l10n, colors, settings)),
          const SizedBox(height: 20),

          // Mode
          _section(colors, l10n.psSectionMode,
              _buildModeRadios(l10n, colors, settings)),
          const SizedBox(height: 20),

          // Options
          _section(colors, l10n.psSectionOptions,
              [_buildAutoRestoreToggle(l10n, colors, settings)]),
          const SizedBox(height: 32),
        ],
      ],
    );
  }

  // ── Enable toggle ──────────────────────────────────────────────────────────

  Widget _buildEnableToggle(
    AppLocalizations l10n,
    AppSemanticColors colors,
    PrayerSilenceSettings settings,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.borderSubtle, width: 0.5),
      ),
      child: SwitchListTile.adaptive(
        value: settings.enabled,
        onChanged: (val) async {
          await ref.read(prayerSilenceProvider.notifier).setEnabled(val);
          await _checkPermission();
          _reschedule();
        },
        title: Text(
          l10n.prayerSilenceTitle,
          style: GoogleFonts.tajawal(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        subtitle: Text(
          l10n.prayerSilenceSubtitle,
          style: GoogleFonts.tajawal(
            fontSize: 12,
            color: colors.textSecondary,
          ),
        ),
        activeTrackColor: AppColors.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  // ── Permission banner ──────────────────────────────────────────────────────

  Widget _buildPermissionBanner(AppLocalizations l10n, AppSemanticColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.psPermissionBannerTitle,
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.psPermissionBannerBody,
            style: GoogleFonts.tajawal(
              fontSize: 13,
              color: colors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () async {
              await PrayerSilenceService.openDndSettings();
              await _checkPermission();
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.orange.shade600),
              foregroundColor: Colors.orange.shade700,
            ),
            child: Text(l10n.psPermissionButton, style: GoogleFonts.tajawal()),
          ),
        ],
      ),
    );
  }

  // ── Prayer checkboxes ──────────────────────────────────────────────────────

  static const _silencePrayers = [
    Prayer.fajr,
    Prayer.dhuhr,
    Prayer.asr,
    Prayer.maghrib,
    Prayer.isha,
  ];

  List<Widget> _buildPrayerCheckboxes(
    AppSemanticColors colors,
    PrayerSilenceSettings settings,
  ) {
    final widgets = <Widget>[];
    for (var i = 0; i < _silencePrayers.length; i++) {
      final prayer = _silencePrayers[i];
      widgets.add(
        CheckboxListTile.adaptive(
          value: settings.isIncluded(prayer),
          onChanged: (val) async {
            await ref
                .read(prayerSilenceProvider.notifier)
                .setIncluded(prayer, val ?? true);
            _reschedule();
          },
          title: Text(
            _prayerName(prayer),
            style: GoogleFonts.tajawal(
              fontSize: 15,
              color: colors.textPrimary,
            ),
          ),
          activeColor: AppColors.primary,
          controlAffinity: ListTileControlAffinity.trailing,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      );
      if (i < _silencePrayers.length - 1) widgets.add(_divider(colors));
    }
    return widgets;
  }

  // ── Timing rows ────────────────────────────────────────────────────────────

  List<Widget> _buildTimingRows(
    AppLocalizations l10n,
    AppSemanticColors colors,
    PrayerSilenceSettings settings,
  ) {
    return [
      _buildMinutePicker(
        label: l10n.psMinutesBeforeLabel,
        displayText: l10n.psMinutesValue(settings.minutesBefore),
        value: settings.minutesBefore,
        min: 0,
        max: 60,
        colors: colors,
        onDecrement: () async {
          final next = (settings.minutesBefore - 5).clamp(0, 60);
          await ref.read(prayerSilenceProvider.notifier).setMinutesBefore(next);
          _reschedule();
        },
        onIncrement: () async {
          final next = (settings.minutesBefore + 5).clamp(0, 60);
          await ref.read(prayerSilenceProvider.notifier).setMinutesBefore(next);
          _reschedule();
        },
      ),
      _divider(colors),
      _buildMinutePicker(
        label: l10n.psMinutesAfterLabel,
        displayText: l10n.psMinutesValue(settings.minutesAfter),
        value: settings.minutesAfter,
        min: 5,
        max: 120,
        colors: colors,
        onDecrement: () async {
          final next = (settings.minutesAfter - 5).clamp(5, 120);
          await ref.read(prayerSilenceProvider.notifier).setMinutesAfter(next);
          _reschedule();
        },
        onIncrement: () async {
          final next = (settings.minutesAfter + 5).clamp(5, 120);
          await ref.read(prayerSilenceProvider.notifier).setMinutesAfter(next);
          _reschedule();
        },
      ),
    ];
  }

  Widget _buildMinutePicker({
    required String label,
    required String displayText,
    required int value,
    required int min,
    required int max,
    required AppSemanticColors colors,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: 15,
                color: colors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: value <= min ? null : onDecrement,
            icon: const Icon(Icons.remove_circle_outline),
            color: AppColors.primary,
            disabledColor: colors.textSecondary,
          ),
          SizedBox(
            width: 64,
            child: Text(
              displayText,
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: value >= max ? null : onIncrement,
            icon: const Icon(Icons.add_circle_outline),
            color: AppColors.primary,
            disabledColor: colors.textSecondary,
          ),
        ],
      ),
    );
  }

  // ── Mode radios ────────────────────────────────────────────────────────────

  List<Widget> _buildModeRadios(
    AppLocalizations l10n,
    AppSemanticColors colors,
    PrayerSilenceSettings settings,
  ) {
    final modes = [
      (PrayerSilenceMode.dnd,     l10n.psModeDnd,     Icons.do_not_disturb_on_rounded),
      (PrayerSilenceMode.silent,  l10n.psModeSilent,  Icons.volume_off_rounded),
      (PrayerSilenceMode.vibrate, l10n.psModeVibrate, Icons.vibration_rounded),
    ];

    final tiles = <Widget>[];
    for (var i = 0; i < modes.length; i++) {
      final (mode, label, icon) = modes[i];
      tiles.add(
        RadioListTile<PrayerSilenceMode>.adaptive(
          value: mode,
          title: Row(
            children: [
              Icon(icon, size: 18, color: colors.textSecondary),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.tajawal(fontSize: 15, color: colors.textPrimary),
              ),
            ],
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        ),
      );
      if (i < modes.length - 1) tiles.add(_divider(colors));
    }
    return [
      RadioGroup<PrayerSilenceMode>(
        groupValue: settings.mode,
        onChanged: (val) async {
          if (val == null) return;
          await ref.read(prayerSilenceProvider.notifier).setMode(val);
          await _checkPermission();
          _reschedule();
        },
        child: Column(children: tiles),
      ),
    ];
  }

  // ── Auto-restore toggle ────────────────────────────────────────────────────

  Widget _buildAutoRestoreToggle(
    AppLocalizations l10n,
    AppSemanticColors colors,
    PrayerSilenceSettings settings,
  ) {
    return SwitchListTile.adaptive(
      value: settings.autoRestore,
      onChanged: (val) async {
        await ref.read(prayerSilenceProvider.notifier).setAutoRestore(val);
        _reschedule();
      },
      title: Text(
        l10n.psAutoRestore,
        style: GoogleFonts.tajawal(fontSize: 15, color: colors.textPrimary),
      ),
      subtitle: Text(
        l10n.psAutoRestoreSubtitle,
        style: GoogleFonts.tajawal(fontSize: 12, color: colors.textSecondary),
      ),
      activeTrackColor: AppColors.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

}
