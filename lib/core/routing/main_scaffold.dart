import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/l10n.dart';
import '../providers/navigation_provider.dart';
import '../theme/app_colors.dart';

class MainScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _buildBottomNav(context, ref),
    );
  }

  Widget _buildBottomNav(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context).withValues(alpha: 0.97),
        border: Border(
          top: BorderSide(color: AppColors.border(context), width: 1.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context, ref,
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: context.l10n.navHome,
                index: 0,
              ),
              _buildNavItem(
                context, ref,
                icon: FlutterIslamicIcons.quran,
                label: context.l10n.navQuran,
                index: 1,
              ),
              _buildNavItem(
                context, ref,
                icon: Icons.explore_outlined,
                activeIcon: Icons.explore_rounded,
                label: context.l10n.navQibla,
                index: 2,
              ),
              _buildNavItem(
                context, ref,
                icon: FlutterIslamicIcons.mohammad,
                label: context.l10n.navHadith,
                index: 3,
              ),
              _buildNavItem(
                context, ref,
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings_rounded,
                label: context.l10n.navSettings,
                index: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    IconData? activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = navigationShell.currentIndex == index;
    final displayIcon = isActive ? (activeIcon ?? icon) : icon;

    return GestureDetector(
      onTap: () {
        ref.read(activeBranchIndexProvider.notifier).setIndex(index);
        navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: isActive ? 16 : 0,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                displayIcon,
                color: isActive
                    ? AppColors.primary
                    : AppColors.textSecondary(context),
                size: 24,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive
                    ? AppColors.primary
                    : AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
