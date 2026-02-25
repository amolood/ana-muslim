import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/utils/arabic_utils.dart';
import '../../../qibla/presentation/providers/qibla_feedback_provider.dart';
import '../../../prayer_times/presentation/providers/prayer_times_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adhanAlerts = ref.watch(adhanAlertsProvider);
    final theme = ref.watch(appThemeProvider);
    final fontSize = ref.watch(fontSizeProvider);
    final language = ref.watch(appLanguageProvider);
    final calcMethod = ref.watch(calculationMethodProvider);
    final locationNameAsync = ref.watch(locationNameProvider);
    final qiblaToneEnabled = ref.watch(qiblaSuccessToneProvider);
    final qiblaToneOption = ref.watch(qiblaSuccessToneOptionProvider);
    final sebhaDefaultGoal = ref.watch(sebhaDefaultDailyGoalProvider);
    final sebhaState = ref.watch(sebhaStateProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'إعدادات التطبيق',
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
            // ─── Appearance ──────────────────────────────────────
            _buildSectionTitle('المظهر', context),
            _buildSectionContainer(
              context,
              children: [
                _buildSettingsItem(
                  context,
                  icon: Icons.dark_mode,
                  title: 'الثيم',
                  trailingText: theme,
                  onTap: () => _showSelectionSheet(
                    context,
                    'الثيم',
                    ['داكن', 'فاتح'],
                    theme,
                    (val) async =>
                        ref.read(appThemeProvider.notifier).save(val),
                  ),
                ),
                _buildDivider(context),
                _buildSettingsItem(
                  context,
                  icon: Icons.format_size,
                  title: 'حجم الخط',
                  trailingText: fontSize,
                  onTap: () => _showSelectionSheet(
                    context,
                    'حجم الخط',
                    ['صغير', 'متوسط', 'كبير'],
                    fontSize,
                    (val) async {
                      await ref.read(fontSizeProvider.notifier).save(val);
                      final mapped = switch (val) {
                        'صغير' => 21.0,
                        'كبير' => 28.0,
                        _ => 24.0,
                      };
                      await ref
                          .read(quranFontSizeProvider.notifier)
                          .save(mapped);
                    },
                  ),
                ),
                _buildDivider(context),
                _buildSettingsItem(
                  context,
                  icon: Icons.language,
                  title: 'اللغة',
                  trailingText: language,
                  onTap: () => _showSelectionSheet(
                    context,
                    'اللغة',
                    ['العربية', 'English', 'Français'],
                    language,
                    (val) async =>
                        ref.read(appLanguageProvider.notifier).save(val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // ─── Prayer ──────────────────────────────────────────
            _buildSectionTitle('الصلاة', context),
            _buildSectionContainer(
              context,
              children: [
                _buildSettingsItem(
                  context,
                  icon: Icons.calculate,
                  title: 'طريقة الحساب',
                  trailingText: calcMethod,
                  onTap: () => _showSelectionSheet(
                    context,
                    'طريقة الحساب',
                    [
                      'أم القرى',
                      'رابطة العالم الإسلامي',
                      'الهيئة العامة للمساحة المصرية',
                      'جامعة العلوم الإسلامية بكراتشي',
                      'الجمعية الإسلامية لأمريكا الشمالية',
                    ],
                    calcMethod,
                    (val) async =>
                        ref.read(calculationMethodProvider.notifier).save(val),
                  ),
                ),
                _buildDivider(context),
                _buildSettingsItem(
                  context,
                  icon: Icons.tune,
                  title: 'ضبط مواقيت الصلاة',
                  subtitle: 'تقديم أو تأخير كل صلاة بدقائق',
                  onTap: () => context.push('/settings/prayer-adjustment'),
                ),
                _buildDivider(context),
                _buildSettingsItem(
                  context,
                  icon: Icons.notifications_active,
                  title: 'تنبيهات الصلاة',
                  trailingText: adhanAlerts ? 'مفعلة' : 'موقفة',
                  onTap: () => context.push('/settings/notifications'),
                ),
                _buildDivider(context),
                _buildSettingsItem(
                  context,
                  icon: Icons.spatial_audio,
                  title: 'نغمة نجاح القبلة',
                  trailingText: qiblaToneEnabled ? 'مفعلة' : 'موقفة',
                  onTap: () => _showSelectionSheet(
                    context,
                    'نغمة نجاح القبلة',
                    ['مفعلة', 'موقفة'],
                    qiblaToneEnabled ? 'مفعلة' : 'موقفة',
                    (val) async => ref
                        .read(qiblaSuccessToneProvider.notifier)
                        .save(val == 'مفعلة'),
                  ),
                ),
                _buildDivider(context),
                _buildSettingsItem(
                  context,
                  icon: Icons.music_note_rounded,
                  title: 'نوع نغمة القبلة',
                  trailingText: qiblaToneOption.label,
                  onTap: () => _showSelectionSheet(
                    context,
                    'نوع نغمة القبلة',
                    ['high', 'bell', 'labbaik'],
                    qiblaToneOption.key,
                    (val) async {
                      final option = switch (val) {
                        'bell' => QiblaSuccessToneOption.bell,
                        'labbaik' => QiblaSuccessToneOption.labbaik,
                        _ => QiblaSuccessToneOption.high,
                      };
                      await ref
                          .read(qiblaSuccessToneOptionProvider.notifier)
                          .save(option);
                    },
                    displayMapper: _qiblaToneOptionLabel,
                  ),
                ),
                _buildDivider(context),
                _buildSettingsItem(
                  context,
                  icon: Icons.play_arrow_rounded,
                  title: 'معاينة نغمة القبلة',
                  subtitle: 'تشغيل النغمة المختارة للتأكد من الصوت',
                  onTap: () async {
                    if (!qiblaToneEnabled) {
                      _showInfoMessage(
                        context,
                        'فعّل نغمة نجاح القبلة أولًا من الإعدادات',
                      );
                      return;
                    }
                    try {
                      await ref
                          .read(qiblaTonePlayerProvider)
                          .play(qiblaToneOption);
                    } catch (_) {
                      if (!context.mounted) return;
                      _showInfoMessage(context, 'تعذّر تشغيل النغمة');
                    }
                  },
                ),
                _buildDivider(context),
                _buildSettingsItem(
                  context,
                  icon: Icons.location_on,
                  title: 'الموقع الحالي',
                  trailingText: locationNameAsync.maybeWhen(
                    data: (loc) => loc.split('،').first,
                    orElse: () => 'تلقائي',
                  ),
                  onTap: () async {
                    ref.invalidate(locationProvider);
                    ref.invalidate(locationNameProvider);
                    ref.invalidate(prayerTimesProvider);
                    try {
                      await ref.read(locationNameProvider.future);
                      if (!context.mounted) return;
                      _showInfoMessage(context, 'تم تحديث الموقع بنجاح');
                    } catch (e) {
                      if (!context.mounted) return;
                      _showInfoMessage(context, 'تعذّر تحديث الموقع: $e');
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            // ─── Calendar ────────────────────────────────────────
            _buildSectionTitle('التقويم', context),
            _buildSectionContainer(
              context,
              children: [
                _buildSettingsItem(
                  context,
                  icon: Icons.calendar_month,
                  title: 'التقويم الهجري',
                  subtitle: 'عرض ومنتقي التاريخ الهجري',
                  onTap: () => context.push('/settings/hijri'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // ─── Quran ───────────────────────────────────────────
            _buildSectionTitle('القرآن الكريم', context),
            _buildSectionContainer(
              context,
              children: [
                _buildSettingsItem(
                  context,
                  icon: Icons.menu_book,
                  title: 'مصدر التفسير',
                  trailingText: _tafsirDisplayName(
                    ref.watch(tafsirSourceProvider),
                  ),
                  onTap: () => _showSelectionSheet(
                    context,
                    'مصدر التفسير',
                    [
                      'saadi',
                      'ibnkatheer',
                      'tabari',
                      'qurtubi',
                      'tafsir-jalalayn',
                    ],
                    ref.read(tafsirSourceProvider),
                    (val) async =>
                        ref.read(tafsirSourceProvider.notifier).save(val),
                    displayMapper: _tafsirDisplayName,
                  ),
                ),
                _buildDivider(context),
                _buildSettingsItem(
                  context,
                  icon: Icons.record_voice_over,
                  title: 'القارئ الافتراضي',
                  trailingText:
                      ref.watch(defaultReciterNameProvider) ?? 'غير محدد',
                  onTap: () => context.push('/settings/default-reciter'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // ─── Sebha ───────────────────────────────────────────
            _buildSectionTitle('السبحة', context),
            _buildSectionContainer(
              context,
              children: [
                _buildSettingsItem(
                  context,
                  icon: Icons.track_changes_rounded,
                  title: 'الهدف الافتراضي للتسبيح',
                  trailingText: _sebhaGoalLabel(sebhaDefaultGoal),
                  subtitle: 'يُطبّق تلقائيًا على جميع التسبيحات',
                  onTap: () => _showSebhaDefaultGoalSheet(
                    context,
                    ref,
                    currentGoal: sebhaDefaultGoal,
                  ),
                ),
                _buildDivider(context),
                _buildSettingsItem(
                  context,
                  icon: Icons.format_list_bulleted_rounded,
                  title: 'قائمة التسبيحات',
                  trailingText: ArabicUtils.toArabicDigits(
                    sebhaState.phrases.length,
                  ),
                  subtitle:
                      'الحالية: ${_truncateText(sebhaState.selectedPhrase.text, maxChars: 24)}',
                  onTap: () => _showSebhaPhrasesManagerSheet(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // ─── Other ───────────────────────────────────────────
            _buildSectionTitle('أخرى', context),
            _buildSectionContainer(
              context,
              children: [
                _buildSettingsItem(
                  context,
                  icon: Icons.privacy_tip,
                  title: 'الخصوصية',
                  onTap: () => _showInfoDialog(
                    context,
                    title: 'الخصوصية',
                    message:
                        'لا يتم إرسال بياناتك الشخصية إلى خوادم خارجية. يتم حفظ الإعدادات محليًا على جهازك فقط.',
                  ),
                ),
                _buildDivider(context),
                _buildSettingsItem(
                  context,
                  icon: Icons.chat,
                  title: 'تواصل معنا',
                  subtitle: 'واتساب',
                  onTap: () => _openWhatsapp(context),
                ),
                _buildDivider(context),
                _buildSettingsItem(
                  context,
                  icon: Icons.info,
                  title: 'عن التطبيق',
                  trailingText: 'الإصدار 1.0.0',
                  onTap: () => _showInfoDialog(
                    context,
                    title: 'عن التطبيق',
                    message:
                        'تطبيق المسلم: قرآن، أذكار، قبلة، ومواقيت الصلاة في تجربة عربية متكاملة.\n\nصدقة جارية عني وعن والديَّ وعن كل المسلمين.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  static const _tafsirMap = {
    'saadi': 'تفسير السعدي',
    'ibnkatheer': 'تفسير ابن كثير',
    'tabari': 'تفسير الطبري',
    'qurtubi': 'تفسير القرطبي',
    'tafsir-jalalayn': 'تفسير الجلالين',
  };

  static String _tafsirDisplayName(String key) =>
      _tafsirMap[key] ?? 'تفسير السعدي';

  static const _qiblaToneOptionMap = {
    'high': 'نغمة عالية',
    'bell': 'نغمة جرس',
    'labbaik': 'لبيك اللهم',
  };

  static String _qiblaToneOptionLabel(String key) =>
      _qiblaToneOptionMap[key] ?? 'نغمة عالية';

  static String _sebhaGoalLabel(int goal) {
    if (goal <= 0) return 'غير محدد';
    return ArabicUtils.toArabicDigits(goal);
  }

  static String _truncateText(String text, {required int maxChars}) {
    final normalized = text.trim();
    if (normalized.length <= maxChars) return normalized;
    return '${normalized.substring(0, maxChars)}…';
  }

  void _showSelectionSheet(
    BuildContext context,
    String title,
    List<String> options,
    String currentValue,
    Future<void> Function(String) onSelected, {
    String Function(String)? displayMapper,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: GoogleFonts.tajawal(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              ...options.map((option) {
                final label = displayMapper != null
                    ? displayMapper(option)
                    : option;
                return ListTile(
                  title: Text(
                    label,
                    style: GoogleFonts.tajawal(
                      fontSize: 16,
                      color: option == currentValue
                          ? AppColors.primary
                          : Colors.white,
                      fontWeight: option == currentValue
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  trailing: option == currentValue
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () async {
                    try {
                      await onSelected(option);
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    } catch (e) {
                      if (!context.mounted) return;
                      _showInfoMessage(context, 'تعذّر حفظ الإعداد: $e');
                    }
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showSebhaDefaultGoalSheet(
    BuildContext context,
    WidgetRef ref, {
    required int currentGoal,
  }) {
    const goals = [0, 3, 7, 33, 100];
    _showSelectionSheet(
      context,
      'الهدف الافتراضي للتسبيح',
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
        return parsed == 0 ? 'غير محدد' : ArabicUtils.toArabicDigits(parsed);
      },
    );
  }

  void _showSebhaPhrasesManagerSheet(BuildContext context) {
    final controller = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          minChildSize: 0.55,
          maxChildSize: 0.92,
          builder: (context, scrollController) {
            return Consumer(
              builder: (context, sheetRef, _) {
                final sebhaState = sheetRef.watch(sebhaStateProvider);
                final defaultGoal = sheetRef.watch(
                  sebhaDefaultDailyGoalProvider,
                );

                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    12,
                    16,
                    16 + MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'إدارة قائمة التسبيحات',
                              style: GoogleFonts.tajawal(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Text(
                            'الهدف: ${_sebhaGoalLabel(defaultGoal)}',
                            style: GoogleFonts.tajawal(
                              fontSize: 13,
                              color: AppColors.textSecondaryDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          hintText: 'أضف تسبيحة جديدة',
                          hintStyle: GoogleFonts.tajawal(
                            color: AppColors.textSecondaryDark,
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.06),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1.6,
                            ),
                          ),
                          suffixIcon: IconButton(
                            tooltip: 'إضافة',
                            icon: const Icon(
                              Icons.add_circle_rounded,
                              color: AppColors.primary,
                            ),
                            onPressed: () async {
                              final text = controller.text.trim();
                              if (text.isEmpty) {
                                _showInfoMessage(
                                  context,
                                  'اكتب التسبيحة قبل الإضافة',
                                );
                                return;
                              }
                              final added = await sheetRef
                                  .read(sebhaStateProvider.notifier)
                                  .addCustomPhrase(
                                    text: text,
                                    goal: defaultGoal,
                                  );
                              if (!context.mounted) return;
                              if (!added) {
                                _showInfoMessage(
                                  context,
                                  'التسبيحة موجودة بالفعل',
                                );
                                return;
                              }
                              controller.clear();
                              FocusScope.of(context).unfocus();
                            },
                          ),
                        ),
                        style: GoogleFonts.tajawal(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        onSubmitted: (_) async {
                          final text = controller.text.trim();
                          if (text.isEmpty) return;
                          final added = await sheetRef
                              .read(sebhaStateProvider.notifier)
                              .addCustomPhrase(text: text, goal: defaultGoal);
                          if (!context.mounted) return;
                          if (!added) {
                            _showInfoMessage(context, 'التسبيحة موجودة بالفعل');
                            return;
                          }
                          controller.clear();
                          FocusScope.of(context).unfocus();
                        },
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.separated(
                          controller: scrollController,
                          itemCount: sebhaState.phrases.length,
                          separatorBuilder: (_, _) => Divider(
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                          itemBuilder: (context, index) {
                            final phrase = sebhaState.phrases[index];
                            final isSelected =
                                phrase.id == sebhaState.selectedPhraseId;
                            final phraseGoal = phrase.dailyGoal <= 0
                                ? 'غير محدد'
                                : ArabicUtils.toArabicDigits(phrase.dailyGoal);

                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () async {
                                  await sheetRef
                                      .read(sebhaStateProvider.notifier)
                                      .selectPhrase(phrase.id);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isSelected
                                            ? Icons.check_circle_rounded
                                            : Icons
                                                  .radio_button_unchecked_rounded,
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.textSecondaryDark,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              phrase.text,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.tajawal(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              phrase.isCustom
                                                  ? 'مخصصة • الهدف $phraseGoal'
                                                  : 'افتراضية • الهدف $phraseGoal',
                                              style: GoogleFonts.tajawal(
                                                fontSize: 12,
                                                color:
                                                    AppColors.textSecondaryDark,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (phrase.isCustom)
                                        IconButton(
                                          tooltip: 'حذف',
                                          onPressed: () async {
                                            final shouldDelete =
                                                await showDialog<bool>(
                                                  context: context,
                                                  builder: (dialogContext) {
                                                    return AlertDialog(
                                                      backgroundColor:
                                                          AppColors.surfaceDark,
                                                      title: Text(
                                                        'حذف التسبيحة',
                                                        style:
                                                            GoogleFonts.tajawal(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                            ),
                                                      ),
                                                      content: Text(
                                                        'هل تريد حذف "${phrase.text}"؟',
                                                        style: GoogleFonts.tajawal(
                                                          color: AppColors
                                                              .textSecondaryDark,
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                dialogContext,
                                                              ).pop(false),
                                                          child: Text(
                                                            'إلغاء',
                                                            style: GoogleFonts.tajawal(
                                                              color: AppColors
                                                                  .textSecondaryDark,
                                                            ),
                                                          ),
                                                        ),
                                                        FilledButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                dialogContext,
                                                              ).pop(true),
                                                          style: FilledButton.styleFrom(
                                                            backgroundColor:
                                                                AppColors
                                                                    .primary,
                                                            foregroundColor:
                                                                AppColors
                                                                    .backgroundDark,
                                                          ),
                                                          child: Text(
                                                            'حذف',
                                                            style:
                                                                GoogleFonts.tajawal(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                ) ??
                                                false;
                                            if (!shouldDelete) return;
                                            await sheetRef
                                                .read(
                                                  sebhaStateProvider.notifier,
                                                )
                                                .removeCustomPhrase(phrase.id);
                                          },
                                          icon: const Icon(
                                            Icons.delete_outline_rounded,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    ).whenComplete(controller.dispose);
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
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

  Widget _buildSectionContainer(BuildContext context, {required List<Widget> children}) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : colors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.borderSubtle,
          width: 1.5,
        ),
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

  Widget _buildDivider(BuildContext context) {
    final colors = context.colors;
    return Divider(
      height: 1,
      thickness: 1,
      color: colors.borderSubtle,
      indent: 64,
    );
  }

  Widget _buildSettingsItem(BuildContext context, {
    required IconData icon,
    required String title,
    String? trailingText,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: AppColors.primary.withValues(alpha: 0.1),
        highlightColor: AppColors.primary.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.15),
                      AppColors.primary.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: isDark
                      ? null
                      : [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
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
                        color: colors.textPrimary,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              if (trailingText != null) ...[
                Text(
                  trailingText,
                  style: GoogleFonts.tajawal(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Icon(
                Icons.arrow_forward_ios,
                color: colors.iconSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    final year = DateTime.now().year;
    return Center(
      child: Column(
        children: [
          Text(
            'تطبيق المسلم © $year',
            style: GoogleFonts.tajawal(
              fontSize: 12,
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'صمم لخدمة الأمة الإسلامية',
            style: GoogleFonts.tajawal(
              fontSize: 10,
              color: AppColors.textSecondaryDark.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: GoogleFonts.tajawal())),
    );
  }

  void _showInfoDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
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
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'تم',
                style: GoogleFonts.tajawal(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openWhatsapp(BuildContext context) async {
    try {
      final opened = await launchUrl(
        Uri.parse('https://wa.me/249912740956'),
        mode: LaunchMode.externalApplication,
      );
      if (!opened && context.mounted) {
        _showInfoMessage(context, 'تعذّر فتح واتساب على هذا الجهاز');
      }
    } catch (_) {
      if (context.mounted) {
        _showInfoMessage(context, 'تعذّر فتح واتساب على هذا الجهاز');
      }
    }
  }
}
