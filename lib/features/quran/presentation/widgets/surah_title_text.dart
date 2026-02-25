import 'package:flutter/material.dart';

class SurahTitleText extends StatelessWidget {
  const SurahTitleText(
    this.text, {
    super.key,
    this.fontSize = 22,
    this.maxLines = 1,
    this.textAlign = TextAlign.center,
    this.color = const Color(0xFFD6B06B),
    this.height = 1.25,
    this.overflow = TextOverflow.ellipsis,
  });

  final String text;
  final double fontSize;
  final int maxLines;
  final TextAlign textAlign;
  final Color color;
  final double height;
  final TextOverflow overflow;

  @override
  Widget build(BuildContext context) {
    // استخدام خط ثابت مناسب لعناوين السور بدلاً من اعتماد خط القرآن
    // لأن عناوين السور تحتاج لخط واضح ومقروء
    const titleFont = 'KFGQPC Uthmanic Script';

    return Text(
      text,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      textDirection: TextDirection.rtl,
      style: TextStyle(
        fontFamily: titleFont,
        fontFamilyFallback: const ['Amiri', 'naskh', 'Scheherazade'],
        fontSize: fontSize,
        height: height,
        color: color,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
