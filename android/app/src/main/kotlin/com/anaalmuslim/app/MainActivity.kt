package com.anaalmuslim.app

import android.app.PictureInPictureParams
import android.content.pm.PackageManager
import android.os.Build
import android.util.Rational
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {
    companion object {
        private const val PIP_CHANNEL = "im_muslim/pip"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PIP_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isSupported" -> result.success(isPipSupported())
                    "enterPipMode" -> result.success(enterPipMode(call))
                    else -> result.notImplemented()
                }
            }

        PrayerSilenceChannel.register(this, flutterEngine.dartExecutor.binaryMessenger)
    }

    private fun isPipSupported(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return false
        return packageManager.hasSystemFeature(PackageManager.FEATURE_PICTURE_IN_PICTURE)
    }

    private fun enterPipMode(call: MethodCall): Boolean {
        if (!isPipSupported()) return false

        val numeratorRaw = call.argument<Int>("numerator") ?: 16
        val denominatorRaw = call.argument<Int>("denominator") ?: 9
        val numerator = numeratorRaw.coerceIn(1, 23939)
        val denominator = denominatorRaw.coerceIn(1, 23939)

        val params = PictureInPictureParams.Builder()
            .setAspectRatio(Rational(numerator, denominator))
            .build()

        setPictureInPictureParams(params)
        return enterPictureInPictureMode(params)
    }
}
