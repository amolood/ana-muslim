package com.anaalmuslim.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Refreshes date-bearing widgets when the system date/time/timezone changes.
 * Registered in AndroidManifest for: DATE_CHANGED, TIME_SET, TIMEZONE_CHANGED.
 * These are protected broadcasts that can only be delivered to manifest receivers.
 */
class DateChangeReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_DATE_CHANGED,
            Intent.ACTION_TIME_CHANGED,
            Intent.ACTION_TIMEZONE_CHANGED -> {
                DateWidgetProvider.updateAllWidgets(context)
                TransparentWidgetProvider.updateAllWidgets(context)
            }
        }
    }
}
