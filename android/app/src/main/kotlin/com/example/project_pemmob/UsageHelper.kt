package com.example.project_pemmob

import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.os.Process
import java.util.Calendar

object UsageHelper {
    fun hasPermission(ctx: Context): Boolean {
        val ops = ctx.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = ops.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), ctx.packageName
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    /** Hasil: (total ms di foreground hari ini per package, package yang sedang di layar sekarang) */
    fun today(ctx: Context): Pair<Map<String, Long>, String?> {
        val usm = ctx.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val cal = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, 0); set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0); set(Calendar.MILLISECOND, 0)
        }
        val now = System.currentTimeMillis()
        val events = usm.queryEvents(cal.timeInMillis, now)
        val ev = UsageEvents.Event()

        val total = HashMap<String, Long>()
        val resumedAt = HashMap<String, Long>()
        var current: String? = null

        fun close(pkg: String, ts: Long) {
            val start = resumedAt.remove(pkg) ?: return
            total[pkg] = (total[pkg] ?: 0L) + (ts - start)
        }

        while (events.hasNextEvent()) {
            events.getNextEvent(ev)
            val pkg = ev.packageName ?: continue
            when (ev.eventType) {
                1 -> { resumedAt[pkg] = ev.timeStamp; current = pkg }
                2 -> { close(pkg, ev.timeStamp); if (current == pkg) current = null }
                16 -> { current?.let { close(it, ev.timeStamp) }; current = null }
            }
        }
        current?.let { close(it, now) }
        return Pair(total, current)
    }
}
