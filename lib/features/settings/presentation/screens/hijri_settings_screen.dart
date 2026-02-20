import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/theme/app_colors.dart';

class HijriSettingsScreen extends ConsumerStatefulWidget {
  const HijriSettingsScreen({super.key});

  @override
  ConsumerState<HijriSettingsScreen> createState() =>
      _HijriSettingsScreenState();
}

class _HijriSettingsScreenState extends ConsumerState<HijriSettingsScreen> {
  HijriCalendar? _selectedHijri;

  @override
  void initState() {
    super.initState();
    HijriCalendar.setLocal('ar');
  }

  HijriCalendar _effectiveHijri() {
    final offset = ref.read(hijriOffsetProvider);
    final adjusted = DateTime.now().add(Duration(days: offset));
    return HijriCalendar.fromDate(adjusted);
  }

  @override
  Widget build(BuildContext context) {
    final offset = ref.watch(hijriOffsetProvider);
    final effectiveHijri = _effectiveHijri();
    final gregorianNow = DateTime.now();
    final gregorianStr = DateFormat(
      'EEEE، d MMMM yyyy',
      'ar',
    ).format(gregorianNow);

    final hijriStr =
        '${_toAr(effectiveHijri.hDay)} ${effectiveHijri.longMonthName} ${_toAr(effectiveHijri.hYear)} هـ';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'التقويم الهجري',
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Date display card ────────────────────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    hijriStr,
                    style: GoogleFonts.notoNaskhArabic(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 48,
                    height: 2,
                    color: AppColors.primary.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    gregorianStr,
                    style: GoogleFonts.tajawal(
                      fontSize: 15,
                      color: AppColors.textSecondaryDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (offset != 0) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        offset > 0
                            ? 'تعديل: +$offset أيام'
                            : 'تعديل: $offset أيام',
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            // ─── Open date picker ─────────────────────────────────
            _buildActionTile(
              icon: Icons.calendar_month,
              title: 'اختر تاريخًا للمعاينة',
              subtitle: 'اعرض التقويم الميلادي واطّلع على مقابله الهجري',
              onTap: () => _openDatePicker(context),
            ),
            const SizedBox(height: 16),
            // ─── Offset adjustment ────────────────────────────────
            _buildSectionHeader('تعديل التاريخ الهجري'),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  Text(
                    'يمكنك تعديل التاريخ الهجري بمقدار ±3 أيام لمطابقة رؤية الهلال في بلدك.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.tajawal(
                      fontSize: 13,
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _offsetButton(
                        icon: Icons.remove,
                        onTap: offset > -3
                            ? () => _saveOffset(ref, offset - 1)
                            : null,
                      ),
                      const SizedBox(width: 24),
                      Column(
                        children: [
                          Text(
                            offset == 0
                                ? '0'
                                : offset > 0
                                    ? '+$offset'
                                    : '$offset',
                            style: GoogleFonts.manrope(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            'أيام',
                            style: GoogleFonts.tajawal(
                              color: AppColors.textSecondaryDark,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      _offsetButton(
                        icon: Icons.add,
                        onTap: offset < 3
                            ? () => _saveOffset(ref, offset + 1)
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (offset != 0)
                    TextButton(
                      onPressed: () => _saveOffset(ref, 0),
                      child: Text(
                        'إعادة تعيين',
                        style: GoogleFonts.tajawal(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // ─── Selected date preview ────────────────────────────
            if (_selectedHijri != null) ...[
              const SizedBox(height: 24),
              _buildSectionHeader('التاريخ المختار'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                ),
                child: Text(
                  '${_toAr(_selectedHijri!.hDay)} ${_selectedHijri!.longMonthName} ${_toAr(_selectedHijri!.hYear)} هـ',
                  style: GoogleFonts.notoNaskhArabic(
                    fontSize: 20,
                    color: Colors.white,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
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

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surfaceDark,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
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

  Widget _offsetButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: onTap != null
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.05),
            border: Border.all(
              color: onTap != null
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Icon(
            icon,
            color: onTap != null ? AppColors.primary : Colors.grey,
          ),
        ),
      ),
    );
  }

  Future<void> _openDatePicker(BuildContext context) async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      locale: const Locale('ar'),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedHijri = HijriCalendar.fromDate(result);
      });
    }
  }

  void _saveOffset(WidgetRef ref, int value) {
    ref.read(hijriOffsetProvider.notifier).save(value);
    setState(() {
      _selectedHijri = _effectiveHijri();
    });
  }

  String _toAr(int n) {
    const e = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const a = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var s = n.toString();
    for (int i = 0; i < e.length; i++) {
      s = s.replaceAll(e[i], a[i]);
    }
    return s;
  }
}
