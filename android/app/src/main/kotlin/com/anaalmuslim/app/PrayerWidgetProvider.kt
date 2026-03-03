package com.anaalmuslim.app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.widget.RemoteViews

/**
 * Home-screen widget showing all 5 daily prayer times.
 * Data is saved by Flutter via the home_widget package.
 *
 * SharedPreferences keys (in "HomeWidgetPreferences"):
 *   fajr_raw, dhuhr_raw, asr_raw, maghrib_raw, isha_raw  — "HH:mm" 24h
 *   numberFormat  — "arabic" or "english"
 *   use12h        — boolean
 *   widgetStyle   — style key (default "fff")
 *   prayer_textColor_{style}, prayer_finalWidgetColor_{style},
 *   prayer_backgroundOpacity_{style}, prayer_decorOpacity_{style},
 *   prayer_widgetRadius_{style}, prayer_nameFontSize_{style},
 *   prayer_timeFontSize_{style}, prayer_decorImage_{style},
 *   prayer_decorColor_{style}
 */
class PrayerWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (id in appWidgetIds) {
            updateWidget(context, appWidgetManager, id)
        }
    }

    companion object {
        private val PRAYER_SLOTS = listOf(
            Triple(R.id.fajr, R.id.fajr_title, "fajr_raw"),
            Triple(R.id.dhuhr, R.id.dhuhr_title, "dhuhr_raw"),
            Triple(R.id.asr, R.id.asr_title, "asr_raw"),
            Triple(R.id.maghrib, R.id.maghrib_title, "maghrib_raw"),
            Triple(R.id.isha, R.id.isha_title, "isha_raw"),
        )

        fun updateAllWidgets(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(
                ComponentName(context, PrayerWidgetProvider::class.java)
            )
            for (id in ids) {
                updateWidget(context, manager, id)
            }
        }

        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val prefs = context.getSharedPreferences(WidgetHelper.PREFS_NAME, Context.MODE_PRIVATE)
            val views = RemoteViews(context.packageName, R.layout.prayer_widget)

            val style = prefs.getString("widgetStyle", "fff") ?: "fff"
            val numberFormat = prefs.getAll()["numberFormat"]?.toString() ?: "arabic"
            val use12h = prefs.getBoolean("use12h", true)
            val allPrefs = prefs.getAll()

            // Text color
            val textColor = WidgetHelper.parseColor(
                prefs.getString("prayer_textColor_$style", null),
                0xFFFFFFFF.toInt()
            )

            // Font sizes
            val nameFontSize = WidgetHelper.safeFloat(allPrefs["prayer_nameFontSize_$style"], 12f)
            val timeFontSize = WidgetHelper.safeFloat(allPrefs["prayer_timeFontSize_$style"], 14f)

            // Apply background + decor
            try {
                WidgetHelper.applyBackground(context, views, prefs, "prayer_", style)
            } catch (_: Exception) {}

            // Set each prayer time + title
            for ((timeViewId, titleViewId, prefsKey) in PRAYER_SLOTS) {
                val rawTime = prefs.getString(prefsKey, "--:--")
                val formatted = WidgetHelper.formatTime(rawTime, numberFormat, use12h)

                views.setTextViewText(timeViewId, formatted)
                views.setTextColor(timeViewId, textColor)
                views.setTextViewTextSize(timeViewId, 2, timeFontSize)

                views.setTextColor(titleViewId, textColor)
                views.setTextViewTextSize(titleViewId, 2, nameFontSize)
            }

            // Launch app on click
            if (!prefs.getBoolean("disableWidgetClick", false)) {
                WidgetHelper.setLaunchIntent(context, views, R.id.widget_root, 1)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
