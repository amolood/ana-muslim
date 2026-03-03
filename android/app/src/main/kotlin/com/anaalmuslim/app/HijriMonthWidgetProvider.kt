package com.anaalmuslim.app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.widget.RemoteViews

/**
 * Home-screen widget showing the current Hijri month name + number.
 *
 * SharedPreferences keys (in "HomeWidgetPreferences"):
 *   hijri_month_number — 1-12
 *   hijri_month_name   — Arabic month name
 *   numberFormat       — "arabic" or "english"
 *   widgetStyle        — style key (default "fff")
 *   hijri_textColor_{style}, hijri_finalWidgetColor_{style}, etc.
 */
class HijriMonthWidgetProvider : AppWidgetProvider() {

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
        fun updateAllWidgets(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(
                ComponentName(context, HijriMonthWidgetProvider::class.java)
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
            val views = RemoteViews(context.packageName, R.layout.hijri_month_widget)

            val style = prefs.getString("widgetStyle", "fff") ?: "fff"
            val numberFormat = prefs.getAll()["numberFormat"]?.toString() ?: "arabic"

            // Text color
            val textColor = WidgetHelper.parseColor(
                prefs.getString("hijri_textColor_$style", null),
                0xCCFFFFFF.toInt()
            )

            // Apply background + decor
            try {
                WidgetHelper.applyBackground(context, views, prefs, "hijri_", style)
            } catch (_: Exception) {}

            // Month name as calligraphy bitmap
            val monthName = prefs.getString("hijri_month_name", "") ?: ""
            if (monthName.isNotEmpty()) {
                val monthBitmap = WidgetHelper.renderTextAsBitmap(
                    context, monthName, textColor, R.font.ayman, 200f
                )
                if (monthBitmap != null) {
                    views.setImageViewBitmap(R.id.monthImage, monthBitmap)
                    views.setViewVisibility(R.id.monthImage, android.view.View.VISIBLE)
                } else {
                    views.setViewVisibility(R.id.monthImage, android.view.View.GONE)
                }
            } else {
                views.setViewVisibility(R.id.monthImage, android.view.View.GONE)
            }

            // Month number
            val monthNumber = prefs.getInt("hijri_month_number", 0)
            val monthNumStr = if (monthNumber in 1..12) {
                WidgetHelper.formatDigits(monthNumber.toString(), numberFormat)
            } else {
                ""
            }
            views.setTextViewText(R.id.txtMonthNumber, monthNumStr)
            views.setTextColor(R.id.txtMonthNumber, textColor)

            // Launch app on click
            if (!prefs.getBoolean("disableWidgetClick", false)) {
                WidgetHelper.setLaunchIntent(context, views, R.id.widgetRoot, 4)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
