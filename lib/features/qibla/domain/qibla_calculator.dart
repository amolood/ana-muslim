import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';

/// حساب دقيق لاتجاه القبلة باستخدام الإحداثيات الجغرافية
/// يستخدم معادلات هافرساين (Haversine) لحساب الاتجاه الأدق
class QiblaCalculator {
  // إحداثيات الكعبة المشرفة (مكة المكرمة)
  static const double kaabaLatitude = 21.422487;
  static const double kaabaLongitude = 39.826206;

  /// حساب اتجاه القبلة من موقع المستخدم إلى الكعبة
  /// يرجع الزاوية بالدرجات (0-360)
  /// 0° = شمال، 90° = شرق، 180° = جنوب، 270° = غرب
  static double calculateQiblaDirection(Position userPosition) {
    return calculateQiblaFromLatLng(
      userPosition.latitude,
      userPosition.longitude,
    );
  }

  /// حساب اتجاه القبلة مباشرة من إحداثيات (بدون كائن Position)
  static double calculateQiblaFromLatLng(double lat, double lng) {
    return _calculateBearing(lat, lng, kaabaLatitude, kaabaLongitude);
  }

  /// حساب المسافة إلى الكعبة بالكيلومترات
  static double calculateDistanceToKaaba(Position userPosition) {
    return calculateDistanceFromLatLng(
      userPosition.latitude,
      userPosition.longitude,
    );
  }

  /// حساب المسافة مباشرة من إحداثيات (بدون كائن Position)
  static double calculateDistanceFromLatLng(double lat, double lng) {
    return _calculateDistance(lat, lng, kaabaLatitude, kaabaLongitude);
  }

  /// حساب الاتجاه (Bearing) بين نقطتين جغرافيتين
  /// يستخدم معادلة forward azimuth
  static double _calculateBearing(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // تحويل الدرجات إلى راديان
    final double lat1Rad = _toRadians(lat1);
    final double lat2Rad = _toRadians(lat2);
    final double dLon = _toRadians(lon2 - lon1);

    // حساب bearing باستخدام معادلة forward azimuth
    final double y = math.sin(dLon) * math.cos(lat2Rad);
    final double x = math.cos(lat1Rad) * math.sin(lat2Rad) -
        math.sin(lat1Rad) * math.cos(lat2Rad) * math.cos(dLon);

    double bearing = math.atan2(y, x);

    // تحويل من راديان إلى درجات
    bearing = _toDegrees(bearing);

    // تحويل النتيجة لتكون من 0 إلى 360
    return (bearing + 360) % 360;
  }

  /// حساب المسافة بين نقطتين باستخدام معادلة هافرساين
  /// النتيجة بالكيلومترات
  static double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371.0; // نصف قطر الأرض بالكيلومترات

    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  /// تحويل من درجات إلى راديان
  static double _toRadians(double degrees) {
    return degrees * math.pi / 180.0;
  }

  /// تحويل من راديان إلى درجات
  static double _toDegrees(double radians) {
    return radians * 180.0 / math.pi;
  }

  /// حساب أقصر فرق زاوية بين اتجاهين
  /// النتيجة تتراوح من -180 إلى 180
  /// موجب = يمين، سالب = يسار
  static double shortestAngleDelta(double from, double to) {
    double delta = to - from;

    // تطبيع النتيجة لتكون بين -180 و 180
    while (delta > 180) {
      delta -= 360;
    }
    while (delta < -180) {
      delta += 360;
    }

    return delta;
  }

  /// دمج زاويتين باستخدام Exponential Moving Average (EMA)
  /// يُستخدم لتنعيم قراءات البوصلة
  static double smoothAngle(double currentAngle, double newAngle, double alpha) {
    // معالجة حالة العبور من 360 إلى 0
    double delta = shortestAngleDelta(currentAngle, newAngle);
    double smoothed = currentAngle + alpha * delta;

    // تطبيع النتيجة لتكون بين 0 و 360
    return (smoothed + 360) % 360;
  }

  /// التحقق من دقة الموقع
  /// يرجع true إذا كانت دقة الموقع جيدة
  static bool isLocationAccurate(Position position) {
    // نعتبر الموقع دقيق إذا كانت دقته أقل من 50 متر
    return position.accuracy <= 50.0;
  }

  /// حساب مستوى الثقة بناءً على دقة الموقع
  /// يرجع قيمة من 0 إلى 100
  static double calculateLocationConfidence(Position position) {
    final accuracy = position.accuracy;

    if (accuracy <= 10) return 100.0; // ممتاز
    if (accuracy <= 20) return 90.0;  // جيد جداً
    if (accuracy <= 50) return 75.0;  // جيد
    if (accuracy <= 100) return 50.0; // مقبول

    return 25.0; // ضعيف
  }

  /// تحسين دقة حساب القبلة باستخدام متوسط عدة قراءات
  static double calculateAverageQibla(List<Position> positions) {
    if (positions.isEmpty) return 0.0;
    if (positions.length == 1) {
      return calculateQiblaDirection(positions.first);
    }

    // حساب متوسط الاتجاهات باستخدام circular mean
    double sumX = 0.0;
    double sumY = 0.0;

    for (final position in positions) {
      final qibla = calculateQiblaDirection(position);
      final rad = _toRadians(qibla);
      sumX += math.cos(rad);
      sumY += math.sin(rad);
    }

    final meanRad = math.atan2(sumY, sumX);
    final meanDegrees = _toDegrees(meanRad);

    return (meanDegrees + 360) % 360;
  }
}
