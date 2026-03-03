package com.anaalmuslim.app

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.AudioManager
import android.os.Build
import org.json.JSONArray

/**
 * Handles prayer silence START / END alarms and device BOOT.
 *
 * - ACTION_START: saves previous ringer mode and applies the configured silence.
 * - ACTION_END  : restores the saved mode (overlap guard via [KEY_ACTIVE_END_MS]).
 * - BOOT_COMPLETED / MY_PACKAGE_REPLACED: re-schedules from stored JSON.
 */
class PrayerSilenceReceiver : BroadcastReceiver() {

    companion object {
        const val ACTION_START        = "com.anaalmuslim.app.PRAYER_SILENCE_START"
        const val ACTION_END          = "com.anaalmuslim.app.PRAYER_SILENCE_END"

        const val EXTRA_MODE          = "mode"
        const val EXTRA_AUTO_RESTORE  = "autoRestore"
        const val EXTRA_WINDOW_END_MS = "windowEndMs"

        const val PREFS_NAME          = "prayer_silence_prefs"
        const val KEY_PREV_RINGER     = "ps_prev_ringer"
        const val KEY_ACTIVE_END_MS   = "ps_active_end_ms"
        const val KEY_AUTO_RESTORE    = "ps_auto_restore"
        const val KEY_WINDOWS_JSON    = "ps_windows_json"
        const val KEY_MODE            = "ps_mode"
    }

    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            ACTION_START -> handleStart(context, intent)
            ACTION_END   -> handleEnd(context, intent)
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            "android.intent.action.LOCKED_BOOT_COMPLETED" -> handleBoot(context)
        }
    }

    // ── START ──────────────────────────────────────────────────────────────────

    private fun handleStart(context: Context, intent: Intent) {
        val mode        = intent.getIntExtra(EXTRA_MODE, 1)
        val autoRestore = intent.getBooleanExtra(EXTRA_AUTO_RESTORE, true)
        val windowEndMs = intent.getLongExtra(EXTRA_WINDOW_END_MS, 0L)

        val audio = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

        if (autoRestore) {
            prefs.edit()
                .putInt(KEY_PREV_RINGER, audio.ringerMode)
                .putLong(KEY_ACTIVE_END_MS, windowEndMs)
                .putBoolean(KEY_AUTO_RESTORE, autoRestore)
                .apply()
        }

        applyMode(context, audio, mode)
    }

    // ── END ────────────────────────────────────────────────────────────────────

    private fun handleEnd(context: Context, intent: Intent) {
        val windowEndMs = intent.getLongExtra(EXTRA_WINDOW_END_MS, 0L)
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

        // Overlap guard: only restore if this END matches the current active window.
        // A later START updates KEY_ACTIVE_END_MS, so older END alarms are ignored.
        val activeEndMs = prefs.getLong(KEY_ACTIVE_END_MS, 0L)
        if (activeEndMs != windowEndMs) return

        val autoRestore = prefs.getBoolean(KEY_AUTO_RESTORE, true)
        if (!autoRestore) return

        val prevRinger = prefs.getInt(KEY_PREV_RINGER, AudioManager.RINGER_MODE_NORMAL)
        val audio = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager

        try {
            audio.ringerMode = prevRinger
        } catch (_: SecurityException) {
            // DND permission was revoked between START and END — ignore silently.
        }

        prefs.edit().remove(KEY_ACTIVE_END_MS).apply()
    }

    // ── BOOT ───────────────────────────────────────────────────────────────────

    private fun handleBoot(context: Context) {
        val prefs       = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val json        = prefs.getString(KEY_WINDOWS_JSON, null) ?: return
        val mode        = prefs.getInt(KEY_MODE, 1)
        val autoRestore = prefs.getBoolean(KEY_AUTO_RESTORE, true)

        try {
            val arr  = JSONArray(json)
            val list = (0 until arr.length()).map { arr.getJSONObject(it) }
            PrayerSilenceChannel.scheduleWindowsInternal(context, list, mode, autoRestore)
        } catch (_: Exception) {
            // Malformed JSON — skip; Dart will reschedule on next app launch.
        }
    }

    // ── Ringer helper ──────────────────────────────────────────────────────────

    private fun applyMode(context: Context, audio: AudioManager, mode: Int) {
        when (mode) {
            0 -> { // DND
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                    if (nm.isNotificationPolicyAccessGranted) {
                        nm.setInterruptionFilter(NotificationManager.INTERRUPTION_FILTER_NONE)
                        return
                    }
                }
                // Fallback: silent (requires DND permission on API 23+, but we try)
                try { audio.ringerMode = AudioManager.RINGER_MODE_SILENT } catch (_: SecurityException) {}
            }
            1 -> { // Silent
                try { audio.ringerMode = AudioManager.RINGER_MODE_SILENT } catch (_: SecurityException) {}
            }
            2 -> { // Vibrate — no DND permission required
                audio.ringerMode = AudioManager.RINGER_MODE_VIBRATE
            }
        }
    }
}
