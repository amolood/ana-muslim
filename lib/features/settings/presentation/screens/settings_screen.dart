import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/preferences_provider.dart';
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
            // ─── Appearance ──────────────────────────────────────
            _buildSectionTitle('المظهر'),
            _buildSectionContainer(
              children: [
                _buildSettingsItem(
                  icon: Icons.dark_mode,
                  title: 'الثيم',
                  trailingText: theme,
                  onTap: () => _showSelectionSheet(
                    context,
                    ref,
                    'الثيم',
                    ['داكن', 'فاتح'],
                    theme,
                    (val) => ref.read(appThemeProvider.notifier).save(val),
                  ),
                ),
                _buildDivider(),
                _buildSettingsItem(
                  icon: Icons.format_size,
                  title: 'حجم الخط',
                  trailingText: fontSize,
                  onTap: () => _showSelectionSheet(
                    context,
                    ref,
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
                _buildDivider(),
                _buildSettingsItem(
                  icon: Icons.language,
                  title: 'اللغة',
                  trailingText: language,
                  onTap: () => _showSelectionSheet(
                    context,
                    ref,
                    'اللغة',
                    ['العربية', 'English', 'Français'],
                    language,
                    (val) => ref.read(appLanguageProvider.notifier).save(val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // ─── Prayer ──────────────────────────────────────────
            _buildSectionTitle('الصلاة'),
            _buildSectionContainer(
              children: [
                _buildSettingsItem(
                  icon: Icons.calculate,
                  title: 'طريقة الحساب',
                  trailingText: calcMethod,
                  onTap: () => _showSelectionSheet(
                    context,
                    ref,
                    'طريقة الحساب',
                    [
                      'أم القرى',
                      'رابطة العالم الإسلامي',
                      'الهيئة العامة للمساحة المصرية',
                      'جامعة العلوم الإسلامية بكراتشي',
                      'الجمعية الإسلامية لأمريكا الشمالية',
                    ],
                    calcMethod,
                    (val) => ref
                        .read(calculationMethodProvider.notifier)
                        .save(val),
                  ),
                ),
                _buildDivider(),
                _buildSettingsItem(
                  icon: Icons.notifications_active,
                  title: 'تنبيهات الصلاة',
                  trailingText: adhanAlerts ? 'مفعلة' : 'موقفة',
                  onTap: () => context.push('/settings/notifications'),
                ),
                _buildDivider(),
                _buildSettingsItem(
                  icon: Icons.location_on,
                  title: 'الموقع الحالي',
                  trailingText: locationNameAsync.maybeWhen(
                    data: (loc) => loc.split('،').first,
                    orElse: () => 'تلقائي',
                  ),
                  onTap: () {
                    ref.invalidate(locationProvider);
                    ref.invalidate(locationNameProvider);
                    ref.invalidate(prayerTimesProvider);
                    _showInfoMessage(context, 'تم تحديث الموقع بنجاح');
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            // ─── Calendar ────────────────────────────────────────
            _buildSectionTitle('التقويم'),
            _buildSectionContainer(
              children: [
                _buildSettingsItem(
                  icon: Icons.calendar_month,
                  title: 'التقويم الهجري',
                  subtitle: 'عرض ومنتقي التاريخ الهجري',
                  onTap: () => context.push('/settings/hijri'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // ─── Quran ───────────────────────────────────────────
            _buildSectionTitle('القرآن الكريم'),
            _buildSectionContainer(
              children: [
                _buildSettingsItem(
                  icon: Icons.menu_book,
                  title: 'مصدر التفسير',
                  trailingText: _tafsirDisplayName(
                    ref.watch(tafsirSourceProvider),
                  ),
                  onTap: () => _showSelectionSheet(
                    context,
                    ref,
                    'مصدر التفسير',
                    ['saadi', 'ibnkatheer', 'tabari', 'qurtubi', 'tafsir-jalalayn'],
                    ref.read(tafsirSourceProvider),
                    (val) =>
                        ref.read(tafsirSourceProvider.notifier).save(val),
                    displayMapper: _tafsirDisplayName,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // ─── Other ───────────────────────────────────────────
            _buildSectionTitle('أخرى'),
            _buildSectionContainer(
              children: [
                _buildSettingsItem(
                  icon: Icons.privacy_tip,
                  title: 'الخصوصية',
                  onTap: () => _showInfoDialog(
                    context,
                    title: 'الخصوصية',
                    message:
                        'لا يتم إرسال بياناتك الشخصية إلى خوادم خارجية. يتم حفظ الإعدادات محليًا على جهازك فقط.',
                  ),
                ),
                _buildDivider(),
                _buildSettingsItem(
                  icon: Icons.info,
                  title: 'عن التطبيق',
                  trailingText: 'الإصدار 1.0.0',
                  onTap: () => _showInfoDialog(
                    context,
                    title: 'عن التطبيق',
                    message:
                        'تطبيق المسلم: قرآن، أذكار، قبلة، ومواقيت الصلاة في تجربة عربية متكاملة.',
                  ),
                ),
                if (kDebugMode) ...[
                  _buildDivider(),
                  _buildSettingsItem(
                    icon: Icons.bug_report,
                    title: 'شاشة QA Debug',
                    onTap: () => context.push('/debug'),
                  ),
                ],
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
    'saadi':           'تفسير السعدي',
    'ibnkatheer':      'تفسير ابن كثير',
    'tabari':          'تفسير الطبري',
    'qurtubi':         'تفسير القرطبي',
    'tafsir-jalalayn': 'تفسير الجلالين',
  };

  static String _tafsirDisplayName(String key) =>
      _tafsirMap[key] ?? 'تفسير السعدي';

  void _showSelectionSheet(
    BuildContext context,
    WidgetRef ref,
    String title,
    List<String> options,
    String currentValue,
    Function(String) onSelected, {
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
                final label =
                    displayMapper != null ? displayMapper(option) : option;
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
                  onTap: () {
                    onSelected(option);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
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

  Widget _buildSectionContainer({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.white.withValues(alpha: 0.05),
      indent: 64,
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? trailingText,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
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
                    if (subtitle != null)
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
              if (trailingText != null) ...[
                Text(
                  trailingText,
                  style: GoogleFonts.tajawal(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textSecondaryDark,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          Text(
            'تطبيق المسلم © 2024',
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
      SnackBar(
        content: Text(message, style: GoogleFonts.tajawal()),
      ),
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
}
