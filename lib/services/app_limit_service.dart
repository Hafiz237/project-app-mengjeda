import 'dart:convert';
import 'package:flutter/services.dart';
import '../data/jeda_settings.dart';
import '../models/app_limit_model.dart';

class AppLimitService {
  AppLimitService._();
  static final AppLimitService instance = AppLimitService._();

  static const _ch = MethodChannel('mengjeda/app_limit');

  void Function(String pkg, String label)? onJedaRequested;

  void init() {
    _ch.setMethodCallHandler((call) async {
      if (call.method == 'checkPending') await checkPending();
    });
    checkPending();
  }

  Future<void> checkPending() async {
    final m = await _ch.invokeMapMethod<String, String>('consumePending');
    if (m != null) onJedaRequested?.call(m['pkg']!, m['label']!);
  }

  Future<List<InstalledApp>> installedApps() async {
    final l = await _ch.invokeListMethod<Map>('getInstalledApps') ?? [];
    return l
        .map((e) => InstalledApp(e['pkg'] as String, e['label'] as String))
        .toList();
  }

  Future<bool> hasUsagePermission() async =>
      await _ch.invokeMethod<bool>('hasUsagePermission') ?? false;
  Future<void> openUsageSettings() => _ch.invokeMethod('openUsageSettings');
  Future<bool> hasOverlayPermission() async =>
      await _ch.invokeMethod<bool>('hasOverlayPermission') ?? false;
  Future<void> openOverlaySettings() => _ch.invokeMethod('openOverlaySettings');

  Future<List<AppLimitModel>> getLimits() async {
    final raw = await _ch.invokeMethod<String>('getLimits') ?? '[]';
    return (jsonDecode(raw) as List)
        .map((e) => AppLimitModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveLimits(List<AppLimitModel> limits) => _ch.invokeMethod(
      'saveLimits', jsonEncode(limits.map((e) => e.toJson()).toList()));

  Future<Map<String, int>> todayUsage() async {
    final m = await _ch.invokeMapMethod<String, int>('getTodayUsage');
    return m ?? {};
  }

  Future<void> saveJedaDuration(int seconds) =>
      _ch.invokeMethod('saveJedaDuration', seconds);

  Future<bool> isMonitorOn() async =>
      await _ch.invokeMethod<bool>('isMonitorOn') ?? false;
  Future<void> startMonitor() => _ch.invokeMethod('startMonitor');
  Future<void> stopMonitor() => _ch.invokeMethod('stopMonitor');

  Future<List<InstalledApp>> getExclusions() async {
    final raw = await _ch.invokeMethod<String>('getExclusions') ?? '[]';
    return (jsonDecode(raw) as List)
        .map((e) => InstalledApp(e['pkg'] as String, e['label'] as String))
        .toList();
  }

  Future<void> saveExclusions(List<InstalledApp> apps) => _ch.invokeMethod(
      'saveExclusions',
      jsonEncode(apps.map((a) => {'pkg': a.pkg, 'label': a.label}).toList()));

  Future<void> saveAutoJeda({required bool on, required int seconds}) =>
      _ch.invokeMethod('saveAutoJeda', {'on': on, 'seconds': seconds});

  Future<void> syncJedaSettings() async {
    await saveJedaDuration(JedaSettings.durasi.inSeconds);
    await saveAutoJeda(
      on: JedaSettings.otomatisAktif,
      seconds: JedaSettings.interval.inSeconds,
    );
    if (JedaSettings.otomatisAktif &&
        await hasUsagePermission() &&
        !await isMonitorOn()) {
      await startMonitor();
    }
  }
}