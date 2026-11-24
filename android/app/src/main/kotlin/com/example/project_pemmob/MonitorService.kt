package com.example.project_pemmob

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
import android.graphics.BitmapFactory
import android.graphics.ImageDecoder
import android.graphics.drawable.AnimatedImageDrawable
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.graphics.drawable.GradientDrawable
import android.view.MotionEvent
import android.widget.ImageView
import java.io.File

class MonitorService : Service() {
    private val handler = Handler(Looper.getMainLooper())
    private val lastAlert = HashMap<String, Long>()
    private var overlayView: View? = null
    private var overlayTimer: CountDownTimer? = null

    private var activeMs = 0L
    private var logTs = 0L
    private var autoDue = false

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
        val t0 = System.nanoTime()
        val (usage, fg) = UsageHelper.today(this)
        Log.d(TAG, "today() ${(System.nanoTime() - t0) / 1_000_000} ms, fg=$fg")
        if (fg == null) return

        checkAuto(fg)

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

    private fun checkAuto(fg: String) {
        val prefs = getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        if (!prefs.getBoolean(KEY_AUTO_ON, false)) {
            activeMs = 0L; autoDue = false; activeSnapshot = 0L; return
        }
        if (overlayView?.isAttachedToWindow == true) return

        val intervalMs = prefs.getInt(KEY_AUTO_SECONDS, 7200) * 1000L
        if (!autoDue) {
            activeMs += CHECK_INTERVAL_MS
            if (activeMs >= intervalMs) autoDue = true
        }
        activeSnapshot = activeMs
        if (!autoDue) return

        if (isExcluded(fg)) {
            Log.d(TAG, "jeda otomatis ditunda: $fg dikecualikan")
            return
        }
        autoDue = false
        activeMs = 0L
        activeSnapshot = 0L
        Log.d(TAG, "jeda otomatis dipicu di $fg")
        fireAuto(fg)
    }

    private fun isExcluded(pkg: String): Boolean {
        val raw = getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString(KEY_EXCLUSIONS, "[]")
        val arr = JSONArray(raw)
        for (i in 0 until arr.length()) {
            if (arr.getJSONObject(i).getString("pkg") == pkg) return true
        }
        return false
    }

    private fun fireAuto(fg: String) {
        val msg = "Sudah waktunya istirahat.\nLetakkan HP-mu, istirahatkan matamu."
        if (Settings.canDrawOverlays(this)) {
            showOverlay("", "", msg, "auto", fg)
        } else {
            val n = NotificationCompat.Builder(this, CH_ALERT)
                .setSmallIcon(applicationInfo.icon)
                .setContentTitle("Waktunya jeda")
                .setContentText("Sudah waktunya istirahat sejenak.")
                .setPriority(NotificationCompat.PRIORITY_MAX)
                .setAutoCancel(true)
                .build()
            try { getSystemService(NotificationManager::class.java).notify(7001, n) } catch (_: SecurityException) {}
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
        if (bisaOverlay) showOverlay(label, usedText, null, "limit", pkg)
    }

    private fun showOverlay(label: String, usedText: String, message: String? = null,
                           src: String = "limit", pkg: String = "") {
        overlayView?.let {
            if (it.isAttachedToWindow) { Log.d(TAG, "overlay masih tampil, dilewati"); return }
            Log.d(TAG, "overlay lama sudah hilang, dibuat ulang")
            removeOverlay()
        }
        val prefs = getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val wm = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val seconds = prefs.getInt(KEY_JEDA_SECONDS, 20)
        val pct = prefs.getInt(KEY_OVERLAY_PCT, 50).coerceIn(20, 100)
        val full = pct >= 100
        val compact = pct <= 30
        val dp = resources.displayMetrics.density
        fun px(v: Int) = (v * dp).toInt()

        val title = TextView(this).apply {
            text = "Waktunya Jeda Sejenak"
            setTextColor(Color.WHITE); textSize = if (compact) 16f else 24f
            typeface = Typeface.DEFAULT_BOLD; gravity = Gravity.CENTER
        }
        title.setOnLongClickListener { removeOverlay(); true }

        val sub = TextView(this).apply {
            text = message ?: "Kamu sudah $usedText di $label hari ini.\nLetakkan HP-mu, istirahatkan matamu."
            setTextColor(0xCCFFFFFF.toInt()); textSize = 14f; gravity = Gravity.CENTER
            setPadding(0, px(8), 0, px(8))
            visibility = if (compact) View.GONE else View.VISIBLE
        }

        val drawable = loadMedia()
        val mediaView: View = if (drawable != null) {
            ImageView(this).apply {
                setImageDrawable(drawable)
                scaleType = ImageView.ScaleType.FIT_CENTER
                if (Build.VERSION.SDK_INT >= 28 && drawable is AnimatedImageDrawable) drawable.start()
            }
        } else {
            TextView(this).apply {
                text = "🐾"; textSize = if (compact) 36f else 72f; gravity = Gravity.CENTER
            }
        }

        val count = TextView(this).apply {
            text = fmt(seconds.toLong())
            setTextColor(Color.WHITE); textSize = if (compact) 26f else 48f
            typeface = Typeface.DEFAULT_BOLD; gravity = Gravity.CENTER
            setPadding(0, px(if (compact) 4 else 12), 0, px(4))
        }
        val hint = TextView(this).apply {
            setTextColor(0x99FFFFFF.toInt()); textSize = if (compact) 11f else 13f
            gravity = Gravity.CENTER
        }
        val close = Button(this).apply {
            text = "Selesai"; visibility = View.GONE
            setOnClickListener { removeOverlay() }
        }

        fun startCountdown(info: String) {
            overlayTimer?.cancel()
            hint.text = info
            close.visibility = View.GONE
            count.text = fmt(seconds.toLong())
            overlayTimer = object : CountDownTimer(seconds * 1000L, 1000L) {
                override fun onTick(ms: Long) { count.text = fmt((ms + 999) / 1000) }
                override fun onFinish() {
                    JedaLog.markDone(this@MonitorService, logTs)
                    count.text = fmt(0)
                    hint.text = "Jeda selesai. Terima kasih!"
                    close.visibility = View.VISIBLE
                }
            }.start()
        }

        var resets = 0
        val radius = if (full) 0f else px(24).toFloat()
        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            background = GradientDrawable().apply {
                setColor(0xF2102A3A.toInt())
                cornerRadii = floatArrayOf(radius, radius, radius, radius, 0f, 0f, 0f, 0f)
            }
            val pad = px(if (compact) 12 else 20)
            setPadding(pad, pad, pad, if (full) pad else pad + px(16))
            isClickable = true
            addView(title)
            addView(mediaView, LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT, 0, 1f))
            addView(sub); addView(count); addView(hint); addView(close)
            setOnTouchListener { _, e ->
                if (e.action == MotionEvent.ACTION_OUTSIDE && resets < MAX_RESETS) {
                    resets++
                    startCountdown("Jeda diulang ($resets/$MAX_RESETS): letakkan HP dulu")
                }
                false
            }
        }

        val type = if (Build.VERSION.SDK_INT >= 26)
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        else
            @Suppress("DEPRECATION") WindowManager.LayoutParams.TYPE_PHONE
        val baseFlags = WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
        val flags = if (full) baseFlags else baseFlags or
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH
        val lp = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            if (full) WindowManager.LayoutParams.MATCH_PARENT
            else resources.displayMetrics.heightPixels * pct / 100,
            type, flags, PixelFormat.TRANSLUCENT
        ).apply { gravity = Gravity.BOTTOM }

        try { wm.addView(root, lp) } catch (e: Exception) {
            Log.e(TAG, "Overlay gagal: $e")
            return
        }
        Log.d(TAG, "overlay tampil ($pct%), media=${drawable != null}")
        overlayView = root
        logTs = System.currentTimeMillis()
        JedaLog.add(this, logTs, src, pkg, seconds)
        startCountdown("Jeda belum selesai, tidak dapat dilewati")
    }

    private fun removeOverlay() {
        overlayTimer?.cancel(); overlayTimer = null
        overlayView?.let {
            try { (getSystemService(Context.WINDOW_SERVICE) as WindowManager).removeView(it) } catch (_: Exception) {}
        }
        overlayView = null
    }

    private fun loadMedia(): Drawable? {
        val prefs = getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val kind = prefs.getString(KEY_MEDIA_KIND, null)
        val path = prefs.getString(KEY_MEDIA_PATH, null)
        if (kind.isNullOrEmpty() || path.isNullOrEmpty()) return null
        return try {
            if (Build.VERSION.SDK_INT >= 28) {
                val source = if (kind == "asset")
                    ImageDecoder.createSource(assets, "flutter_assets/$path")
                else
                    ImageDecoder.createSource(File(path))
                ImageDecoder.decodeDrawable(source) { decoder, info, _ ->
                    // perkecil gambar besar agar hemat memori (NFR-02)
                    val scale = minOf(1f, 1080f / maxOf(info.size.width, info.size.height))
                    decoder.setTargetSize(
                        (info.size.width * scale).toInt(),
                        (info.size.height * scale).toInt()
                    )
                }
            } else {
                val stream = if (kind == "asset") assets.open("flutter_assets/$path")
                else File(path).inputStream()
                stream.use { s -> BitmapFactory.decodeStream(s)?.let { BitmapDrawable(resources, it) } }
            }
        } catch (e: Exception) {
            Log.e(TAG, "media gagal dimuat: $e")
            null
        }
    }

    private fun fmt(s: Long) = "%02d:%02d".format(s / 60, s % 60)

    companion object {
        const val TAG = "MengJeda"
        const val PREFS = "mengjeda_prefs"
        const val KEY_LIMITS = "limits"
        const val KEY_JEDA_SECONDS = "jeda_seconds"
        const val KEY_EXCLUSIONS = "app_exclusions"
        const val KEY_AUTO_ON = "auto_on"
        const val KEY_AUTO_SECONDS = "auto_seconds"
        const val EXTRA_PKG = "jeda_pkg"
        const val EXTRA_LABEL = "jeda_label"
        const val CH_MONITOR = "mengjeda_monitor"
        const val CH_ALERT = "mengjeda_limit_alert"

        const val KEY_OVERLAY_PCT = "overlay_pct"
        const val KEY_MEDIA_KIND = "media_kind"
        const val KEY_MEDIA_PATH = "media_path"
        const val MAX_RESETS = 3
        const val CHECK_INTERVAL_MS = 5_000L
        const val COOLDOWN_MS = 5 * 60_000L

        @Volatile var activeSnapshot = 0L
    }
}