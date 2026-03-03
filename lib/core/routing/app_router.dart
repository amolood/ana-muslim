import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/worship_stats_screen.dart';
import '../../features/prayer_times/presentation/screens/prayer_times_screen.dart';
import '../../features/qibla/presentation/screens/qibla_screen.dart';
import '../../features/azkar/presentation/screens/azkar_screen.dart';
import '../../features/sebha/presentation/screens/sebha_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/notification_settings_screen.dart';
import '../../features/settings/presentation/screens/hijri_settings_screen.dart';
import '../../features/settings/presentation/screens/prayer_adjustment_screen.dart';
import '../../features/settings/presentation/screens/default_reciter_screen.dart';
import '../../features/settings/presentation/screens/prayer_silence_screen.dart';
import '../../features/settings/presentation/screens/widget_settings_screen.dart';
import '../../features/settings/presentation/screens/widget_detail_settings_screen.dart';
import '../../core/providers/widget_settings_provider.dart';
import '../../features/quran/presentation/screens/quran_index_screen.dart';
import '../../features/quran/presentation/screens/quran_reader_screen.dart';
import '../../features/quran/presentation/screens/quran_search_screen.dart';
import '../../features/quran/presentation/widgets/bookmarks_view.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/hadith/presentation/screens/hadith_screen.dart';
import '../../features/hadith/presentation/screens/hadith_book_screen.dart';
import '../../features/hadith/presentation/screens/hadith_search_screen.dart';
import '../../features/islamic_content/presentation/screens/islamic_content_detail_screen.dart';
import '../../features/islamic_content/presentation/screens/islamic_content_hub_screen.dart';
import '../../features/islamic_content/presentation/screens/islamic_content_list_screen.dart';
import '../../features/khatmah/presentation/screens/khatmah_screen.dart';
import '../../features/tahfeez/presentation/screens/tahfeez_screen.dart';
import '../../features/adhan_player/presentation/screens/adhan_player_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/ramadan/presentation/screens/ramadan_screen.dart';
import 'main_scaffold.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(
  debugLabel: 'shellHome',
);
final _shellNavigatorQuranKey = GlobalKey<NavigatorState>(
  debugLabel: 'shellQuran',
);
final _shellNavigatorQiblaKey = GlobalKey<NavigatorState>(
  debugLabel: 'shellQibla',
);
final _shellNavigatorHadithKey = GlobalKey<NavigatorState>(
  debugLabel: 'shellHadith',
);
final _shellNavigatorSettingsKey = GlobalKey<NavigatorState>(
  debugLabel: 'shellSettings',
);

class AppRouter {
  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      // ─── Splash ──────────────────────────────────────────────
      GoRoute(
        path: '/',
        name: 'splash',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OnboardingScreen(),
      ),
      // ─── Adhan player (full-screen, above bottom nav) ──────
      GoRoute(
        path: '/adhan-player',
        name: 'adhan_player',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final prayerName =
              state.uri.queryParameters['prayer'] ?? '';
          return AdhanPlayerScreen(prayerName: prayerName);
        },
      ),
      // ─── Main shell ───────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Home
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'worship-stats',
                    name: 'worship_stats',
                    builder: (context, state) => const WorshipStatsScreen(),
                  ),
                ],
              ),
            ],
          ),
          // Quran
          StatefulShellBranch(
            navigatorKey: _shellNavigatorQuranKey,
            routes: [
              GoRoute(
                path: '/quran',
                name: 'quran_index',
                builder: (context, state) => const QuranIndexScreen(),
                routes: [
                  GoRoute(
                    path: 'khatmah',
                    name: 'khatmah',
                    builder: (context, state) => const KhatmahScreen(),
                  ),
                  GoRoute(
                    path: 'tahfeez',
                    name: 'tahfeez',
                    builder: (context, state) => const TahfeezScreen(),
                  ),
                  GoRoute(
                    path: 'bookmarks',
                    name: 'quran_bookmarks',
                    builder: (context, state) => const Scaffold(
                      body: BookmarksView(),
                    ),
                  ),
                  GoRoute(
                    path: 'search',
                    name: 'quran_search',
                    builder: (context, state) => const QuranSearchScreen(),
                  ),
                  GoRoute(
                    path: 'reader/:id',
                    name: 'quran_reader',
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters['id']!);
                      final ayahParam = state.uri.queryParameters['ayah'];
                      final ayah = ayahParam == null
                          ? null
                          : int.tryParse(ayahParam);
                      final pageParam = state.uri.queryParameters['page'];
                      final page = pageParam == null
                          ? null
                          : int.tryParse(pageParam);
                      return QuranReaderScreen(
                        surahNumber: id,
                        initialVerse: ayah,
                        initialPage: page,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          // Qibla + feature screens
          StatefulShellBranch(
            navigatorKey: _shellNavigatorQiblaKey,
            routes: [
              GoRoute(
                path: '/qibla',
                name: 'qibla',
                builder: (context, state) => const QiblaScreen(),
              ),
              GoRoute(
                path: '/prayer-times',
                name: 'prayer_times',
                builder: (context, state) => const PrayerTimesScreen(),
              ),
              GoRoute(
                path: '/azkar',
                name: 'azkar',
                builder: (context, state) => const AzkarScreen(),
              ),
              GoRoute(
                path: '/sebha',
                name: 'sebha',
                builder: (context, state) => const SebhaScreen(),
              ),
              GoRoute(
                path: '/ramadan',
                name: 'ramadan',
                builder: (context, state) => const RamadanScreen(),
              ),
            ],
          ),
          // Hadith (Sahihain)
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHadithKey,
            routes: [
              GoRoute(
                path: '/hadith',
                name: 'hadith',
                builder: (context, state) => const HadithScreen(),
                routes: [
                  GoRoute(
                    path: 'search',
                    name: 'hadith_search',
                    builder: (context, state) => const HadithSearchScreen(),
                  ),
                  GoRoute(
                    path: 'islamic-content',
                    name: 'islamic_content_hub',
                    builder: (context, state) =>
                        const IslamicContentHubScreen(),
                  ),
                  GoRoute(
                    path: 'islamic-content/type/:type',
                    name: 'islamic_content_type',
                    builder: (context, state) {
                      final type = state.pathParameters['type'] ?? 'showall';
                      final title =
                          state.uri.queryParameters['title'] ??
                          'المحتوى الإسلامي';
                      return IslamicContentListScreen(type: type, title: title);
                    },
                  ),
                  GoRoute(
                    path: 'islamic-content/item/:id',
                    name: 'islamic_content_detail',
                    builder: (context, state) {
                      final idRaw = state.pathParameters['id'];
                      final id = int.tryParse(idRaw ?? '');
                      return IslamicContentDetailScreen(itemId: id ?? 0);
                    },
                  ),
                  GoRoute(
                    path: 'book',
                    name: 'hadith_book',
                    builder: (context, state) {
                      final args = state.extra as HadithBookArgs;
                      return HadithBookScreen(args: args);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Settings
          StatefulShellBranch(
            navigatorKey: _shellNavigatorSettingsKey,
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'notifications',
                    name: 'notification_settings',
                    builder: (context, state) =>
                        const NotificationSettingsScreen(),
                  ),
                  GoRoute(
                    path: 'hijri',
                    name: 'hijri_settings',
                    builder: (context, state) => const HijriSettingsScreen(),
                  ),
                  GoRoute(
                    path: 'prayer-adjustment',
                    name: 'prayer_adjustment',
                    builder: (context, state) => const PrayerAdjustmentScreen(),
                  ),
                  GoRoute(
                    path: 'default-reciter',
                    name: 'default_reciter',
                    builder: (context, state) => const DefaultReciterScreen(),
                  ),
                  GoRoute(
                    path: 'prayer-silence',
                    name: 'prayer_silence',
                    builder: (context, state) => const PrayerSilenceScreen(),
                  ),
                  GoRoute(
                    path: 'widgets',
                    name: 'widget_settings',
                    builder: (context, state) => const WidgetSettingsScreen(),
                    routes: [
                      GoRoute(
                        path: ':type',
                        name: 'widget_detail_settings',
                        builder: (context, state) {
                          final type = WidgetType.values.byName(
                            state.pathParameters['type']!,
                          );
                          return WidgetDetailSettingsScreen(widgetType: type);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Route not found: ${state.uri}'))),
  );
}
