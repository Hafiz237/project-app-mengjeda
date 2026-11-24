package com.example.project_pemmob

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.core.content.ContextCompat

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(ctx: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED) return
        val prefs = ctx.getSharedPreferences(MonitorService.PREFS, Context.MODE_PRIVATE)
        if (!prefs.getBoolean("monitor_on", false)) return
        try {
            ContextCompat.startForegroundService(ctx, Intent(ctx, MonitorService::class.java))
        } catch (e: Exception) {
            Log.e(MonitorService.TAG, "gagal menyalakan pemantau setelah boot: $e")
        }
    }
}