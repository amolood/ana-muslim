import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/providers/widget_settings_provider.dart';

/// Builds the content layer for a widget preview at the given [scale].
///
/// [scale] controls font/spacing sizes — use ~0.65 for mini cards, 1.0 for the
/// detail-screen full preview. This single builder eliminates duplication
/// between the Level 1 and Level 2 screens.
Widget buildWidgetContent({
  required WidgetType type,
  required Color textColor,
  WidgetStyleSettings? style,
  double scale = 1.0,
}) {
  return switch (type) {
    WidgetType.prayer => _PrayerPreview(
        textColor: textColor,
        style: style ?? const WidgetStyleSettings(),
        scale: scale,
      ),
    WidgetType.date => _DatePreview(textColor: textColor, scale: scale),
    WidgetType.hijriMonth =>
      _HijriMonthPreview(textColor: textColor, scale: scale),
    WidgetType.quran => _QuranPreview(textColor: textColor, scale: scale),
    WidgetType.transparent =>
      _TransparentPreview(textColor: textColor, scale: scale),
  };
}

/// Preview height for a widget type at the given scale.
double widgetPreviewHeight(WidgetType type, {double scale = 1.0}) {
  final base = switch (type) {
    WidgetType.prayer => 85.0,
    WidgetType.date => 110.0,
    WidgetType.hijriMonth => 100.0,
    WidgetType.quran => 85.0,
    WidgetType.transparent => 80.0,
  };
  return base * scale;
}

// ═══════════════════════════════════════════════════════════════════════════════
// Prayer — 5 equal columns matching prayer_widget.xml
// ═══════════════════════════════════════════════════════════════════════════════

class _PrayerPreview extends StatelessWidget {
  const _PrayerPreview({
    required this.textColor,
    required this.style,
    required this.scale,
  });
  final Color textColor;
  final WidgetStyleSettings style;
  final double scale;

  static const _prayers = [
    ('الفجر', '05:00'),
    ('الظهر', '12:00'),
    ('العصر', '15:00'),
    ('المغرب', '18:00'),
    ('العشاء', '19:30'),
  ];

  @override
  Widget build(BuildContext context) {
    final nameSize = (style.fontSize1.clamp(8.0, 22.0)) * scale;
    final timeSize = (style.fontSize2.clamp(10.0, 24.0)) * scale;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12 * scale),
      child: Row(
        children: [
          for (final (name, time) in _prayers)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: nameSize,
                      fontFamily: 'IBMPlexSansArabic',
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 2 * scale),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: timeSize,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'IBMPlexSansArabic',
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Date — large calligraphy day (fitCenter, full width) + gregorian | hijri
// Matches date_widget.xml: dayImage takes full width, fitCenter + adjustViewBounds.
// Below: txtDate (20sp) | txtDivider (18sp) | txtHijri (20sp), marginTop=2dp.
// Kotlin renders day digit as bitmap at 280f size — we simulate with large font.
// ═══════════════════════════════════════════════════════════════════════════════

class _DatePreview extends StatelessWidget {
  const _DatePreview({required this.textColor, required this.scale});
  final Color textColor;
  final double scale;

  @override
  Widget build(BuildContext context) {
    // CalligraphyDays: digits 1-7 map to Arabic day calligraphy
    // 1=الأحد 2=الاثنين 3=الثلاثاء 4=الأربعاء 5=الخميس 6=الجمعة 7=السبت
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8 * scale),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Day calligraphy — large, prominent, full width like Android's dayImage
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '6', // الجمعة
              style: TextStyle(
                fontSize: 52 * scale,
                color: textColor,
                fontFamily: 'CalligraphyDays',
                height: 1.15,
              ),
            ),
          ),

          SizedBox(height: 2 * scale),

          // Gregorian | Hijri row — matches XML: 20sp dates, 18sp divider
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '٢٧ فبراير ٢٠٢٦',
                style: TextStyle(
                  fontSize: 13 * scale,
                  fontFamily: 'IBMPlexSansArabic',
                  color: textColor,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6 * scale),
                child: Text(
                  '|',
                  style: TextStyle(
                    fontSize: 12 * scale,
                    color: textColor.withValues(alpha: 0.4),
                  ),
                ),
              ),
              Text(
                '٢ رمضان ١٤٤٧',
                style: TextStyle(
                  fontSize: 13 * scale,
                  fontFamily: 'IBMPlexSansArabic',
                  color: textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Hijri Month — calligraphy month name (weight=1) + large month number
// Matches hijri_month_widget.xml:
//   monthImage: width=0dp, weight=1, fitCenter, adjustViewBounds
//   txtMonthNumber: 55sp, Ayman font, #CCFFFFFF, paddingStart=5dp, paddingEnd=15dp
// Kotlin renders month name as bitmap at 200f size with Ayman font.
// ═══════════════════════════════════════════════════════════════════════════════

class _HijriMonthPreview extends StatelessWidget {
  const _HijriMonthPreview({required this.textColor, required this.scale});
  final Color textColor;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 4 * scale,
        vertical: 2 * scale,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Month name — takes all available space (weight=1 in XML)
          // Rendered as Ayman calligraphy, scaled to fit width
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8 * scale),
                child: Text(
                  'رمضان',
                  style: TextStyle(
                    fontSize: 44 * scale,
                    color: textColor,
                    fontFamily: 'Ayman',
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ),
            ),
          ),

          // Month number — large Ayman font, right-padded
          // XML: 55sp, paddingStart=5dp, paddingEnd=15dp
          Padding(
            padding: EdgeInsets.only(
              left: 4 * scale,
              right: 12 * scale,
            ),
            child: Text(
              '٩',
              style: TextStyle(
                fontSize: 55 * scale,
                color: textColor,
                fontFamily: 'Ayman',
                height: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Quran — Uthmanic script verse  (matches quran_widget.xml)
// ═══════════════════════════════════════════════════════════════════════════════

class _QuranPreview extends StatelessWidget {
  const _QuranPreview({required this.textColor, required this.scale});
  final Color textColor;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16 * scale,
        vertical: 12 * scale,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            style: TextStyle(
              fontSize: 18 * scale,
              fontFamily: 'KFGQPC Uthmanic Script',
              color: textColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4 * scale),
          Text(
            'سورة الفاتحة • آية ١',
            style: GoogleFonts.ibmPlexSansArabic(
              fontSize: 10 * scale,
              color: textColor.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Transparent — calligraphy day + date + next prayer
// ═══════════════════════════════════════════════════════════════════════════════

class _TransparentPreview extends StatelessWidget {
  const _TransparentPreview({required this.textColor, required this.scale});
  final Color textColor;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16 * scale,
        vertical: 6 * scale,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '6', // digit "6" = الجمعة
            style: TextStyle(
              fontSize: 28 * scale,
              color: textColor,
              fontFamily: 'CalligraphyDays',
              height: 1.1,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '٢ رمضان',
                style: TextStyle(
                  fontSize: 12 * scale,
                  fontFamily: 'IBMPlexSansArabic',
                  color: textColor.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(width: 16 * scale),
              Text(
                'المغرب 06:20',
                style: TextStyle(
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'IBMPlexSansArabic',
                  color: textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
