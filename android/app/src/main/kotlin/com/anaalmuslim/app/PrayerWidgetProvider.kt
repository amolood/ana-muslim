package com.anaalmuslim.app

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Bundle
import android.view.View
import android.widget.RemoteViews
import java.util.Calendar

/**
 * Home-screen widget showing all 5 daily prayer times.
 *
 * Rendering approach (same as com.ayman.widget):
 *   All prayer names and time strings are rendered to Bitmap via Canvas+Paint+Typeface
 *   and set on ImageViews — because RemoteViews cannot apply custom fonts to TextViews.
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
        appWidgetIds: IntArray,
    ) {
        for (id in appWidgetIds) updateWidget(context, appWidgetManager, id)
        scheduleNextUpdate(context)
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle,
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        updateWidget(context, appWidgetManager, appWidgetId)
    }

    companion object {

        /** Four-tuple tying all view IDs for one prayer to its prefs key. */
        private data class PrayerSlot(
            val timeViewId: Int,
            val titleViewId: Int,
            val indicatorViewId: Int,
            val prefsKey: String,
            val defaultTitleFull: String,   // full name, e.g. "الفجر"
            val defaultTitleCompact: String, // compact abbrev, e.g. "ف"
        )

        private val PRAYER_SLOTS = listOf(
            PrayerSlot(R.id.fajr,    R.id.fajr_title,    R.id.next_prayer_indicator_fajr,    "fajr_raw",    "الفجر",   "ف"),
            PrayerSlot(R.id.dhuhr,   R.id.dhuhr_title,   R.id.next_prayer_indicator_dhuhr,   "dhuhr_raw",   "الظهر",   "ظ"),
            PrayerSlot(R.id.asr,     R.id.asr_title,     R.id.next_prayer_indicator_asr,     "asr_raw",     "العصر",   "ع"),
            PrayerSlot(R.id.maghrib, R.id.maghrib_title, R.id.next_prayer_indicator_maghrib, "maghrib_raw", "المغرب",  "م"),
            PrayerSlot(R.id.isha,    R.id.isha_title,    R.id.next_prayer_indicator_isha,    "isha_raw",    "العشاء",  "عش"),
        )

        // ── Time helpers ──────────────────────────────────────────────────────

        /** "HH:mm" → total minutes since midnight. Returns -1 on failure. */
        private fun parseMinutes(raw: String?): Int {
            if (raw.isNullOrBlank() || raw == "--:--") return -1
            val parts = raw.trim().split(":")
            if (parts.size < 2) return -1
            val h = parts[0].toIntOrNull() ?: return -1
            val m = parts[1].toIntOrNull() ?: return -1
            return h * 60 + m
        }

        /** Index (0-4) of the next upcoming prayer, or null if all passed today. */
        private fun findNextPrayerIndex(prefs: SharedPreferences): Int? {
            val now = Calendar.getInstance()
            val nowMin = now.get(Calendar.HOUR_OF_DAY) * 60 + now.get(Calendar.MINUTE)
            for ((index, slot) in PRAYER_SLOTS.withIndex()) {
                val pm = parseMinutes(prefs.getString(slot.prefsKey, null))
                if (pm > nowMin) return index
            }
            return null
        }

        /** Formatted countdown to [targetMinutes]. E.g. "١:٣٠" or "1:30". */
        private fun computeCountdown(targetMinutes: Int, numberFormat: String): String {
            val now = Calendar.getInstance()
            val nowMin = now.get(Calendar.HOUR_OF_DAY) * 60 + now.get(Calendar.MINUTE)
            var diff = targetMinutes - nowMin
            if (diff < 0) diff += 24 * 60
            val h = diff / 60
            val m = diff % 60
            val hStr = h.toString()
            val mStr = m.toString().padStart(2, '0')
            val raw = if (h > 0) "$hStr:$mStr" else "0:$mStr"
            return if (numberFormat == "arabic") WidgetHelper.toArabicDigits(raw) else raw
        }

        // ── AlarmManager scheduling ───────────────────────────────────────────

        fun scheduleNextUpdate(context: Context) {
            val prefs = context.getSharedPreferences(WidgetHelper.PREFS_NAME, Context.MODE_PRIVATE)
            val now = Calendar.getInstance()
            val nowMin = now.get(Calendar.HOUR_OF_DAY) * 60 + now.get(Calendar.MINUTE)

            var nextMs = -1L
            for (slot in PRAYER_SLOTS) {
                val pm = parseMinutes(prefs.getString(slot.prefsKey, null))
                if (pm > nowMin) {
                    nextMs = Calendar.getInstance().apply {
                        set(Calendar.HOUR_OF_DAY, pm / 60)
                        set(Calendar.MINUTE, pm % 60)
                        set(Calendar.SECOND, 0)
                        set(Calendar.MILLISECOND, 0)
                    }.timeInMillis
                    break
                }
            }
            // All passed → schedule tomorrow Fajr
            if (nextMs < 0) {
                val fajrMin = parseMinutes(prefs.getString("fajr_raw", null))
                if (fajrMin >= 0) {
                    nextMs = Calendar.getInstance().apply {
                        add(Calendar.DAY_OF_YEAR, 1)
                        set(Calendar.HOUR_OF_DAY, fajrMin / 60)
                        set(Calendar.MINUTE, fajrMin % 60)
                        set(Calendar.SECOND, 0)
                        set(Calendar.MILLISECOND, 0)
                    }.timeInMillis
                }
            }
            if (nextMs < 0) return

            val intent = Intent(context, PrayerWidgetProvider::class.java).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                putExtra(
                    AppWidgetManager.EXTRA_APPWIDGET_IDS,
                    AppWidgetManager.getInstance(context)
                        .getAppWidgetIds(ComponentName(context, PrayerWidgetProvider::class.java)),
                )
            }
            val pi = PendingIntent.getBroadcast(
                context, 8100, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            am.cancel(pi)
            am.set(AlarmManager.RTC, nextMs, pi)
        }

        // ── Public entry points ───────────────────────────────────────────────

        fun updateAllWidgets(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, PrayerWidgetProvider::class.java))
            for (id in ids) updateWidget(context, manager, id)
            scheduleNextUpdate(context)
        }

        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
        ) {
            val prefs = context.getSharedPreferences(WidgetHelper.PREFS_NAME, Context.MODE_PRIVATE)
            val views = RemoteViews(context.packageName, R.layout.prayer_widget)
            val profile = WidgetHelper.resolveSizeProfile(appWidgetManager, appWidgetId)

            val style = prefs.getString("widgetStyle", "fff") ?: "fff"
            val numberFormat = prefs.getAll()["numberFormat"]?.toString() ?: "arabic"
            val use12h = prefs.getBoolean("use12h", true)
            val allPrefs = prefs.getAll()

            // ── Colors ─────────────────────────────────────────────────────────
            val textColor = WidgetHelper.parseColor(
                prefs.getString("prayer_textColor_$style", null), 0xFFFFFFFF.toInt(),
            )
            // Dimmer color for prayer titles (same as ayman.widget's #AAAAAA default)
            val titleColor = blendWithAlpha(textColor, 0.7f)

            // ── Font sizes per profile ─────────────────────────────────────────
            val baseNameSp = WidgetHelper.safeFloat(allPrefs["prayer_nameFontSize_$style"], 13f)
            val baseTimeSp = WidgetHelper.safeFloat(allPrefs["prayer_timeFontSize_$style"], 15f)
            val fontScale = when (profile) {
                WidgetHelper.WidgetSizeProfile.COMPACT -> 0.80f
                WidgetHelper.WidgetSizeProfile.MEDIUM  -> 1.00f
                WidgetHelper.WidgetSizeProfile.LARGE   -> 1.15f
            }
            val nameSp = (baseNameSp * fontScale).coerceIn(9f, 18f)
            val timeSp = (baseTimeSp * fontScale).coerceIn(10f, 22f)

            // ── Background + decor ─────────────────────────────────────────────
            try { WidgetHelper.applyBackground(context, views, prefs, "prayer_", style) }
            catch (_: Exception) {}

            // ── Root padding ───────────────────────────────────────────────────
            val padDp = when (profile) {
                WidgetHelper.WidgetSizeProfile.COMPACT -> 6
                WidgetHelper.WidgetSizeProfile.MEDIUM  -> 10
                WidgetHelper.WidgetSizeProfile.LARGE   -> 12
            }
            val padPx = WidgetHelper.dp(context, padDp)
            val padVDp = when (profile) {
                WidgetHelper.WidgetSizeProfile.COMPACT -> 4
                WidgetHelper.WidgetSizeProfile.MEDIUM  -> 8
                WidgetHelper.WidgetSizeProfile.LARGE   -> 10
            }
            val padVPx = WidgetHelper.dp(context, padVDp)
            views.setViewPadding(R.id.widget_root, padPx, padVPx, padPx, padVPx)

            // ── Next prayer ────────────────────────────────────────────────────
            val nextIdx = findNextPrayerIndex(prefs)

            // ── Prayer columns ────────────────────────────────────────────────
            for ((index, slot) in PRAYER_SLOTS.withIndex()) {
                val rawTime = prefs.getString(slot.prefsKey, "--:--")
                val formattedTime = WidgetHelper.formatTime(rawTime, numberFormat, use12h)

                val titleText = if (profile == WidgetHelper.WidgetSizeProfile.COMPACT)
                    slot.defaultTitleCompact else slot.defaultTitleFull

                // Title bitmap (IBMPlexSansArabic Medium, dimmer)
                val titleBmp = WidgetHelper.renderTextBitmapSp(
                    context, titleText, titleColor,
                    R.font.ibm_plex_sans_arabic_medium, nameSp, padding = 20,
                )
                if (titleBmp != null) views.setImageViewBitmap(slot.titleViewId, titleBmp)

                // Time bitmap (IBMPlexSansArabic Bold, full color)
                val timeBmp = WidgetHelper.renderTextBitmapSp(
                    context, formattedTime, textColor,
                    R.font.ibm_plex_sans_arabic_bold, timeSp, padding = 40,
                )
                if (timeBmp != null) views.setImageViewBitmap(slot.timeViewId, timeBmp)

                // Indicator dot — show only for next prayer
                views.setViewVisibility(
                    slot.indicatorViewId,
                    if (index == nextIdx) View.VISIBLE else View.GONE,
                )
            }

            // ── Countdown row ─────────────────────────────────────────────────
            if (nextIdx != null && profile != WidgetHelper.WidgetSizeProfile.COMPACT) {
                val slot = PRAYER_SLOTS[nextIdx]
                val targetMin = parseMinutes(prefs.getString(slot.prefsKey, null))
                if (targetMin >= 0) {
                    val countdown = computeCountdown(targetMin, numberFormat)
                    val labelColor  = blendWithAlpha(textColor, 0.75f)
                    val countSp = (10f * fontScale).coerceIn(8f, 14f)

                    val labelBmp = WidgetHelper.renderTextBitmapSp(
                        context, "الوقت المتبقي: ", labelColor,
                        R.font.ibm_plex_sans_arabic_medium, countSp, padding = 10,
                    )
                    val countBmp = WidgetHelper.renderTextBitmapSp(
                        context, countdown, textColor,
                        R.font.ibm_plex_sans_arabic_bold, countSp, padding = 10,
                    )
                    if (labelBmp != null) views.setImageViewBitmap(R.id.remainingTitle, labelBmp)
                    if (countBmp != null) views.setImageViewBitmap(R.id.countdownText, countBmp)
                    views.setViewVisibility(R.id.nextPrayerCountdownContainer, View.VISIBLE)
                } else {
                    views.setViewVisibility(R.id.nextPrayerCountdownContainer, View.GONE)
                }
            } else {
                views.setViewVisibility(R.id.nextPrayerCountdownContainer, View.GONE)
            }

            // ── Click → open app ──────────────────────────────────────────────
            if (!prefs.getBoolean("disableWidgetClick", false)) {
                WidgetHelper.setLaunchIntent(context, views, R.id.widget_root, 1)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        /** Blend [color] with black at [alpha] (0f = black, 1f = original). */
        private fun blendWithAlpha(color: Int, alpha: Float): Int {
            val a = ((color ushr 24) and 0xFF)
            val r = ((color ushr 16) and 0xFF)
            val g = ((color ushr  8) and 0xFF)
            val b = (color           and 0xFF)
            val r2 = (r * alpha).toInt()
            val g2 = (g * alpha).toInt()
            val b2 = (b * alpha).toInt()
            return (a shl 24) or (r2 shl 16) or (g2 shl 8) or b2
        }
    }
}
