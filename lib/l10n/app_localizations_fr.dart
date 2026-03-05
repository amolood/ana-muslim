// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get navHome => 'Accueil';

  @override
  String get navQuran => 'Coran';

  @override
  String get navQibla => 'Outils';

  @override
  String get navHadith => 'Hadith';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get cancel => 'Annuler';

  @override
  String get done => 'Terminer';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get back => 'Retour';

  @override
  String get search => 'Rechercher';

  @override
  String get retry => 'Réessayer';

  @override
  String get loading => 'Chargement';

  @override
  String get notSet => 'Non défini';

  @override
  String get errorSavingSetting => 'Échec de l\'enregistrement';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get sectionAppearance => 'Apparence';

  @override
  String get sectionPrayer => 'Prière';

  @override
  String get sectionCalendar => 'Calendrier';

  @override
  String get sectionQuran => 'Coran';

  @override
  String get sectionSebha => 'Sebha';

  @override
  String get sectionOther => 'Autre';

  @override
  String get settingTheme => 'Thème';

  @override
  String get settingFontSize => 'Taille de police';

  @override
  String get settingLanguage => 'Langue';

  @override
  String get settingHijriCalendar => 'Calendrier Hégirien';

  @override
  String get settingHijriCalendarSubtitle =>
      'Affichage et sélecteur de date hégirien';

  @override
  String get settingCalcMethod => 'Méthode de calcul';

  @override
  String get settingPrayerAdjustment => 'Ajustement des horaires';

  @override
  String get settingPrayerAdjustmentSubtitle =>
      'Avancer ou retarder chaque prière en minutes';

  @override
  String get settingPrayerAlerts => 'Alertes de prière';

  @override
  String get settingEnabled => 'Activé';

  @override
  String get settingDisabled => 'Désactivé';

  @override
  String get settingQiblaTone => 'Son de la Qibla';

  @override
  String get settingQiblaToneType => 'Type de son Qibla';

  @override
  String get settingQiblaPreview => 'Aperçu du son Qibla';

  @override
  String get settingQiblaPreviewSubtitle =>
      'Jouer le son sélectionné pour vérifier';

  @override
  String get settingCurrentLocation => 'Position actuelle';

  @override
  String get locationAuto => 'Auto';

  @override
  String get locationUpdated => 'Position mise à jour';

  @override
  String get locationUpdateFailed => 'Échec de la mise à jour de position';

  @override
  String get qiblaToneEnableFirst =>
      'Activez d\'abord le son Qibla dans les paramètres';

  @override
  String get qiblaTonePlayFailed => 'Impossible de jouer le son';

  @override
  String get settingTafsir => 'Source de Tafsir';

  @override
  String get settingDefaultReciter => 'Récitant par défaut';

  @override
  String get settingPrivacy => 'Confidentialité';

  @override
  String get privacyMessage =>
      'Vos données personnelles ne sont pas envoyées à des serveurs externes. Les paramètres sont enregistrés localement sur votre appareil uniquement.';

  @override
  String get settingContactUs => 'Nous contacter';

  @override
  String get settingContactSubtitle => 'Visitez notre site web';

  @override
  String get whatsappError => 'Impossible d\'ouvrir la page de contact';

  @override
  String get settingAbout => 'À propos';

  @override
  String get aboutMessage =>
      'Application I\'m Muslim : Coran, Dhikr, Qibla et horaires de prière.\n\nSadaqah Jariyah pour moi, mes parents et tous les musulmans.';

  @override
  String footerTitle(int year) {
    final intl.NumberFormat yearNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String yearString = yearNumberFormat.format(year);

    return 'I\'m Muslim © $yearString';
  }

  @override
  String get footerSubtitle => 'Conçu pour servir la Oumma musulmane';

  @override
  String get sebhaDefaultGoalTitle => 'Objectif Dhikr par défaut';

  @override
  String get sebhaDefaultGoalSubtitle =>
      'Appliqué automatiquement à tous les dhikr';

  @override
  String get sebhaPhraseListTitle => 'Phrases de Dhikr';

  @override
  String sebhaPhraseListSubtitle(String phrase) {
    return 'Actuel : $phrase';
  }

  @override
  String get todayDateLabel => 'Date d\'aujourd\'hui';

  @override
  String get nextPrayerLabel => 'Prochaine prière';

  @override
  String get remainingLabel => 'Restant';

  @override
  String get locating => 'Localisation';

  @override
  String get unknownLocation => 'Position inconnue';

  @override
  String get locationError => 'Erreur de position';

  @override
  String get sebhaTitle => 'Sebha';

  @override
  String get resetTodayCounters => 'Réinitialiser les compteurs du jour';

  @override
  String get resetCurrentPhraseTitle => 'Réinitialiser la phrase actuelle';

  @override
  String get resetCurrentPhraseMsg =>
      'Seul le compteur de la phrase sélectionnée sera réinitialisé.';

  @override
  String get resetTodayTitle => 'Réinitialiser le compteur du jour';

  @override
  String get resetTodayMsg =>
      'Tous les compteurs du jour pour chaque phrase seront réinitialisés.';

  @override
  String get resetTodayBtn => 'Réinitialiser aujourd\'hui';

  @override
  String get phraseResetSuccess => 'La phrase actuelle a été réinitialisée';

  @override
  String get todayResetSuccess => 'Le compteur du jour a été réinitialisé';

  @override
  String goalReachedSwitched(String phrase) {
    return 'Objectif atteint pour \"$phrase\" — passage à la phrase suivante';
  }

  @override
  String goalReached(String phrase) {
    return 'Objectif atteint pour \"$phrase\"';
  }

  @override
  String dailyGoalLabel(String goal) {
    return 'Objectif quotidien : $goal';
  }

  @override
  String get dailyGoalUnset => 'Objectif quotidien : non défini';

  @override
  String get goalUnsetText => 'Objectif non défini';

  @override
  String get prevPhrase => 'Précédent';

  @override
  String get nextPhraseLabel => 'Suivant';

  @override
  String get tapToCount => 'Appuyer pour compter';

  @override
  String get totalCountLabel => 'Total';

  @override
  String get todayTotalLabel => 'Total du jour';

  @override
  String get completedGoalsLabel => 'Objectifs atteints';

  @override
  String get resetCurrentBtn => 'Réinitialiser';

  @override
  String get manageSebhaTitle => 'Gérer les phrases et objectifs';

  @override
  String get manageSebhaDesc =>
      'L\'ajout et la suppression de phrases et la définition de l\'objectif par défaut se font maintenant dans les paramètres.';

  @override
  String get openSettings => 'Ouvrir les paramètres';

  @override
  String get hadithLibraryTitle => 'Bibliothèque de Hadith';

  @override
  String get noHadithCollections => 'Aucune collection de hadith disponible';

  @override
  String get hadithCollectionsError => 'Échec du chargement des collections';

  @override
  String get hadithDataError => 'Une erreur est survenue lors du chargement';

  @override
  String hadithCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString hadiths';
  }

  @override
  String get prayerSilenceTitle => 'Silence pendant la prière';

  @override
  String get prayerSilenceSubtitle =>
      'Mettre le téléphone en silence pendant les prières';

  @override
  String get psSectionPrayers => 'Prières incluses';

  @override
  String get psSectionTiming => 'Fenêtre d\'activation';

  @override
  String get psSectionMode => 'Mode silence';

  @override
  String get psSectionOptions => 'Options';

  @override
  String get psModeDnd => 'Ne pas déranger (DND)';

  @override
  String get psModeSilent => 'Silencieux';

  @override
  String get psModeVibrate => 'Vibreur';

  @override
  String get psMinutesBeforeLabel => 'Avant l\'adhan';

  @override
  String get psMinutesAfterLabel => 'Après l\'adhan';

  @override
  String psMinutesValue(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString min';
  }

  @override
  String get psAutoRestore => 'Restaurer le mode précédent automatiquement';

  @override
  String get psAutoRestoreSubtitle =>
      'Revenir au mode normal après la fenêtre de prière';

  @override
  String get psPermissionBannerTitle => 'Permission requise';

  @override
  String get psPermissionBannerBody =>
      'Accordez à l\'application l\'accès Ne pas déranger pour activer cette fonctionnalité sur Android.';

  @override
  String get psPermissionButton => 'Ouvrir les paramètres système';

  @override
  String get psIosTitle => 'Non pris en charge sur iOS';

  @override
  String get psIosBody =>
      'iOS ne permet pas aux applications de contrôler le mode sonnerie par programmation. Vous pouvez utiliser la fonctionnalité Focus dans les paramètres de l\'appareil pour créer un planning de silence personnalisé.';

  @override
  String get psRescheduleSuccess => 'Planning de silence de prière mis à jour';

  @override
  String get psRescheduleFailed =>
      'Échec de la planification du silence de prière';

  @override
  String get sectionWidgets => 'Widgets d\'écran';

  @override
  String get widgetSettingsTitle => 'Paramètres des widgets';

  @override
  String get widgetSettingsSubtitle => 'Personnaliser l\'apparence des widgets';

  @override
  String get widgetGeneral => 'Général';

  @override
  String get widgetNumberFormat => 'Format des chiffres';

  @override
  String get widgetTimeFormat => 'Format de l\'heure';

  @override
  String get widgetTextColor => 'Couleur du texte';

  @override
  String get widgetBgColor => 'Couleur de fond';

  @override
  String get widgetBgOpacity => 'Opacité du fond';

  @override
  String get widgetCornerRadius => 'Rayon des coins';

  @override
  String get widgetFontSize => 'Taille de police';

  @override
  String get widgetDecorImage => 'Image décorative';

  @override
  String get widgetDecorOpacity => 'Opacité de la décoration';

  @override
  String get widgetDecorColor => 'Couleur de la décoration';

  @override
  String get widgetNoDecor => 'Aucune';

  @override
  String get widgetPreview => 'Aperçu';

  @override
  String get updateAvailableTitle => 'Mise à jour disponible';

  @override
  String get forceUpdateTitle => 'Mise à jour requise';

  @override
  String get updateNow => 'Mettre à jour';

  @override
  String get updateLater => 'Plus tard';
}
