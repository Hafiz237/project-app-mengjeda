import 'package:shared_preferences/shared_preferences.dart';

class JedaSettings {
  static Duration interval = const Duration(minutes: 2);
  static Duration durasi = const Duration(seconds: 20);
  static bool otomatisAktif = false;
  static int ukuranPopupPersen = 50;

  static Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    interval = Duration(seconds: p.getInt('jeda_interval_s') ?? interval.inSeconds);
    durasi = Duration(seconds: p.getInt('jeda_durasi_s') ?? durasi.inSeconds);
    otomatisAktif = p.getBool('jeda_otomatis') ?? otomatisAktif;
    ukuranPopupPersen = p.getInt('jeda_ukuran_pct') ?? ukuranPopupPersen;
  }

  static Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('jeda_interval_s', interval.inSeconds);
    await p.setInt('jeda_durasi_s', durasi.inSeconds);
    await p.setBool('jeda_otomatis', otomatisAktif);
    await p.setInt('jeda_ukuran_pct', ukuranPopupPersen);
  }

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