import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/l10n.dart';
import '../theme/app_colors.dart';

class MainScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
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
                context,
                icon: Icons.home,
                label: context.l10n.navHome,
                index: 0,
              ),
              _buildNavItem(
                context,
                icon: FlutterIslamicIcons.quran,
                label: context.l10n.navQuran,
                index: 1,
              ),
              _buildNavItem(
                context,
                icon: FlutterIslamicIcons.qibla,
                label: context.l10n.navQibla,
                index: 2,
              ),
              _buildNavItem(
                context,
                icon: FlutterIslamicIcons.mohammad,
                label: context.l10n.navHadith,
                index: 3,
              ),
              _buildNavItem(
                context,
                icon: Icons.settings,
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
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isActive = navigationShell.currentIndex == index;

    return GestureDetector(
      onTap: () {
        navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Icon(
                icon,
                color: isActive
                    ? AppColors.primary
                    : AppColors.textSecondary(context),
                size: 26,
              ),
              if (isActive)
                Positioned(
                  bottom: -8,
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.tajawal(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isActive
                  ? AppColors.textPrimary(context)
                  : AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}
