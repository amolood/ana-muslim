import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import '../models/permission_info.dart';

/// Full-screen-height bottom sheet shown **before** the OS permission dialog.
///
/// Explains in plain Arabic:
///  - what the permission is for
///  - what the user gains by granting it
///  - what won't work if they decline
///
/// Returns `true` if the user wants to proceed to the OS dialog,
/// `false` if they chose to skip.
class PermissionRationaleSheet extends StatelessWidget {
  const PermissionRationaleSheet({super.key, required this.permission});

  final PermissionInfo permission;

  /// Helper to push this sheet and await the user's decision.
  /// Returns `true` → proceed to OS dialog.  Returns `false` → skip.
  static Future<bool> show(
    BuildContext context,
    PermissionInfo permission,
  ) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => PermissionRationaleSheet(permission: permission),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.surfaceDark : Colors.white;
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark
        ? Colors.white.withValues(alpha: 0.65)
        : Colors.black.withValues(alpha: 0.55);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          top: 12,
          left: 24,
          right: 24,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Drag handle ────────────────────────────────────────────────
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 28),

            // ── Icon ───────────────────────────────────────────────────────
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: permission.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                permission.icon,
                size: 44,
                color: permission.color,
              ),
            ),

            const SizedBox(height: 20),

            // ── Title ──────────────────────────────────────────────────────
            Text(
              permission.title,
              style: GoogleFonts.tajawal(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 6),

            // ── Required / Optional badge ──────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: permission.isRequired
                    ? Colors.red.withValues(alpha: 0.1)
                    : Colors.blueGrey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                permission.isRequired ? 'ضروري لعمل التطبيق' : 'اختياري — موصى به',
                style: GoogleFonts.tajawal(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: permission.isRequired ? Colors.red : Colors.blueGrey,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Description ────────────────────────────────────────────────
            Text(
              permission.description,
              style: GoogleFonts.tajawal(
                fontSize: 15,
                height: 1.7,
                color: textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // ── Benefit highlight ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: permission.color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: permission.color.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.auto_awesome, size: 18, color: permission.color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      permission.benefit,
                      style: GoogleFonts.tajawal(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                        color: permission.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── "What if I decline?" note for required permissions ─────────
            if (permission.isRequired) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'بدون هذا الإذن لن تتمكن من استخدام هذه الميزة بشكل صحيح.',
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 28),

            // ── Allow button ───────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: permission.color,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'السماح الآن',
                      style: GoogleFonts.tajawal(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ── Skip button ────────────────────────────────────────────────
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                permission.isRequired
                    ? 'تخطي الآن (ستتأثر بعض الميزات)'
                    : 'تخطي',
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  color: textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
