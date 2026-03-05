package com.anaalmuslim.app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.graphics.Color
import android.os.Bundle
import android.util.TypedValue
import android.view.View
import android.widget.RemoteViews

class TransparentWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
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
            val ids = manager.getAppWidgetIds(ComponentName(context, TransparentWidgetProvider::class.java))
            for (id in ids) {
                updateWidget(context, manager, id)
            }
        }

        fun updateWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
            val prefs = context.getSharedPreferences(WidgetHelper.PREFS_NAME, Context.MODE_PRIVATE)
            val views = RemoteViews(context.packageName, R.layout.transparent_widget)
            val profile = WidgetHelper.resolveSizeProfile(appWidgetManager, appWidgetId)

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

            val hijri = prefs.getString("hijri_simple", "—") ?: "—"
            val gregorian = prefs.getString("gregorian_simple", "—") ?: "—"
            val prayerName = prefs.getString("next_prayer_name_simple", "—") ?: "—"
            val prayerTime = prefs.getString("next_prayer_time", "—") ?: "—"

            val dateText = "$hijri • $gregorian"
            val prayerText = "$prayerName: $prayerTime"

            val textColorStr = prefs.getString("widget_text_color", "#FFFFFF") ?: "#FFFFFF"
            val effectiveColor = try {
                Color.parseColor(textColorStr)
            } catch (e: Exception) {
                Color.WHITE
            }

            val calligraphySize = when (profile) {
                WidgetHelper.WidgetSizeProfile.COMPACT -> 180f
                WidgetHelper.WidgetSizeProfile.MEDIUM -> 230f
                WidgetHelper.WidgetSizeProfile.LARGE -> 280f
            }
            val dayBitmap = WidgetHelper.renderTextAsBitmap(
                context,
                resolvedDigit,
                effectiveColor,
                R.font.calligraphy_days,
                textSize = calligraphySize,
            )

            if (dayBitmap != null) {
                views.setImageViewBitmap(R.id.widget_day_image, dayBitmap)
                views.setViewVisibility(R.id.widget_day_image, View.VISIBLE)
            } else {
                views.setViewVisibility(R.id.widget_day_image, View.GONE)
            }

            views.setTextViewText(R.id.widget_date_text, dateText)
            views.setTextViewText(R.id.widget_prayer_text, prayerText)
            views.setTextColor(R.id.widget_date_text, effectiveColor)
            views.setTextColor(R.id.widget_prayer_text, effectiveColor)

            val rootPaddingDp = when (profile) {
                WidgetHelper.WidgetSizeProfile.COMPACT -> 4
                WidgetHelper.WidgetSizeProfile.MEDIUM -> 8
                WidgetHelper.WidgetSizeProfile.LARGE -> 10
            }
            val rootPaddingPx = WidgetHelper.dp(context, rootPaddingDp)
            views.setViewPadding(
                R.id.widget_root,
                rootPaddingPx,
                rootPaddingPx,
                rootPaddingPx,
                rootPaddingPx,
            )

            val dateTextSize = when (profile) {
                WidgetHelper.WidgetSizeProfile.COMPACT -> 10f
                WidgetHelper.WidgetSizeProfile.MEDIUM -> 12f
                WidgetHelper.WidgetSizeProfile.LARGE -> 13f
            }
            val prayerTextSize = when (profile) {
                WidgetHelper.WidgetSizeProfile.COMPACT -> 9f
                WidgetHelper.WidgetSizeProfile.MEDIUM -> 11f
                WidgetHelper.WidgetSizeProfile.LARGE -> 12f
            }
            views.setTextViewTextSize(R.id.widget_date_text, TypedValue.COMPLEX_UNIT_SP, dateTextSize)
            views.setTextViewTextSize(R.id.widget_prayer_text, TypedValue.COMPLEX_UNIT_SP, prayerTextSize)

            if (profile == WidgetHelper.WidgetSizeProfile.COMPACT) {
                views.setViewVisibility(R.id.widget_prayer_text, View.GONE)
                views.setViewVisibility(R.id.widget_divider, View.GONE)
            } else {
                views.setViewVisibility(R.id.widget_prayer_text, View.VISIBLE)
                views.setViewVisibility(R.id.widget_divider, View.VISIBLE)
            }

            if (!prefs.getBoolean("disableWidgetClick", false)) {
                WidgetHelper.setLaunchIntent(context, views, R.id.widget_root, 2)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
