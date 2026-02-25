/// Data models for the Ramadan 2026 fasting schedule.
library;

class RamadanDua {
  final String? title;
  final String? arabic;
  final String? translation;
  final String? transliteration;
  final String? reference;

  const RamadanDua({
    this.title,
    this.arabic,
    this.translation,
    this.transliteration,
    this.reference,
  });

  factory RamadanDua.fromMap(Map<String, dynamic> map) {
    return RamadanDua(
      title: map['title'] as String?,
      arabic: map['arabic'] as String?,
      translation: map['translation'] as String?,
      transliteration: map['transliteration'] as String?,
      reference: map['reference'] as String?,
    );
  }
}

class RamadanHadith {
  final String? arabic;
  final String? english;
  final String? source;
  final String? grade;

  const RamadanHadith({this.arabic, this.english, this.source, this.grade});

  factory RamadanHadith.fromMap(Map<String, dynamic> map) {
    return RamadanHadith(
      arabic: map['arabic'] as String?,
      english: map['english'] as String?,
      source: map['source'] as String?,
      grade: map['grade'] as String?,
    );
  }
}

class RamadanDay {
  final String date;
  final String? dayName;
  final String? hijri;
  final String? hijriReadable;
  final bool isWhiteDay;
  final String? sahurTime;
  final String? iftarTime;
  final String? fastingDuration;
  final RamadanDua? dua;
  final RamadanHadith? hadith;

  const RamadanDay({
    required this.date,
    this.dayName,
    this.hijri,
    this.hijriReadable,
    this.isWhiteDay = false,
    this.sahurTime,
    this.iftarTime,
    this.fastingDuration,
    this.dua,
    this.hadith,
  });

  factory RamadanDay.fromMap(Map<String, dynamic> map) {
    final duaRaw = map['dua'];
    final hadithRaw = map['hadith'];

    return RamadanDay(
      date: (map['date'] ?? '').toString(),
      dayName: map['day_name'] as String?,
      hijri: map['hijri'] as String?,
      hijriReadable: map['hijri_readable'] as String?,
      isWhiteDay: (map['is_white_day'] as bool?) ?? false,
      sahurTime: map['sahur_time'] as String?,
      iftarTime: map['iftar_time'] as String?,
      fastingDuration: map['fasting_duration'] as String?,
      dua: duaRaw is Map
          ? RamadanDua.fromMap(Map<String, dynamic>.from(duaRaw))
          : null,
      hadith: hadithRaw is Map
          ? RamadanHadith.fromMap(Map<String, dynamic>.from(hadithRaw))
          : null,
    );
  }

  bool get isToday {
    final today = DateTime.now();
    final formatted =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return date == formatted;
  }

  /// تحويل التاريخ الهجري من الإنجليزية إلى العربية
  String? get hijriArabic {
    if (hijriReadable == null) return hijri;

    String text = hijriReadable!;

    // تحويل أسماء الأشهر الهجرية
    text = text.replaceAll('MUHARRAM', 'محرم');
    text = text.replaceAll('SAFAR', 'صفر');
    text = text.replaceAll('RABI AL-AWWAL', 'ربيع الأول');
    text = text.replaceAll('RABI AL-THANI', 'ربيع الثاني');
    text = text.replaceAll('JUMADA AL-AWWAL', 'جمادى الأولى');
    text = text.replaceAll('JUMADA AL-THANI', 'جمادى الثانية');
    text = text.replaceAll('RAJAB', 'رجب');
    text = text.replaceAll('SHABAN', 'شعبان');
    text = text.replaceAll('RAMADAN', 'رمضان');
    text = text.replaceAll('SHAWWAL', 'شوال');
    text = text.replaceAll('DHU AL-QADAH', 'ذو القعدة');
    text = text.replaceAll('DHU AL-HIJJAH', 'ذو الحجة');

    // إزالة AH
    text = text.replaceAll(' AH', ' هـ');

    return text;
  }
}

class RamadanSchedule {
  final String cityKey;
  final int totalDays;
  final List<RamadanDay> days;
  final List<String> whiteDayDates;

  const RamadanSchedule({
    required this.cityKey,
    required this.totalDays,
    required this.days,
    required this.whiteDayDates,
  });

  factory RamadanSchedule.fromMap(Map<String, dynamic> map) {
    final daysRaw = map['days'];
    final days = <RamadanDay>[];
    if (daysRaw is List) {
      for (final d in daysRaw) {
        if (d is Map) {
          days.add(RamadanDay.fromMap(Map<String, dynamic>.from(d)));
        }
      }
    }

    final whiteDaysRaw = map['white_days'];
    final whiteDays = <String>[];
    if (whiteDaysRaw is List) {
      whiteDays.addAll(whiteDaysRaw.map((e) => e.toString()));
    }

    return RamadanSchedule(
      cityKey: (map['city_key'] ?? '').toString(),
      totalDays: (map['total_days'] as int?) ?? days.length,
      days: days,
      whiteDayDates: whiteDays,
    );
  }

  RamadanDay? get today {
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    try {
      return days.firstWhere((d) => d.date == todayStr);
    } catch (_) {
      return null;
    }
  }
}
