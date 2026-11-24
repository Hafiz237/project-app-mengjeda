package com.example.project_pemmob

import android.content.Context
import android.util.Log
import org.json.JSONArray
import org.json.JSONObject
import java.util.Calendar

data class PickedMessage(val id: String, val teks: String, val alasan: String)

object MessageEngine {
    private const val ASSET = "flutter_assets/assets/data/pesan_motivasi.json"
    private const val KEY_LAST = "msg_last_id"
    private var cache: List<JSONObject>? = null

    private fun load(ctx: Context): List<JSONObject> {
        cache?.let { return it }
        val list = try {
            val text = ctx.assets.open(ASSET).bufferedReader().use { it.readText() }
            val arr = JSONArray(text)
            (0 until arr.length()).map { arr.getJSONObject(it) }
        } catch (e: Exception) {
            Log.e(MonitorService.TAG, "pesan_motivasi.json gagal dimuat: $e")
            return emptyList() // kegagalan tidak disimpan di cache
        }
        cache = list
        return list
    }

    private fun hourIn(h: Int, from: Int, to: Int) =
        if (from <= to) h in from until to else (h >= from || h < to)

    private fun fmt(sec: Long): String = when {
        sec < 60 -> "$sec detik"
        sec < 3600 -> "${sec / 60} menit"
        else -> {
            val h = sec / 3600
            val m = (sec % 3600) / 60
            if (m == 0L) "$h jam" else "$h jam $m menit"
        }
    }

    private fun jamLabel(h: Int) = when {
        h < 5 -> "dini hari"
        h < 11 -> "pagi"
        h < 15 -> "siang"
        h < 18 -> "sore"
        else -> "malam"
    }

    fun pick(ctx: Context, src: String, label: String = "", usedText: String = ""): PickedMessage {
        val prefs = ctx.getSharedPreferences(MonitorService.PREFS, Context.MODE_PRIVATE)
        val hour = Calendar.getInstance().get(Calendar.HOUR_OF_DAY)
        val limitSec = prefs.getInt(MonitorService.KEY_DAILY_LIMIT, 3 * 3600).coerceAtLeast(60)
        val usedSec = if (UsageHelper.hasPermission(ctx)) UsageHelper.todayTotal(ctx) else 0L
        val progress = usedSec.toDouble() / limitSec
        val jeda = JedaLog.countToday(ctx)
        val lastId = prefs.getString(KEY_LAST, null)

        // 1. Saring pesan yang syaratnya cocok, beri skor = 1 + jumlah syarat yang dimiliki
        val matched = ArrayList<Pair<JSONObject, Int>>()
        for (m in load(ctx)) {
            var score = 1
            if (m.has("sumber")) {
                val a = m.getJSONArray("sumber")
                if (!(0 until a.length()).any { a.getString(it) == src }) continue
                score++
            }
            if (m.has("jam")) {
                val a = m.getJSONArray("jam")
                if (!hourIn(hour, a.getInt(0), a.getInt(1))) continue
                score++
            }
            if (m.has("progres")) {
                val a = m.getJSONArray("progres")
                if (progress < a.getDouble(0) || progress >= a.getDouble(1)) continue
                score++
            }
            if (m.has("minJeda")) {
                if (jeda < m.getInt("minJeda")) continue
                score++
            }
            matched.add(m to score)
        }
        if (matched.isEmpty()) {
            return PickedMessage("", "Istirahat sejenak, yuk. Matamu perlu rehat.", "Pesan cadangan")
        }

        // 2. Pilih acak berbobot, hindari pesan yang sama dengan sebelumnya
        val filtered = if (matched.size > 1) matched.filter { it.first.optString("id") != lastId } else matched
        val pool = if (filtered.isEmpty()) matched else filtered
        val total = pool.sumOf { it.second }
        var r = (Math.random() * total).toInt()
        var chosen = pool.first()
        for (p in pool) {
            if (r < p.second) { chosen = p; break }
            r -= p.second
        }

        // 3. Susun teks dan alasan
        val m = chosen.first
        val reasons = ArrayList<String>()
        if (m.has("sumber") && src == "limit") reasons.add("batas aplikasi tercapai")
        if (m.has("jam")) reasons.add("waktu ${jamLabel(hour)}")
        if (m.has("progres")) reasons.add("${(progress * 100).toInt()}% dari batas harian")
        if (m.has("minJeda")) reasons.add("$jeda jeda hari ini")
        val alasan = if (reasons.isEmpty()) "Pesan umum" else "Dipilih karena " + reasons.joinToString(" · ")

        val teks = m.getString("teks")
            .replace("{aplikasi}", if (label.isBlank()) "aplikasi ini" else label)
            .replace("{durasi}", if (usedText.isBlank()) fmt(usedSec) else usedText)
            .replace("{total}", fmt(usedSec))
            .replace("{jeda}", jeda.toString())

        val id = m.optString("id")
        prefs.edit().putString(KEY_LAST, id).apply()
        Log.d(MonitorService.TAG,
            "pesan: src=$src jam=$hour progres=${"%.2f".format(progress)} jeda=$jeda " +
                    "kandidat=${matched.size} dipilih=$id")
        return PickedMessage(id, teks, alasan)
    }
}