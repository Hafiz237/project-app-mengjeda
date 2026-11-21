package com.example.tes

import android.app.*
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.Typeface
import android.os.Build
import android.os.CountDownTimer
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.provider.Settings
import android.util.Log
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.app.NotificationCompat
import org.json.JSONArray

class MonitorService : Service() {
    private val handler = Handler(Looper.getMainLooper())
    private val lastAlert = HashMap<String, Long>()
    private var overlayView: View? = null
    private var overlayTimer: CountDownTimer? = null

    private val tick = object : Runnable {
        override fun run() {
            try { check() } catch (_: Exception) {}
            handler.postDelayed(this, CHECK_INTERVAL_MS)
        }
    }

    override fun onBind(i: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        val nm = getSystemService(NotificationManager::class.java)
        nm.createNotificationChannel(
            NotificationChannel(CH_MONITOR, "Pemantau MengJeda", NotificationManager.IMPORTANCE_MIN)
        )
        nm.createNotificationChannel(
            NotificationChannel(CH_ALERT, "Batas Aplikasi", NotificationManager.IMPORTANCE_HIGH)
        )
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val n = NotificationCompat.Builder(this, CH_MONITOR)
            .setSmallIcon(applicationInfo.icon)
            .setContentTitle("MengJeda aktif")
            .setContentText("Memantau batas waktu aplikasi")
            .setOngoing(true)
            .build()
        if (Build.VERSION.SDK_INT >= 34) {
            startForeground(1, n, ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
        } else {
            startForeground(1, n)
        }
        handler.removeCallbacks(tick)
        handler.post(tick)
        return START_STICKY
    }

    override fun onDestroy() {
        handler.removeCallbacks(tick)
        removeOverlay()
        super.onDestroy()
    }

    private fun check() {
        if (!UsageHelper.hasPermission(this)) return
        val raw = getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString(KEY_LIMITS, "[]")
        val arr = JSONArray(raw)
        val (usage, fg) = UsageHelper.today(this)
        if (fg == null) return

        for (i in 0 until arr.length()) {
            val o = arr.getJSONObject(i)
            if (o.getString("pkg") != fg) continue
            val limitMs = (if (o.has("seconds")) o.getInt("seconds") else o.getInt("minutes") * 60) * 1000L
            val used = usage[fg] ?: 0L
            Log.d(TAG, "cek $fg terpakai=${used / 1000}s batas=${limitMs / 1000}s")
            if (used < limitMs) return

            val now = System.currentTimeMillis()
            val cooldown = if (limitMs <= 60_000L) 30_000L else COOLDOWN_MS 
            if (now - (lastAlert[fg] ?: 0L) < cooldown) {
                Log.d(TAG, "lewati: masih masa jeda pengulangan")
                return
            }
            lastAlert[fg] = now
            fire(fg, o.getString("label"), used / 1000)
            return
        }
    }

    private fun fire(pkg: String, label: String, usedSec: Long) {
        val usedText = if (usedSec < 60) "$usedSec detik" else "${usedSec / 60} menit"
       
        val open = Intent(this, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        }
        val pi = PendingIntent.getActivity(
            this, pkg.hashCode(), open,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val n = NotificationCompat.Builder(this, CH_ALERT)
            .setSmallIcon(applicationInfo.icon)
            .setContentTitle("Waktunya jeda dari $label")
            .setContentText("Kamu sudah $usedText di $label hari ini.")
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setAutoCancel(true)
            .setContentIntent(pi)
            .build()
        try {
            getSystemService(NotificationManager::class.java).notify(pkg.hashCode(), n)
        } catch (_: SecurityException) {}

        
        val bisaOverlay = Settings.canDrawOverlays(this)
        Log.d(TAG, "fire: $label, canDrawOverlays=$bisaOverlay, overlayAda=${overlayView != null}")
        if (bisaOverlay) showOverlay(label, usedText)
    }

    private fun showOverlay(label: String, usedText: String) {
        overlayView?.let {
            if (it.isAttachedToWindow) { Log.d(TAG, "overlay masih tampil, dilewati"); return }
            Log.d(TAG, "overlay lama sudah hilang, dibuat ulang")
            removeOverlay()
        }
        val wm = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val seconds = getSharedPreferences(PREFS, Context.MODE_PRIVATE).getInt(KEY_JEDA_SECONDS, 20)
        val dp = resources.displayMetrics.density
        fun px(v: Int) = (v * dp).toInt()

        val title = TextView(this).apply {
            text = "Waktunya Jeda Sejenak"
            setTextColor(Color.WHITE); textSize = 26f
            typeface = Typeface.DEFAULT_BOLD; gravity = Gravity.CENTER
        }
        val sub = TextView(this).apply {
            text = "Kamu sudah $usedText di $label hari ini.\nLetakkan HP-mu, istirahatkan matamu."
            setTextColor(0xCCFFFFFF.toInt()); textSize = 15f; gravity = Gravity.CENTER
            setPadding(0, px(12), 0, px(24))
        }
        val paw = TextView(this).apply {
            text = "🐾"; textSize = 72f; gravity = Gravity.CENTER
        }
        val count = TextView(this).apply {
            text = fmt(seconds.toLong())
            setTextColor(Color.WHITE); textSize = 56f
            typeface = Typeface.DEFAULT_BOLD; gravity = Gravity.CENTER
            setPadding(0, px(24), 0, px(8))
        }
        val hint = TextView(this).apply {
            text = "Jeda belum selesai, tidak dapat dilewati"
            setTextColor(0x99FFFFFF.toInt()); textSize = 13f; gravity = Gravity.CENTER
        }
        val close = Button(this).apply {
            text = "Selesai"; visibility = View.GONE
            setOnClickListener { removeOverlay() }
        }

        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setBackgroundColor(0xF2102A3A.toInt())
            setPadding(px(24), px(24), px(24), px(24))
            isClickable = true
            addView(title); addView(sub); addView(paw); addView(count); addView(hint); addView(close)
        }

        val type = if (Build.VERSION.SDK_INT >= 26)
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        else
            @Suppress("DEPRECATION") WindowManager.LayoutParams.TYPE_PHONE
        val lp = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            type,
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON,
            PixelFormat.TRANSLUCENT
        )
        try { wm.addView(root, lp) } catch (e: Exception) {
            Log.e(TAG, "Overlay gagal: $e")
            return
        }
        Log.d(TAG, "overlay tampil")
        overlayView = root

        overlayTimer = object : CountDownTimer(seconds * 1000L, 1000L) {
            override fun onTick(ms: Long) { count.text = fmt((ms + 999) / 1000) }
            override fun onFinish() {
                count.text = fmt(0)
                hint.text = "Jeda selesai. Terima kasih!"
                close.visibility = View.VISIBLE
            }
        }.start()
    }

    private fun removeOverlay() {
        overlayTimer?.cancel(); overlayTimer = null
        overlayView?.let {
            try { (getSystemService(Context.WINDOW_SERVICE) as WindowManager).removeView(it) } catch (_: Exception) {}
        }
        overlayView = null
    }

    private fun fmt(s: Long) = "%02d:%02d".format(s / 60, s % 60)

    companion object {
        const val TAG = "MengJeda"
        const val PREFS = "mengjeda_prefs"
        const val KEY_LIMITS = "limits"
        const val KEY_JEDA_SECONDS = "jeda_seconds"
        const val EXTRA_PKG = "jeda_pkg"
        const val EXTRA_LABEL = "jeda_label"
        const val CH_MONITOR = "mengjeda_monitor"
        const val CH_ALERT = "mengjeda_limit_alert"
        const val CHECK_INTERVAL_MS = 5_000L
        const val COOLDOWN_MS = 5 * 60_000L
    }
}