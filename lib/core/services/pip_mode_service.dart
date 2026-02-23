import 'package:flutter/services.dart';

class PipModeService {
  PipModeService._();

  static const MethodChannel _channel = MethodChannel('im_muslim/pip');

  static Future<bool> isSupported() async {
    try {
      final supported = await _channel.invokeMethod<bool>('isSupported');
      return supported ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> enterPipMode({
    int? aspectRatioNumerator,
    int? aspectRatioDenominator,
  }) async {
    try {
      final entered = await _channel.invokeMethod<bool>('enterPipMode', {
        if (aspectRatioNumerator != null && aspectRatioNumerator > 0)
          'numerator': aspectRatioNumerator,
        if (aspectRatioDenominator != null && aspectRatioDenominator > 0)
          'denominator': aspectRatioDenominator,
      });
      return entered ?? false;
    } catch (_) {
      return false;
    }
  }
}
