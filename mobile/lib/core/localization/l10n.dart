import 'package:flutter/widgets.dart';

import 'generated/app_localizations.dart';

export 'generated/app_localizations.dart' show AppL10n;

/// Locales the app ships with today. Arabic (RTL) can be added by dropping an
/// `app_ar.arb` file in `lib/l10n/` — Flutter derives text direction from the
/// active locale, so no further wiring is needed.
const supportedLocales = <Locale>[
  Locale('so'),
  Locale('en'),
];

const fallbackLocale = Locale('en');

extension L10nContext on BuildContext {
  AppL10n get l10n => AppL10n.of(this);
}
