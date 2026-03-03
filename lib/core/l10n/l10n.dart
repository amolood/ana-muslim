import 'package:flutter/widgets.dart';
import 'package:im_muslim/l10n/app_localizations.dart';

export 'package:im_muslim/l10n/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
