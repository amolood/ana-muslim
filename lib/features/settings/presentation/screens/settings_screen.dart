import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/providers/package_info_provider.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/utils/arabic_utils.dart';
import '../../../qibla/presentation/providers/qibla_feedback_provider.dart';
import '../../../prayer_times/presentation/providers/prayer_times_provider.dart';
import '../widgets/sebha_phrases_sheet.dart';
import '../widgets/settings_item_tile.dart';
import '../widgets/settings_selection_sheet.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.l10n.settingsTitle,
          style: GoogleFonts.tajawal(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: context.colors.textPrimary,
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
            _buildSectionTitle(context.l10n.sectionAppearance, context),
            const _AppearanceSection(),
            const SizedBox(height: 24),
            _buildSectionTitle(context.l10n.sectionPrayer, context),
            const _PrayerSection(),
            const SizedBox(height: 24),
            _buildSectionTitle('القبلة', context),
            const _QiblaSection(),
            const SizedBox(height: 24),
            _buildSectionTitle(context.l10n.sectionQuran, context),
            const _QuranSection(),
            const SizedBox(height: 24),
            _buildSectionTitle(context.l10n.sectionSebha, context),
            const _SebhaSection(),
            const SizedBox(height: 24),
            _buildSectionTitle('المكتبة', context),
            _buildSectionContainer(
              context,
              children: [
                SettingsItemTile(
                  icon: Icons.download_for_offline_rounded,
                  title: 'المحتوى غير المتصل',
                  subtitle: 'تفاسير، ترجمات، خطوط القرآن',
                  onTap: () => context.push(Routes.settingsLibrary),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('عام', context),
            const _GeneralSection(),
            const SizedBox(height: 48),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  // ─── Shared layout helpers (static) ────────────────────────────────────

  static Widget _buildSectionTitle(String title, BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Text(
        title,
        style: GoogleFonts.tajawal(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: colors.textSecondary,
        ),
      ),
    );
  }

  static Widget _buildSectionContainer(
    BuildContext context, {
    required List<Widget> children,
  }) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.borderSubtle, width: 1.5),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(children: children),
    );
  }

  static Widget _buildDivider(BuildContext context) {
    final colors = context.colors;
    return Divider(
      height: 1,
      thickness: 1,
      color: colors.borderSubtle,
      indent: 64,
    );
  }

  static Widget _buildFooter(BuildContext context) {
    final year = DateTime.now().year;
    return Center(
      child: Column(
        children: [
          Text(
            context.l10n.footerTitle(year),
            style: GoogleFonts.tajawal(
              fontSize: 12,
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.footerSubtitle,
            style: GoogleFonts.tajawal(
              fontSize: 10,
              color: AppColors.textSecondaryDark.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Dialogs & messaging ────────────────────────────────────────────────

  static void _showInfoMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: GoogleFonts.tajawal())),
    );
  }

  static void _showInfoDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: AppColors.surfaceDark,
            title: Text(
              title,
              style: GoogleFonts.tajawal(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            content: Text(
              message,
              style: GoogleFonts.tajawal(
                fontSize: 14,
                color: AppColors.textSecondaryDark,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  context.l10n.done,
                  style: GoogleFonts.tajawal(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> _openContactPage(BuildContext context) async {
    try {
      final opened = await launchUrl(
        Uri.parse('https://anaalmuslim.com/contact'),
        mode: LaunchMode.externalApplication,
      );
      if (!opened && context.mounted) {
        _showInfoMessage(context, context.l10n.whatsappError);
      }
    } catch (_) {
      if (context.mounted) {
        _showInfoMessage(context, context.l10n.whatsappError);
      }
    }
  }
}

// ─── Appearance section ────────────────────────────────────────────────────
// Watches: appThemeProvider, fontSizeProvider, appLanguageProvider

class _AppearanceSection extends ConsumerWidget {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final fontSize = ref.watch(fontSizeProvider);
    final language = ref.watch(appLanguageProvider);

    return SettingsScreen._buildSectionContainer(
      context,
      children: [
        SettingsItemTile(
          icon: Icons.dark_mode,
          title: context.l10n.settingTheme,
          trailingText: theme,
          onTap: () => showSettingsSelectionSheet(
            context,
            context.l10n.settingTheme,
            ['داكن', 'فاتح', 'نظام'],
            theme,
            (val) async => ref.read(appThemeProvider.notifier).save(val),
          ),
        ),
        SettingsScreen._buildDivider(context),
        SettingsItemTile(
          icon: Icons.format_size,
          title: context.l10n.settingFontSize,
          trailingText: fontSize,
          onTap: () => showSettingsSelectionSheet(
            context,
            context.l10n.settingFontSize,
            ['صغير', 'متوسط', 'كبير'],
            fontSize,
            (val) async {
              await ref.read(fontSizeProvider.notifier).save(val);
              final mapped = switch (val) {
                'صغير' => 21.0,
                'كبير' => 28.0,
                _ => 24.0,
              };
              await ref.read(quranFontSizeProvider.notifier).save(mapped);
            },
          ),
        ),
        SettingsScreen._buildDivider(context),
        SettingsItemTile(
          icon: Icons.language,
          title: context.l10n.settingLanguage,
          trailingText: language,
          onTap: () => showSettingsSelectionSheet(
            context,
            context.l10n.settingLanguage,
            ['العربية', 'English', 'Français'],
            language,
            (val) async => ref.read(appLanguageProvider.notifier).save(val),
          ),
        ),
      ],
    );
  }
}

// ─── Prayer section ────────────────────────────────────────────────────────
// Watches: adhanAlertsProvider, calculationMethodProvider, madhabProvider,
//          locationNameProvider

class _PrayerSection extends ConsumerWidget {
  const _PrayerSection();

  static const _calcMethods = [
    'أم القرى',
    'رابطة العالم الإسلامي',
    'الهيئة العامة للمساحة المصرية',
    'جامعة العلوم الإسلامية بكراتشي',
    'الجمعية الإسلامية لأمريكا الشمالية',
    'دبي',
    'الكويت',
    'قطر',
    'تركيا',
    'إيران',
    'سنغافورة',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adhanAlerts = ref.watch(adhanAlertsProvider);
    final calcMethod = ref.watch(calculationMethodProvider);
    final madhab = ref.watch(madhabProvider);
    final locationNameAsync = ref.watch(locationNameProvider);

    return SettingsScreen._buildSectionContainer(
      context,
      children: [
        SettingsItemTile(
          icon: Icons.calculate,
          title: context.l10n.settingCalcMethod,
          trailingText: calcMethod,
          onTap: () => showSettingsSelectionSheet(
            context,
            context.l10n.settingCalcMethod,
            _calcMethods,
            calcMethod,
            (val) async =>
                ref.read(calculationMethodProvider.notifier).save(val),
          ),
        ),
        SettingsScreen._buildDivider(context),
        SettingsItemTile(
          icon: Icons.mosque_rounded,
          title: 'المذهب الفقهي',
          subtitle: 'يؤثر على حساب وقت العصر',
          trailingText: madhab,
          onTap: () => showSettingsSelectionSheet(
            context,
            'المذهب الفقهي',
            ['شافعي', 'حنفي'],
            madhab,
            (val) async => ref.read(madhabProvider.notifier).save(val),
          ),
        ),
        SettingsScreen._buildDivider(context),
        SettingsItemTile(
          icon: Icons.tune,
          title: context.l10n.settingPrayerAdjustment,
          subtitle: context.l10n.settingPrayerAdjustmentSubtitle,
          onTap: () => context.push(Routes.settingsPrayerAdjustment),
        ),
        SettingsScreen._buildDivider(context),
        SettingsItemTile(
          icon: Icons.notifications_active,
          title: context.l10n.settingPrayerAlerts,
          trailingText: adhanAlerts
              ? context.l10n.settingEnabled
              : context.l10n.settingDisabled,
          onTap: () => context.push(Routes.settingsNotifications),
        ),
        SettingsScreen._buildDivider(context),
        SettingsItemTile(
          icon: Icons.phone_in_talk_rounded,
          title: context.l10n.prayerSilenceTitle,
          subtitle: context.l10n.prayerSilenceSubtitle,
          onTap: () => context.push(Routes.settingsPrayerSilence),
        ),
        SettingsScreen._buildDivider(context),
        SettingsItemTile(
          icon: Icons.location_on,
          title: context.l10n.settingCurrentLocation,
          trailingText: locationNameAsync.maybeWhen(
            data: (loc) => loc.split('،').first,
            orElse: () => context.l10n.locationAuto,
          ),
          onTap: () async {
            ref.invalidate(locationProvider);
            ref.invalidate(locationNameProvider);
            ref.invalidate(prayerTimesProvider);
            try {
              await ref.read(locationNameProvider.future);
              if (!context.mounted) return;
              SettingsScreen._showInfoMessage(
                  context, context.l10n.locationUpdated);
            } catch (e) {
              if (!context.mounted) return;
              SettingsScreen._showInfoMessage(
                  context, context.l10n.locationUpdateFailed);
            }
          },
        ),
      ],
    );
  }
}

// ─── Qibla section ─────────────────────────────────────────────────────────
// Watches: qiblaSuccessToneProvider, qiblaSuccessToneOptionProvider

class _QiblaSection extends ConsumerWidget {
  const _QiblaSection();

  static const _qiblaToneOptionMap = {
    'high': 'نغمة عالية',
    'bell': 'نغمة جرس',
    'labbaik': 'لبيك اللهم',
  };

  static String _qiblaToneOptionLabel(String key) =>
      _qiblaToneOptionMap[key] ?? 'نغمة عالية';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qiblaToneEnabled = ref.watch(qiblaSuccessToneProvider);
    final qiblaToneOption = ref.watch(qiblaSuccessToneOptionProvider);

    return SettingsScreen._buildSectionContainer(
      context,
      children: [
        SettingsItemTile(
          icon: Icons.spatial_audio,
          title: context.l10n.settingQiblaTone,
          trailingText: qiblaToneEnabled
              ? context.l10n.settingEnabled
              : context.l10n.settingDisabled,
          onTap: () => showSettingsSelectionSheet(
            context,
            context.l10n.settingQiblaTone,
            ['مفعلة', 'موقفة'],
            qiblaToneEnabled ? 'مفعلة' : 'موقفة',
            (val) async =>
                ref.read(qiblaSuccessToneProvider.notifier).save(val == 'مفعلة'),
          ),
        ),
        SettingsScreen._buildDivider(context),
        SettingsItemTile(
          icon: Icons.music_note_rounded,
          title: context.l10n.settingQiblaToneType,
          trailingText: qiblaToneOption.label,
          onTap: () => showSettingsSelectionSheet(
            context,
            context.l10n.settingQiblaToneType,
            ['high', 'bell', 'labbaik'],
            qiblaToneOption.key,
            (val) async {
              final option = switch (val) {
                'bell' => QiblaSuccessToneOption.bell,
                'labbaik' => QiblaSuccessToneOption.labbaik,
                _ => QiblaSuccessToneOption.high,
              };
              await ref.read(qiblaSuccessToneOptionProvider.notifier).save(option);
            },
            displayMapper: _qiblaToneOptionLabel,
          ),
        ),
        SettingsScreen._buildDivider(context),
        SettingsItemTile(
          icon: Icons.play_arrow_rounded,
          title: context.l10n.settingQiblaPreview,
          subtitle: context.l10n.settingQiblaPreviewSubtitle,
          onTap: () async {
            if (!qiblaToneEnabled) {
              SettingsScreen._showInfoMessage(
                context,
                context.l10n.qiblaToneEnableFirst,
              );
              return;
            }
            try {
              await ref.read(qiblaTonePlayerProvider).play(qiblaToneOption);
            } catch (_) {
              if (!context.mounted) return;
              SettingsScreen._showInfoMessage(
                  context, context.l10n.qiblaTonePlayFailed);
            }
          },
        ),
      ],
    );
  }
}

// ─── Quran section ─────────────────────────────────────────────────────────
// Watches: tafsirSourceProvider, defaultReciterNameProvider

class _QuranSection extends ConsumerWidget {
  const _QuranSection();

  static const _tafsirMap = {
    'saadi': 'تفسير السعدي',
    'ibnkatheer': 'تفسير ابن كثير',
    'tabari': 'تفسير الطبري',
    'qurtubi': 'تفسير القرطبي',
    'tafsir-jalalayn': 'تفسير الجلالين',
  };

  static String _tafsirDisplayName(String key) =>
      _tafsirMap[key] ?? 'تفسير السعدي';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tafsirSource = ref.watch(tafsirSourceProvider);
    final defaultReciterName = ref.watch(defaultReciterNameProvider);

    return SettingsScreen._buildSectionContainer(
      context,
      children: [
        SettingsItemTile(
          icon: Icons.menu_book,
          title: context.l10n.settingTafsir,
          trailingText: _tafsirDisplayName(tafsirSource),
          onTap: () => showSettingsSelectionSheet(
            context,
            context.l10n.settingTafsir,
            [
              'saadi',
              'ibnkatheer',
              'tabari',
              'qurtubi',
              'tafsir-jalalayn',
            ],
            tafsirSource,
            (val) async => ref.read(tafsirSourceProvider.notifier).save(val),
            displayMapper: _tafsirDisplayName,
          ),
        ),
        SettingsScreen._buildDivider(context),
        SettingsItemTile(
          icon: Icons.record_voice_over,
          title: context.l10n.settingDefaultReciter,
          trailingText: defaultReciterName ?? context.l10n.notSet,
          onTap: () => context.push(Routes.settingsDefaultReciter),
        ),
      ],
    );
  }
}

// ─── Sebha section ─────────────────────────────────────────────────────────
// Watches: sebhaDefaultDailyGoalProvider, sebhaStateProvider

class _SebhaSection extends ConsumerWidget {
  const _SebhaSection();

  static String _sebhaGoalLabel(BuildContext context, int goal) {
    if (goal <= 0) return context.l10n.notSet;
    return ArabicUtils.toArabicDigits(goal);
  }

  static String _truncateText(String text, {required int maxChars}) {
    final normalized = text.trim();
    if (normalized.length <= maxChars) return normalized;
    return '${normalized.substring(0, maxChars)}…';
  }

  void _showSebhaDefaultGoalSheet(
    BuildContext context,
    WidgetRef ref, {
    required int currentGoal,
  }) {
    const goals = [0, 3, 7, 33, 100];
    showSettingsSelectionSheet(
      context,
      context.l10n.sebhaDefaultGoalTitle,
      goals.map((goal) => goal.toString()).toList(growable: false),
      currentGoal.toString(),
      (value) async {
        final parsed = int.tryParse(value);
        if (parsed == null) return;
        await ref.read(sebhaDefaultDailyGoalProvider.notifier).save(parsed);
        await ref.read(sebhaStateProvider.notifier).setDailyGoalForAll(parsed);
      },
      displayMapper: (value) {
        final parsed = int.tryParse(value) ?? 0;
        return parsed == 0 ? context.l10n.notSet : ArabicUtils.toArabicDigits(parsed);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sebhaDefaultGoal = ref.watch(sebhaDefaultDailyGoalProvider);
    final sebhaState = ref.watch(sebhaStateProvider);

    return SettingsScreen._buildSectionContainer(
      context,
      children: [
        SettingsItemTile(
          icon: Icons.track_changes_rounded,
          title: context.l10n.sebhaDefaultGoalTitle,
          trailingText: _sebhaGoalLabel(context, sebhaDefaultGoal),
          subtitle: context.l10n.sebhaDefaultGoalSubtitle,
          onTap: () => _showSebhaDefaultGoalSheet(
            context,
            ref,
            currentGoal: sebhaDefaultGoal,
          ),
        ),
        SettingsScreen._buildDivider(context),
        SettingsItemTile(
          icon: Icons.format_list_bulleted_rounded,
          title: context.l10n.sebhaPhraseListTitle,
          trailingText: ArabicUtils.toArabicDigits(sebhaState.phrases.length),
          subtitle: context.l10n.sebhaPhraseListSubtitle(
            _truncateText(sebhaState.selectedPhrase.text, maxChars: 24),
          ),
          onTap: () => showSebhaPhrasesSheet(context),
        ),
      ],
    );
  }
}

// ─── General section ─────────────────────────────────────────────────────────
// Watches: packageInfoProvider (for dynamic version string)
// Contains: Calendar, Widgets, rating, privacy, contact, about

class _GeneralSection extends ConsumerWidget {
  const _GeneralSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageInfo = ref.watch(packageInfoProvider);
    final versionText = packageInfo.maybeWhen(
      data: (info) => 'v${info.version}',
      orElse: () => '',
    );

    return SettingsScreen._buildSectionContainer(
      context,
      children: [
        SettingsItemTile(
          icon: Icons.widgets_rounded,
          title: context.l10n.widgetSettingsTitle,
          subtitle: context.l10n.widgetSettingsSubtitle,
          onTap: () => context.push(Routes.settingsWidgets),
        ),
        SettingsScreen._buildDivider(context),
        SettingsItemTile(
          icon: Icons.star_rounded,
          title: 'تقييم التطبيق',
          subtitle: 'ساعدنا بتقييم أنا المسلم على المتجر',
          onTap: () async {
            const url =
                'https://play.google.com/store/apps/details?id=com.anaalmuslim.app';
            try {
              final opened = await launchUrl(
                Uri.parse(url),
                mode: LaunchMode.externalApplication,
              );
              if (!opened && context.mounted) {
                SettingsScreen._showInfoMessage(context, 'تعذّر فتح المتجر');
              }
            } catch (_) {
              if (context.mounted) {
                SettingsScreen._showInfoMessage(context, 'تعذّر فتح المتجر');
              }
            }
          },
        ),
        SettingsScreen._buildDivider(context),
        SettingsItemTile(
          icon: Icons.privacy_tip,
          title: context.l10n.settingPrivacy,
          onTap: () => SettingsScreen._showInfoDialog(
            context,
            title: context.l10n.settingPrivacy,
            message: context.l10n.privacyMessage,
          ),
        ),
        SettingsScreen._buildDivider(context),
        SettingsItemTile(
          icon: Icons.language_rounded,
          title: context.l10n.settingContactUs,
          subtitle: context.l10n.settingContactSubtitle,
          onTap: () => SettingsScreen._openContactPage(context),
        ),
        SettingsScreen._buildDivider(context),
        SettingsItemTile(
          icon: Icons.info_outline_rounded,
          title: context.l10n.settingAbout,
          trailingText: versionText,
          onTap: () => SettingsScreen._showInfoDialog(
            context,
            title: context.l10n.settingAbout,
            message: context.l10n.aboutMessage,
          ),
        ),
      ],
    );
  }
}
