// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navHome => 'Home';

  @override
  String get navQuran => 'Quran';

  @override
  String get navQibla => 'Qibla';

  @override
  String get navHadith => 'Hadith';

  @override
  String get navSettings => 'Settings';

  @override
  String get cancel => 'Cancel';

  @override
  String get done => 'Done';

  @override
  String get reset => 'Reset';

  @override
  String get back => 'Back';

  @override
  String get search => 'Search';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading';

  @override
  String get notSet => 'Not set';

  @override
  String get errorSavingSetting => 'Failed to save setting';

  @override
  String get settingsTitle => 'App Settings';

  @override
  String get sectionAppearance => 'Appearance';

  @override
  String get sectionPrayer => 'Prayer';

  @override
  String get sectionCalendar => 'Calendar';

  @override
  String get sectionQuran => 'Holy Quran';

  @override
  String get sectionSebha => 'Sebha';

  @override
  String get sectionOther => 'Other';

  @override
  String get settingTheme => 'Theme';

  @override
  String get settingFontSize => 'Font Size';

  @override
  String get settingLanguage => 'Language';

  @override
  String get settingHijriCalendar => 'Hijri Calendar';

  @override
  String get settingHijriCalendarSubtitle => 'Hijri date display and picker';

  @override
  String get settingCalcMethod => 'Calculation Method';

  @override
  String get settingPrayerAdjustment => 'Prayer Time Adjustment';

  @override
  String get settingPrayerAdjustmentSubtitle =>
      'Shift each prayer time by minutes';

  @override
  String get settingPrayerAlerts => 'Prayer Alerts';

  @override
  String get settingEnabled => 'Enabled';

  @override
  String get settingDisabled => 'Disabled';

  @override
  String get settingQiblaTone => 'Qibla Success Tone';

  @override
  String get settingQiblaToneType => 'Qibla Tone Type';

  @override
  String get settingQiblaPreview => 'Preview Qibla Tone';

  @override
  String get settingQiblaPreviewSubtitle =>
      'Play the selected tone to verify the sound';

  @override
  String get settingCurrentLocation => 'Current Location';

  @override
  String get locationAuto => 'Auto';

  @override
  String get locationUpdated => 'Location updated successfully';

  @override
  String get locationUpdateFailed => 'Failed to update location';

  @override
  String get qiblaToneEnableFirst =>
      'Enable the Qibla success tone in Settings first';

  @override
  String get qiblaTonePlayFailed => 'Failed to play the tone';

  @override
  String get settingTafsir => 'Tafsir Source';

  @override
  String get settingDefaultReciter => 'Default Reciter';

  @override
  String get settingPrivacy => 'Privacy';

  @override
  String get privacyMessage =>
      'Your personal data is not sent to external servers. Settings are saved locally on your device only.';

  @override
  String get settingContactUs => 'Contact Us';

  @override
  String get settingContactSubtitle => 'Visit our website';

  @override
  String get whatsappError => 'Could not open the contact page';

  @override
  String get settingAbout => 'About';

  @override
  String get aboutMessage =>
      'I\'m Muslim App: Quran, Adhkar, Qibla, and Prayer Times in a complete Islamic experience.\n\nSadaqah Jariyah for me, my parents, and all Muslims.';

  @override
  String footerTitle(int year) {
    final intl.NumberFormat yearNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String yearString = yearNumberFormat.format(year);

    return 'I\'m Muslim App © $yearString';
  }

  @override
  String get footerSubtitle => 'Designed to serve the Muslim Ummah';

  @override
  String get sebhaDefaultGoalTitle => 'Default Dhikr Goal';

  @override
  String get sebhaDefaultGoalSubtitle =>
      'Automatically applied to all dhikr phrases';

  @override
  String get sebhaPhraseListTitle => 'Dhikr Phrases';

  @override
  String sebhaPhraseListSubtitle(String phrase) {
    return 'Current: $phrase';
  }

  @override
  String get todayDateLabel => 'Today\'s Date';

  @override
  String get nextPrayerLabel => 'Next Prayer';

  @override
  String get remainingLabel => 'Remaining';

  @override
  String get locating => 'Locating';

  @override
  String get unknownLocation => 'Unknown location';

  @override
  String get locationError => 'Location error';

  @override
  String get sebhaTitle => 'Sebha';

  @override
  String get resetTodayCounters => 'Reset today\'s counters';

  @override
  String get resetCurrentPhraseTitle => 'Reset Current Phrase';

  @override
  String get resetCurrentPhraseMsg =>
      'Only the selected phrase counter will be reset.';

  @override
  String get resetTodayTitle => 'Reset Today\'s Counter';

  @override
  String get resetTodayMsg =>
      'All today\'s counters for every phrase will be reset.';

  @override
  String get resetTodayBtn => 'Reset Today';

  @override
  String get phraseResetSuccess => 'Current phrase has been reset';

  @override
  String get todayResetSuccess => 'Today\'s counter has been reset';

  @override
  String goalReachedSwitched(String phrase) {
    return 'Completed goal for \"$phrase\" and moved to the next phrase';
  }

  @override
  String goalReached(String phrase) {
    return 'Completed goal for \"$phrase\"';
  }

  @override
  String dailyGoalLabel(String goal) {
    return 'Daily goal: $goal';
  }

  @override
  String get dailyGoalUnset => 'Daily goal: not set';

  @override
  String get goalUnsetText => 'Goal not set';

  @override
  String get prevPhrase => 'Previous';

  @override
  String get nextPhraseLabel => 'Next';

  @override
  String get tapToCount => 'Tap to count';

  @override
  String get totalCountLabel => 'Total Count';

  @override
  String get todayTotalLabel => 'Today\'s Total';

  @override
  String get completedGoalsLabel => 'Goals Completed';

  @override
  String get resetCurrentBtn => 'Reset Current';

  @override
  String get manageSebhaTitle => 'Manage Phrases & Goals';

  @override
  String get manageSebhaDesc =>
      'Adding and removing phrases and setting the default goal is now done from the Settings screen.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get hadithLibraryTitle => 'Hadith Library';

  @override
  String get noHadithCollections => 'No hadith collections available';

  @override
  String get hadithCollectionsError => 'Failed to load hadith collections';

  @override
  String get hadithDataError => 'An error occurred loading data';

  @override
  String hadithCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString hadiths';
  }

  @override
  String get prayerSilenceTitle => 'Prayer Time Silence';

  @override
  String get prayerSilenceSubtitle => 'Auto-silence phone during prayer times';

  @override
  String get psSectionPrayers => 'Included Prayers';

  @override
  String get psSectionTiming => 'Activation Window';

  @override
  String get psSectionMode => 'Silence Mode';

  @override
  String get psSectionOptions => 'Options';

  @override
  String get psModeDnd => 'Do Not Disturb (DND)';

  @override
  String get psModeSilent => 'Silent';

  @override
  String get psModeVibrate => 'Vibrate';

  @override
  String get psMinutesBeforeLabel => 'Before adhan';

  @override
  String get psMinutesAfterLabel => 'After adhan';

  @override
  String psMinutesValue(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString min';
  }

  @override
  String get psAutoRestore => 'Restore previous mode automatically';

  @override
  String get psAutoRestoreSubtitle =>
      'Return to normal mode after prayer window ends';

  @override
  String get psPermissionBannerTitle => 'Permission Required';

  @override
  String get psPermissionBannerBody =>
      'Grant the app Do Not Disturb access to enable this feature on Android.';

  @override
  String get psPermissionButton => 'Open System Settings';

  @override
  String get psIosTitle => 'Not Supported on iOS';

  @override
  String get psIosBody =>
      'iOS does not allow apps to control the ringer mode programmatically. You can use the Focus feature in device Settings to set up a custom silence schedule.';

  @override
  String get psRescheduleSuccess => 'Prayer silence schedule updated';

  @override
  String get psRescheduleFailed => 'Failed to schedule prayer silence';

  @override
  String get sectionWidgets => 'Home Screen Widgets';

  @override
  String get widgetSettingsTitle => 'Widget Settings';

  @override
  String get widgetSettingsSubtitle =>
      'Customize home screen widget appearance';

  @override
  String get widgetGeneral => 'General';

  @override
  String get widgetNumberFormat => 'Number Format';

  @override
  String get widgetTimeFormat => 'Time Format';

  @override
  String get widgetTextColor => 'Text Color';

  @override
  String get widgetBgColor => 'Background Color';

  @override
  String get widgetBgOpacity => 'Background Opacity';

  @override
  String get widgetCornerRadius => 'Corner Radius';

  @override
  String get widgetFontSize => 'Font Size';

  @override
  String get widgetDecorImage => 'Decor Image';

  @override
  String get widgetDecorOpacity => 'Decor Opacity';

  @override
  String get widgetDecorColor => 'Decor Color';

  @override
  String get widgetNoDecor => 'None';

  @override
  String get widgetPreview => 'Preview';

  @override
  String get updateAvailableTitle => 'Update Available';

  @override
  String get forceUpdateTitle => 'Update Required';

  @override
  String get updateNow => 'Update Now';

  @override
  String get updateLater => 'Later';
}
