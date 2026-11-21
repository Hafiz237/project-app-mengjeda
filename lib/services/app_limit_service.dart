import 'dart:convert';
import 'package:flutter/services.dart';
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
}
