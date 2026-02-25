package com.anaalmuslim.app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.graphics.*
import android.widget.RemoteViews
import androidx.core.content.res.ResourcesCompat

class TransparentWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (id in appWidgetIds) {
            updateWidget(context, appWidgetManager, id)
        }
    }

    companion object {
        private const val PREFS_NAME = "HomeWidgetPreferences"

        fun updateAllWidgets(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, TransparentWidgetProvider::class.java))
            for (id in ids) {
                updateWidget(context, manager, id)
            }
        }

        fun updateWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            
            val views = RemoteViews(context.packageName, R.layout.transparent_widget)
            
            val dayName = prefs.getString("day_name", "—") ?: "—"
            val hijri = prefs.getString("hijri_simple", "—")
            val gregorian = prefs.getString("gregorian_simple", "—")
            val prayerName = prefs.getString("next_prayer_name_simple", "—")
            val prayerTime = prefs.getString("next_prayer_time", "—")

            val dateText = "$hijri • $gregorian"
            val prayerText = "$prayerName: $prayerTime"
            
            // Customizable text color (main text only)
            val textColorStr = prefs.getString("widget_text_color", "#FFFFFF") ?: "#FFFFFF"
            val effectiveColor = try { Color.parseColor(textColorStr) } catch (e: Exception) { Color.WHITE }

            // Map day name to calligraphic manuscript digit and render as Bitmap
            val calligraphicDigit = mapDayToCalligraphy(dayName)
            val dayBitmap = renderCalligraphyAsBitmap(context, calligraphicDigit, effectiveColor)
            
            if (dayBitmap != null) {
                views.setImageViewBitmap(R.id.widget_day_image, dayBitmap)
            }
            
            views.setTextViewText(R.id.widget_date_text, dateText)
            views.setTextViewText(R.id.widget_prayer_text, prayerText)

            try {
                views.setTextColor(R.id.widget_date_text, effectiveColor)
            } catch (e: Exception) {}

            val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            if (launchIntent != null) {
                val pendingIntent = android.app.PendingIntent.getActivity(
                    context, 2, launchIntent,
                    android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        private fun renderCalligraphyAsBitmap(context: Context, text: String, color: Int): Bitmap? {
            return try {
                val paint = Paint(Paint.ANTI_ALIAS_FLAG)
                paint.textSize = 280f // Large size for clarity
                paint.color = color
                paint.textAlign = Paint.Align.CENTER
                
                val typeface = ResourcesCompat.getFont(context, R.font.calligraphy_days)
                paint.typeface = typeface

                val baseline = -paint.ascent() 
                val width = (paint.measureText(text)).toInt() + 40
                val height = (baseline + paint.descent()).toInt() + 40

                val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
                val canvas = Canvas(bitmap)
                canvas.drawText(text, width / 2f, baseline + 20f, paint)
                bitmap
            } catch (e: Exception) {
                null
            }
        }

        private fun mapDayToCalligraphy(day: String): String {
            return when {
                day.contains("الأحد") -> "1"
                day.contains("الاثنين") -> "2"
                day.contains("الثلاثاء") -> "3"
                day.contains("الأربعاء") -> "4"
                day.contains("الخميس") -> "5"
                day.contains("الجمعة") -> "6"
                day.contains("السبت") -> "7"
                else -> day 
            }
        }
    }
}
