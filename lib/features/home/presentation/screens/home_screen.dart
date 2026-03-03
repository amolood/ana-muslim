import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routing/routes.dart';

import '../../../../core/permissions/permissions_provider.dart';
import '../../../../core/permissions/permissions_screen.dart';
import '../../../../core/providers/clock_provider.dart';
import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../khatmah/presentation/providers/khatmah_controller.dart';
import '../widgets/continue_reading_card.dart';
import '../widgets/daily_wird_section.dart';
import '../widgets/motivation_stats_card.dart';
import '../widgets/now_playing_card.dart';
import '../widgets/prayer_times_card.dart';
import '../widgets/quick_actions_grid.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late DateTime _lastDayMarker;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _lastDayMarker = DateTime(now.year, now.month, now.day);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(prayerDailyProgressProvider.notifier).ensureToday();
      ref.read(sebhaStateProvider.notifier).ensureToday();
      _checkAndShowPermissions();
    });
  }

  Future<void> _checkAndShowPermissions() async {
    final permissionsAsync = ref.read(permissionsCheckedProvider);
    final allGranted = permissionsAsync.whenOrNull(
      data: (value) => value,
    );

    if (allGranted == false && mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const PermissionsScreen(),
          fullscreenDialog: true,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Day-rollover: invalidate providers at midnight using the shared clock.
    ref.listen<AsyncValue<DateTime>>(clockProvider, (_, next) {
      if (!mounted) return;
      next.whenData((current) {
        final dayMarker = DateTime(current.year, current.month, current.day);
        if (dayMarker != _lastDayMarker) {
          _lastDayMarker = dayMarker;
          ref.invalidate(khatmahControllerProvider);
          ref.read(prayerDailyProgressProvider.notifier).ensureToday();
          ref.read(sebhaStateProvider.notifier).ensureToday();
        }
      });
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBrandingHeader(context),
              const PrayerTimesCard(),
              const NowPlayingCard(),
              const SizedBox(height: 24),
              const QuickActionsGrid(),
              const SizedBox(height: 32),
              const MotivationStatsCard(),
              const SizedBox(height: 24),
              const DailyWirdSection(),
              const SizedBox(height: 32),
              const ContinueReadingCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandingHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/branding/logo.png',
                    fit: BoxFit.cover,
                    semanticLabel: 'شعار تطبيق انا المسلم',
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'انا المسلم',
                    style: GoogleFonts.tajawal(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary(context),
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'انا المسلم',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            onPressed: () => context.push(Routes.settings),
            tooltip: 'الإعدادات',
            icon: Icon(
              Icons.settings_outlined,
              color: AppColors.textSecondary(context),
              size: 26,
            ),
          ),
        ],
      ),
    );
  }
}
