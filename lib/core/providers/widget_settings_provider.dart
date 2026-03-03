import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

// ─── Widget type enum ────────────────────────────────────────────────────────

enum WidgetType {
  prayer(
    prefix: 'prayer_',
    androidName: 'PrayerWidgetProvider',
    displayNameAr: 'ودجة الصلاة',
    icon: Icons.mosque_rounded,
    supportsFullStyling: true,
  ),
  date(
    prefix: 'date_',
    androidName: 'DateWidgetProvider',
    displayNameAr: 'ودجة التاريخ',
    icon: Icons.calendar_today_rounded,
    supportsFullStyling: true,
  ),
  hijriMonth(
    prefix: 'hijri_',
    androidName: 'HijriMonthWidgetProvider',
    displayNameAr: 'ودجة الشهر الهجري',
    icon: Icons.date_range_rounded,
    supportsFullStyling: true,
  ),
  quran(
    prefix: 'quran_',
    androidName: 'QuranWidgetProvider',
    displayNameAr: 'ودجة القرآن',
    icon: Icons.menu_book_rounded,
    supportsFullStyling: false,
  ),
  transparent(
    prefix: 'transparent_',
    androidName: 'TransparentWidgetProvider',
    displayNameAr: 'ودجة شفافة',
    icon: Icons.blur_on_rounded,
    supportsFullStyling: false,
  );

  const WidgetType({
    required this.prefix,
    required this.androidName,
    required this.displayNameAr,
    required this.icon,
    required this.supportsFullStyling,
  });

  final String prefix;
  final String androidName;
  final String displayNameAr;
  final IconData icon;
  final bool supportsFullStyling;
}

// ─── Immutable style settings model ─────────────────────────────────────────

@immutable
class WidgetStyleSettings {
  const WidgetStyleSettings({
    this.textColor = 'FFFFFFFF',
    this.bgColor = 'FFFFFBF0',
    this.bgOpacity = 0.4,
    this.radius = 40.0,
    this.decorImage = 'decor_1',
    this.decorOpacity = 0.2,
    this.decorColor = 'FFFFFFFF',
    this.fontSize1 = 12.0,
    this.fontSize2 = 14.0,
  });

  final String textColor;
  final String bgColor;
  final double bgOpacity;
  final double radius;
  final String decorImage;
  final double decorOpacity;
  final String decorColor;
  final double fontSize1;
  final double fontSize2;

  WidgetStyleSettings copyWith({
    String? textColor,
    String? bgColor,
    double? bgOpacity,
    double? radius,
    String? decorImage,
    double? decorOpacity,
    String? decorColor,
    double? fontSize1,
    double? fontSize2,
  }) {
    return WidgetStyleSettings(
      textColor: textColor ?? this.textColor,
      bgColor: bgColor ?? this.bgColor,
      bgOpacity: bgOpacity ?? this.bgOpacity,
      radius: radius ?? this.radius,
      decorImage: decorImage ?? this.decorImage,
      decorOpacity: decorOpacity ?? this.decorOpacity,
      decorColor: decorColor ?? this.decorColor,
      fontSize1: fontSize1 ?? this.fontSize1,
      fontSize2: fontSize2 ?? this.fontSize2,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WidgetStyleSettings &&
          textColor == other.textColor &&
          bgColor == other.bgColor &&
          bgOpacity == other.bgOpacity &&
          radius == other.radius &&
          decorImage == other.decorImage &&
          decorOpacity == other.decorOpacity &&
          decorColor == other.decorColor &&
          fontSize1 == other.fontSize1 &&
          fontSize2 == other.fontSize2;

  @override
  int get hashCode => Object.hash(
        textColor, bgColor, bgOpacity, radius,
        decorImage, decorOpacity, decorColor, fontSize1, fontSize2,
      );
}

// ─── Map-based notifier holding all widget type styles ──────────────────────

typedef WidgetStyleMap = Map<WidgetType, WidgetStyleSettings>;

class WidgetStyleMapNotifier extends Notifier<WidgetStyleMap> {
  static const _style = 'fff';

  @override
  WidgetStyleMap build() {
    // Initialize with defaults, then async-load from SharedPrefs
    final defaults = {for (final t in WidgetType.values) t: const WidgetStyleSettings()};
    _loadAll();
    return defaults;
  }

  String _key(WidgetType type, String field) =>
      '${type.prefix}${field}_$_style';

  Future<void> _loadAll() async {
    final map = <WidgetType, WidgetStyleSettings>{};
    for (final type in WidgetType.values) {
      try {
        final results = await Future.wait([
          HomeWidget.getWidgetData<String>(_key(type, 'textColor')),
          HomeWidget.getWidgetData<String>(_key(type, 'finalWidgetColor')),
          HomeWidget.getWidgetData<double>(_key(type, 'backgroundOpacity')),
          HomeWidget.getWidgetData<double>(_key(type, 'widgetRadius')),
          HomeWidget.getWidgetData<String>(_key(type, 'decorImage')),
          HomeWidget.getWidgetData<double>(_key(type, 'decorOpacity')),
          HomeWidget.getWidgetData<String>(_key(type, 'decorColor')),
          HomeWidget.getWidgetData<double>(_key(type, 'nameFontSize')),
          HomeWidget.getWidgetData<double>(_key(type, 'timeFontSize')),
        ]);
        map[type] = WidgetStyleSettings(
          textColor: (results[0] as String?) ?? 'FFFFFFFF',
          bgColor: (results[1] as String?) ?? 'FFFFFBF0',
          bgOpacity: (results[2] as double?) ?? 0.4,
          radius: (results[3] as double?) ?? 40.0,
          decorImage: (results[4] as String?) ?? 'decor_1',
          decorOpacity: (results[5] as double?) ?? 0.2,
          decorColor: (results[6] as String?) ?? 'FFFFFFFF',
          fontSize1: (results[7] as double?) ?? 12.0,
          fontSize2: (results[8] as double?) ?? 14.0,
        );
      } catch (e) {
        if (kDebugMode) debugPrint('[WidgetStyle] load ${type.name} error: $e');
        map[type] = const WidgetStyleSettings();
      }
    }
    state = map;
  }

  Future<void> _save(WidgetType type, String field, dynamic value) async {
    try {
      if (value is String) {
        await HomeWidget.saveWidgetData<String>(_key(type, field), value);
      } else if (value is double) {
        await HomeWidget.saveWidgetData<double>(_key(type, field), value);
      }
      await HomeWidget.updateWidget(androidName: type.androidName);
    } catch (e) {
      if (kDebugMode) debugPrint('[WidgetStyle] save error: $e');
    }
  }

  void _update(WidgetType type, WidgetStyleSettings newSettings) {
    state = {...state, type: newSettings};
  }

  WidgetStyleSettings _get(WidgetType type) =>
      state[type] ?? const WidgetStyleSettings();

  Future<void> setTextColor(WidgetType type, String hex) async {
    _update(type, _get(type).copyWith(textColor: hex));
    if (type == WidgetType.transparent) {
      final withHash = '#${hex.substring(2)}'; // AARRGGBB -> #RRGGBB
      await HomeWidget.saveWidgetData<String>('widget_text_color', withHash);
      await HomeWidget.updateWidget(androidName: type.androidName);
    }
    await _save(type, 'textColor', hex);
  }

  Future<void> setBgColor(WidgetType type, String hex) async {
    _update(type, _get(type).copyWith(bgColor: hex));
    await _save(type, 'finalWidgetColor', hex);
  }

  Future<void> setBgOpacity(WidgetType type, double value) async {
    _update(type, _get(type).copyWith(bgOpacity: value));
    await _save(type, 'backgroundOpacity', value);
  }

  Future<void> setRadius(WidgetType type, double value) async {
    _update(type, _get(type).copyWith(radius: value));
    await _save(type, 'widgetRadius', value);
  }

  Future<void> setDecorImage(WidgetType type, String name) async {
    _update(type, _get(type).copyWith(decorImage: name));
    await _save(type, 'decorImage', name);
  }

  Future<void> setDecorOpacity(WidgetType type, double value) async {
    _update(type, _get(type).copyWith(decorOpacity: value));
    await _save(type, 'decorOpacity', value);
  }

  Future<void> setDecorColor(WidgetType type, String hex) async {
    _update(type, _get(type).copyWith(decorColor: hex));
    await _save(type, 'decorColor', hex);
  }

  Future<void> setFontSize1(WidgetType type, double value) async {
    _update(type, _get(type).copyWith(fontSize1: value));
    await _save(type, 'nameFontSize', value);
  }

  Future<void> setFontSize2(WidgetType type, double value) async {
    _update(type, _get(type).copyWith(fontSize2: value));
    await _save(type, 'timeFontSize', value);
  }
}

final _widgetStyleMapProvider =
    NotifierProvider<WidgetStyleMapNotifier, WidgetStyleMap>(
  WidgetStyleMapNotifier.new,
);

/// Watch the style settings for a specific widget type.
/// Uses `.select()` so only rebuilds when the specific type's settings change.
final widgetStyleProvider =
    Provider.family<WidgetStyleSettings, WidgetType>((ref, type) {
  final map = ref.watch(_widgetStyleMapProvider);
  return map[type] ?? const WidgetStyleSettings();
});

/// Access the style controller for mutations.
WidgetStyleMapNotifier widgetStyleNotifier(WidgetRef ref) =>
    ref.read(_widgetStyleMapProvider.notifier);

// ─── Number format provider ─────────────────────────────────────────────────

class WidgetNumberFormatNotifier extends Notifier<String> {
  @override
  String build() {
    _load();
    return 'arabic';
  }

  Future<void> _load() async {
    try {
      final val = await HomeWidget.getWidgetData<String>('numberFormat');
      if (val != null) state = val;
    } catch (e) {
      if (kDebugMode) debugPrint('[WidgetNumberFormat] load error: $e');
    }
  }

  Future<void> save(String value) async {
    state = value;
    try {
      await HomeWidget.saveWidgetData<String>('numberFormat', value);
      await _refreshAllWidgets();
    } catch (e) {
      if (kDebugMode) debugPrint('[WidgetNumberFormat] save error: $e');
    }
  }
}

final widgetNumberFormatProvider =
    NotifierProvider<WidgetNumberFormatNotifier, String>(
  WidgetNumberFormatNotifier.new,
);

// ─── 12h format provider ────────────────────────────────────────────────────

class WidgetUse12hNotifier extends Notifier<bool> {
  @override
  bool build() {
    _load();
    return true;
  }

  Future<void> _load() async {
    try {
      final val = await HomeWidget.getWidgetData<bool>('use12h');
      if (val != null) state = val;
    } catch (e) {
      if (kDebugMode) debugPrint('[WidgetUse12h] load error: $e');
    }
  }

  Future<void> save(bool value) async {
    state = value;
    try {
      await HomeWidget.saveWidgetData<bool>('use12h', value);
      await _refreshAllWidgets();
    } catch (e) {
      if (kDebugMode) debugPrint('[WidgetUse12h] save error: $e');
    }
  }
}

final widgetUse12hProvider = NotifierProvider<WidgetUse12hNotifier, bool>(
  WidgetUse12hNotifier.new,
);

// ─── Helpers ────────────────────────────────────────────────────────────────

Future<void> _refreshAllWidgets() async {
  for (final wt in WidgetType.values) {
    try {
      await HomeWidget.updateWidget(androidName: wt.androidName);
    } catch (e) {
      if (kDebugMode) debugPrint('[Widget] refresh ${wt.name} error: $e');
    }
  }
}
