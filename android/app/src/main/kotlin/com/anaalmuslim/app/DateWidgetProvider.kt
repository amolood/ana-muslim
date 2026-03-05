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
            val profile = WidgetHelper.resolveSizeProfile(appWidgetManager, appWidgetId)

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

            // Day calligraphy image (new robust key chain with legacy fallback)
            val dayName = prefs.getString("day_name", "—") ?: "—"
            val dayCalligraphyDigit = prefs.getString("day_calligraphy_digit", null)
            val dayIndexSun1: Int? = when (val raw = prefs.all["day_index_sun1"]) {
                is Int -> raw
                is Long -> raw.toInt()
                is String -> raw.toIntOrNull()
                else -> null
            }
            val resolvedDigit = WidgetHelper.resolveDayCalligraphyDigit(
                dayCalligraphyDigit = dayCalligraphyDigit,
                dayIndexSun1 = dayIndexSun1,
                legacyDayName = dayName,
            )

            val calligraphySize = when (profile) {
                WidgetHelper.WidgetSizeProfile.COMPACT -> 190f
                WidgetHelper.WidgetSizeProfile.MEDIUM -> 240f
                WidgetHelper.WidgetSizeProfile.LARGE -> 290f
            }
            val dayBitmap = WidgetHelper.renderTextAsBitmap(
                context,
                resolvedDigit,
                textColor,
                R.font.calligraphy_days,
                textSize = calligraphySize,
            )
            if (dayBitmap != null) {
                views.setImageViewBitmap(R.id.dayImage, dayBitmap)
                views.setViewVisibility(R.id.dayImage, View.VISIBLE)
            } else {
                views.setViewVisibility(R.id.dayImage, View.GONE)
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

            val rootPadding = when (profile) {
                WidgetHelper.WidgetSizeProfile.COMPACT -> 6
                WidgetHelper.WidgetSizeProfile.MEDIUM -> 8
                WidgetHelper.WidgetSizeProfile.LARGE -> 10
            }
            val rootPaddingPx = WidgetHelper.dp(context, rootPadding)
            views.setViewPadding(R.id.widgetRoot, rootPaddingPx, rootPaddingPx, rootPaddingPx, rootPaddingPx)

            val dateTextSize = when (profile) {
                WidgetHelper.WidgetSizeProfile.COMPACT -> 14f
                WidgetHelper.WidgetSizeProfile.MEDIUM -> 17f
                WidgetHelper.WidgetSizeProfile.LARGE -> 20f
            }
            val dividerTextSize = when (profile) {
                WidgetHelper.WidgetSizeProfile.COMPACT -> 12f
                WidgetHelper.WidgetSizeProfile.MEDIUM -> 15f
                WidgetHelper.WidgetSizeProfile.LARGE -> 18f
            }
            views.setTextViewTextSize(R.id.txtDate, TypedValue.COMPLEX_UNIT_SP, dateTextSize)
            views.setTextViewTextSize(R.id.txtHijri, TypedValue.COMPLEX_UNIT_SP, dateTextSize)
            views.setTextViewTextSize(R.id.txtDivider, TypedValue.COMPLEX_UNIT_SP, dividerTextSize)

            if (profile == WidgetHelper.WidgetSizeProfile.COMPACT) {
                views.setViewVisibility(R.id.txtDate, View.GONE)
                views.setViewVisibility(R.id.txtDivider, View.GONE)
            } else {
                views.setViewVisibility(R.id.txtDate, View.VISIBLE)
                views.setViewVisibility(R.id.txtDivider, View.VISIBLE)
            }

            // Launch app on click
            if (!prefs.getBoolean("disableWidgetClick", false)) {
                WidgetHelper.setLaunchIntent(context, views, R.id.widgetRoot, 3)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
