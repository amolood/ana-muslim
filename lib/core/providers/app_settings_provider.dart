import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'shared_preferences_base.dart';

// ─── Tafsir source ────────────────────────────────────────────────────────

final tafsirSourceProvider = NotifierProvider<TafsirSourceNotifier, String>(
  TafsirSourceNotifier.new,
);

class TafsirSourceNotifier extends Notifier<String> {
  static const _key = 'tafsir_source';

  @override
  String build() =>
      ref.watch(sharedPreferencesProvider).getString(_key) ?? 'saadi';

  Future<void> save(String val) async {
    state = val;
    await ref.read(sharedPreferencesProvider).setString(_key, val);
  }
}

// ─── Hijri offset ─────────────────────────────────────────────────────────

final hijriOffsetProvider = NotifierProvider<HijriOffsetNotifier, int>(
  HijriOffsetNotifier.new,
);

class HijriOffsetNotifier extends Notifier<int> {
  static const _key = 'hijri_offset_days';

  @override
  int build() => ref.watch(sharedPreferencesProvider).getInt(_key) ?? 0;

  Future<void> save(int val) async {
    final clamped = val.clamp(-3, 3);
    state = clamped;
    await ref.read(sharedPreferencesProvider).setInt(_key, clamped);
  }
}

// ─── App settings ─────────────────────────────────────────────────────────

final calculationMethodProvider =
    NotifierProvider<CalculationMethodNotifier, String>(
      CalculationMethodNotifier.new,
    );

class CalculationMethodNotifier extends Notifier<String> {
  @override
  String build() =>
      ref.watch(sharedPreferencesProvider).getString('calculation_method') ??
      'أم القرى';

  Future<void> save(String val) async {
    state = val;
    await ref
        .read(sharedPreferencesProvider)
        .setString('calculation_method', val);
  }
}

// ─── Madhab ───────────────────────────────────────────────────────────────

final madhabProvider = NotifierProvider<MadhabNotifier, String>(
  MadhabNotifier.new,
);

class MadhabNotifier extends Notifier<String> {
  static const _key = 'madhab';

  @override
  String build() =>
      ref.watch(sharedPreferencesProvider).getString(_key) ?? 'شافعي';

  Future<void> save(String val) async {
    state = val;
    await ref.read(sharedPreferencesProvider).setString(_key, val);
  }
}

final appThemeProvider = NotifierProvider<AppThemeNotifier, String>(
  AppThemeNotifier.new,
);

class AppThemeNotifier extends Notifier<String> {
  @override
  String build() =>
      ref.watch(sharedPreferencesProvider).getString('app_theme') ?? 'داكن';

  Future<void> save(String val) async {
    state = val;
    await ref.read(sharedPreferencesProvider).setString('app_theme', val);
  }
}

final appLanguageProvider = NotifierProvider<AppLanguageNotifier, String>(
  AppLanguageNotifier.new,
);

class AppLanguageNotifier extends Notifier<String> {
  @override
  String build() =>
      ref.watch(sharedPreferencesProvider).getString('app_language') ??
      'العربية';

  Future<void> save(String val) async {
    state = val;
    await ref.read(sharedPreferencesProvider).setString('app_language', val);
  }
}

final fontSizeProvider = NotifierProvider<FontSizeNotifier, String>(
  FontSizeNotifier.new,
);

class FontSizeNotifier extends Notifier<String> {
  @override
  String build() =>
      ref.watch(sharedPreferencesProvider).getString('font_size') ?? 'متوسط';

  Future<void> save(String val) async {
    state = val;
    await ref.read(sharedPreferencesProvider).setString('font_size', val);
  }
}

// ─── Onboarding ─────────────────────────────────────────────────────────────

final onboardingCompletedProvider =
    NotifierProvider<OnboardingCompletedNotifier, bool>(
      OnboardingCompletedNotifier.new,
    );

class OnboardingCompletedNotifier extends Notifier<bool> {
  static const _key = 'onboarding_completed';

  @override
  bool build() => ref.watch(sharedPreferencesProvider).getBool(_key) ?? false;

  Future<void> save(bool val) async {
    state = val;
    await ref.read(sharedPreferencesProvider).setBool(_key, val);
  }
}
