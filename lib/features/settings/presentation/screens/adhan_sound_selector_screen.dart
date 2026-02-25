import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/notifications/notifications_service.dart';
import 'notification_settings_screen.dart' show reschedulePrayerNotifications;

class AdhanSoundSelectorScreen extends ConsumerStatefulWidget {
  const AdhanSoundSelectorScreen({super.key});

  @override
  ConsumerState<AdhanSoundSelectorScreen> createState() =>
      _AdhanSoundSelectorScreenState();
}

class _AdhanSoundSelectorScreenState
    extends ConsumerState<AdhanSoundSelectorScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  AdhanSoundOption? _playingOption;
  bool _isLoading = false;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    // الاستماع لحالة التشغيل بشكل دائم
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (mounted) {
          setState(() => _playingOption = null);
        }
      }
    });
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playPreview(AdhanSoundOption option) async {
    if (_playingOption == option) {
      // إيقاف الصوت إذا كان يعمل
      await _audioPlayer.stop();
      setState(() => _playingOption = null);
      return;
    }

    setState(() {
      _isLoading = true;
      _playingOption = option;
    });

    try {
      // إيقاف أي صوت سابق
      await _audioPlayer.stop();

      if (option == AdhanSoundOption.custom) {
        final customPath = ref.read(customAdhanFilePathProvider);
        if (customPath != null && customPath.isNotEmpty) {
          await _audioPlayer.setFilePath(customPath);
          await _audioPlayer.play();
        } else {
          // لا يوجد ملف مخصص بعد
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'لم يتم اختيار ملف مخصص بعد',
                  style: GoogleFonts.tajawal(),
                ),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 2),
              ),
            );
          }
          setState(() {
            _playingOption = null;
            _isLoading = false;
          });
          return;
        }
      } else {
        // تحميل وتشغيل الصوت من assets باستخدام just_audio
        if (kDebugMode) {
          print('محاولة تحميل: ${option.assetPath}');
        }

        await _audioPlayer.setAsset(option.assetPath);
        await _audioPlayer.play();

        if (kDebugMode) {
          print('تم تحميل وتشغيل الصوت بنجاح');
        }
      }

      // إخفاء مؤشر التحميل بعد بدء التشغيل
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (kDebugMode) {
        print('خطأ في تشغيل الصوت: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'فشل تشغيل المعاينة: ${e.toString()}',
              style: GoogleFonts.tajawal(),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        setState(() {
          _playingOption = null;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectOption(AdhanSoundOption option) async {
    // إيقاف أي صوت يعمل
    await _audioPlayer.stop();

    if (option == AdhanSoundOption.custom) {
      // فتح file picker
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;

        // حفظ مسار الملف
        await ref.read(customAdhanFilePathProvider.notifier).save(filePath);

        // حفظ الخيار كـ custom
        await ref.read(adhanSoundOptionProvider.notifier).save(option);

        // تحديث الصوت في NotificationsService
        NotificationsService.setAdhanSound('custom_adhan');

        // Auto-reschedule notifications with new sound
        await reschedulePrayerNotifications(ref);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تم اختيار الملف المخصص بنجاح',
                style: GoogleFonts.tajawal(),
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } else {
      // حفظ الخيار العادي
      await ref.read(adhanSoundOptionProvider.notifier).save(option);

      // تحديث الصوت في NotificationsService
      NotificationsService.setAdhanSound(option.androidResourceName);

      // Auto-reschedule notifications with new sound
      await reschedulePrayerNotifications(ref);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم اختيار: ${option.label}',
              style: GoogleFonts.tajawal(),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }

    setState(() => _playingOption = null);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentOption = ref.watch(adhanSoundOptionProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: colors.textPrimary,
          ),
        ),
        title: Text(
          'اختر صوت الأذان',
          style: GoogleFonts.tajawal(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: AdhanSoundOption.values.length,
        itemBuilder: (context, index) {
          final option = AdhanSoundOption.values[index];
          final isSelected = option == currentOption;
          final isPlaying = _playingOption == option;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.2),
                        AppColors.primary.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected
                  ? null
                  : isDark
                      ? AppColors.surfaceDark
                      : colors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _selectOption(option),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // أيقونة الاختيار
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : colors.textSecondary,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Center(
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),

                      // اسم الخيار
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option.label,
                              style: GoogleFonts.tajawal(
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: isSelected
                                    ? AppColors.primary
                                    : colors.textPrimary,
                              ),
                            ),
                            if (option == AdhanSoundOption.custom &&
                                ref.watch(customAdhanFilePathProvider) != null)
                              Text(
                                'ملف مخصص محدد',
                                style: GoogleFonts.tajawal(
                                  fontSize: 12,
                                  color: colors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),

                      // زر المعاينة
                      if (option != AdhanSoundOption.custom ||
                          ref.watch(customAdhanFilePathProvider) != null)
                        IconButton(
                          onPressed: () => _playPreview(option),
                          icon: _isLoading && isPlaying
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                )
                              : Icon(
                                  isPlaying ? Icons.stop : Icons.play_arrow,
                                  color: AppColors.primary,
                                ),
                          style: IconButton.styleFrom(
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.1),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
