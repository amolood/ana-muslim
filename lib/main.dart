import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' as intl;
import 'package:quran_library/quran_library.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/notifications/notifications_service.dart';
import 'core/providers/preferences_provider.dart';
import 'core/routing/app_router.dart';
import 'core/services/pusher_service.dart';
import 'core/services/widget_service.dart';
import 'core/theme/app_theme.dart';
import 'features/prayer_times/presentation/providers/prayer_times_provider.dart';

// Provider to handle all asynchronous app initializations.
final appStartupProvider = FutureProvider<void>((ref) async {
  await initializeDateFormatting();
  await QuranLibrary.init();
  await Future.wait<void>([
    NotificationsService.init(),
    WidgetService.initialize(),
    PusherService.init(), // تهيئة Pusher
  ]);
  intl.Intl.defaultLocale = 'ar';
});

void main() async {
  // Ensure Flutter is ready
  WidgetsFlutterBinding.ensureInitialized();

  // تحميل متغيرات البيئة من ملف .env
  await dotenv.load(fileName: '.env');

  final sharedPreferences = await SharedPreferences.getInstance();

  // تهيئة صوت الأذان من الإعدادات المحفوظة
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
    ],
  );
  final adhanSound = container.read(adhanSoundOptionProvider);
  NotificationsService.setAdhanSound(adhanSound.androidResourceName);
  container.dispose();

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
        final textDirection = locale.languageCode == 'ar'
            ? TextDirection.rtl
            : TextDirection.ltr;

        return MaterialApp.router(
          title: "انا المسلم",
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
          supportedLocales: const [Locale('ar'), Locale('en'), Locale('fr')],
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
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF11D4B4)),
        ),
      ),
    );
  }

  Widget _buildErrorScreen(Object e) {
    return MaterialApp(
      home: Scaffold(body: Center(child: Text('Error initializing app: $e'))),
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

class _NotificationSchedulerState extends ConsumerState<_NotificationScheduler>
    with WidgetsBindingObserver {
  ProviderSubscription<AsyncValue<PrayerTimes>>? _prayerTimesSub;
  ProviderSubscription<bool>? _adhanToggleSub;
  ProviderSubscription<PrayerNotifSettings>? _prayerSettingsSub;
  ProviderSubscription<PrayerManualExactSettings>? _manualPrayerExactSub;
  ProviderSubscription<PrayerManualOffsets>? _manualPrayerOffsetSub;
  ProviderSubscription<String>? _calcMethodSub;
  ProviderSubscription<MotivationReminderSettings>? _motivationSub;
  Timer? _prayerRescheduleDebounce;
  Timer? _locationRefreshTimer;
  bool _isPrayerRescheduleRunning = false;
  bool _hasPendingPrayerReschedule = false;
  String? _lastPrayerScheduleSignature;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() {
      _bindListeners();
      _startLocationRefreshTimer();
      _requestPrayerReschedule(delay: Duration.zero);
      _rescheduleMotivationReminders(ref.read(motivationReminderProvider));
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _prayerRescheduleDebounce?.cancel();
    _locationRefreshTimer?.cancel();
    _prayerTimesSub?.close();
    _adhanToggleSub?.close();
    _prayerSettingsSub?.close();
    _manualPrayerExactSub?.close();
    _manualPrayerOffsetSub?.close();
    _calcMethodSub?.close();
    _motivationSub?.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    _refreshLocationAndPrayerTimes();
    _requestPrayerReschedule(delay: Duration.zero);
  }

  void _bindListeners() {
    _prayerTimesSub = ref.listenManual<AsyncValue<PrayerTimes>>(
      prayerTimesProvider,
      (previous, next) {
        if (next is AsyncData<PrayerTimes>) {
          _requestPrayerReschedule();
        }
      },
    );

    _adhanToggleSub = ref.listenManual<bool>(adhanAlertsProvider, (
      previous,
      next,
    ) {
      _requestPrayerReschedule();
    });

    _prayerSettingsSub = ref.listenManual<PrayerNotifSettings>(
      prayerNotifSettingsProvider,
      (previous, next) {
        _requestPrayerReschedule();
      },
    );

    _manualPrayerExactSub = ref.listenManual<PrayerManualExactSettings>(
      prayerManualExactSettingsProvider,
      (previous, next) {
        _requestPrayerReschedule();
      },
    );

    _manualPrayerOffsetSub = ref.listenManual<PrayerManualOffsets>(
      prayerManualOffsetsProvider,
      (previous, next) {
        _requestPrayerReschedule();
      },
    );

    _calcMethodSub = ref.listenManual<String>(calculationMethodProvider, (
      previous,
      next,
    ) {
      _requestPrayerReschedule();
    });

    _motivationSub = ref.listenManual<MotivationReminderSettings>(
      motivationReminderProvider,
      (previous, next) {
        _rescheduleMotivationReminders(next);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void _requestPrayerReschedule({
    Duration delay = const Duration(milliseconds: 400),
  }) {
    _prayerRescheduleDebounce?.cancel();
    _prayerRescheduleDebounce = Timer(delay, _runPrayerRescheduleIfNeeded);
  }

  void _startLocationRefreshTimer() {
    _locationRefreshTimer?.cancel();
    _locationRefreshTimer = Timer.periodic(const Duration(minutes: 30), (_) {
      _refreshLocationAndPrayerTimes();
      _requestPrayerReschedule(delay: Duration.zero);
    });
  }

  void _refreshLocationAndPrayerTimes() {
    final manualExact = ref.read(prayerManualExactSettingsProvider);
    if (manualExact.enabled) {
      return;
    }
    ref.invalidate(locationProvider);
    ref.invalidate(prayerTimesProvider);
  }

  Future<void> _runPrayerRescheduleIfNeeded() async {
    if (_isPrayerRescheduleRunning) {
      _hasPendingPrayerReschedule = true;
      return;
    }

    _isPrayerRescheduleRunning = true;
    try {
      do {
        _hasPendingPrayerReschedule = false;
        final signature = await _rescheduleIfEnabled();
        if (signature != null) {
          _lastPrayerScheduleSignature = signature;
        }
      } while (_hasPendingPrayerReschedule);
    } finally {
      _isPrayerRescheduleRunning = false;
    }
  }

  String _buildPrayerScheduleSignature({
    required PrayerManualExactSettings manualExact,
    double? latitude,
    double? longitude,
  }) {
    final enabled = ref.read(adhanAlertsProvider);
    final notif = ref.read(prayerNotifSettingsProvider);
    final manualOffsets = ref.read(prayerManualOffsetsProvider);
    final calcMethod = ref.read(calculationMethodProvider);
    final now = DateTime.now();
    final dayKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final manualExactPart = manualExact.enabled
        ? 'exact:1:${manualExact.fajr.hour}:${manualExact.fajr.minute}:${manualExact.dhuhr.hour}:${manualExact.dhuhr.minute}:${manualExact.asr.hour}:${manualExact.asr.minute}:${manualExact.maghrib.hour}:${manualExact.maghrib.minute}:${manualExact.isha.hour}:${manualExact.isha.minute}'
        : 'exact:0';
    final locationPart = latitude == null || longitude == null
        ? 'loc:none'
        : 'loc:${latitude.toStringAsFixed(2)},${longitude.toStringAsFixed(2)}';

    return [
      'day:$dayKey',
      'enabled:$enabled',
      'calc:$calcMethod',
      'notif:${notif.fajrEnabled}:${notif.fajrOffset}:${notif.dhuhrEnabled}:${notif.dhuhrOffset}:${notif.asrEnabled}:${notif.asrOffset}:${notif.maghribEnabled}:${notif.maghribOffset}:${notif.ishaEnabled}:${notif.ishaOffset}',
      manualExactPart,
      'adj:${manualOffsets.fajr}:${manualOffsets.sunrise}:${manualOffsets.dhuhr}:${manualOffsets.asr}:${manualOffsets.maghrib}:${manualOffsets.isha}',
      locationPart,
    ].join('|');
  }

  Future<String?> _rescheduleIfEnabled() async {
    try {
      final manualExact = ref.read(prayerManualExactSettingsProvider);
      String scheduleSignature;
      Position? position;
      if (manualExact.enabled) {
        scheduleSignature = _buildPrayerScheduleSignature(
          manualExact: manualExact,
        );
      } else {
        position = await ref.read(locationProvider.future);
        scheduleSignature = _buildPrayerScheduleSignature(
          manualExact: manualExact,
          latitude: position!.latitude,
          longitude: position.longitude,
        );
      }
      if (scheduleSignature == _lastPrayerScheduleSignature) {
        return scheduleSignature;
      }

      final prefs = ref.read(sharedPreferencesProvider);
      final savedSignature = prefs.getString('prayer_schedule_signature_v1');
      if (savedSignature == scheduleSignature) {
        return scheduleSignature;
      }

      final enabled = ref.read(adhanAlertsProvider);
      final notifSettings = ref.read(prayerNotifSettingsProvider);
      final enabledMap = <Prayer, bool>{
        Prayer.fajr: enabled && notifSettings.fajrEnabled,
        Prayer.dhuhr: enabled && notifSettings.dhuhrEnabled,
        Prayer.asr: enabled && notifSettings.asrEnabled,
        Prayer.maghrib: enabled && notifSettings.maghribEnabled,
        Prayer.isha: enabled && notifSettings.ishaEnabled,
      };

      final offsetMap = <Prayer, int>{
        Prayer.fajr: notifSettings.fajrOffset,
        Prayer.dhuhr: notifSettings.dhuhrOffset,
        Prayer.asr: notifSettings.asrOffset,
        Prayer.maghrib: notifSettings.maghribOffset,
        Prayer.isha: notifSettings.ishaOffset,
      };

      if (manualExact.enabled) {
        final now = DateTime.now();
        await NotificationsService.rescheduleManualPrayerTimes(
          enabledMap: enabledMap,
          manualTimes: <Prayer, DateTime>{
            Prayer.fajr: manualExact.dateTimeFor(Prayer.fajr, now),
            Prayer.dhuhr: manualExact.dateTimeFor(Prayer.dhuhr, now),
            Prayer.asr: manualExact.dateTimeFor(Prayer.asr, now),
            Prayer.maghrib: manualExact.dateTimeFor(Prayer.maghrib, now),
            Prayer.isha: manualExact.dateTimeFor(Prayer.isha, now),
          },
          offsetMinutes: offsetMap,
          scheduleSignature: scheduleSignature,
        );
      } else {
        final currentPosition = position!;
        final calcMethodStr = ref.read(calculationMethodProvider);
        final coords = Coordinates(
          currentPosition.latitude,
          currentPosition.longitude,
        );
        final params = _buildParams(calcMethodStr);
        final prayerAdjust = ref.read(prayerManualOffsetsProvider);

        await NotificationsService.rescheduleAll(
          coordinates: coords,
          calcParams: params,
          enabledMap: enabledMap,
          prayerAdjustMinutes: <Prayer, int>{
            Prayer.fajr: prayerAdjust.fajr,
            Prayer.dhuhr: prayerAdjust.dhuhr,
            Prayer.asr: prayerAdjust.asr,
            Prayer.maghrib: prayerAdjust.maghrib,
            Prayer.isha: prayerAdjust.isha,
          },
          offsetMinutes: offsetMap,
          scheduleSignature: scheduleSignature,
        );
      }
      await prefs.setString('prayer_schedule_signature_v1', scheduleSignature);
      return scheduleSignature;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[_NotificationScheduler] Reschedule error: $e');
      }
      return null;
    }
  }

  Future<void> _rescheduleMotivationReminders(
    MotivationReminderSettings settings,
  ) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final now = DateTime.now();
    final dayKey = '${now.year}-${now.month}-${now.day}';
    final signature =
        '${settings.enabled}:${settings.startHour}:${settings.endHour}:${settings.remindersPerDay}:$dayKey';
    final savedSignature = prefs.getString('motivation_schedule_signature_v1');
    if (savedSignature == signature) return;

    try {
      await NotificationsService.scheduleMotivationReminders(
        enabled: settings.enabled,
        startHour: settings.startHour,
        endHour: settings.endHour,
        remindersPerDay: settings.remindersPerDay,
      );
      await prefs.setString('motivation_schedule_signature_v1', signature);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[_NotificationScheduler] Motivation schedule error: $e');
      }
    }
  }

  static CalculationParameters _buildParams(String method) => switch (method) {
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
