import 'package:audio_service/audio_service.dart';

import 'quran_audio_handler.dart';

/// Initialise [AudioService] once in [main], **before** [runApp].
///
/// Returns the singleton [QuranAudioHandler] that must be injected into the
/// widget tree via a [ProviderScope] override so that every provider can reach
/// it synchronously:
///
/// ```dart
/// final handler = await initAudioService();
/// runApp(ProviderScope(
///   overrides: [quranAudioHandlerProvider.overrideWithValue(handler)],
///   child: const MyApp(),
/// ));
/// ```
Future<QuranAudioHandler> initAudioService() async {
  return AudioService.init<QuranAudioHandler>(
    builder: QuranAudioHandler.new,
    config: const AudioServiceConfig(
      // ── Android notification channel ────────────────────────────────────
      // Channel ID is globally unique per app. The name appears in the
      // system's "App notifications" settings page.
      androidNotificationChannelId: 'com.anaalmuslim.app.audio',
      androidNotificationChannelName: 'تلاوة القرآن الكريم',
      androidNotificationChannelDescription: 'يعرض معلومات السورة وأدوات التحكم في التشغيل',

      // Small icon shown in the status bar and at the top of the notification.
      // Must refer to a drawable/mipmap resource inside the Android project.
      androidNotificationIcon: 'mipmap/ic_launcher',

      // ── Foreground service lifecycle ─────────────────────────────────────
      // ongoing: true  → notification cannot be swiped away while the
      //                   foreground service is running (i.e., while playing).
      // stopForegroundOnPause: true → when the user pauses, audio_service calls
      //                   stopForeground(), making the notification dismissible.
      //                   This satisfies Google Play's requirement that the
      //                   foreground service is active only during audible playback.
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,

      // Tapping the notification body reopens the app (standard media UX).
      androidResumeOnClick: true,
    ),
  );
}
