import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../network/fast_api_client.dart';

enum VersionStatus { upToDate, updateAvailable, forceUpdate }

class AppVersionInfo {
  final VersionStatus status;
  final String latestVersion;
  final String storeUrlAndroid;
  final String storeUrlIos;
  final String messageAr;
  final String messageEn;
  final String messageFr;

  const AppVersionInfo({
    required this.status,
    required this.latestVersion,
    required this.storeUrlAndroid,
    required this.storeUrlIos,
    required this.messageAr,
    required this.messageEn,
    required this.messageFr,
  });

  String get storeUrl => Platform.isIOS ? storeUrlIos : storeUrlAndroid;

  String messageForLocale(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return messageAr.isNotEmpty ? messageAr : messageEn;
      case 'fr':
        return messageFr.isNotEmpty ? messageFr : messageEn;
      default:
        return messageEn.isNotEmpty ? messageEn : messageAr;
    }
  }
}

/// Returns null if the check fails (network error, timeout) — never blocks the user.
final appVersionCheckProvider = FutureProvider<AppVersionInfo?>((ref) async {
  try {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;

    const apiBaseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://anaalmuslim.com/api',
    );
    final uri = Uri.parse('$apiBaseUrl/app-version');

    final data = await FastApiClient.instance.getJson(
      uri,
      timeout: const Duration(seconds: 5),
      ttl: Duration.zero,
      forceRefresh: true,
    ) as Map<String, dynamic>;

    final latestVersion = data['latest_version'] as String? ?? '1.0.0';
    final minVersion = data['min_version'] as String? ?? '1.0.0';
    final forceUpdateFlag = data['force_update'] as bool? ?? false;
    final storeUrlAndroid = data['store_url_android'] as String? ?? '';
    final storeUrlIos = data['store_url_ios'] as String? ?? '';
    final messageAr = data['message_ar'] as String? ?? '';
    final messageEn = data['message_en'] as String? ?? '';
    final messageFr = data['message_fr'] as String? ?? '';

    final isBelowMin = _isVersionBelow(currentVersion, minVersion);
    final isBelowLatest = _isVersionBelow(currentVersion, latestVersion);

    final VersionStatus status;
    if (forceUpdateFlag || isBelowMin) {
      status = VersionStatus.forceUpdate;
    } else if (isBelowLatest) {
      status = VersionStatus.updateAvailable;
    } else {
      status = VersionStatus.upToDate;
    }

    return AppVersionInfo(
      status: status,
      latestVersion: latestVersion,
      storeUrlAndroid: storeUrlAndroid,
      storeUrlIos: storeUrlIos,
      messageAr: messageAr,
      messageEn: messageEn,
      messageFr: messageFr,
    );
  } catch (e) {
    if (kDebugMode) debugPrint('[AppVersion] check failed: $e');
    return null;
  }
});

/// Returns true if [current] is strictly below [target] using semver comparison.
bool _isVersionBelow(String current, String target) {
  final curr = _parseSemver(current);
  final targ = _parseSemver(target);
  for (int i = 0; i < 3; i++) {
    final c = i < curr.length ? curr[i] : 0;
    final t = i < targ.length ? targ[i] : 0;
    if (c < t) return true;
    if (c > t) return false;
  }
  return false;
}

List<int> _parseSemver(String version) {
  return version
      .split('.')
      .map((s) => int.tryParse(s.trim()) ?? 0)
      .toList();
}
