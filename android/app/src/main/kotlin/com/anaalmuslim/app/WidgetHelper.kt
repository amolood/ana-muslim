package com.anaalmuslim.app

import android.content.Context
import android.content.SharedPreferences
import android.graphics.*
import android.os.Build
import android.widget.RemoteViews
import androidx.core.content.res.ResourcesCompat

/**
 * Shared utilities for all home-screen widgets.
 * Handles digit conversion, time formatting, background/decor styling.
 */
object WidgetHelper {
    const val PREFS_NAME = "HomeWidgetPreferences"

    // ── Digit conversion ────────────────────────────────────────────────
    private val latinToArabic = mapOf(
        '0' to '٠', '1' to '١', '2' to '٢', '3' to '٣', '4' to '٤',
        '5' to '٥', '6' to '٦', '7' to '٧', '8' to '٨', '9' to '٩'
    )

    fun toArabicDigits(input: String): String =
        input.map { latinToArabic[it] ?: it }.joinToString("")

    fun formatDigits(input: String, numberFormat: String): String =
        if (numberFormat == "arabic") toArabicDigits(input) else input

    // ── Time formatting ────────────────────────────────────────────────
    fun formatTime(raw: String?, numberFormat: String, use12h: Boolean): String {
        if (raw.isNullOrEmpty() || raw == "--:--") return formatDigits("--:--", numberFormat)
        val formatted = if (use12h) convertTo12h(raw) else raw
        return formatDigits(formatted, numberFormat)
    }

    private fun convertTo12h(time24: String): String {
        return try {
            val parts = time24.split(":")
            val hour = parts[0].toInt()
            val minute = parts[1]
            val suffix = if (hour >= 12) "م" else "ص"
            val hour12 = when {
                hour == 0 -> 12
                hour > 12 -> hour - 12
                else -> hour
            }
            "$hour12:$minute $suffix"
        } catch (e: Exception) {
            time24
        }
    }

    // ── Float parsing (handles home_widget's Long-encoded doubles) ──────
    fun safeFloat(obj: Any?, default: Float): Float {
        return when (obj) {
            is Double -> obj.toFloat()
            is Float -> obj
            is Int -> obj.toFloat()
            is Long -> {
                // home_widget encodes Dart doubles as Long via Double.doubleToRawLongBits
                if (obj > 1000L) java.lang.Double.longBitsToDouble(obj).toFloat()
                else obj.toFloat()
            }
            is String -> obj.toFloatOrNull() ?: default
            else -> default
        }
    }

    // ── Color parsing ──────────────────────────────────────────────────
    fun parseColor(hexStr: String?, default: Int): Int {
        if (hexStr.isNullOrEmpty()) return default
        return try {
            java.lang.Long.parseLong(hexStr, 16).toInt()
        } catch (e: Exception) {
            default
        }
    }

    // ── Background drawable selection ───────────────────────────────────
    fun getBackgroundDrawable(radius: Float): Int = when {
        radius <= 10f -> R.drawable.widget_bg_10
        radius <= 25f -> R.drawable.widget_bg_25
        radius <= 45f -> R.drawable.widget_bg_45
        radius <= 75f -> R.drawable.widget_bg_75
        else -> R.drawable.widget_bg_100
    }

    fun getRoundedImageDrawable(radius: Float): Int = when {
        radius <= 10f -> R.drawable.rounded_image_10
        radius <= 25f -> R.drawable.rounded_image_25
        radius <= 45f -> R.drawable.rounded_image_45
        radius <= 75f -> R.drawable.rounded_image_75
        else -> R.drawable.rounded_image_100
    }

    // ── Apply background + decor styling ────────────────────────────────
    fun applyBackground(
        context: Context,
        views: RemoteViews,
        prefs: SharedPreferences,
        stylePrefix: String,   // e.g. "prayer_", "date_", "hijri_"
        style: String
    ) {
        val allPrefs = prefs.all

        val bgColor = parseColor(
            prefs.getString("${stylePrefix}finalWidgetColor_$style", null),
            0xFF333333.toInt()
        )
        val bgOpacity = safeFloat(allPrefs["${stylePrefix}backgroundOpacity_$style"], 0.4f)
            .coerceIn(0f, 1f)
        val decorColor = parseColor(
            prefs.getString("${stylePrefix}decorColor_$style", null),
            -1 // white
        )
        val decorOpacity = safeFloat(allPrefs["${stylePrefix}decorOpacity_$style"], 0.2f)
            .coerceIn(0f, 1f)
        val radius = safeFloat(allPrefs["${stylePrefix}widgetRadius_$style"], 40f)
            .coerceIn(5f, 105f)

        val bgDrawable = getBackgroundDrawable(radius)
        val roundedDrawable = getRoundedImageDrawable(radius)

        if (Build.VERSION.SDK_INT >= 31) {
            try {
                views.setBoolean(R.id.widgetBackgroundLayer, "setClipToOutline", true)
            } catch (_: Exception) {}
        }

        views.setImageViewResource(R.id.widgetBackgroundLayer, bgDrawable)
        views.setInt(R.id.widgetBackgroundLayer, "setColorFilter", bgColor)
        views.setInt(R.id.widgetBackgroundLayer, "setImageAlpha", (bgOpacity * 255).toInt())

        // Decor overlay image
        val decorImageName = prefs.getString("${stylePrefix}decorImage_$style", "decor_1")
        if (!decorImageName.isNullOrEmpty()) {
            val resId = context.resources.getIdentifier(decorImageName, "drawable", context.packageName)
            if (resId != 0) {
                views.setViewVisibility(R.id.decorImage, android.view.View.VISIBLE)
                views.setImageViewResource(R.id.decorImage, resId)
                views.setInt(R.id.decorImage, "setBackgroundResource", roundedDrawable)
                views.setInt(R.id.decorImage, "setColorFilter", decorColor)
                views.setInt(R.id.decorImage, "setImageAlpha", (decorOpacity * 255).toInt())
            } else {
                views.setViewVisibility(R.id.decorImage, android.view.View.GONE)
            }
        }
    }

    // ── Launch-app PendingIntent ────────────────────────────────────────
    fun setLaunchIntent(context: Context, views: RemoteViews, viewId: Int, requestCode: Int) {
        val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        if (launchIntent != null) {
            val pendingIntent = android.app.PendingIntent.getActivity(
                context, requestCode, launchIntent,
                android.app.PendingIntent.FLAG_UPDATE_CURRENT or
                        android.app.PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(viewId, pendingIntent)
        }
    }

    // ── Bitmap rendering (for calligraphy text) ─────────────────────────
    fun renderTextAsBitmap(
        context: Context,
        text: String,
        color: Int,
        fontResId: Int,
        textSize: Float = 280f
    ): Bitmap? {
        return try {
            val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                this.textSize = textSize
                this.color = color
                textAlign = Paint.Align.CENTER
                typeface = ResourcesCompat.getFont(context, fontResId)
            }
            val baseline = -paint.ascent()
            val width = paint.measureText(text).toInt() + 40
            val height = (baseline + paint.descent()).toInt() + 40
            val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
            Canvas(bitmap).drawText(text, width / 2f, baseline + 20f, paint)
            bitmap
        } catch (e: Exception) {
            null
        }
    }
}
