import 'package:flutter/material.dart';

import '../theme/app_semantic_colors.dart';
import '../theme/app_spacing.dart';

/// Animated shimmer-style loading placeholder.
///
/// Uses an [AnimatedBuilder] + gradient sweep so no third-party package is needed.
/// Colors are taken from the semantic extension, so it adapts to light/dark.
///
/// Usage:
/// ```dart
/// // Single bar
/// AppSkeletonLoader(width: 200, height: 16)
///
/// // Card placeholder
/// Column(children: [
///   AppSkeletonLoader(height: 20, width: double.infinity),
///   SizedBox(height: 8),
///   AppSkeletonLoader(height: 14, width: 140),
/// ])
/// ```
class AppSkeletonLoader extends StatefulWidget {
  const AppSkeletonLoader({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = AppSpacing.radiusMd,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  State<AppSkeletonLoader> createState() => _AppSkeletonLoaderState();
}

class _AppSkeletonLoaderState extends State<AppSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final baseColor = colors.borderSubtle;
    final highlightColor = colors.surfaceVariant;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// Convenience widget for a skeleton placeholder card (title + subtitle + body).
class AppSkeletonCard extends StatelessWidget {
  const AppSkeletonCard({super.key, this.lines = 3});

  final int lines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSkeletonLoader(height: 18, width: 160),
          const SizedBox(height: AppSpacing.sm),
          for (int i = 0; i < lines - 1; i++) ...[
            AppSkeletonLoader(
              height: 13,
              width: i == lines - 2 ? 120 : double.infinity,
            ),
            if (i < lines - 2) const SizedBox(height: AppSpacing.xs),
          ],
        ],
      ),
    );
  }
}
