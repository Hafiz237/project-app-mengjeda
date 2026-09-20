import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'alarm_list_screen.dart';
import 'jadwal_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _motivationQuotes = [
    "Meow! Mata lelah butuh rehat sejenak, yuk istirahatkan pandanganmu. 🐾",
    "Postur tubuhmu sudah tegak belum? Regangkan pundakmu dulu seperti kucing meregang! 🐈",
    "Dunia nyata di sekitarmu tidak kalah seru dari layar kaca. 🐱",
    "Jeda 5 menit sekarang membuat fokusmu berlipat ganda nanti. Purr-fect! ✨",
    "Waktumu sangat berharga, gunakan dengan bijak hari ini. 🐾",
  ];

  late String _activeMotivation;
  final int _screenTimeMinutes = 135;
  final int _targetDailyMinutes = 180;
  bool _isBreakSessionActive = true;

  @override
  void initState() {
    super.initState();
    _pickRandomMotivation();
  }

  void _pickRandomMotivation() {
    final random = Random();
    setState(() {
      _activeMotivation = _motivationQuotes[random.nextInt(_motivationQuotes.length)];
    });
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
            onPressed: () {},
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
                    border: Border.all(color: AppColors.skyBlue.withValues(alpha: 0.3), width: 2),
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
                      Icon(Icons.auto_awesome, color: AppColors.skyBlue, size: 28),
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
                                color: AppColors.primaryBlue.withValues(alpha: 0.9),
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
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 10,
                        backgroundColor: Colors.grey.shade100,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.tealMint),
                        strokeCap: StrokeCap.round,
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricItem(Icons.timer_outlined, 'Sesi Jeda', '4 Kali'),
                      _buildMetricItem(Icons.hourglass_top, 'Jeda Berikutnya', '25 Menit'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Pemantauan Jeda Otomatis',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Pop-up pengingat tiap 2 jam aktif'),
                value: _isBreakSessionActive,
                activeThumbColor: AppColors.tealMint,
                onChanged: (val) {
                  setState(() => _isBreakSessionActive = val);
                },
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
                  subtitle: 'sesuaikan bentuk notif jeda',
                  onTap: () {},
                ),
                _buildActionCard(
                  icon: Icons.alarm,
                  color: AppColors.goldenYellow,
                  title: 'Alarm Jeda',
                  subtitle: 'Kelola Alarm',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AlarmListScreen()),
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
                      MaterialPageRoute(builder: (context) => const JadwalListScreen()),
                    );
                  },
                ),
                _buildActionCard(
                  icon: Icons.bar_chart_rounded,
                  color: AppColors.skyBlue,
                  title: 'Statistik Penuh',
                  subtitle: 'Lihat Riwayat Jeda',
                  onTap: () {},
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
            Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            const SizedBox(height: 0),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryBlue)),
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryBlue),
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