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
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../khatmah/presentation/providers/khatmah_controller.dart';
import '../../../prayer_times/presentation/providers/prayer_times_provider.dart';
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
          ref.invalidate(prayerTimesProvider);
          ref.invalidate(aladhanTimesProvider);
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
              const SizedBox(height: 20),
              const ContinueReadingCard(),
              const SizedBox(height: 28),
              const QuickActionsGrid(),
              const SizedBox(height: 28),
              const MotivationStatsCard(),
              const SizedBox(height: 24),
              const DailyWirdSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandingHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(9),
              child: const BrandLogo(fit: BoxFit.contain),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'أنا المسلم',
              style: GoogleFonts.tajawal(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: context.colors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
          ),
          IconButton(
            onPressed: () => context.push(Routes.settings),
            tooltip: 'الإعدادات',
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(10),
            ),
            icon: Icon(
              Icons.settings_outlined,
              color: context.colors.iconSecondary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
