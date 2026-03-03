import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Lazily loads app version metadata (name, version, build number, etc.).
/// Safe to watch in widgets — resolves once per app lifecycle.
final packageInfoProvider = FutureProvider<PackageInfo>(
  (ref) => PackageInfo.fromPlatform(),
);
