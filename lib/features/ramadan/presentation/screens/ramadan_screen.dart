import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/utils/arabic_utils.dart';
import '../../data/models/ramadan_model.dart';
import '../providers/ramadan_provider.dart';

class RamadanScreen extends ConsumerWidget {
  const RamadanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsync = ref.watch(ramadanScheduleProvider);
    final appLanguage = ref.watch(appLanguageProvider);
    final isArabic = appLanguage == 'العربية';

    final strings = _getLocalization(appLanguage);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: scheduleAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _buildError(context, e.toString(), strings),
          data: (schedule) {
            if (schedule == null || schedule.days.isEmpty) {
              return _buildEmpty(context, strings);
            }
            return _buildContent(context, schedule, strings, isArabic);
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    RamadanSchedule schedule,
    Map<String, String> strings,
    bool isArabic,
  ) {
    final today = schedule.today;

    return CustomScrollView(
      slivers: [
        _buildAppBar(context, strings),
        if (today != null) ...[
          SliverToBoxAdapter(child: _buildTodayCard(today, strings, isArabic)),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
        ],
        if (today?.dua != null || today?.hadith != null)
          SliverToBoxAdapter(
            child: _buildDailyResource(today!, strings, isArabic),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              strings['schedule_title']!,
              style: GoogleFonts.tajawal(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
        ),
        SliverList.builder(
          itemCount: schedule.days.length,
          itemBuilder: (context, i) {
            final day = schedule.days[i];
            return _buildDayRow(
              context,
              day,
              strings,
              isArabic,
              isFirst: i == 0,
              isLast: i == schedule.days.length - 1,
            );
          },
        ),
        if (schedule.whiteDayDates.isNotEmpty)
          SliverToBoxAdapter(
            child: _buildWhiteDaysCard(context, schedule, strings),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, Map<String, String> strings) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: false,
      expandedHeight: 0,
      flexibleSpace: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFBBF24).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.mosque,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                strings['app_bar_title']!,
                style: GoogleFonts.tajawal(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayCard(
    RamadanDay today,
    Map<String, String> strings,
    bool isArabic,
  ) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      const Color(0xFF065F46), // Emerald-800
                      const Color(0xFF047857), // Emerald-700
                      const Color(0xFF059669), // Emerald-600
                    ]
                  : [
                      const Color(0xFF10B981).withValues(alpha: 0.2),
                      const Color(0xFF059669).withValues(alpha: 0.15),
                      AppColors.surfaceLight,
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF10B981).withValues(alpha: 0.3)
                  : const Color(0xFF059669).withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? const Color(0xFF10B981).withValues(alpha: 0.4)
                    : const Color(0xFF059669).withValues(alpha: 0.2),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: isDark
                    ? const Color(0xFF34D399).withValues(alpha: 0.2)
                    : const Color(0xFF10B981).withValues(alpha: 0.1),
                blurRadius: 40,
                spreadRadius: 0,
                offset: const Offset(0, 16),
              ),
            ],
          ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings['today_label']!,
                        style: GoogleFonts.tajawal(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFF6EE7B7) // Emerald-300
                              : const Color(0xFF047857), // Emerald-700
                          letterSpacing: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        ArabicUtils.ensureLatinDigits(
                          today.hijriArabic ?? '',
                        ),
                        style: GoogleFonts.tajawal(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF065F46),
                          shadows: isDark
                              ? [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (today.isWhiteDay) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFBBF24).withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              strings['white_days_label']!,
                              style: GoogleFonts.tajawal(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildTimeItem(
                    Icons.wb_twilight_rounded,
                    strings['sahur']!,
                    _formatTo12h(today.sahurTime, isArabic),
                  ),
                ),
                Container(
                  width: 1,
                  height: 48,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                Expanded(
                  child: _buildTimeItem(
                    Icons.wb_sunny_rounded,
                    strings['iftar']!,
                    _formatTo12h(today.iftarTime, isArabic),
                  ),
                ),
              ],
            ),
            if (today.fastingDuration != null) ...[
              const SizedBox(height: 14),
              Center(
                child: Text(
                  '${strings['fasting_duration']!}: ${today.fastingDuration}',
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFF95D5B2)
                        : const Color(0xFF059669),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
      },
    );
  }

  String _formatTo12h(String? time, bool isArabic) {
    if (time == null || time.isEmpty) return '—';
    try {
      final parts = time.split(':');
      if (parts.length != 2) return time;
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final dt = DateTime(2026, 1, 1, hour, minute);

      if (isArabic) {
        // Use Arabic locale but ensure Latin digits
        final formatted = DateFormat.jm('ar').format(dt);
        return ArabicUtils.ensureLatinDigits(formatted);
      }
      return DateFormat.jm('en_US').format(dt);
    } catch (_) {
      return time;
    }
  }

  Widget _buildTimeItem(IconData icon, String label, String time) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF6EE7B7).withValues(alpha: 0.15)
                    : const Color(0xFF047857).withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF6EE7B7).withValues(alpha: 0.3)
                      : const Color(0xFF047857).withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                icon,
                color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857),
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: GoogleFonts.manrope(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF065F46),
                letterSpacing: 0.5,
                shadows: isDark
                    ? [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
    );
  }

  Widget _buildDailyResource(
    RamadanDay day,
    Map<String, String> strings,
    bool isArabic,
  ) {
    return Column(
      children: [
        if (day.dua?.arabic != null)
          _buildResourceCard(
            icon: Icons.format_quote_rounded,
            iconColor: const Color(0xFF818CF8),
            label: isArabic
                ? (day.dua!.title ?? strings['dua_today']!)
                : strings['dua_today']!,
            content: day.dua!.arabic!,
            subtitle: isArabic
                ? null
                : (day.dua!.translation ?? day.dua!.transliteration),
            reference: day.dua!.reference,
          ),
        if (day.hadith?.arabic != null)
          _buildResourceCard(
            icon: Icons.menu_book_rounded,
            iconColor: const Color(0xFFF472B6),
            label: strings['hadith_today']!,
            content: day.hadith!.arabic!,
            subtitle: isArabic ? null : day.hadith!.english,
            reference: day.hadith!.source,
          ),
      ],
    );
  }

  Widget _buildResourceCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String content,
    String? subtitle,
    String? reference,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      AppColors.surfaceDark,
                      AppColors.surfaceDark.withValues(alpha: 0.8),
                    ]
                  : [
                      Colors.white,
                      Colors.grey[50]!,
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: iconColor.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: iconColor.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          iconColor,
                          iconColor.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: iconColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: GoogleFonts.tajawal(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: iconColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontFamily: 'KFGQPC Uthmanic Script',
              fontFamilyFallback: const ['naskh'],
              fontSize: 17,
              color: isDark ? Colors.white : const Color(0xFF1F2937),
              height: 1.8,
            ),
          ),
          if (subtitle != null && subtitle.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.tajawal(
                fontSize: 13,
                color: AppColors.textSecondaryDark,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          if (reference != null && reference.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              reference,
              style: GoogleFonts.tajawal(
                fontSize: 12,
                color: iconColor.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
      },
    );
  }

  Widget _buildDayRow(
    BuildContext context,
    RamadanDay day,
    Map<String, String> strings,
    bool isArabic, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    final isToday = day.isToday;
    final locale = Localizations.localeOf(context).toString();
    final date = DateFormat(
      'dd MMM',
      locale,
    ).format(DateTime.tryParse(day.date) ?? DateTime.now());

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.fromLTRB(20, isFirst ? 0 : 6, 20, isLast ? 0 : 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isToday
              ? isDark
                  ? [
                      const Color(0xFF059669).withValues(alpha: 0.4),
                      const Color(0xFF047857).withValues(alpha: 0.3),
                    ]
                  : [
                      const Color(0xFF10B981).withValues(alpha: 0.2),
                      const Color(0xFF059669).withValues(alpha: 0.1),
                    ]
              : day.isWhiteDay
                  ? isDark
                      ? [
                          const Color(0xFFFBBF24).withValues(alpha: 0.15),
                          const Color(0xFFF59E0B).withValues(alpha: 0.1),
                        ]
                      : [
                          const Color(0xFFFBBF24).withValues(alpha: 0.1),
                          const Color(0xFFF59E0B).withValues(alpha: 0.05),
                        ]
                  : isDark
                      ? [AppColors.surfaceDark, AppColors.surfaceDark]
                      : [Colors.white, Colors.grey[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isToday
              ? const Color(0xFF10B981).withValues(alpha: 0.4)
              : day.isWhiteDay
                  ? const Color(0xFFFBBF24).withValues(alpha: 0.3)
                  : isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.grey.withValues(alpha: 0.2),
          width: isToday || day.isWhiteDay ? 1.5 : 1,
        ),
        boxShadow: isToday
            ? [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : day.isWhiteDay
                ? [
                    BoxShadow(
                      color: const Color(0xFFFBBF24).withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
      ),
      child: Row(
        children: [
          // Day number badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: isToday
                  ? const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : day.isWhiteDay
                      ? const LinearGradient(
                          colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
              color: isToday || day.isWhiteDay
                  ? null
                  : isDark
                      ? AppColors.surfaceDark.withValues(alpha: 0.6)
                      : Colors.grey[200],
              shape: BoxShape.circle,
              boxShadow: isToday || day.isWhiteDay
                  ? [
                      BoxShadow(
                        color: (isToday
                                ? const Color(0xFF10B981)
                                : const Color(0xFFFBBF24))
                            .withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: Text(
                date,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: isToday || day.isWhiteDay
                      ? Colors.white
                      : isDark
                          ? AppColors.textSecondaryDark
                          : Colors.grey[700],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Hijri
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ArabicUtils.ensureLatinDigits(
                    day.hijriArabic ?? '',
                  ),
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                    color: isToday
                        ? isDark
                            ? Colors.white
                            : const Color(0xFF065F46)
                        : isDark
                            ? Colors.white.withValues(alpha: 0.85)
                            : const Color(0xFF374151),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  DateFormat(
                    'EEEE',
                    locale,
                  ).format(DateTime.tryParse(day.date) ?? DateTime.now()),
                  style: GoogleFonts.tajawal(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : const Color(0xFF6B7280),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Sahur / Iftar times
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildMiniTime(
                Icons.nightlight_round,
                _formatTo12h(day.sahurTime, isArabic),
              ),
              const SizedBox(height: 2),
              _buildMiniTime(
                Icons.wb_sunny_rounded,
                _formatTo12h(day.iftarTime, isArabic),
              ),
            ],
          ),
          if (day.isWhiteDay) ...[
            const SizedBox(width: 8),
            const Icon(Icons.star_rounded, color: Color(0xFFFACC15), size: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniTime(IconData icon, String? time) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : const Color(0xFF6B7280),
              size: 12,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                time ?? '—',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.85)
                      : const Color(0xFF374151),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWhiteDaysCard(
    BuildContext context,
    RamadanSchedule schedule,
    Map<String, String> strings,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFFFBBF24).withValues(alpha: 0.2),
                  const Color(0xFFF59E0B).withValues(alpha: 0.15),
                ]
              : [
                  const Color(0xFFFBBF24).withValues(alpha: 0.15),
                  const Color(0xFFF59E0B).withValues(alpha: 0.1),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFBBF24).withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFBBF24).withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFBBF24).withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.star_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings['white_days_detail']!,
                  style: GoogleFonts.tajawal(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? const Color(0xFFFBBF24)
                        : const Color(0xFFD97706),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  schedule.whiteDayDates
                      .map((d) {
                        try {
                          final locale = Localizations.localeOf(
                            context,
                          ).toString();
                          return DateFormat(
                            'dd MMM yyyy',
                            locale,
                          ).format(DateTime.parse(d));
                        } catch (_) {
                          return d;
                        }
                      })
                      .join(' · '),
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.75)
                        : const Color(0xFF92400E),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(
    BuildContext context,
    String msg,
    Map<String, String> strings,
  ) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, color: Colors.grey, size: 48),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              strings['error_title']!,
              style: GoogleFonts.tajawal(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              strings['error_subtitle']!,
              style: GoogleFonts.tajawal(color: Colors.grey, fontSize: 13),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, Map<String, String> strings) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 60),
          Icon(
            Icons.nightlight_round,
            color: const Color(0xFFFACC15),
            size: 64,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              strings['empty_msg']!,
              style: GoogleFonts.tajawal(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String> _getLocalization(String appLanguage) {
    if (appLanguage == 'English') {
      return {
        'app_bar_title': 'Ramadan 2026',
        'schedule_title': 'Ramadan Schedule 1447',
        'today_label': 'TODAY',
        'sahur': 'Sahur',
        'iftar': 'Iftar',
        'fasting_duration': 'Fasting Duration',
        'white_days_label': 'White Days',
        'white_days_detail': 'White Days (13, 14, 15 Ramadan)',
        'dua_today': 'Dua of the Day',
        'hadith_today': 'Hadith about Ramadan',
        'empty_msg': 'No Ramadan data available yet',
        'error_title': 'Could not load Ramadan schedule',
        'error_subtitle': 'Check your internet connection and try again',
      };
    } else if (appLanguage == 'Français') {
      return {
        'app_bar_title': 'Ramadan 2026',
        'schedule_title': 'Calendrier du Ramadan 1447',
        'today_label': "AUJOURD'HUI",
        'sahur': 'Sahur',
        'iftar': 'Iftar',
        'fasting_duration': 'Durée du jeûne',
        'white_days_label': 'Jours Blancs',
        'white_days_detail': 'Jours Blancs (13, 14, 15 Ramadan)',
        'dua_today': 'Doua du jour',
        'hadith_today': 'Hadith sur le Ramadan',
        'empty_msg': 'Aucune donnée disponible pour le Ramadan',
        'error_title': 'Impossible de charger le calendrier',
        'error_subtitle': 'Vérifiez votre connexion internet et réessayez',
      };
    }
    // Default Arabic
    return {
      'app_bar_title': 'رمضان 2026',
      'schedule_title': 'جدول رمضان 1447',
      'today_label': 'اليوم',
      'sahur': 'السحور',
      'iftar': 'الإفطار',
      'fasting_duration': 'مدة الصيام',
      'white_days_label': 'الأيام البيض',
      'white_days_detail': 'الأيام البيض (13، 14، 15 رمضان)',
      'dua_today': 'دعاء اليوم',
      'hadith_today': 'حديث عن رمضان',
      'empty_msg': 'لا توجد بيانات لرمضان بعد',
      'error_title': 'تعذر تحميل جدول رمضان',
      'error_subtitle': 'تأكد من اتصالك بالإنترنت وأن قاعدة البيانات محدّثة',
    };
  }
}
