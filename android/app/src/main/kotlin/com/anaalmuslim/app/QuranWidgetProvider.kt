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
 * Home-screen widget that shows a random Quran verse.
 * Verse pool is pre-saved by Flutter via the home_widget package.
 */
class QuranWidgetProvider : AppWidgetProvider() {

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

        fun advanceVerseIndex(context: Context) {
            val prefs = context.getSharedPreferences(WidgetHelper.PREFS_NAME, Context.MODE_PRIVATE)
            val count = prefs.getInt("verse_count", 0)
            if (count > 0) {
                val current = prefs.getInt("verse_index", 0)
                prefs.edit().putInt("verse_index", (current + 1) % count).apply()
            }
        }

        fun updateAllWidgets(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(
                ComponentName(context, QuranWidgetProvider::class.java)
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
            val count = prefs.getInt("verse_count", 0)
            val index = prefs.getInt("verse_index", 0)

            val verseText: String = if (count > 0) {
                prefs.getString("verse_text_$index", defaultVerse) ?: defaultVerse
            } else {
                defaultVerse
            }
            val verseRef: String = if (count > 0) {
                prefs.getString("verse_ref_$index", defaultRef) ?: defaultRef
            } else {
                defaultRef
            }

            val views = RemoteViews(context.packageName, R.layout.quran_widget)
            val profile = WidgetHelper.resolveSizeProfile(appWidgetManager, appWidgetId)
            views.setTextViewText(R.id.widget_verse, verseText)
            views.setTextViewText(R.id.widget_ref, verseRef)

            val contentPadding = when (profile) {
                WidgetHelper.WidgetSizeProfile.COMPACT -> 8
                WidgetHelper.WidgetSizeProfile.MEDIUM -> 12
                WidgetHelper.WidgetSizeProfile.LARGE -> 16
            }
            val contentPaddingPx = WidgetHelper.dp(context, contentPadding)
            views.setViewPadding(
                R.id.widget_content,
                contentPaddingPx,
                contentPaddingPx,
                contentPaddingPx,
                contentPaddingPx,
            )

            val verseTextSize = when (profile) {
                WidgetHelper.WidgetSizeProfile.COMPACT -> 16f
                WidgetHelper.WidgetSizeProfile.MEDIUM -> 20f
                WidgetHelper.WidgetSizeProfile.LARGE -> 22f
            }
            val refTextSize = when (profile) {
                WidgetHelper.WidgetSizeProfile.COMPACT -> 10f
                WidgetHelper.WidgetSizeProfile.MEDIUM -> 11f
                WidgetHelper.WidgetSizeProfile.LARGE -> 12f
            }
            views.setTextViewTextSize(R.id.widget_verse, TypedValue.COMPLEX_UNIT_SP, verseTextSize)
            views.setTextViewTextSize(R.id.widget_ref, TypedValue.COMPLEX_UNIT_SP, refTextSize)

            if (profile == WidgetHelper.WidgetSizeProfile.COMPACT) {
                views.setViewVisibility(R.id.widget_brand, View.GONE)
                views.setViewVisibility(R.id.widget_divider, View.GONE)
            } else {
                views.setViewVisibility(R.id.widget_brand, View.VISIBLE)
                views.setViewVisibility(R.id.widget_divider, View.VISIBLE)
            }

            // Apply the dark background programmatically so the XML layout can safely
            // declare android:background="@android:color/transparent". This avoids the
            // HnCurvatureRoundUtils NumberFormatException crash on Huawei/Honor launchers
            // which only fires during layout inflation, not during onUpdate().
            try {
                views.setInt(R.id.widget_root, "setBackgroundResource", R.drawable.quran_widget_bg)
            } catch (e: Exception) { /* fallback: transparent background is still readable */ }

            // Open app when any part of the widget is tapped
            val launchIntent = context.packageManager
                .getLaunchIntentForPackage(context.packageName)
            if (launchIntent != null) {
                val pendingIntent = android.app.PendingIntent.getActivity(
                    context, 0, launchIntent,
                    android.app.PendingIntent.FLAG_UPDATE_CURRENT or
                            android.app.PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        private const val defaultVerse = "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ"
        private const val defaultRef = "سورة الفاتحة • آية ١"
    }
}
