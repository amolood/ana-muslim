import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.size = 48,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.semanticsLabel = 'شعار تطبيق أنا المسلم',
    /// Override the logo color. When null, adapts automatically:
    /// light mode → [AppColors.primary], dark mode → white.
    this.color,
  });

  final double size;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String semanticsLabel;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logoColor = color ?? (isDark ? Colors.white : AppColors.primary);

    return SizedBox(
      width: width ?? size,
      height: height ?? size,
      child: SvgPicture.asset(
        'assets/branding/anaalmuslim.svg',
        fit: fit,
        semanticsLabel: semanticsLabel,
        colorFilter: ColorFilter.mode(logoColor, BlendMode.srcIn),
      ),
    );
  }
}
