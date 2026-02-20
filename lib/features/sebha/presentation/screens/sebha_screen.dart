import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/preferences_provider.dart';

class SebhaScreen extends ConsumerStatefulWidget {
  const SebhaScreen({super.key});

  @override
  ConsumerState<SebhaScreen> createState() => _SebhaScreenState();
}

class _SebhaScreenState extends ConsumerState<SebhaScreen> with SingleTickerProviderStateMixin {
  
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _incrementCounter() {
    HapticFeedback.lightImpact(); // Add touch feedback
    
    final currentCount = ref.read(sebhaCurrentCountProvider);
    final totalCount = ref.read(sebhaTotalCountProvider);
    int target = ref.read(sebhaDailyGoalProvider);
    if (target == 0) target = 100;
    
    ref.read(sebhaCurrentCountProvider.notifier).save(currentCount + 1);
    ref.read(sebhaTotalCountProvider.notifier).save(totalCount + 1);
    
    if (currentCount + 1 >= target) {
      HapticFeedback.heavyImpact();
    }
  }

  void _resetCounter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text(
          'تصفير العداد',
          style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'هل أنت متأكد من تصفير الورد الحالي؟',
          style: GoogleFonts.tajawal(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: GoogleFonts.tajawal(color: AppColors.textSecondaryDark)),
          ),
          TextButton(
            onPressed: () {
              ref.read(sebhaCurrentCountProvider.notifier).save(0);
              Navigator.pop(context);
            },
            child: Text('تصفير', style: GoogleFonts.tajawal(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            _buildBackgroundPattern(),
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 120),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildCounterSection(),
                        const SizedBox(height: 40),
                        _buildNeumorphicTapButton(),
                        const SizedBox(height: 40),
                        _buildStatsSection(),
                        const SizedBox(height: 24),
                        _buildHistoryScroller(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return Positioned.fill(
      child: Center(
        child: Opacity(
          opacity: 0.05,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.1),
                child: child,
              );
            },
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.restart_alt, color: AppColors.textSecondaryDark),
            onPressed: _resetCounter,
          ),
          Column(
            children: [
              Text(
                'الورد الحالي',
                style: GoogleFonts.tajawal(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary.withValues(alpha: 0.8),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'سبحان الله',
                    style: GoogleFonts.notoSansArabic(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      // Simulated gold gradient using standard color
                      color: const Color(0xFFD4AF37),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.expand_more, color: Color(0xFFD4AF37), size: 16),
                ],
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.textSecondaryDark),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCounterSection() {
    final currentCount = ref.watch(sebhaCurrentCountProvider);
    int targetCount = ref.watch(sebhaDailyGoalProvider);
    if (targetCount == 0) targetCount = 100;
    
    final double percentage = targetCount == 0 ? 0 : (currentCount / targetCount).clamp(0.0, 1.0);
    
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 256,
          height: 256,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: percentage),
            duration: const Duration(milliseconds: 300),
            builder: (context, value, child) {
              return CircularProgressIndicator(
                value: value,
                strokeWidth: 4,
                backgroundColor: AppColors.surfaceDark.withValues(alpha: 0.5),
                color: AppColors.primary,
              );
            },
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$currentCount',
              style: GoogleFonts.manrope(
                fontSize: 96,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.0,
              ),
            ),
            Text(
              'من $targetCount',
              style: GoogleFonts.tajawal(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondaryDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNeumorphicTapButton() {
    return GestureDetector(
      onTapDown: (_) => _incrementCounter(),
      child: Container(
        width: 192,
        height: 192,
        decoration: BoxDecoration(
          color: AppColors.surfaceDarker,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.surfaceDark.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0d1a18),
              offset: const Offset(8, 8),
              blurRadius: 16,
            ),
            BoxShadow(
              color: const Color(0xFF1b3632),
              offset: const Offset(-8, -8),
              blurRadius: 16,
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.fingerprint,
                size: 48,
                color: AppColors.primary,
              ),
              const SizedBox(height: 8),
              Text(
                'اضغط للتسبيح',
                style: GoogleFonts.tajawal(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          Expanded(child: _buildGoalCard()),
          const SizedBox(width: 16),
          Expanded(child: _buildTotalCard()),
        ],
      ),
    );
  }

  Widget _buildGoalCard() {
    final currentCount = ref.watch(sebhaCurrentCountProvider);
    int targetCount = ref.watch(sebhaDailyGoalProvider);
    if (targetCount == 0) targetCount = 100;
    
    double completion = targetCount == 0 ? 0 : (currentCount / targetCount).clamp(0.0, 1.0);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'هدف اليوم',
                style: GoogleFonts.tajawal(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondaryDark,
                ),
              ),
              const Icon(Icons.emoji_events, color: Color(0xFFD4AF37), size: 18),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$currentCount',
                style: GoogleFonts.manrope(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: Text(
                  '/ $targetCount',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceDarker,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 150 * completion, // Approximate total width relative to card size
                height: 6,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF0ca88e)],
                  ),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard() {
    final totalSpoken = ref.watch(sebhaTotalCountProvider);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'مجموع التسبيح',
                style: GoogleFonts.tajawal(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondaryDark,
                ),
              ),
              const Icon(Icons.history, color: AppColors.primary, size: 18),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$totalSpoken',
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.greenAccent, size: 12),
              const SizedBox(width: 4),
              Text(
                '+12% هذا الأسبوع',
                style: GoogleFonts.tajawal(
                  fontSize: 10,
                  color: Colors.greenAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryScroller() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            'سجل اليوم',
            style: GoogleFonts.tajawal(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondaryDark,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 64,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              _buildHistoryItem(Icons.wb_twilight, 'بعد الفجر', '100 تسبيحة', AppColors.primary),
              const SizedBox(width: 12),
              _buildHistoryItem(Icons.sunny, 'الضحى', '33 تسبيحة', const Color(0xFFD4AF37)),
              const SizedBox(width: 12),
              _buildHistoryItem(Icons.bedtime, 'أمس', '500 تسبيحة', Colors.grey, isOpacity: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(IconData icon, String title, String count, Color iconColor, {bool isOpacity = false}) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceDarker,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Opacity(
        opacity: isOpacity ? 0.6 : 1.0,
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  count,
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
