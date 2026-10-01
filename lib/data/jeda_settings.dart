import 'package:flutter/material.dart';

class JedaSettings {
  static Duration interval = const Duration(minutes: 2);
  static Duration durasi = const Duration(seconds: 20);
  static bool otomatisAktif = false;

  static String formatDuration(Duration d) {
    if (d.inSeconds < 60) return '${d.inSeconds} detik';
    if (d.inMinutes < 60) {
      final sisaDetik = d.inSeconds % 60;
      if (sisaDetik == 0) return '${d.inMinutes} menit';
      return '${d.inMinutes} menit $sisaDetik detik';
    }
    return '${d.inHours} jam';
  }
}