package com.bitchat.android.service

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class BootCompletedReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        // Ensure preferences are initialized on cold boot before reading values
        try { MeshServicePreferences.init(context.applicationContext) } catch (_: Exception) { }

        // imeCep: in a disaster the phone may reboot (battery swap, crash). Keep the
        // mesh relaying after boot when the user left auto-start on (default).
        try {
            if (MeshServicePreferences.isAutoStartEnabled(true)) {
                MeshForegroundService.start(context.applicationContext)
            }
        } catch (_: Exception) { }
    }
}
