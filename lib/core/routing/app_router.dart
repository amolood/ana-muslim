import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/prayer_times/presentation/screens/prayer_times_screen.dart';
import '../../features/qibla/presentation/screens/qibla_screen.dart';
import '../../features/azkar/presentation/screens/azkar_screen.dart';
import '../../features/sebha/presentation/screens/sebha_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/notification_settings_screen.dart';
import '../../features/settings/presentation/screens/hijri_settings_screen.dart';
import '../../features/quran/presentation/screens/quran_index_screen.dart';
import '../../features/quran/presentation/screens/quran_reader_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/debug/presentation/screens/debug_screen.dart';
import 'main_scaffold.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final _shellNavigatorQuranKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellQuran');
final _shellNavigatorQiblaKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellQibla');
final _shellNavigatorSettingsKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellSettings');

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
      // ─── Debug (root, only in debug builds) ──────────────────
      if (kDebugMode)
        GoRoute(
          path: '/debug',
          name: 'debug',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const DebugScreen(),
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
                    path: 'reader/:id',
                    name: 'quran_reader',
                    builder: (context, state) {
                      final id =
                          int.parse(state.pathParameters['id']!);
                      final ayahParam =
                          state.uri.queryParameters['ayah'];
                      final ayah = ayahParam == null
                          ? null
                          : int.tryParse(ayahParam);
                      return QuranReaderScreen(
                        surahNumber: id,
                        initialVerse: ayah,
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
                    builder: (context, state) =>
                        const HijriSettingsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.uri}'),
      ),
    ),
  );
}
