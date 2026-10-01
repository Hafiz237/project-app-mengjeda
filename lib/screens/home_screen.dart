import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../data/dummy_jadwal.dart';
import '../data/jeda_settings.dart';
import 'alarm_list_screen.dart';
import 'jadwal_list_screen.dart';
import 'media_kustom_screen.dart';
import 'statistik_penuh_screen.dart';
import 'jeda_popup_screen.dart';
import 'pengaturan_jeda_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _motivationQuotes = [
    "Mata lelah butuh rehat sejenak nih, yuk istirahatkan pandanganmu sebentar!",
    "Postur tubuhmu sudah tegak belum? Regangkan pundakmu dulu yuk, biar nggak pegal. ",
    "Dunia nyata di sekitarmu tidak kalah seru dari layar kaca. ",
    "Jeda 5 menit sekarang membuat fokusmu berlipat ganda nanti!!",
    "Waktumu sangat berharga, gunakan dengan bijak hari ini.",
  ];

  late String _activeMotivation;
  final int _screenTimeMinutes = 135;
  final int _targetDailyMinutes = 180;
  Timer? _autoJedaTimer;
  Timer? _jadwalCheckTimer;
  final Set<String> _triggeredJadwalHariIni = {};

  @override
  void initState() {
    super.initState();
    _pickRandomMotivation();
    _startAutoJeda();
    _startJadwalChecker();
  }

  @override
  void dispose() {
    _autoJedaTimer?.cancel();
    _jadwalCheckTimer?.cancel();
    super.dispose();
  }

  void _pickRandomMotivation() {
    final random = Random();
    setState(() {
      _activeMotivation =
          _motivationQuotes[random.nextInt(_motivationQuotes.length)];
    });
  }

  void _startAutoJeda() {
    _autoJedaTimer?.cancel();
    if (!JedaSettings.otomatisAktif) return;

    _autoJedaTimer = Timer.periodic(JedaSettings.interval, (_) {
      if (mounted && JedaSettings.otomatisAktif) _showPopupJeda();
    });
  }

  void _startJadwalChecker() {
    _jadwalCheckTimer?.cancel();
    _jadwalCheckTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      final now = TimeOfDay.now();
      for (final jadwal in dummyJadwal) {
        if (!jadwal.isActive) continue;
        if (_triggeredJadwalHariIni.contains(jadwal.id)) continue;

        final sameHour = jadwal.time.hour == now.hour;
        final sameMinute = jadwal.time.minute == now.minute;

        if (sameHour && sameMinute) {
          _triggeredJadwalHariIni.add(jadwal.id);
          _triggerJedaDariJadwal(jadwal.label);
        }
      }
    });
  }

  Future<void> _triggerJedaDariJadwal(String labelJadwal) async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Waktunya: $labelJadwal')),
    );
    await _showPopupJeda();
  }

  Future<void> _showPopupJeda({Duration? durasi}) async {
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => JedaPopupScreen(durasi: durasi ?? JedaSettings.durasi),
      ),
    );
  }

  Future<void> _triggerJeda() async {
    final durasi = await showDialog<Duration>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Durasi Jeda'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDurasiOption(context, '15 Detik', const Duration(seconds: 15)),
              _buildDurasiOption(context, '30 Detik', const Duration(seconds: 30)),
              _buildDurasiOption(context, '1 Menit', const Duration(minutes: 1)),
              _buildDurasiOption(context, '2 Menit', const Duration(minutes: 2)),
              _buildDurasiOption(context, '5 Menit', const Duration(minutes: 5)),
              _buildDurasiOption(context, '10 Menit', const Duration(minutes: 10)),
            ],
          ),
        ),
      ),
    );

    if (durasi == null) return;
    await _showPopupJeda(durasi: durasi);
  }

  Widget _buildDurasiOption(BuildContext context, String label, Duration durasi) {
    return ListTile(
      title: Text(label),
      trailing: const Icon(Icons.timer_outlined),
      onTap: () => Navigator.pop(context, durasi),
    );
  }

  Future<void> _bukaPengaturanJeda() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const PengaturanJedaScreen()),
    );
    if (saved == true) {
      _startAutoJeda();
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenTimeHours = (_screenTimeMinutes / 60).toStringAsFixed(1);
    final progress = (_screenTimeMinutes / _targetDailyMinutes).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logofinish.png',
              height: 38,
              width: 38,
            ),
            const SizedBox(width: 10),
            const Text(
              'MengJeda',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 22,
                letterSpacing: 1.2,
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: AppColors.bgColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            color: AppColors.skyBlue,
            iconSize: 26,
            onPressed: _bukaPengaturanJeda,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: AppColors.skyBlue.withValues(alpha: 0.3),
                        width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.skyBlue.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome,
                          color: AppColors.skyBlue, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pesan Jeda Hari Ini',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.skyBlue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _activeMotivation,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.primaryBlue
                                    .withValues(alpha: 0.9),
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 20),
                        color: AppColors.skyBlue,
                        onPressed: _pickRandomMotivation,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 20,
                  child: Row(
                    children: [
                      _buildEar(AppColors.skyBlue),
                      const SizedBox(width: 4),
                      _buildEar(AppColors.skyBlue),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Statistik Penggunaan Hari Ini',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$screenTimeHours Jam',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Dari batas harian 3.0 Jam',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 10,
                        backgroundColor: Colors.grey.shade100,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(AppColors.tealMint),
                        strokeCap: StrokeCap.round,
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricItem(Icons.timer_outlined, 'Sesi Jeda', '4 Kali'),
                      _buildMetricItem(
                          Icons.hourglass_top, 'Jeda Berikutnya', '25 Menit'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _bukaPengaturanJeda,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: JedaSettings.otomatisAktif
                        ? [AppColors.tealMint, AppColors.deepCyan]
                        : [Colors.grey.shade300, Colors.grey.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (JedaSettings.otomatisAktif
                              ? AppColors.tealMint
                              : Colors.grey)
                          .withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        JedaSettings.otomatisAktif ? Icons.timer : Icons.timer_off,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pemantauan Jeda Otomatis',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            JedaSettings.otomatisAktif
                                ? 'AKTIF — tiap ${JedaSettings.formatDuration(JedaSettings.interval)}, pop-up ${JedaSettings.formatDuration(JedaSettings.durasi)}'
                                : 'NONAKTIF — tap untuk atur',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepCyan,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: _triggerJeda,
                icon: const Icon(Icons.self_improvement),
                label: const Text(
                  'Mulai Jeda Sekarang',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Fitur MengJeda',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.25,
              children: [
                _buildActionCard(
                  icon: Icons.photo_library_outlined,
                  color: AppColors.deepCyan,
                  title: 'Media Kustom',
                  subtitle: 'atur gambar & suara jeda',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MediaKustomScreen()),
                    );
                  },
                ),
                _buildActionCard(
                  icon: Icons.alarm,
                  color: AppColors.goldenYellow,
                  title: 'Alarm Jeda',
                  subtitle: 'Kelola Alarm',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AlarmListScreen()),
                    );
                  },
                ),
                _buildActionCard(
                  icon: Icons.calendar_today_outlined,
                  color: AppColors.tealMint,
                  title: 'Jadwal Aktivitas',
                  subtitle: 'kelola jadwal aktivitas',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const JadwalListScreen()),
                    );
                  },
                ),
                _buildActionCard(
                  icon: Icons.bar_chart_rounded,
                  color: AppColors.skyBlue,
                  title: 'Statistik Penuh',
                  subtitle: 'Lihat Riwayat Jeda',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const StatistikPenuhScreen()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEar(Color color) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: color, width: 2),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
          bottomLeft: Radius.circular(2),
          bottomRight: Radius.circular(2),
        ),
      ),
    );
  }

  Widget _buildMetricItem(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            const SizedBox(height: 0),
            Text(
              value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.primaryBlue),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color, size: 22),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.primaryBlue),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}