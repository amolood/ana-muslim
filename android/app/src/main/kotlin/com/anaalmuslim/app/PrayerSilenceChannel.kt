package com.anaalmuslim.app

import android.app.AlarmManager
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject

/**
 * Flutter MethodChannel handler for `im_muslim/prayer_silence`.
 *
 * Methods exposed to Dart:
 * - checkDndPermission  → Boolean
 * - openDndSettings     → void
 * - scheduleWindows     → Boolean (success)
 * - cancelAllWindows    → void
 */
object PrayerSilenceChannel {

    private const val CHANNEL       = "im_muslim/prayer_silence"
    private const val REQ_BASE_START = 9000  // AlarmManager request codes (start windows)
    private const val REQ_BASE_END   = 9500  // AlarmManager request codes (end windows)
    private const val MAX_WINDOWS    = 20

    fun register(context: Context, messenger: BinaryMessenger) {
        MethodChannel(messenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkDndPermission" ->
                    result.success(hasDndPermission(context))

                "openDndSettings" -> {
                    openDndSettings(context)
                    result.success(null)
                }

                "scheduleWindows" -> {
                    @Suppress("UNCHECKED_CAST")
                    val rawWindows = call.argument<List<Map<String, Any>>>("windows") ?: emptyList()
                    val mode       = call.argument<Int>("mode")     ?: 1
                    val autoRestore = call.argument<Boolean>("autoRestore") ?: true

                    // Convert to JSONObject list and persist for BOOT recovery
                    val jsonList = rawWindows.map { w ->
                        JSONObject().apply {
                            put("prayer", w["prayer"] as? String ?: "")
                            put("startMs", (w["startMs"] as? Number)?.toLong() ?: 0L)
                            put("endMs",   (w["endMs"]   as? Number)?.toLong() ?: 0L)
                        }
                    }

                    context.silencePrefs.edit()
                        .putString(PrayerSilenceReceiver.KEY_WINDOWS_JSON, JSONArray(jsonList).toString())
                        .putInt(PrayerSilenceReceiver.KEY_MODE, mode)
                        .putBoolean(PrayerSilenceReceiver.KEY_AUTO_RESTORE, autoRestore)
                        .apply()

                    scheduleWindowsInternal(context, jsonList, mode, autoRestore)
                    result.success(true)
                }

                "cancelAllWindows" -> {
                    cancelAll(context)
                    context.silencePrefs.edit()
                        .remove(PrayerSilenceReceiver.KEY_WINDOWS_JSON)
                        .apply()
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }

    // ── DND permission ─────────────────────────────────────────────────────────

    private fun hasDndPermission(context: Context): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return true
        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        return nm.isNotificationPolicyAccessGranted
    }

    private fun openDndSettings(context: Context) {
        val intent = Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        context.startActivity(intent)
    }

    // ── Window scheduling (also called from BOOT handler in Receiver) ──────────

    internal fun scheduleWindowsInternal(
        context: Context,
        windows: List<JSONObject>,
        mode: Int,
        autoRestore: Boolean,
    ) {
        val am  = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val now = System.currentTimeMillis()

        windows.forEachIndexed { index, w ->
            val startMs = w.getLong("startMs")
            val endMs   = w.getLong("endMs")

            if (endMs <= now) return@forEachIndexed // window already elapsed

            if (startMs > now) {
                // Schedule the START alarm
                val startPi = buildPendingIntent(
                    context, PrayerSilenceReceiver.ACTION_START,
                    REQ_BASE_START + index, mode, autoRestore, endMs,
                )
                scheduleExact(am, startMs, startPi)
            } else {
                // Window has started but not ended — apply silence immediately
                context.sendBroadcast(
                    Intent(PrayerSilenceReceiver.ACTION_START).apply {
                        `package` = context.packageName
                        putExtra(PrayerSilenceReceiver.EXTRA_MODE, mode)
                        putExtra(PrayerSilenceReceiver.EXTRA_AUTO_RESTORE, autoRestore)
                        putExtra(PrayerSilenceReceiver.EXTRA_WINDOW_END_MS, endMs)
                    }
                )
            }

            // Always schedule the END alarm
            val endPi = buildPendingIntent(
                context, PrayerSilenceReceiver.ACTION_END,
                REQ_BASE_END + index, mode, autoRestore, endMs,
            )
            scheduleExact(am, endMs, endPi)
        }
    }

    private fun cancelAll(context: Context) {
        val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        for (i in 0 until MAX_WINDOWS) {
            listOf(
                REQ_BASE_START + i to PrayerSilenceReceiver.ACTION_START,
                REQ_BASE_END   + i to PrayerSilenceReceiver.ACTION_END,
            ).forEach { (reqCode, action) ->
                val pi = PendingIntent.getBroadcast(
                    context, reqCode,
                    Intent(action).apply { `package` = context.packageName },
                    PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE,
                )
                if (pi != null) am.cancel(pi)
            }
        }
    }

    // ── PendingIntent factory ──────────────────────────────────────────────────

    private fun buildPendingIntent(
        context: Context,
        action: String,
        requestCode: Int,
        mode: Int,
        autoRestore: Boolean,
        windowEndMs: Long,
    ): PendingIntent {
        val intent = Intent(action).apply {
            `package` = context.packageName
            putExtra(PrayerSilenceReceiver.EXTRA_MODE, mode)
            putExtra(PrayerSilenceReceiver.EXTRA_AUTO_RESTORE, autoRestore)
            putExtra(PrayerSilenceReceiver.EXTRA_WINDOW_END_MS, windowEndMs)
        }
        return PendingIntent.getBroadcast(
            context, requestCode, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private fun scheduleExact(am: AlarmManager, triggerMs: Long, pi: PendingIntent) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                am.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerMs, pi)
            } else {
                am.setExact(AlarmManager.RTC_WAKEUP, triggerMs, pi)
            }
        } catch (_: SecurityException) {
            // SCHEDULE_EXACT_ALARM not granted — fall back to inexact alarm
            am.set(AlarmManager.RTC_WAKEUP, triggerMs, pi)
        }
    }
}

// ── Package-level extension ────────────────────────────────────────────────────

private val Context.silencePrefs
    get() = getSharedPreferences(PrayerSilenceReceiver.PREFS_NAME, Context.MODE_PRIVATE)
