package com.example.project_pemmob

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

object JedaLog {
    private const val KEY = "jeda_log"
    private const val MAX = 500

    private fun prefs(ctx: Context) =
        ctx.getSharedPreferences(MonitorService.PREFS, Context.MODE_PRIVATE)

    @Synchronized
    fun add(ctx: Context, ts: Long, src: String, pkg: String, secs: Int) {
        val old = JSONArray(prefs(ctx).getString(KEY, "[]"))
        val list = ArrayList<JSONObject>()
        for (i in 0 until old.length()) list.add(old.getJSONObject(i))
        list.add(
            JSONObject().put("ts", ts).put("src", src).put("pkg", pkg)
                .put("secs", secs).put("done", false)
        )
        val trimmed = if (list.size > MAX) list.subList(list.size - MAX, list.size) else list
        val out = JSONArray()
        trimmed.forEach { out.put(it) }
        prefs(ctx).edit().putString(KEY, out.toString()).apply()
    }

    @Synchronized
    fun markDone(ctx: Context, ts: Long) {
        val arr = JSONArray(prefs(ctx).getString(KEY, "[]"))
        for (i in 0 until arr.length()) {
            val o = arr.getJSONObject(i)
            if (o.getLong("ts") == ts) { o.put("done", true); break }
        }
        prefs(ctx).edit().putString(KEY, arr.toString()).apply()
    }

    fun readAll(ctx: Context): String = prefs(ctx).getString(KEY, "[]") ?: "[]"
}