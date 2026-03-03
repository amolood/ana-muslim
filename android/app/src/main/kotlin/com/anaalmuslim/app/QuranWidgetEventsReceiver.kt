package com.anaalmuslim.app

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context.MODE_PRIVATE
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

/**
 * Handles widget-related system events that are not AppWidget lifecycle events.
 */
class QuranWidgetEventsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            Intent.ACTION_LOCKED_BOOT_COMPLETED -> {
                // After reboot / app update: refresh all widget providers so they
                // don't show stale or default data.
                QuranWidgetProvider.updateAllWidgets(context)
                PrayerWidgetProvider.updateAllWidgets(context)
                TransparentWidgetProvider.updateAllWidgets(context)
                DateWidgetProvider.updateAllWidgets(context)
                HijriMonthWidgetProvider.updateAllWidgets(context)
            }
            Intent.ACTION_USER_PRESENT -> {
                QuranWidgetProvider.advanceVerseIndex(context)
                QuranWidgetProvider.updateAllWidgets(context)
                maybeShowSalaOnProphetReminder(context)
            }
            Intent.ACTION_SCREEN_ON -> {
                maybeShowSalaOnProphetReminder(context)
            }
        }
    }

    private fun maybeShowSalaOnProphetReminder(context: Context) {
        val flutterPrefs = context.getSharedPreferences(FLUTTER_PREFS, MODE_PRIVATE)
        val enabled = flutterPrefs.getBoolean(FLUTTER_KEY_AWAKE_SALA_ENABLED, false)
        if (!enabled) return

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            val granted = context.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) ==
                    PackageManager.PERMISSION_GRANTED
            if (!granted) return
        }

        val managerCompat = NotificationManagerCompat.from(context)
        if (!managerCompat.areNotificationsEnabled()) return

        val receiverPrefs = context.getSharedPreferences(RECEIVER_PREFS, MODE_PRIVATE)
        val now = System.currentTimeMillis()
        val lastShownAt = receiverPrefs.getLong(KEY_LAST_SHOWN_AT, 0L)
        if (now - lastShownAt < COOLDOWN_MS) return

        ensureChannel(context)

        val launchIntent = context.packageManager
            .getLaunchIntentForPackage(context.packageName)
        val pendingIntent = if (launchIntent != null) {
            PendingIntent.getActivity(
                context,
                0,
                launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        } else null

        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("الصلاة على النبي ﷺ")
            .setContentText("اللهم صل وسلم على نبينا محمد")
            .setStyle(
                NotificationCompat.BigTextStyle()
                    .bigText("اللهم صل وسلم على نبينا محمد")
            )
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .build()

        managerCompat.notify(NOTIFICATION_ID, notification)
        receiverPrefs.edit().putLong(KEY_LAST_SHOWN_AT, now).apply()
    }

    private fun ensureChannel(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val existing = manager.getNotificationChannel(CHANNEL_ID)
        if (existing != null) return

        val channel = NotificationChannel(
            CHANNEL_ID,
            "تذكير الصلاة على النبي",
            NotificationManager.IMPORTANCE_DEFAULT
        ).apply {
            description = "تنبيهات الذكر أثناء اليقظة"
        }
        manager.createNotificationChannel(channel)
    }

    companion object {
        private const val FLUTTER_PREFS = "FlutterSharedPreferences"
        private const val FLUTTER_KEY_AWAKE_SALA_ENABLED = "flutter.sala_prophet_awake_enabled"

        private const val RECEIVER_PREFS = "awake_sala_receiver_prefs"
        private const val KEY_LAST_SHOWN_AT = "last_shown_at"
        private const val COOLDOWN_MS = 15 * 60 * 1000L

        private const val CHANNEL_ID = "awake_sala_channel"
        private const val NOTIFICATION_ID = 2115
    }
}
