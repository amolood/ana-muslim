import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/khatmah_controller.dart';
import '../widgets/khatmah_active_plan_view.dart';
import '../widgets/khatmah_create_plan_form.dart';

class KhatmahScreen extends ConsumerWidget {
  const KhatmahScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final khatmahAsync = ref.watch(khatmahControllerProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'الختمة',
            style: GoogleFonts.tajawal(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(context),
            ),
          ),
        ),
        body: khatmahAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (error, _) => _buildError(context, ref, error),
          data: (viewState) {
            if (!viewState.hasActivePlan) {
              return const KhatmahCreatePlanForm();
            }
            return KhatmahActivePlanView(viewState: viewState);
          },
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Theme.of(context).colorScheme.error,
              size: 56,
            ),
            const SizedBox(height: 10),
            Text(
              'تعذر تحميل بيانات الختمة',
              style: GoogleFonts.tajawal(
                color: AppColors.textPrimary(context),
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'حدث خطأ غير متوقع، يرجى المحاولة مجدداً',
              style: GoogleFonts.tajawal(
                color: AppColors.textSecondary(context),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: () {
                ref
                    .read(khatmahControllerProvider.notifier)
                    .refreshState();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.backgroundDark,
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                'إعادة المحاولة',
                style: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
