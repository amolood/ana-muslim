import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/ramadan_model.dart';
import '../providers/ramadan_provider.dart';

class RamadanScreen extends ConsumerWidget {
  const RamadanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsync = ref.watch(ramadanScheduleProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: scheduleAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _buildError(context, e.toString()),
          data: (schedule) {
            if (schedule == null || schedule.days.isEmpty) {
              return _buildEmpty(context);
            }
            return _buildContent(context, schedule);
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, RamadanSchedule schedule) {
    final today = schedule.today;

    return CustomScrollView(
      slivers: [
        _buildAppBar(context),
        if (today != null) ...[
          SliverToBoxAdapter(child: _buildTodayCard(today)),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
        ],
        if (today?.dua != null || today?.hadith != null)
          SliverToBoxAdapter(child: _buildDailyResource(today!)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              'جدول رمضان ١٤٤٧',
              style: GoogleFonts.tajawal(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SliverList.builder(
          itemCount: schedule.days.length,
          itemBuilder: (context, i) {
            final day = schedule.days[i];
            return _buildDayRow(day, isFirst: i == 0, isLast: i == schedule.days.length - 1);
          },
        ),
        if (schedule.whiteDayDates.isNotEmpty)
          SliverToBoxAdapter(child: _buildWhiteDaysCard(schedule)),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
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
            const Icon(Icons.crescent_moon_rounded, color: Color(0xFFFACC15), size: 22),
            const SizedBox(width: 10),
            Text(
              'رمضان ٢٠٢٦',
              style: GoogleFonts.tajawal(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayCard(RamadanDay today) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF52B788).withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'اليوم',
                      style: GoogleFonts.tajawal(
                        fontSize: 13,
                        color: const Color(0xFF95D5B2),
                      ),
                    ),
                    Text(
                      today.hijriReadable ?? today.hijri ?? '',
                      style: GoogleFonts.tajawal(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                if (today.isWhiteDay)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFACC15).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFACC15).withValues(alpha: 0.6)),
                    ),
                    child: Text(
                      'الأيام البيض',
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        color: const Color(0xFFFACC15),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildTimeItem(Icons.wb_twilight_rounded, 'السحور', today.sahurTime ?? '—')),
                Container(
                  width: 1,
                  height: 48,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                Expanded(child: _buildTimeItem(Icons.wb_sunny_rounded, 'الإفطار', today.iftarTime ?? '—')),
              ],
            ),
            if (today.fastingDuration != null) ...[
              const SizedBox(height: 14),
              Center(
                child: Text(
                  'مدة الصيام: ${today.fastingDuration}',
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    color: const Color(0xFF95D5B2),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeItem(IconData icon, String label, String time) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF95D5B2), size: 22),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.tajawal(fontSize: 12, color: const Color(0xFF95D5B2)),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyResource(RamadanDay day) {
    return Column(
      children: [
        if (day.dua?.arabic != null)
          _buildResourceCard(
            icon: Icons.format_quote_rounded,
            iconColor: const Color(0xFF818CF8),
            label: day.dua!.title ?? 'دعاء اليوم',
            content: day.dua!.arabic!,
            subtitle: day.dua!.translation,
            reference: day.dua!.reference,
          ),
        if (day.hadith?.arabic != null)
          _buildResourceCard(
            icon: Icons.menu_book_rounded,
            iconColor: const Color(0xFFF472B6),
            label: 'حديث عن رمضان',
            content: day.hadith!.arabic!,
            subtitle: day.hadith!.english,
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
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: iconColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontFamily: 'KFGQPC Uthmanic Script',
              fontFamilyFallback: ['naskh'],
              fontSize: 17,
              color: Colors.white,
              height: 1.8,
            ),
            textDirection: TextDirection.rtl,
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
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDayRow(RamadanDay day, {bool isFirst = false, bool isLast = false}) {
    final isToday = day.isToday;
    final date = DateFormat('dd MMM').format(DateTime.tryParse(day.date) ?? DateTime.now());

    return Container(
      margin: EdgeInsets.fromLTRB(
        20,
        isFirst ? 0 : 4,
        20,
        isLast ? 0 : 4,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isToday
            ? const Color(0xFF2D6A4F).withValues(alpha: 0.3)
            : day.isWhiteDay
                ? const Color(0xFFFACC15).withValues(alpha: 0.06)
                : AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isToday
              ? const Color(0xFF52B788).withValues(alpha: 0.5)
              : day.isWhiteDay
                  ? const Color(0xFFFACC15).withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.04),
        ),
      ),
      child: Row(
        children: [
          // Day number badge
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isToday
                  ? const Color(0xFF52B788)
                  : AppColors.surfaceDark.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                date,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: isToday ? Colors.white : AppColors.textSecondaryDark,
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
                  day.hijriReadable ?? day.hijri ?? '',
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                    color: isToday ? Colors.white : Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                Text(
                  day.dayName ?? '',
                  style: GoogleFonts.tajawal(
                    fontSize: 11,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),
          // Sahur / Iftar times
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildMiniTime('🌙', day.sahurTime),
              const SizedBox(height: 2),
              _buildMiniTime('☀️', day.iftarTime),
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

  Widget _buildMiniTime(String emoji, String? time) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 11)),
        const SizedBox(width: 4),
        Text(
          time ?? '—',
          style: GoogleFonts.manrope(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildWhiteDaysCard(RamadanSchedule schedule) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFACC15).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFACC15).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFFFACC15)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الأيام البيض (١٣، ١٤، ١٥ رمضان)',
                  style: GoogleFonts.tajawal(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFACC15),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  schedule.whiteDayDates.map((d) {
                    try {
                      return DateFormat('dd MMM yyyy').format(DateTime.parse(d));
                    } catch (_) {
                      return d;
                    }
                  }).join(' · '),
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String msg) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, color: Colors.grey, size: 48),
          const SizedBox(height: 12),
          Text(
            'تعذر تحميل جدول رمضان',
            style: GoogleFonts.tajawal(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            'تأكد من اتصالك بالإنترنت وأن قاعدة البيانات محدّثة',
            style: GoogleFonts.tajawal(color: Colors.grey, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 60),
          const Text('🌙', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'لا توجد بيانات لرمضان بعد',
            style: GoogleFonts.tajawal(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'قم بتشغيل أمر الاستيراد على الخادم:\nphp artisan import:ramadan-schedule',
            style: GoogleFonts.tajawal(
              color: AppColors.textSecondaryDark,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
