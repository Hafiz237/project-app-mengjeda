package com.example.project_pemmob

import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.os.Process
import java.util.Calendar
import android.content.Intent
import org.json.JSONArray
import org.json.JSONObject

object UsageHelper {
    fun hasPermission(ctx: Context): Boolean {
        val ops = ctx.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = ops.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), ctx.packageName
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    fun todayTotal(ctx: Context): Long {
        val ignore = ignoredPackages(ctx)
        return today(ctx).first.filterKeys { it !in ignore }.values.sum() / 1000
    }
    private var dayStart = 0L
    private var lastEventTs = 0L
    private var countAtLastTs = 0
    private val total = HashMap<String, Long>()
    private val resumedAt = HashMap<String, Long>()
    private var current: String? = null

    private fun resetDay(begin: Long) {
        dayStart = begin
        lastEventTs = begin
        countAtLastTs = 0
        total.clear(); resumedAt.clear(); current = null
    }

    private fun close(pkg: String, ts: Long) {
        val start = resumedAt.remove(pkg) ?: return
        total[pkg] = (total[pkg] ?: 0L) + (ts - start)
    }

    private fun handle(pkg: String?, type: Int, ts: Long) {
        if (pkg == null) return
        when (type) {
            1 -> { resumedAt[pkg] = ts; current = pkg }
            2 -> { close(pkg, ts); if (current == pkg) current = null }
            16 -> { current?.let { close(it, ts) }; current = null }
        }
    }

    /** Hasil: (total ms di foreground hari ini per package, package yang sedang di layar sekarang) */
    @Synchronized
    fun today(ctx: Context): Pair<Map<String, Long>, String?> {
        val usm = ctx.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val begin = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, 0); set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0); set(Calendar.MILLISECOND, 0)
        }.timeInMillis
        val now = System.currentTimeMillis()
        if (begin != dayStart) resetDay(begin)

        val events = usm.queryEvents(lastEventTs, now)
        val ev = UsageEvents.Event()
        var skip = countAtLastTs
        while (events.hasNextEvent()) {
            events.getNextEvent(ev)
            val ts = ev.timeStamp
            if (ts == lastEventTs && skip > 0) { skip--; continue }
            handle(ev.packageName, ev.eventType, ts)
            if (ts == lastEventTs) {
                countAtLastTs++
            } else {
                lastEventTs = ts; countAtLastTs = 1; skip = 0
            }
        }

        val snapshot = HashMap(total)
        current?.let { c ->
            resumedAt[c]?.let { s -> snapshot[c] = (snapshot[c] ?: 0L) + (now - s) }
        }
        return Pair(snapshot, current)
    }

    private fun forRange(ctx: Context, begin: Long, end: Long): Map<String, Long> {
        val usm = ctx.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val events = usm.queryEvents(begin, end)
        val ev = UsageEvents.Event()
        val total = HashMap<String, Long>()
        val resumed = HashMap<String, Long>()
        var cur: String? = null

        fun close(pkg: String, ts: Long) {
            val s = resumed.remove(pkg) ?: return
            total[pkg] = (total[pkg] ?: 0L) + (ts - s)
        }

        while (events.hasNextEvent()) {
            events.getNextEvent(ev)
            val pkg = ev.packageName ?: continue
            when (ev.eventType) {
                1 -> { resumed[pkg] = ev.timeStamp; cur = pkg }
                2 -> { close(pkg, ev.timeStamp); if (cur == pkg) cur = null }
                16 -> { cur?.let { close(it, ev.timeStamp) }; cur = null }
            }
        }
        cur?.let { close(it, end) }
        return total
    }

    private fun ignoredPackages(ctx: Context): Set<String> {
        val set = hashSetOf(ctx.packageName, "com.android.systemui")
        val home = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME)
        ctx.packageManager.queryIntentActivities(home, 0)
            .forEach { set.add(it.activityInfo.packageName) }
        return set
    }

    /** JSON: {"days":[{"ts":..,"total":detik}], "apps":{"pkg":detik, ...}} (10 aplikasi teratas) */
    fun summary(ctx: Context, days: Int): String {
        val ignore = ignoredPackages(ctx)
        val daysArr = JSONArray()
        val appTotals = HashMap<String, Long>()

        for (offset in days.coerceIn(1, 14) - 1 downTo 0) {
            val c = Calendar.getInstance().apply {
                add(Calendar.DAY_OF_YEAR, -offset)
                set(Calendar.HOUR_OF_DAY, 0); set(Calendar.MINUTE, 0)
                set(Calendar.SECOND, 0); set(Calendar.MILLISECOND, 0)
            }
            val begin = c.timeInMillis
            val endCal = c.clone() as Calendar
            endCal.add(Calendar.DAY_OF_YEAR, 1)

            val per = if (offset == 0) today(ctx).first
            else forRange(ctx, begin, endCal.timeInMillis)

            var sum = 0L
            for ((pkg, ms) in per) {
                if (pkg in ignore) continue
                sum += ms
                appTotals[pkg] = (appTotals[pkg] ?: 0L) + ms
            }
            daysArr.put(JSONObject().put("ts", begin).put("total", sum / 1000))
        }

        val apps = JSONObject()
        appTotals.entries.sortedByDescending { it.value }.take(10)
            .forEach { apps.put(it.key, it.value / 1000) }
        return JSONObject().put("days", daysArr).put("apps", apps).toString()
    }
}