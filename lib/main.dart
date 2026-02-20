import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' as intl;
import 'package:quran_library/quran_library.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tafsir_library/tafsir_library.dart';

import 'core/notifications/notifications_service.dart';
import 'core/providers/preferences_provider.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/azkar/data/repositories/azkar_repository.dart';
import 'features/prayer_times/presentation/providers/prayer_times_provider.dart';

// Provider to handle all asynchronous app initializations.
final appStartupProvider = FutureProvider<void>((ref) async {
  await initializeDateFormatting();
  intl.Intl.defaultLocale = 'ar';

  // Core library initializations
  await QuranLibrary.init();
  await NotificationsService.init();

  // Warm-up Muslim data repository (drift SQLite database)
  await AzkarRepository.instance.init();
});

void main() async {
  // Ensure Flutter is ready
  WidgetsFlutterBinding.ensureInitialized();
  
  // Tafsir library — initializes GetX controllers + get_storage internally.
  // We move this to main() to ensure it's registered early and once.
  try {
    await TafsirLibrary.initialize();
  } catch (e) {
    debugPrint('[TafsirLibrary] Init failed: $e');
  }

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startupAsync = ref.watch(appStartupProvider);

    return startupAsync.when(
      loading: () => _buildSimpleSplash(),
      error: (e, st) => _buildErrorScreen(e),
      data: (_) {
        final appTheme = ref.watch(appThemeProvider);
        final appLanguage = ref.watch(appLanguageProvider);
        final appFontSize = ref.watch(fontSizeProvider);

        final themeMode = appTheme == 'فاتح' ? ThemeMode.light : ThemeMode.dark;
        final locale = switch (appLanguage) {
          'English' => const Locale('en'),
          'Français' => const Locale('fr'),
          _ => const Locale('ar'),
        };
        final textScale = switch (appFontSize) {
          'صغير' => 0.92,
          'كبير' => 1.12,
          _ => 1.0,
        };
        final textDirection =
            locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr;

        return MaterialApp.router(
          title: "I'm Muslim",
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          locale: locale,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ar'),
            Locale('en'),
            Locale('fr'),
          ],
          routerConfig: AppRouter.router,
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            return MediaQuery(
              data: mediaQuery.copyWith(
                textScaler: TextScaler.linear(textScale),
              ),
              child: Directionality(
                textDirection: textDirection,
                child: _NotificationScheduler(
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSimpleSplash() {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF11D4B4),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen(Object e) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Error initializing app: $e'),
        ),
      ),
    );
  }
}

/// Watches prayer times and scheduling preferences; reschedules notifications
/// automatically whenever prayer times are loaded or any relevant setting changes.
class _NotificationScheduler extends ConsumerStatefulWidget {
  const _NotificationScheduler({required this.child});

  final Widget child;

  @override
  ConsumerState<_NotificationScheduler> createState() =>
      _NotificationSchedulerState();
}

class _NotificationSchedulerState
    extends ConsumerState<_NotificationScheduler> {
  @override
  void initState() {
    super.initState();
    // Reschedule on first build via a microtask so providers are ready
    Future.microtask(_rescheduleIfEnabled);
  }

  @override
  Widget build(BuildContext context) {
    // Re-schedule whenever prayer times data changes
    ref.listen<AsyncValue<PrayerTimes>>(prayerTimesProvider, (prev, next) {
      if (next is AsyncData<PrayerTimes>) {
        _rescheduleIfEnabled();
      }
    });

    // Re-schedule whenever the global notification toggle changes
    ref.listen<bool>(adhanAlertsProvider, (prev, next) {
      _rescheduleIfEnabled();
    });

    // Re-schedule when calculation method changes (triggers new prayer times)
    ref.listen<String>(calculationMethodProvider, (prev, next) {
      // prayerTimesProvider will automatically update; the listen above handles it
    });

    return widget.child;
  }

  Future<void> _rescheduleIfEnabled() async {
    try {
      final enabled = ref.read(adhanAlertsProvider);
      final locationAsync = ref.read(locationProvider);
      final calcMethodStr = ref.read(calculationMethodProvider);

      locationAsync.whenData((position) {
        final coords =
            Coordinates(position.latitude, position.longitude);
        final params = _buildParams(calcMethodStr);

        final notifSettings = ref.read(prayerNotifSettingsProvider);
        final enabledMap = <Prayer, bool>{
          Prayer.fajr:    enabled && notifSettings.fajrEnabled,
          Prayer.dhuhr:   enabled && notifSettings.dhuhrEnabled,
          Prayer.asr:     enabled && notifSettings.asrEnabled,
          Prayer.maghrib: enabled && notifSettings.maghribEnabled,
          Prayer.isha:    enabled && notifSettings.ishaEnabled,
        };

        final offsetMap = <Prayer, int>{
          Prayer.fajr:    notifSettings.fajrOffset,
          Prayer.dhuhr:   notifSettings.dhuhrOffset,
          Prayer.asr:     notifSettings.asrOffset,
          Prayer.maghrib: notifSettings.maghribOffset,
          Prayer.isha:    notifSettings.ishaOffset,
        };

        NotificationsService.rescheduleAll(
          coordinates: coords,
          calcParams: params,
          enabledMap: enabledMap,
          offsetMinutes: offsetMap,
        );
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[_NotificationScheduler] Reschedule error: $e');
      }
    }
  }

  static CalculationParameters _buildParams(String method) =>
      switch (method) {
        'رابطة العالم الإسلامي' =>
          CalculationMethod.muslim_world_league.getParameters(),
        'الهيئة العامة للمساحة المصرية' =>
          CalculationMethod.egyptian.getParameters(),
        'جامعة العلوم الإسلامية بكراتشي' =>
          CalculationMethod.karachi.getParameters(),
        'الجمعية الإسلامية لأمريكا الشمالية' =>
          CalculationMethod.north_america.getParameters(),
        _ => CalculationMethod.umm_al_qura.getParameters(),
      };
}
