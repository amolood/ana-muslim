package com.anaalmuslim.app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.widget.RemoteViews

/**
 * Home-screen widget showing day calligraphy + hijri & gregorian dates.
 *
 * SharedPreferences keys (in "HomeWidgetPreferences"):
 *   day_name        — Arabic day name (e.g. "الجمعة")
 *   hijri_date      — Hijri date string
 *   gregorian_date  — Gregorian date string
 *   numberFormat    — "arabic" or "english"
 *   widgetStyle     — style key (default "fff")
 *   date_textColor_{style}, date_finalWidgetColor_{style}, etc.
 */
class DateWidgetProvider : AppWidgetProvider() {

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
        // Day name → digit for calligraphy font rendering
        private val DAY_MAP = mapOf(
            "الأحد" to "1", "الاثنين" to "2", "الثلاثاء" to "3",
            "الأربعاء" to "4", "الخميس" to "5", "الجمعة" to "6", "السبت" to "7"
        )

        fun updateAllWidgets(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(
                ComponentName(context, DateWidgetProvider::class.java)
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
            val views = RemoteViews(context.packageName, R.layout.date_widget)

            val style = prefs.getString("widgetStyle", "fff") ?: "fff"
            val numberFormat = prefs.getAll()["numberFormat"]?.toString() ?: "arabic"

            // Text color
            val textColor = WidgetHelper.parseColor(
                prefs.getString("date_textColor_$style", null),
                0xFFFFFFFF.toInt()
            )

            // Apply background + decor
            try {
                WidgetHelper.applyBackground(context, views, prefs, "date_", style)
            } catch (_: Exception) {}

            // Day calligraphy image
            val dayName = prefs.getString("day_name", "—") ?: "—"
            val calligraphyDigit = DAY_MAP.entries
                .firstOrNull { dayName.contains(it.key) }?.value ?: dayName

            val dayBitmap = WidgetHelper.renderTextAsBitmap(
                context, calligraphyDigit, textColor, R.font.calligraphy_days
            )
            if (dayBitmap != null) {
                views.setImageViewBitmap(R.id.dayImage, dayBitmap)
                views.setViewVisibility(R.id.dayImage, android.view.View.VISIBLE)
            } else {
                views.setViewVisibility(R.id.dayImage, android.view.View.GONE)
            }

            // Date texts
            val hijriDate = prefs.getString("hijri_date", "—") ?: "—"
            val gregorianDate = prefs.getString("gregorian_date", "—") ?: "—"

            val hijriFormatted = WidgetHelper.formatDigits(hijriDate, numberFormat)
            val gregorianFormatted = WidgetHelper.formatDigits(gregorianDate, numberFormat)

            views.setTextViewText(R.id.txtHijri, hijriFormatted)
            views.setTextViewText(R.id.txtDate, gregorianFormatted)
            views.setTextColor(R.id.txtHijri, textColor)
            views.setTextColor(R.id.txtDate, textColor)
            views.setTextColor(R.id.txtDivider, textColor)

            // Launch app on click
            if (!prefs.getBoolean("disableWidgetClick", false)) {
                WidgetHelper.setLaunchIntent(context, views, R.id.widgetRoot, 3)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
