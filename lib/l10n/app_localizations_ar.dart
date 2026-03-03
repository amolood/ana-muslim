// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navQuran => 'القرآن';

  @override
  String get navQibla => 'القبلة';

  @override
  String get navHadith => 'الحديث';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get cancel => 'إلغاء';

  @override
  String get done => 'تم';

  @override
  String get reset => 'تصفير';

  @override
  String get back => 'رجوع';

  @override
  String get search => 'بحث';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get loading => 'جاري التحميل';

  @override
  String get notSet => 'غير محدد';

  @override
  String get errorSavingSetting => 'تعذّر حفظ الإعداد';

  @override
  String get settingsTitle => 'إعدادات التطبيق';

  @override
  String get sectionAppearance => 'المظهر';

  @override
  String get sectionPrayer => 'الصلاة';

  @override
  String get sectionCalendar => 'التقويم';

  @override
  String get sectionQuran => 'القرآن الكريم';

  @override
  String get sectionSebha => 'السبحة';

  @override
  String get sectionOther => 'أخرى';

  @override
  String get settingTheme => 'الثيم';

  @override
  String get settingFontSize => 'حجم الخط';

  @override
  String get settingLanguage => 'اللغة';

  @override
  String get settingHijriCalendar => 'التقويم الهجري';

  @override
  String get settingHijriCalendarSubtitle => 'عرض ومنتقي التاريخ الهجري';

  @override
  String get settingCalcMethod => 'طريقة الحساب';

  @override
  String get settingPrayerAdjustment => 'ضبط مواقيت الصلاة';

  @override
  String get settingPrayerAdjustmentSubtitle => 'تقديم أو تأخير كل صلاة بدقائق';

  @override
  String get settingPrayerAlerts => 'تنبيهات الصلاة';

  @override
  String get settingEnabled => 'مفعلة';

  @override
  String get settingDisabled => 'موقفة';

  @override
  String get settingQiblaTone => 'نغمة نجاح القبلة';

  @override
  String get settingQiblaToneType => 'نوع نغمة القبلة';

  @override
  String get settingQiblaPreview => 'معاينة نغمة القبلة';

  @override
  String get settingQiblaPreviewSubtitle =>
      'تشغيل النغمة المختارة للتأكد من الصوت';

  @override
  String get settingCurrentLocation => 'الموقع الحالي';

  @override
  String get locationAuto => 'تلقائي';

  @override
  String get locationUpdated => 'تم تحديث الموقع بنجاح';

  @override
  String get locationUpdateFailed => 'تعذّر تحديث الموقع';

  @override
  String get qiblaToneEnableFirst => 'فعّل نغمة نجاح القبلة أولًا من الإعدادات';

  @override
  String get qiblaTonePlayFailed => 'تعذّر تشغيل النغمة';

  @override
  String get settingTafsir => 'مصدر التفسير';

  @override
  String get settingDefaultReciter => 'القارئ الافتراضي';

  @override
  String get settingPrivacy => 'الخصوصية';

  @override
  String get privacyMessage =>
      'لا يتم إرسال بياناتك الشخصية إلى خوادم خارجية. يتم حفظ الإعدادات محليًا على جهازك فقط.';

  @override
  String get settingContactUs => 'تواصل معنا';

  @override
  String get settingContactSubtitle => 'زيارة الموقع الرسمي';

  @override
  String get whatsappError => 'تعذّر فتح صفحة التواصل';

  @override
  String get settingAbout => 'عن التطبيق';

  @override
  String get aboutMessage =>
      'تطبيق المسلم: قرآن، أذكار، قبلة، ومواقيت الصلاة في تجربة عربية متكاملة.\n\nصدقة جارية عني وعن والديَّ وعن كل المسلمين.';

  @override
  String footerTitle(int year) {
    final intl.NumberFormat yearNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String yearString = yearNumberFormat.format(year);

    return 'تطبيق المسلم © $yearString';
  }

  @override
  String get footerSubtitle => 'صمم لخدمة الأمة الإسلامية';

  @override
  String get sebhaDefaultGoalTitle => 'الهدف الافتراضي للتسبيح';

  @override
  String get sebhaDefaultGoalSubtitle => 'يُطبّق تلقائيًا على جميع التسبيحات';

  @override
  String get sebhaPhraseListTitle => 'قائمة التسبيحات';

  @override
  String sebhaPhraseListSubtitle(String phrase) {
    return 'الحالية: $phrase';
  }

  @override
  String get todayDateLabel => 'التاريخ اليوم';

  @override
  String get nextPrayerLabel => 'الصلاة القادمة';

  @override
  String get remainingLabel => 'متبقي';

  @override
  String get locating => 'جاري تحديد الموقع';

  @override
  String get unknownLocation => 'موقع غير معروف';

  @override
  String get locationError => 'خطأ في الموقع';

  @override
  String get sebhaTitle => 'السبحة';

  @override
  String get resetTodayCounters => 'تصفير عدادات اليوم';

  @override
  String get resetCurrentPhraseTitle => 'تصفير التسبيحة الحالية';

  @override
  String get resetCurrentPhraseMsg => 'سيتم تصفير عداد التسبيحة المختارة فقط.';

  @override
  String get resetTodayTitle => 'تصفير عداد اليوم';

  @override
  String get resetTodayMsg => 'سيتم تصفير جميع عدادات اليوم لكل التسبيحات.';

  @override
  String get resetTodayBtn => 'تصفير اليوم';

  @override
  String get phraseResetSuccess => 'تم تصفير التسبيحة الحالية';

  @override
  String get todayResetSuccess => 'تم تصفير عداد اليوم';

  @override
  String goalReachedSwitched(String phrase) {
    return 'أكملت هدف \"$phrase\" وتم الانتقال للتسبيحة التالية';
  }

  @override
  String goalReached(String phrase) {
    return 'أكملت هدف \"$phrase\"';
  }

  @override
  String dailyGoalLabel(String goal) {
    return 'هدف يومي: $goal';
  }

  @override
  String get dailyGoalUnset => 'هدف يومي: غير محدد';

  @override
  String get goalUnsetText => 'هدف غير محدد';

  @override
  String get prevPhrase => 'السابق';

  @override
  String get nextPhraseLabel => 'التالي';

  @override
  String get tapToCount => 'اضغط للتسبيح';

  @override
  String get totalCountLabel => 'إجمالي التسبيح';

  @override
  String get todayTotalLabel => 'مجموع اليوم';

  @override
  String get completedGoalsLabel => 'أهداف مكتملة';

  @override
  String get resetCurrentBtn => 'تصفير الحالية';

  @override
  String get manageSebhaTitle => 'إدارة التسبيحات والأهداف';

  @override
  String get manageSebhaDesc =>
      'إضافة وحذف التسبيحات وتحديد الهدف الافتراضي أصبحت من شاشة الإعدادات.';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String get hadithLibraryTitle => 'مكتبة الحديث الشريف';

  @override
  String get noHadithCollections => 'لا توجد مجموعات حديث متاحة الآن';

  @override
  String get hadithCollectionsError => 'تعذر تحميل مجموعات الحديث';

  @override
  String get hadithDataError => 'حدث خطأ في تحميل البيانات';

  @override
  String hadithCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString حديث';
  }

  @override
  String get prayerSilenceTitle => 'صامت وقت الصلاة';

  @override
  String get prayerSilenceSubtitle => 'إسكات الهاتف تلقائياً خلال أوقات الصلاة';

  @override
  String get psSectionPrayers => 'الصلوات المشمولة';

  @override
  String get psSectionTiming => 'نافذة التفعيل';

  @override
  String get psSectionMode => 'وضع الإسكات';

  @override
  String get psSectionOptions => 'خيارات إضافية';

  @override
  String get psModeDnd => 'عدم الإزعاج (DND)';

  @override
  String get psModeSilent => 'صامت';

  @override
  String get psModeVibrate => 'اهتزاز';

  @override
  String get psMinutesBeforeLabel => 'قبل الأذان';

  @override
  String get psMinutesAfterLabel => 'بعد الأذان';

  @override
  String psMinutesValue(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString دقيقة';
  }

  @override
  String get psAutoRestore => 'إرجاع الوضع السابق تلقائياً';

  @override
  String get psAutoRestoreSubtitle =>
      'الرجوع للوضع الطبيعي بعد انتهاء وقت الصلاة';

  @override
  String get psPermissionBannerTitle => 'صلاحية مطلوبة';

  @override
  String get psPermissionBannerBody =>
      'يجب منح التطبيق صلاحية التحكم في وضع \"عدم الإزعاج\" لتفعيل هذه الميزة.';

  @override
  String get psPermissionButton => 'فتح إعدادات النظام';

  @override
  String get psIosTitle => 'غير مدعومة على iOS';

  @override
  String get psIosBody =>
      'لا يسمح نظام iOS بالتحكم في وضع الصوت برمجياً. يمكنك استخدام ميزة التركيز في إعدادات الجهاز لإعداد جدول صمت مخصص.';

  @override
  String get psRescheduleSuccess => 'تمت إعادة جدولة الصمت التلقائي';

  @override
  String get psRescheduleFailed => 'تعذّرت جدولة الصمت التلقائي';

  @override
  String get sectionWidgets => 'ودجات الشاشة';

  @override
  String get widgetSettingsTitle => 'إعدادات الودجات';

  @override
  String get widgetSettingsSubtitle => 'تخصيص مظهر ودجات الشاشة الرئيسية';

  @override
  String get widgetGeneral => 'إعدادات عامة';

  @override
  String get widgetNumberFormat => 'تنسيق الأرقام';

  @override
  String get widgetTimeFormat => 'تنسيق الوقت';

  @override
  String get widgetTextColor => 'لون النص';

  @override
  String get widgetBgColor => 'لون الخلفية';

  @override
  String get widgetBgOpacity => 'شفافية الخلفية';

  @override
  String get widgetCornerRadius => 'استدارة الزوايا';

  @override
  String get widgetFontSize => 'حجم الخط';

  @override
  String get widgetDecorImage => 'صورة الزخرفة';

  @override
  String get widgetDecorOpacity => 'شفافية الزخرفة';

  @override
  String get widgetDecorColor => 'لون الزخرفة';

  @override
  String get widgetNoDecor => 'بدون';

  @override
  String get widgetPreview => 'معاينة';

  @override
  String get updateAvailableTitle => 'تحديث متاح';

  @override
  String get forceUpdateTitle => 'تحديث إلزامي';

  @override
  String get updateNow => 'تحديث الآن';

  @override
  String get updateLater => 'لاحقاً';
}
