import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../models/alarm_model.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'mengjeda_jeda',
      'Pengingat Jeda',
      channelDescription: 'Alarm dan pengingat jeda MengJeda',
      importance: Importance.max,
      priority: Priority.high,
    ),
  );

  Future<void> init() async {
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta')); // WIB

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(settings: settings);
  }

  Future<void> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();
  }

  int _notifId(String id) {
    var hash = 0;
    for (final unit in id.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return hash;
  }

  tz.TZDateTime _nextInstanceOf(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, time.hour, time.minute);
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> _zoned({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime at,
    DateTimeComponents? repeat,
  }) async {
    Future<void> go(AndroidScheduleMode mode) => _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: at,
      notificationDetails: _details,
      androidScheduleMode: mode,
      matchDateTimeComponents: repeat,
    );
    try {
      await go(AndroidScheduleMode.exactAllowWhileIdle);
    } on PlatformException {
      await go(AndroidScheduleMode.inexactAllowWhileIdle);
    }
  }

  Future<void> scheduleAlarm(AlarmModel alarm) async {
    await cancelAlarm(alarm.id);
    if (!alarm.isActive) return;
    await _zoned(
      id: _notifId(alarm.id),
      title: 'Waktunya jeda',
      body: alarm.label,
      at: _nextInstanceOf(alarm.time),
      repeat: DateTimeComponents.time,
    );
  }

  Future<void> cancelAlarm(String id) => _plugin.cancel(id: _notifId(id));

  Future<void> scheduleTest(Duration delay) => _zoned(
    id: 999999,
    title: 'Tes jeda MengJeda',
    body: 'Notifikasi ini datang dari jadwal sistem, bukan dari layar aplikasi.',
    at: tz.TZDateTime.now(tz.local).add(delay),
  );
}