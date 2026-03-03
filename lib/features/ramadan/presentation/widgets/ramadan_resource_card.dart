import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';

/// Styled card for displaying a daily dua or hadith with icon, label,
/// Arabic content, optional translation, and optional source reference.
class RamadanResourceCard extends StatelessWidget {
  const RamadanResourceCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.content,
    this.subtitle,
    this.reference,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String content;
  final String? subtitle;
  final String? reference;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: iconColor.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header row ─────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [iconColor, iconColor.withValues(alpha: 0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.tajawal(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ─── Arabic content ──────────────────────────────────
          Text(
            content,
            style: TextStyle(
              fontFamily: 'KFGQPC Uthmanic Script',
              fontFamilyFallback: const ['naskh'],
              fontSize: 17,
              color: colors.textPrimary,
              height: 1.8,
            ),
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: GoogleFonts.tajawal(
                fontSize: 13,
                color: AppColors.textSecondaryDark,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          if (reference != null && reference!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              reference!,
              style: GoogleFonts.tajawal(
                fontSize: 12,
                color: iconColor.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
