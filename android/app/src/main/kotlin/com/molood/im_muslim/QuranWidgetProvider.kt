package com.molood.im_muslim

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
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

    companion object {
        // home_widget plugin's SharedPreferences file name (matches HomeWidgetPlugin.kt PREFERENCES constant)
        private const val PREFS_NAME = "HomeWidgetPreferences"

        fun advanceVerseIndex(context: Context) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
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
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
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
            views.setTextViewText(R.id.widget_verse, verseText)
            views.setTextViewText(R.id.widget_ref, verseRef)

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
