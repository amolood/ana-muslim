import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'models/suggestion.dart';

/// محرك الاقتراحات الذكية
/// يولد اقتراحات مترابطة بناءً على السياق الحالي
class SuggestionsEngine {
  /// توليد اقتراحات بناءً على السياق
  static List<Suggestion> generateSuggestions(SuggestionContext context) {
    final suggestions = <Suggestion>[];

    // 1. Time-based suggestions
    suggestions.addAll(_getTimeBasedSuggestions(context));

    // 2. Weekly suggestions
    suggestions.addAll(_getWeeklySuggestions(context));

    // 3. Seasonal suggestions
    suggestions.addAll(_getSeasonalSuggestions(context));

    // 4. Behavior-based suggestions
    suggestions.addAll(_getBehaviorBasedSuggestions(context));

    // Filter expired and sort by priority
    final validSuggestions = suggestions.where((s) => s.isValid).toList();
    validSuggestions.sort((a, b) =>
      b.priority.index.compareTo(a.priority.index),
    );

    return validSuggestions;
  }

  /// اقتراحات مبنية على الوقت
  static List<Suggestion> _getTimeBasedSuggestions(SuggestionContext context) {
    final suggestions = <Suggestion>[];
    final now = context.currentTime;

    // بعد الفجر - أذكار الصباح
    if (context.hourOfDay >= 5 && context.hourOfDay < 9) {
      suggestions.add(
        Suggestion(
          id: 'morning_azkar_${now.day}',
          type: SuggestionType.morningAzkar,
          title: 'أذكار الصباح',
          subtitle: 'ابدأ يومك بذكر الله',
          description: 'وقت أذكار الصباح من بعد الفجر حتى طلوع الشمس',
          icon: Icons.wb_sunny,
          color: const Color(0xFFFFB300),
          priority: SuggestionPriority.high,
          expiresAt: DateTime(now.year, now.month, now.day, 9, 0),
          actionLabel: 'ابدأ الأذكار',
        ),
      );

      // صلاة الإشراق (بعد 20 دقيقة من الشروق)
      suggestions.add(
        Suggestion(
          id: 'ishraq_${now.day}',
          type: SuggestionType.ishraq,
          title: 'صلاة الإشراق',
          subtitle: 'حج وعمرة تامة',
          description: 'من صلى الفجر في جماعة ثم قعد يذكر الله حتى تطلع الشمس...',
          icon: Icons.brightness_5,
          color: const Color(0xFFFF6B6B),
          priority: SuggestionPriority.medium,
          expiresAt: DateTime(now.year, now.month, now.day, 8, 0),
          actionLabel: 'تذكير',
        ),
      );
    }

    // الضحى
    if (context.hourOfDay >= 9 && context.hourOfDay < 11) {
      suggestions.add(
        Suggestion(
          id: 'duha_${now.day}',
          type: SuggestionType.duha,
          title: 'صلاة الضحى',
          subtitle: 'ركعتان خفيفتان',
          description: 'يصبح على كل سُلامى من أحدكم صدقة',
          icon: Icons.wb_twilight,
          color: const Color(0xFF4CAF50),
          priority: SuggestionPriority.medium,
          expiresAt: DateTime(now.year, now.month, now.day, 11, 30),
          actionLabel: 'تذكير',
        ),
      );
    }

    // بعد المغرب - أذكار المساء
    if (context.hourOfDay >= 17 && context.hourOfDay < 20) {
      suggestions.add(
        Suggestion(
          id: 'evening_azkar_${now.day}',
          type: SuggestionType.eveningAzkar,
          title: 'أذكار المساء',
          subtitle: 'احفظ نفسك بذكر الله',
          description: 'وقت أذكار المساء من بعد العصر حتى المغرب',
          icon: Icons.nightlight_round,
          color: const Color(0xFF7E57C2),
          priority: SuggestionPriority.high,
          expiresAt: DateTime(now.year, now.month, now.day, 20, 0),
          actionLabel: 'ابدأ الأذكار',
        ),
      );
    }

    // بعد العشاء - الوتر وقيام الليل
    if (context.hourOfDay >= 21 || context.hourOfDay < 2) {
      suggestions.add(
        Suggestion(
          id: 'witr_${now.day}',
          type: SuggestionType.witr,
          title: 'صلاة الوتر',
          subtitle: 'اختم يومك بالوتر',
          description: 'من خاف أن لا يقوم من آخر الليل فليوتر أوله',
          icon: Icons.bedtime,
          color: const Color(0xFF5C6BC0),
          priority: SuggestionPriority.medium,
          actionLabel: 'تذكير',
        ),
      );

      // قيام الليل في الثلث الأخير
      if (context.hourOfDay >= 2 && context.hourOfDay < 5) {
        suggestions.add(
          Suggestion(
            id: 'qiyam_${now.day}',
            type: SuggestionType.qiyamAlLayl,
            title: 'قيام الليل',
            subtitle: 'الثلث الأخير من الليل',
            description: 'ينزل ربنا تبارك وتعالى كل ليلة إلى السماء الدنيا',
            icon: Icons.nights_stay,
            color: const Color(0xFF283593),
            priority: SuggestionPriority.high,
            actionLabel: 'آيات القيام',
          ),
        );
      }
    }

    return suggestions;
  }

  /// اقتراحات أسبوعية
  static List<Suggestion> _getWeeklySuggestions(SuggestionContext context) {
    final suggestions = <Suggestion>[];

    // يوم الجمعة
    if (context.isFriday) {
      // سورة الكهف
      if (context.hourOfDay >= 5 && context.hourOfDay < 15) {
        suggestions.add(
          Suggestion(
            id: 'kahf_${context.currentTime.day}',
            type: SuggestionType.kahfFriday,
            title: 'سورة الكهف',
            subtitle: 'نور من الجمعة إلى الجمعة',
            description: 'من قرأ سورة الكهف يوم الجمعة أضاء له من النور ما بين الجمعتين',
            icon: Icons.auto_stories,
            color: const Color(0xFF11D4B4),
            priority: SuggestionPriority.high,
            expiresAt: DateTime(
              context.currentTime.year,
              context.currentTime.month,
              context.currentTime.day,
              20,
              0,
            ),
            actionLabel: 'اقرأ الكهف',
          ),
        );
      }

      // ساعة الإجابة
      if (context.hourOfDay >= 14 && context.hourOfDay < 18) {
        suggestions.add(
          Suggestion(
            id: 'friday_hour_${context.currentTime.day}',
            type: SuggestionType.salawatFriday,
            title: 'ساعة الإجابة',
            subtitle: 'أكثر من الدعاء والصلاة على النبي',
            description: 'في يوم الجمعة ساعة لا يوافقها عبد مسلم يسأل الله شيئًا إلا أعطاه إياه',
            icon: Icons.access_time,
            color: const Color(0xFFFF9800),
            priority: SuggestionPriority.critical,
            actionLabel: 'افتح الأدعية',
          ),
        );
      }
    }

    // ليلة الجمعة (الخميس مساءً)
    if (context.dayOfWeek == 4 && context.hourOfDay >= 18) {
      suggestions.add(
        Suggestion(
          id: 'thursday_night_${context.currentTime.day}',
          type: SuggestionType.salawatFriday,
          title: 'الصلاة على النبي ﷺ',
          subtitle: 'أكثر من الصلاة على النبي ليلة الجمعة',
          description: 'أكثروا الصلاة علي يوم الجمعة وليلة الجمعة',
          icon: Icons.favorite,
          color: const Color(0xFFE91E63),
          priority: SuggestionPriority.high,
          actionLabel: 'ابدأ الصلاة',
        ),
      );
    }

    return suggestions;
  }

  /// اقتراحات موسمية
  static List<Suggestion> _getSeasonalSuggestions(SuggestionContext context) {
    final suggestions = <Suggestion>[];

    // رمضان
    if (context.isRamadan) {
      suggestions.add(
        Suggestion(
          id: 'ramadan_khatmah',
          type: SuggestionType.ramadan,
          title: 'ختمة رمضان',
          subtitle: 'اختم القرآن في رمضان',
          description: 'شهر رمضان الذي أنزل فيه القرآن',
          icon: Icons.menu_book,
          color: const Color(0xFF9C27B0),
          priority: SuggestionPriority.high,
          actionLabel: 'متابعة الختمة',
        ),
      );

      // العشر الأواخر
      if (context.isLastTenDays) {
        suggestions.add(
          Suggestion(
            id: 'laylat_alqadr',
            type: SuggestionType.ramadan,
            title: 'ليلة القدر',
            subtitle: 'خير من ألف شهر',
            description: 'اللهم إنك عفو تحب العفو فاعف عني',
            icon: Icons.star,
            color: const Color(0xFFFFD700),
            priority: SuggestionPriority.critical,
            actionLabel: 'أدعية ليلة القدر',
          ),
        );
      }
    }

    // الأيام البيض
    if (context.isWhiteDays) {
      suggestions.add(
        Suggestion(
          id: 'white_days_${context.currentTime.month}',
          type: SuggestionType.whiteDays,
          title: 'الأيام البيض',
          subtitle: 'صيام ثلاثة أيام من كل شهر',
          description: 'صيام الأيام البيض: 13، 14، 15 من كل شهر هجري',
          icon: Icons.calendar_today,
          color: const Color(0xFF00BCD4),
          priority: SuggestionPriority.high,
          actionLabel: 'نية الصيام',
        ),
      );
    }

    return suggestions;
  }

  /// اقتراحات مبنية على السلوك
  static List<Suggestion> _getBehaviorBasedSuggestions(
    SuggestionContext context,
  ) {
    final suggestions = <Suggestion>[];

    // إذا توقف عن الورد
    if (context.hasStoppedWird) {
      suggestions.add(
        Suggestion(
          id: 'continue_wird',
          type: SuggestionType.continueDailyWird,
          title: 'استئناف الورد اليومي',
          subtitle: 'لم تقرأ وردك منذ ${context.currentTime.difference(context.lastWirdTime!).inDays} أيام',
          description: 'استمر في رحلتك مع القرآن',
          icon: Icons.refresh,
          color: const Color(0xFFFF5722),
          priority: SuggestionPriority.high,
          actionLabel: 'استئناف',
        ),
      );
    }

    // إذا لم يكن لديه ختمة نشطة
    if (!context.hasActiveKhatmah && context.hasRecentQuranActivity) {
      suggestions.add(
        Suggestion(
          id: 'start_khatmah',
          type: SuggestionType.newKhatmah,
          title: 'ابدأ ختمة جديدة',
          subtitle: 'نظّم قراءتك للقرآن',
          description: 'حدد هدفًا لختم القرآن الكريم',
          icon: Icons.flag,
          color: const Color(0xFF4CAF50),
          priority: SuggestionPriority.medium,
          actionLabel: 'إنشاء ختمة',
        ),
      );
    }

    // إذا قرأ سورة معينة كثيرًا
    if (context.lastReadSurah != null) {
      suggestions.add(
        Suggestion(
          id: 'tafsir_${context.lastReadSurah}',
          type: SuggestionType.completeTafsir,
          title: 'تفسير السورة',
          subtitle: 'اقرأ تفسير السورة التي قرأتها',
          description: 'تعمّق في فهم معاني القرآن',
          icon: Icons.lightbulb,
          color: const Color(0xFFFFC107),
          priority: SuggestionPriority.low,
          actionLabel: 'اقرأ التفسير',
          metadata: {'surah': context.lastReadSurah},
        ),
      );
    }

    return suggestions;
  }

  /// اقتراح بعد حدث معين
  static Suggestion? getSuggestionAfterEvent({
    required String eventType,
    Map<String, dynamic>? eventData,
  }) {
    switch (eventType) {
      case 'after_prayer':
        return Suggestion(
          id: 'after_prayer_${DateTime.now().millisecondsSinceEpoch}',
          type: SuggestionType.afterPrayerAzkar,
          title: 'أذكار بعد الصلاة',
          subtitle: 'سبحان الله 33، الحمد لله 33، الله أكبر 34',
          icon: Icons.auto_awesome,
          color: AppColors.primary,
          priority: SuggestionPriority.high,
          expiresAt: DateTime.now().add(const Duration(minutes: 10)),
          actionLabel: 'ابدأ التسبيح',
        );

      case 'completed_tasbih':
        return Suggestion(
          id: 'tasbih_reward_${DateTime.now().millisecondsSinceEpoch}',
          type: SuggestionType.custom,
          title: 'بارك الله فيك!',
          subtitle: 'من سبّح الله دبر كل صلاة ثلاثًا وثلاثين...',
          description: 'غفرت خطاياه وإن كانت مثل زبد البحر',
          icon: Icons.verified,
          color: const Color(0xFF4CAF50),
          priority: SuggestionPriority.low,
          expiresAt: DateTime.now().add(const Duration(seconds: 30)),
          isDismissible: true,
        );

      case 'completed_khatmah':
        return Suggestion(
          id: 'khatmah_dua_${DateTime.now().millisecondsSinceEpoch}',
          type: SuggestionType.custom,
          title: 'ختمت القرآن!',
          subtitle: 'اقرأ دعاء ختم القرآن',
          description: 'اللهم ارحمني بالقرآن واجعله لي إمامًا ونورًا...',
          icon: Icons.celebration,
          color: const Color(0xFFFFD700),
          priority: SuggestionPriority.critical,
          actionLabel: 'اقرأ الدعاء',
        );

      case 'read_hadith':
        return Suggestion(
          id: 'related_ayah_${DateTime.now().millisecondsSinceEpoch}',
          type: SuggestionType.relatedAyah,
          title: 'آية مرتبطة',
          subtitle: 'اقرأ آية قرآنية مرتبطة بهذا الحديث',
          icon: Icons.link,
          color: const Color(0xFF2196F3),
          priority: SuggestionPriority.low,
          actionLabel: 'اقرأ الآية',
          metadata: eventData,
        );

      case 'entered_qibla_screen':
        return Suggestion(
          id: 'qibla_dua_${DateTime.now().millisecondsSinceEpoch}',
          type: SuggestionType.custom,
          title: 'دعاء التوجه للقبلة',
          subtitle: 'وجهت وجهي للذي فطر السماوات والأرض...',
          icon: Icons.explore,
          color: const Color(0xFF4CAF50),
          priority: SuggestionPriority.medium,
          expiresAt: DateTime.now().add(const Duration(minutes: 5)),
          actionLabel: 'اقرأ الدعاء',
        );

      default:
        return null;
    }
  }
}
