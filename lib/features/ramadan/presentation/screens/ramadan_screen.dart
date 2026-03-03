import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/preferences_provider.dart';
import '../../data/models/ramadan_model.dart';
import '../providers/ramadan_provider.dart';
import '../widgets/ramadan_day_row.dart';
import '../widgets/ramadan_resource_card.dart';
import '../widgets/ramadan_today_card.dart';
import '../widgets/ramadan_white_days_card.dart';

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
          error: (e, _) => _buildError(context, e.toString(), strings, ref),
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
          SliverToBoxAdapter(
            child: RamadanTodayCard(
              today: today,
              strings: strings,
              isArabic: isArabic,
            ),
          ),
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
            return RamadanDayRow(
              day: day,
              strings: strings,
              isArabic: isArabic,
              isFirst: i == 0,
              isLast: i == schedule.days.length - 1,
            );
          },
        ),
        if (schedule.whiteDayDates.isNotEmpty)
          SliverToBoxAdapter(
            child: RamadanWhiteDaysCard(
              schedule: schedule,
              strings: strings,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  SliverAppBar _buildAppBar(
    BuildContext context,
    Map<String, String> strings,
  ) {
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
              child: const Icon(Icons.mosque, color: Colors.white, size: 20),
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

  Widget _buildDailyResource(
    RamadanDay day,
    Map<String, String> strings,
    bool isArabic,
  ) {
    return Column(
      children: [
        if (day.dua?.arabic != null)
          RamadanResourceCard(
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
          RamadanResourceCard(
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

  Widget _buildError(
    BuildContext context,
    String msg,
    Map<String, String> strings,
    WidgetRef ref,
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
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => ref.invalidate(ramadanScheduleProvider),
            icon: const Icon(Icons.refresh, size: 18),
            label: Text('إعادة المحاولة', style: GoogleFonts.tajawal()),
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
          const Icon(
            Icons.nightlight_round,
            color: Color(0xFFFACC15),
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
      'app_bar_title': 'رمضان 1447',
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
