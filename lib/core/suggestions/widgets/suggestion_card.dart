import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_semantic_colors.dart';
import '../models/suggestion.dart';

/// بطاقة عرض الاقتراح
class SuggestionCard extends StatelessWidget {
  final Suggestion suggestion;
  final VoidCallback? onDismiss;
  final EdgeInsets? margin;
  final bool showCloseButton;

  const SuggestionCard({
    super.key,
    required this.suggestion,
    this.onDismiss,
    this.margin,
    this.showCloseButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            suggestion.color.withValues(alpha: 0.15),
            suggestion.color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: suggestion.color.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: suggestion.color.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: suggestion.onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: suggestion.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          suggestion.icon,
                          color: suggestion.color,
                          size: 24,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Title and subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              suggestion.title,
                              style: GoogleFonts.tajawal(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              suggestion.subtitle,
                              style: GoogleFonts.tajawal(
                                fontSize: 14,
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Priority badge
                      if (suggestion.priority == SuggestionPriority.critical)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.priority_high,
                                size: 14,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'مهم',
                                style: GoogleFonts.tajawal(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Close button
                      if (showCloseButton && suggestion.isDismissible) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            size: 20,
                            color: colors.iconSecondary,
                          ),
                          onPressed: onDismiss ?? suggestion.onDismiss,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ],
                  ),

                  // Description
                  if (suggestion.description != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      suggestion.description!,
                      style: GoogleFonts.tajawal(
                        fontSize: 13,
                        color: colors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],

                  // Action button
                  if (suggestion.actionLabel != null) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: suggestion.onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: suggestion.color,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          suggestion.actionLabel!,
                          style: GoogleFonts.tajawal(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],

                  // Expiry indicator
                  if (suggestion.expiresAt != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: colors.iconSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getTimeRemaining(suggestion.expiresAt!),
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            color: colors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getTimeRemaining(DateTime expiresAt) {
    final now = DateTime.now();
    final difference = expiresAt.difference(now);

    if (difference.inMinutes < 60) {
      return 'ينتهي خلال ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'ينتهي خلال ${difference.inHours} ساعة';
    } else {
      return 'ينتهي خلال ${difference.inDays} يوم';
    }
  }
}

/// قائمة الاقتراحات
class SuggestionsList extends StatelessWidget {
  final List<Suggestion> suggestions;
  final Function(Suggestion)? onDismiss;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const SuggestionsList({
    super.key,
    required this.suggestions,
    this.onDismiss,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return SuggestionCard(
          suggestion: suggestion,
          onDismiss: onDismiss != null ? () => onDismiss!(suggestion) : null,
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: colors.iconSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد اقتراحات حالياً',
              style: GoogleFonts.tajawal(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'سنقترح عليك الأذكار والعبادات في أوقاتها',
              style: GoogleFonts.tajawal(
                fontSize: 14,
                color: colors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// بطاقة اقتراح مصغرة (للشاشة الرئيسية)
class CompactSuggestionCard extends StatelessWidget {
  final Suggestion suggestion;
  final VoidCallback? onDismiss;

  const CompactSuggestionCard({
    super.key,
    required this.suggestion,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: suggestion.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: suggestion.color.withValues(alpha: 0.25),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: suggestion.onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: suggestion.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    suggestion.icon,
                    color: suggestion.color,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 12),

                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        suggestion.title,
                        style: GoogleFonts.tajawal(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        suggestion.subtitle,
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  Icons.arrow_back_ios,
                  size: 16,
                  color: suggestion.color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
