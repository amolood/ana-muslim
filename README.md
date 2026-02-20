# I'm Muslim

A production-ready Flutter application focused on daily Islamic worship needs, including Quran reading, prayer times, Qibla direction, adhkar, hadith browsing, and personalization.

## Overview

This project is built as a multi-platform Flutter app (Android, iOS, Web, Desktop). The codebase follows a feature-based modular structure with Riverpod state management and GoRouter navigation.

## Core Features

- Quran index and reader with verse selection, tafsir bottom sheet, reciter selection, and audio playback.
- Prayer times calculated from user location with configurable calculation methods and adjustments.
- Adhan notifications with per-prayer toggles, offsets, and automatic rescheduling.
- Qibla direction support using device sensors.
- Adhkar browsing and categories.
- Hadith browsing (Sahih al-Bukhari and Sahih Muslim) and search flows.
- Sebha counter.
- Home screen with current date (Hijri and Gregorian), next-prayer countdown, and quick actions.
- Home widget integration and shared state for widget content.
- App settings for theme, language, Quran font size, default reciter, Hijri settings, and notification settings.

## Architecture

- Pattern: Feature-first modular architecture.
- State management: `flutter_riverpod`.
- Routing: `go_router` with shell navigation branches.
- Persistence: `shared_preferences` + package-provided local data stores.
- Time and calendar logic: `adhan`, `timezone`, `hijri`, `intl`.
- Notifications: `flutter_local_notifications`.

### Project Structure

```text
lib/
  core/
    notifications/
    providers/
    routing/
    services/
    theme/
    utils/
  features/
    azkar/
    debug/
    hadith/
    home/
    prayer_times/
    qibla/
    quran/
    sebha/
    settings/
    splash/
assets/
  azkar.json
```

## Prerequisites

- Flutter `3.41.1` (stable)
- Dart `3.11.0`
- Android Studio / Xcode (for mobile targets)

## Getting Started

```bash
git clone https://github.com/amolood/ana-muslim.git
cd ana-muslim
flutter pub get
flutter run
```

## Useful Commands

```bash
# Static analysis
flutter analyze

# Tests
flutter test

# Build examples
flutter build apk
flutter build appbundle
flutter build ios
flutter build web
```

## Packages, Versions, and URLs

Versions below are the currently locked versions from `pubspec.lock`.

### Direct Runtime Dependencies

| Package | Version | URL |
|---|---:|---|
| flutter | 0.0.0 (SDK) | [https://docs.flutter.dev/](https://docs.flutter.dev/) |
| flutter_localizations | 0.0.0 (SDK) | [https://api.flutter.dev/flutter/flutter_localizations/flutter_localizations-library.html](https://api.flutter.dev/flutter/flutter_localizations/flutter_localizations-library.html) |
| cupertino_icons | 1.0.8 | [https://pub.dev/packages/cupertino_icons](https://pub.dev/packages/cupertino_icons) |
| flutter_riverpod | 3.2.1 | [https://pub.dev/packages/flutter_riverpod](https://pub.dev/packages/flutter_riverpod) |
| go_router | 17.1.0 | [https://pub.dev/packages/go_router](https://pub.dev/packages/go_router) |
| geolocator | 14.0.2 | [https://pub.dev/packages/geolocator](https://pub.dev/packages/geolocator) |
| flutter_qiblah | 3.2.0 | [https://pub.dev/packages/flutter_qiblah](https://pub.dev/packages/flutter_qiblah) |
| adhan | 2.0.0+1 | [https://pub.dev/packages/adhan](https://pub.dev/packages/adhan) |
| google_fonts | 8.0.2 | [https://pub.dev/packages/google_fonts](https://pub.dev/packages/google_fonts) |
| shared_preferences | 2.5.4 | [https://pub.dev/packages/shared_preferences](https://pub.dev/packages/shared_preferences) |
| flutter_svg | 2.2.3 | [https://pub.dev/packages/flutter_svg](https://pub.dev/packages/flutter_svg) |
| intl | 0.20.2 | [https://pub.dev/packages/intl](https://pub.dev/packages/intl) |
| geocoding | 4.0.0 | [https://pub.dev/packages/geocoding](https://pub.dev/packages/geocoding) |
| quran_library | 3.0.1 | [https://pub.dev/packages/quran_library](https://pub.dev/packages/quran_library) |
| share_plus | 12.0.1 | [https://pub.dev/packages/share_plus](https://pub.dev/packages/share_plus) |
| hijri | 3.0.0 | [https://pub.dev/packages/hijri](https://pub.dev/packages/hijri) |
| muslim_data_flutter | 1.5.0 | [https://pub.dev/packages/muslim_data_flutter](https://pub.dev/packages/muslim_data_flutter) |
| flutter_local_notifications | 20.1.0 | [https://pub.dev/packages/flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) |
| flutter_timezone | 5.0.1 | [https://pub.dev/packages/flutter_timezone](https://pub.dev/packages/flutter_timezone) |
| timezone | 0.10.1 | [https://pub.dev/packages/timezone](https://pub.dev/packages/timezone) |
| hadith | 1.0.1 | [https://pub.dev/packages/hadith](https://pub.dev/packages/hadith) |
| http | 1.6.0 | [https://pub.dev/packages/http](https://pub.dev/packages/http) |
| just_audio | 0.10.5 | [https://pub.dev/packages/just_audio](https://pub.dev/packages/just_audio) |
| path_provider | 2.1.5 | [https://pub.dev/packages/path_provider](https://pub.dev/packages/path_provider) |
| home_widget | 0.7.0+1 | [https://pub.dev/packages/home_widget](https://pub.dev/packages/home_widget) |
| url_launcher | 6.3.2 | [https://pub.dev/packages/url_launcher](https://pub.dev/packages/url_launcher) |

### Direct Development Dependencies

| Package | Version | URL |
|---|---:|---|
| flutter_test | 0.0.0 (SDK) | [https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html](https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html) |
| flutter_lints | 6.0.0 | [https://pub.dev/packages/flutter_lints](https://pub.dev/packages/flutter_lints) |

### Dependency Overrides

| Package | Version | URL |
|---|---:|---|
| get | 4.7.3 | [https://pub.dev/packages/get](https://pub.dev/packages/get) |
| get_storage | 2.1.1 | [https://pub.dev/packages/get_storage](https://pub.dev/packages/get_storage) |

## License

This project is licensed under the **Zero-Clause BSD (0BSD)** license.

- You can use, modify, distribute, and commercialize this software.
- No attribution is required.

See `LICENSE` for full legal text.
