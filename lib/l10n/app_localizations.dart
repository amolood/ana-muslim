import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// Bottom navigation: Home tab
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// Bottom navigation: Quran tab
  ///
  /// In ar, this message translates to:
  /// **'القرآن'**
  String get navQuran;

  /// Bottom navigation: Tools tab (Qibla, Prayer times, Azkar, Sebha, Ramadan)
  ///
  /// In ar, this message translates to:
  /// **'أدوات'**
  String get navQibla;

  /// Bottom navigation: Hadith tab
  ///
  /// In ar, this message translates to:
  /// **'الحديث'**
  String get navHadith;

  /// Bottom navigation: Settings tab
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get navSettings;

  /// Cancel action button label
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// Done/OK action button label
  ///
  /// In ar, this message translates to:
  /// **'تم'**
  String get done;

  /// Reset action button label
  ///
  /// In ar, this message translates to:
  /// **'تصفير'**
  String get reset;

  /// Back navigation tooltip
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get back;

  /// Search action tooltip
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get search;

  /// Retry action button label
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// Generic loading state text
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل'**
  String get loading;

  /// Value not set / unspecified
  ///
  /// In ar, this message translates to:
  /// **'غير محدد'**
  String get notSet;

  /// Snackbar shown when saving a setting fails
  ///
  /// In ar, this message translates to:
  /// **'تعذّر حفظ الإعداد'**
  String get errorSavingSetting;

  /// Settings screen AppBar title
  ///
  /// In ar, this message translates to:
  /// **'إعدادات التطبيق'**
  String get settingsTitle;

  /// Settings section header: Appearance
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get sectionAppearance;

  /// Settings section header: Prayer
  ///
  /// In ar, this message translates to:
  /// **'الصلاة'**
  String get sectionPrayer;

  /// Settings section header: Calendar
  ///
  /// In ar, this message translates to:
  /// **'التقويم'**
  String get sectionCalendar;

  /// Settings section header: Holy Quran
  ///
  /// In ar, this message translates to:
  /// **'القرآن الكريم'**
  String get sectionQuran;

  /// Settings section header: Sebha
  ///
  /// In ar, this message translates to:
  /// **'السبحة'**
  String get sectionSebha;

  /// Settings section header: Other
  ///
  /// In ar, this message translates to:
  /// **'أخرى'**
  String get sectionOther;

  /// Setting tile title: Theme
  ///
  /// In ar, this message translates to:
  /// **'الثيم'**
  String get settingTheme;

  /// Setting tile title: Font Size
  ///
  /// In ar, this message translates to:
  /// **'حجم الخط'**
  String get settingFontSize;

  /// Setting tile title: Language
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get settingLanguage;

  /// Setting tile title: Hijri Calendar
  ///
  /// In ar, this message translates to:
  /// **'التقويم الهجري'**
  String get settingHijriCalendar;

  /// Subtitle for Hijri Calendar tile
  ///
  /// In ar, this message translates to:
  /// **'عرض ومنتقي التاريخ الهجري'**
  String get settingHijriCalendarSubtitle;

  /// Setting tile title: Prayer Calculation Method
  ///
  /// In ar, this message translates to:
  /// **'طريقة الحساب'**
  String get settingCalcMethod;

  /// Setting tile title: Prayer Time Adjustment
  ///
  /// In ar, this message translates to:
  /// **'ضبط مواقيت الصلاة'**
  String get settingPrayerAdjustment;

  /// Subtitle for Prayer Time Adjustment tile
  ///
  /// In ar, this message translates to:
  /// **'تقديم أو تأخير كل صلاة بدقائق'**
  String get settingPrayerAdjustmentSubtitle;

  /// Setting tile title: Prayer Alerts
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات الصلاة'**
  String get settingPrayerAlerts;

  /// State label: Enabled
  ///
  /// In ar, this message translates to:
  /// **'مفعلة'**
  String get settingEnabled;

  /// State label: Disabled
  ///
  /// In ar, this message translates to:
  /// **'موقفة'**
  String get settingDisabled;

  /// Setting tile title: Qibla success tone
  ///
  /// In ar, this message translates to:
  /// **'نغمة نجاح القبلة'**
  String get settingQiblaTone;

  /// Setting tile title: Qibla tone type
  ///
  /// In ar, this message translates to:
  /// **'نوع نغمة القبلة'**
  String get settingQiblaToneType;

  /// Setting tile title: Preview Qibla Tone
  ///
  /// In ar, this message translates to:
  /// **'معاينة نغمة القبلة'**
  String get settingQiblaPreview;

  /// Subtitle for Qibla preview tile
  ///
  /// In ar, this message translates to:
  /// **'تشغيل النغمة المختارة للتأكد من الصوت'**
  String get settingQiblaPreviewSubtitle;

  /// Setting tile title: Current Location
  ///
  /// In ar, this message translates to:
  /// **'الموقع الحالي'**
  String get settingCurrentLocation;

  /// Location trailing text when auto-detected
  ///
  /// In ar, this message translates to:
  /// **'تلقائي'**
  String get locationAuto;

  /// Snackbar: location updated successfully
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الموقع بنجاح'**
  String get locationUpdated;

  /// Snackbar: failed to update location
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحديث الموقع'**
  String get locationUpdateFailed;

  /// Message shown when trying to preview while tone is disabled
  ///
  /// In ar, this message translates to:
  /// **'فعّل نغمة نجاح القبلة أولًا من الإعدادات'**
  String get qiblaToneEnableFirst;

  /// Error snackbar when tone playback fails
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تشغيل النغمة'**
  String get qiblaTonePlayFailed;

  /// Setting tile title: Tafsir source
  ///
  /// In ar, this message translates to:
  /// **'مصدر التفسير'**
  String get settingTafsir;

  /// Setting tile title: Default Reciter
  ///
  /// In ar, this message translates to:
  /// **'القارئ الافتراضي'**
  String get settingDefaultReciter;

  /// Setting tile title: Privacy
  ///
  /// In ar, this message translates to:
  /// **'الخصوصية'**
  String get settingPrivacy;

  /// Privacy policy dialog message
  ///
  /// In ar, this message translates to:
  /// **'لا يتم إرسال بياناتك الشخصية إلى خوادم خارجية. يتم حفظ الإعدادات محليًا على جهازك فقط.'**
  String get privacyMessage;

  /// Setting tile title: Contact Us
  ///
  /// In ar, this message translates to:
  /// **'تواصل معنا'**
  String get settingContactUs;

  /// Contact Us tile subtitle
  ///
  /// In ar, this message translates to:
  /// **'زيارة الموقع الرسمي'**
  String get settingContactSubtitle;

  /// Error snackbar when contact page cannot be opened
  ///
  /// In ar, this message translates to:
  /// **'تعذّر فتح صفحة التواصل'**
  String get whatsappError;

  /// Setting tile title: About App
  ///
  /// In ar, this message translates to:
  /// **'عن التطبيق'**
  String get settingAbout;

  /// About app dialog message
  ///
  /// In ar, this message translates to:
  /// **'تطبيق المسلم: قرآن، أذكار، قبلة، ومواقيت الصلاة في تجربة عربية متكاملة.\n\nصدقة جارية عني وعن والديَّ وعن كل المسلمين.'**
  String get aboutMessage;

  /// Footer copyright line
  ///
  /// In ar, this message translates to:
  /// **'تطبيق المسلم © {year}'**
  String footerTitle(int year);

  /// Footer subtitle line
  ///
  /// In ar, this message translates to:
  /// **'صمم لخدمة الأمة الإسلامية'**
  String get footerSubtitle;

  /// Sebha settings: default daily goal tile title
  ///
  /// In ar, this message translates to:
  /// **'الهدف الافتراضي للتسبيح'**
  String get sebhaDefaultGoalTitle;

  /// Sebha settings: default goal tile subtitle
  ///
  /// In ar, this message translates to:
  /// **'يُطبّق تلقائيًا على جميع التسبيحات'**
  String get sebhaDefaultGoalSubtitle;

  /// Sebha settings: phrases list tile title
  ///
  /// In ar, this message translates to:
  /// **'قائمة التسبيحات'**
  String get sebhaPhraseListTitle;

  /// Sebha settings: current phrase subtitle
  ///
  /// In ar, this message translates to:
  /// **'الحالية: {phrase}'**
  String sebhaPhraseListSubtitle(String phrase);

  /// Prayer times card: today's date label
  ///
  /// In ar, this message translates to:
  /// **'التاريخ اليوم'**
  String get todayDateLabel;

  /// Prayer times card: next prayer label
  ///
  /// In ar, this message translates to:
  /// **'الصلاة القادمة'**
  String get nextPrayerLabel;

  /// Prayer times card: remaining time label
  ///
  /// In ar, this message translates to:
  /// **'متبقي'**
  String get remainingLabel;

  /// Prayer times card: locating state
  ///
  /// In ar, this message translates to:
  /// **'جاري تحديد الموقع'**
  String get locating;

  /// Prayer times card: unknown location
  ///
  /// In ar, this message translates to:
  /// **'موقع غير معروف'**
  String get unknownLocation;

  /// Prayer times card: location error state
  ///
  /// In ar, this message translates to:
  /// **'خطأ في الموقع'**
  String get locationError;

  /// Sebha screen AppBar title
  ///
  /// In ar, this message translates to:
  /// **'السبحة'**
  String get sebhaTitle;

  /// Sebha: reset today's counters tooltip/title
  ///
  /// In ar, this message translates to:
  /// **'تصفير عدادات اليوم'**
  String get resetTodayCounters;

  /// Sebha: reset current phrase dialog title
  ///
  /// In ar, this message translates to:
  /// **'تصفير التسبيحة الحالية'**
  String get resetCurrentPhraseTitle;

  /// Sebha: reset current phrase confirmation message
  ///
  /// In ar, this message translates to:
  /// **'سيتم تصفير عداد التسبيحة المختارة فقط.'**
  String get resetCurrentPhraseMsg;

  /// Sebha: reset today dialog title
  ///
  /// In ar, this message translates to:
  /// **'تصفير عداد اليوم'**
  String get resetTodayTitle;

  /// Sebha: reset today confirmation message
  ///
  /// In ar, this message translates to:
  /// **'سيتم تصفير جميع عدادات اليوم لكل التسبيحات.'**
  String get resetTodayMsg;

  /// Sebha: reset today confirm button label
  ///
  /// In ar, this message translates to:
  /// **'تصفير اليوم'**
  String get resetTodayBtn;

  /// Sebha: snackbar after current phrase reset
  ///
  /// In ar, this message translates to:
  /// **'تم تصفير التسبيحة الحالية'**
  String get phraseResetSuccess;

  /// Sebha: snackbar after today's counter reset
  ///
  /// In ar, this message translates to:
  /// **'تم تصفير عداد اليوم'**
  String get todayResetSuccess;

  /// Sebha: snackbar when goal reached and auto-switched
  ///
  /// In ar, this message translates to:
  /// **'أكملت هدف \"{phrase}\" وتم الانتقال للتسبيحة التالية'**
  String goalReachedSwitched(String phrase);

  /// Sebha: snackbar when daily goal reached
  ///
  /// In ar, this message translates to:
  /// **'أكملت هدف \"{phrase}\"'**
  String goalReached(String phrase);

  /// Sebha: daily goal label with count
  ///
  /// In ar, this message translates to:
  /// **'هدف يومي: {goal}'**
  String dailyGoalLabel(String goal);

  /// Sebha: daily goal not set label
  ///
  /// In ar, this message translates to:
  /// **'هدف يومي: غير محدد'**
  String get dailyGoalUnset;

  /// Sebha: goal unset inside counter card
  ///
  /// In ar, this message translates to:
  /// **'هدف غير محدد'**
  String get goalUnsetText;

  /// Sebha: previous phrase button label
  ///
  /// In ar, this message translates to:
  /// **'السابق'**
  String get prevPhrase;

  /// Sebha: next phrase button label
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get nextPhraseLabel;

  /// Sebha: tap to count label inside circular button
  ///
  /// In ar, this message translates to:
  /// **'اضغط للتسبيح'**
  String get tapToCount;

  /// Sebha stats: total count label
  ///
  /// In ar, this message translates to:
  /// **'إجمالي التسبيح'**
  String get totalCountLabel;

  /// Sebha stats: today's total label
  ///
  /// In ar, this message translates to:
  /// **'مجموع اليوم'**
  String get todayTotalLabel;

  /// Sebha stats: completed goals label
  ///
  /// In ar, this message translates to:
  /// **'أهداف مكتملة'**
  String get completedGoalsLabel;

  /// Sebha: reset current phrase outlined button
  ///
  /// In ar, this message translates to:
  /// **'تصفير الحالية'**
  String get resetCurrentBtn;

  /// Sebha: manage card title
  ///
  /// In ar, this message translates to:
  /// **'إدارة التسبيحات والأهداف'**
  String get manageSebhaTitle;

  /// Sebha: manage card description
  ///
  /// In ar, this message translates to:
  /// **'إضافة وحذف التسبيحات وتحديد الهدف الافتراضي أصبحت من شاشة الإعدادات.'**
  String get manageSebhaDesc;

  /// Sebha: open settings button label
  ///
  /// In ar, this message translates to:
  /// **'فتح الإعدادات'**
  String get openSettings;

  /// Hadith screen title
  ///
  /// In ar, this message translates to:
  /// **'مكتبة الحديث الشريف'**
  String get hadithLibraryTitle;

  /// Hadith screen: empty state message
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مجموعات حديث متاحة الآن'**
  String get noHadithCollections;

  /// Hadith screen: collections load error
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل مجموعات الحديث'**
  String get hadithCollectionsError;

  /// Hadith books: data load error message
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ في تحميل البيانات'**
  String get hadithDataError;

  /// Number of hadiths shown on a book tile
  ///
  /// In ar, this message translates to:
  /// **'{count} حديث'**
  String hadithCount(int count);

  /// Prayer silence feature screen title
  ///
  /// In ar, this message translates to:
  /// **'صامت وقت الصلاة'**
  String get prayerSilenceTitle;

  /// Prayer silence settings tile subtitle
  ///
  /// In ar, this message translates to:
  /// **'إسكات الهاتف تلقائياً خلال أوقات الصلاة'**
  String get prayerSilenceSubtitle;

  /// Prayer silence: section header for prayer selection
  ///
  /// In ar, this message translates to:
  /// **'الصلوات المشمولة'**
  String get psSectionPrayers;

  /// Prayer silence: section header for timing
  ///
  /// In ar, this message translates to:
  /// **'نافذة التفعيل'**
  String get psSectionTiming;

  /// Prayer silence: section header for silence mode
  ///
  /// In ar, this message translates to:
  /// **'وضع الإسكات'**
  String get psSectionMode;

  /// Prayer silence: section header for extra options
  ///
  /// In ar, this message translates to:
  /// **'خيارات إضافية'**
  String get psSectionOptions;

  /// Prayer silence mode: Do Not Disturb
  ///
  /// In ar, this message translates to:
  /// **'عدم الإزعاج (DND)'**
  String get psModeDnd;

  /// Prayer silence mode: Silent
  ///
  /// In ar, this message translates to:
  /// **'صامت'**
  String get psModeSilent;

  /// Prayer silence mode: Vibrate
  ///
  /// In ar, this message translates to:
  /// **'اهتزاز'**
  String get psModeVibrate;

  /// Prayer silence: minutes before adhan label
  ///
  /// In ar, this message translates to:
  /// **'قبل الأذان'**
  String get psMinutesBeforeLabel;

  /// Prayer silence: minutes after adhan label
  ///
  /// In ar, this message translates to:
  /// **'بعد الأذان'**
  String get psMinutesAfterLabel;

  /// Prayer silence: minutes count label
  ///
  /// In ar, this message translates to:
  /// **'{count} دقيقة'**
  String psMinutesValue(int count);

  /// Prayer silence: auto-restore toggle label
  ///
  /// In ar, this message translates to:
  /// **'إرجاع الوضع السابق تلقائياً'**
  String get psAutoRestore;

  /// Prayer silence: auto-restore toggle subtitle
  ///
  /// In ar, this message translates to:
  /// **'الرجوع للوضع الطبيعي بعد انتهاء وقت الصلاة'**
  String get psAutoRestoreSubtitle;

  /// Prayer silence: permission banner title
  ///
  /// In ar, this message translates to:
  /// **'صلاحية مطلوبة'**
  String get psPermissionBannerTitle;

  /// Prayer silence: permission banner body
  ///
  /// In ar, this message translates to:
  /// **'يجب منح التطبيق صلاحية التحكم في وضع \"عدم الإزعاج\" لتفعيل هذه الميزة.'**
  String get psPermissionBannerBody;

  /// Prayer silence: open system settings button
  ///
  /// In ar, this message translates to:
  /// **'فتح إعدادات النظام'**
  String get psPermissionButton;

  /// Prayer silence: iOS unsupported title
  ///
  /// In ar, this message translates to:
  /// **'غير مدعومة على iOS'**
  String get psIosTitle;

  /// Prayer silence: iOS unsupported explanation
  ///
  /// In ar, this message translates to:
  /// **'لا يسمح نظام iOS بالتحكم في وضع الصوت برمجياً. يمكنك استخدام ميزة التركيز في إعدادات الجهاز لإعداد جدول صمت مخصص.'**
  String get psIosBody;

  /// Prayer silence: reschedule success snackbar
  ///
  /// In ar, this message translates to:
  /// **'تمت إعادة جدولة الصمت التلقائي'**
  String get psRescheduleSuccess;

  /// Prayer silence: reschedule failed snackbar
  ///
  /// In ar, this message translates to:
  /// **'تعذّرت جدولة الصمت التلقائي'**
  String get psRescheduleFailed;

  /// Settings section header: Widgets
  ///
  /// In ar, this message translates to:
  /// **'ودجات الشاشة'**
  String get sectionWidgets;

  /// Widget settings screen title
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الودجات'**
  String get widgetSettingsTitle;

  /// Widget settings tile subtitle / widgets section title
  ///
  /// In ar, this message translates to:
  /// **'تخصيص مظهر ودجات الشاشة الرئيسية'**
  String get widgetSettingsSubtitle;

  /// Widget settings: general section header
  ///
  /// In ar, this message translates to:
  /// **'إعدادات عامة'**
  String get widgetGeneral;

  /// Widget settings: number format tile
  ///
  /// In ar, this message translates to:
  /// **'تنسيق الأرقام'**
  String get widgetNumberFormat;

  /// Widget settings: time format tile
  ///
  /// In ar, this message translates to:
  /// **'تنسيق الوقت'**
  String get widgetTimeFormat;

  /// Widget detail: text color label
  ///
  /// In ar, this message translates to:
  /// **'لون النص'**
  String get widgetTextColor;

  /// Widget detail: background color label
  ///
  /// In ar, this message translates to:
  /// **'لون الخلفية'**
  String get widgetBgColor;

  /// Widget detail: background opacity label
  ///
  /// In ar, this message translates to:
  /// **'شفافية الخلفية'**
  String get widgetBgOpacity;

  /// Widget detail: corner radius label
  ///
  /// In ar, this message translates to:
  /// **'استدارة الزوايا'**
  String get widgetCornerRadius;

  /// Widget detail: font size label
  ///
  /// In ar, this message translates to:
  /// **'حجم الخط'**
  String get widgetFontSize;

  /// Widget detail: decor image label
  ///
  /// In ar, this message translates to:
  /// **'صورة الزخرفة'**
  String get widgetDecorImage;

  /// Widget detail: decor opacity label
  ///
  /// In ar, this message translates to:
  /// **'شفافية الزخرفة'**
  String get widgetDecorOpacity;

  /// Widget detail: decor color label
  ///
  /// In ar, this message translates to:
  /// **'لون الزخرفة'**
  String get widgetDecorColor;

  /// Widget detail: no decor option
  ///
  /// In ar, this message translates to:
  /// **'بدون'**
  String get widgetNoDecor;

  /// Widget detail: preview label
  ///
  /// In ar, this message translates to:
  /// **'معاينة'**
  String get widgetPreview;

  /// App update dialog title when a soft update is available
  ///
  /// In ar, this message translates to:
  /// **'تحديث متاح'**
  String get updateAvailableTitle;

  /// App update dialog title when a force update is required
  ///
  /// In ar, this message translates to:
  /// **'تحديث إلزامي'**
  String get forceUpdateTitle;

  /// App update dialog: primary action button
  ///
  /// In ar, this message translates to:
  /// **'تحديث الآن'**
  String get updateNow;

  /// App update dialog: dismiss button for soft updates
  ///
  /// In ar, this message translates to:
  /// **'لاحقاً'**
  String get updateLater;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
