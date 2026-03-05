import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks which bottom-nav branch is currently active (0-indexed).
/// Updated by [MainScaffold] on every tab press so that screens in
/// persistent branches (StatefulShellRoute.indexedStack) can react to
/// becoming visible or hidden without relying on dispose().
class _ActiveBranchNotifier extends Notifier<int> {
  @override
  int build() => 0; // starts on Home
  void setIndex(int i) => state = i;
}

final activeBranchIndexProvider =
    NotifierProvider<_ActiveBranchNotifier, int>(_ActiveBranchNotifier.new);

/// Index of the Qibla branch in the StatefulShellRoute.
const kQiblaBranchIndex = 2;
