package com.example.project_pemmob

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.provider.Settings
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var channel: MethodChannel? = null
    private var pending: Map<String, String>? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        readIntent(intent)
        val prefs = getSharedPreferences(MonitorService.PREFS, Context.MODE_PRIVATE)

        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "mengjeda/app_limit")
        channel!!.setMethodCallHandler { call, result ->
            when (call.method) {
                "getInstalledApps" -> {
                    val pm = packageManager
                    val launcher = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
                    val list = pm.queryIntentActivities(launcher, 0)
                        .map { mapOf("pkg" to it.activityInfo.packageName,
                                     "label" to it.loadLabel(pm).toString()) }
                        .filter { it["pkg"] != packageName }
                        .distinctBy { it["pkg"] }
                        .sortedBy { it["label"]!!.lowercase() }
                    result.success(list)
                }
                "hasUsagePermission" -> result.success(UsageHelper.hasPermission(this))
                "openUsageSettings" -> {
                    startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)); result.success(null)
                }
                "hasOverlayPermission" -> result.success(Settings.canDrawOverlays(this))
                "openOverlaySettings" -> {
                    startActivity(Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                        Uri.parse("package:$packageName"))); result.success(null)
                }
                "saveLimits" -> {
                    prefs.edit().putString(MonitorService.KEY_LIMITS, call.arguments as String).apply()
                    result.success(null)
                }
                "getLimits" -> result.success(prefs.getString(MonitorService.KEY_LIMITS, "[]"))
                "saveExclusions" -> {
                    prefs.edit().putString(MonitorService.KEY_EXCLUSIONS, call.arguments as String).apply()
                    result.success(null)
                }
                "getExclusions" -> result.success(prefs.getString(MonitorService.KEY_EXCLUSIONS, "[]"))
                "saveAutoJeda" -> {
                    val a = call.arguments as Map<*, *>
                    prefs.edit()
                        .putBoolean(MonitorService.KEY_AUTO_ON, a["on"] as Boolean)
                        .putInt(MonitorService.KEY_AUTO_SECONDS, a["seconds"] as Int)
                        .apply()
                    result.success(null)
                }
                "getTodayUsage" -> {
                    if (!UsageHelper.hasPermission(this)) { result.success(emptyMap<String, Int>()); return@setMethodCallHandler }
                    val (usage, _) = UsageHelper.today(this)
                    result.success(usage.mapValues { (it.value / 1000).toInt() })
                }
                "startMonitor" -> {
                    ContextCompat.startForegroundService(this, Intent(this, MonitorService::class.java))
                    prefs.edit().putBoolean("monitor_on", true).apply()
                    result.success(null)
                }
                "stopMonitor" -> {
                    stopService(Intent(this, MonitorService::class.java))
                    prefs.edit().putBoolean("monitor_on", false).apply()
                    result.success(null)
                }
                "saveJedaDuration" -> {
                    prefs.edit().putInt(MonitorService.KEY_JEDA_SECONDS, (call.arguments as Int)).apply()
                    result.success(null)
                }
                "saveJedaMedia" -> {
                    val a = call.arguments as Map<*, *>
                    prefs.edit()
                        .putString(MonitorService.KEY_MEDIA_KIND, a["kind"] as String)
                        .putString(MonitorService.KEY_MEDIA_PATH, a["path"] as String)
                        .apply()
                    result.success(null)
                }
                "getUsageSummary" -> {
                    if (!UsageHelper.hasPermission(this)) {
                        result.success("{\"days\":[],\"apps\":{}}")
                    } else {
                        result.success(UsageHelper.summary(this, call.arguments as Int))
                    }
                }
                "getJedaLog" -> result.success(JedaLog.readAll(this))
                "getAutoProgress" -> result.success(mapOf(
                    "on" to prefs.getBoolean(MonitorService.KEY_AUTO_ON, false),
                    "activeMs" to MonitorService.activeSnapshot,
                    "intervalMs" to prefs.getInt(MonitorService.KEY_AUTO_SECONDS, 7200) * 1000L
                ))
                "saveOverlayPercent" -> {
                    prefs.edit().putInt(MonitorService.KEY_OVERLAY_PCT, call.arguments as Int).apply()
                    result.success(null)
                }

                "pickMessage" -> {
                    val m = MessageEngine.pick(this, call.arguments as String)
                    result.success(mapOf("id" to m.id, "teks" to m.teks, "alasan" to m.alasan))
                }
                "saveDailyLimit" -> {
                    prefs.edit().putInt(MonitorService.KEY_DAILY_LIMIT, call.arguments as Int).apply()
                    result.success(null)
                }

                "isMonitorOn" -> result.success(prefs.getBoolean("monitor_on", false))
                "consumePending" -> { result.success(pending); pending = null }
                else -> result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        readIntent(intent)
        if (pending != null) channel?.invokeMethod("checkPending", null)
    }

    private fun readIntent(i: Intent?) {
        val pkg = i?.getStringExtra(MonitorService.EXTRA_PKG) ?: return
        pending = mapOf("pkg" to pkg, "label" to (i.getStringExtra(MonitorService.EXTRA_LABEL) ?: pkg))
        i.removeExtra(MonitorService.EXTRA_PKG)
    }
}
