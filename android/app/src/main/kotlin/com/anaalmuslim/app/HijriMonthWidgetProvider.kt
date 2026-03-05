package com.anaalmuslim.app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.os.Bundle
import android.util.TypedValue
import android.view.View
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

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        updateWidget(context, appWidgetManager, appWidgetId)
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
            val profile = WidgetHelper.resolveSizeProfile(appWidgetManager, appWidgetId)

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

            val rootPadding = when (profile) {
                WidgetHelper.WidgetSizeProfile.COMPACT -> 2
                WidgetHelper.WidgetSizeProfile.MEDIUM -> 4
                WidgetHelper.WidgetSizeProfile.LARGE -> 6
            }
            val rootPaddingPx = WidgetHelper.dp(context, rootPadding)
            views.setViewPadding(R.id.widgetRoot, rootPaddingPx, rootPaddingPx, rootPaddingPx, rootPaddingPx)

            // Month name as calligraphy bitmap
            val monthName = prefs.getString("hijri_month_name", "") ?: ""
            if (monthName.isNotEmpty()) {
                val monthTextSize = when (profile) {
                    WidgetHelper.WidgetSizeProfile.COMPACT -> 140f
                    WidgetHelper.WidgetSizeProfile.MEDIUM -> 180f
                    WidgetHelper.WidgetSizeProfile.LARGE -> 220f
                }
                val monthBitmap = WidgetHelper.renderTextAsBitmap(
                    context,
                    monthName,
                    textColor,
                    R.font.ayman,
                    monthTextSize,
                )
                if (monthBitmap != null) {
                    views.setImageViewBitmap(R.id.monthImage, monthBitmap)
                    views.setViewVisibility(R.id.monthImage, View.VISIBLE)
                } else {
                    views.setViewVisibility(R.id.monthImage, View.GONE)
                }
            } else {
                views.setViewVisibility(R.id.monthImage, View.GONE)
            }

            // Month number
            val monthNumber = when (val raw = prefs.all["hijri_month_number"]) {
                is Int -> raw
                is Long -> raw.toInt()
                is String -> raw.toIntOrNull() ?: 0
                else -> 0
            }
            val monthNumStr = if (monthNumber in 1..12) {
                WidgetHelper.formatDigits(monthNumber.toString(), numberFormat)
            } else {
                ""
            }
            views.setTextViewText(R.id.txtMonthNumber, monthNumStr)
            views.setTextColor(R.id.txtMonthNumber, textColor)
            views.setViewVisibility(
                R.id.txtMonthNumber,
                if (monthNumStr.isEmpty()) View.GONE else View.VISIBLE,
            )

            val monthNumberTextSize = when (profile) {
                WidgetHelper.WidgetSizeProfile.COMPACT -> 34f
                WidgetHelper.WidgetSizeProfile.MEDIUM -> 44f
                WidgetHelper.WidgetSizeProfile.LARGE -> 55f
            }
            views.setTextViewTextSize(R.id.txtMonthNumber, TypedValue.COMPLEX_UNIT_SP, monthNumberTextSize)

            // Launch app on click
            if (!prefs.getBoolean("disableWidgetClick", false)) {
                WidgetHelper.setLaunchIntent(context, views, R.id.widgetRoot, 4)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
