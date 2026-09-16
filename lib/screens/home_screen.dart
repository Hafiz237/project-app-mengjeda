import 'dart:math';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // FR-06: Rule-based kumpulan pesan motivasi (NFR-05: Maintainable list)
  final List<String> _motivationQuotes = [
    "Mata lelah butuh rehat sejenak, yuk istirahatkan pandanganmu.",
    "Postur tubuhmu sudah tegak belum? Regangkan pundakmu dulu!",
    "Dunia nyata di sekitarmu tidak kalah seru dari layar kaca.",
    "Jeda 5 menit sekarang membuat fokusmu berlipat ganda nanti.",
    "Waktumu sangat berharga, gunakan dengan bijak hari ini.",
  ];

  late String _activeMotivation;
  int _screenTimeMinutes = 135;
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'MengJeda',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue.shade800,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.blue.shade700, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pesan Jeda Hari Ini',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _activeMotivation,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade900,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    color: Colors.blue.shade600,
                    onPressed: _pickRandomMotivation,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Statistik Penggunaan Hari Ini',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
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
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
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
                        strokeWidth: 8,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress > 0.8 ? Colors.orange : Colors.blue,
                        ),
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
                borderRadius: BorderRadius.circular(14),
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
                activeColor: Colors.blue,
                onChanged: (val) {
                  setState(() => _isBreakSessionActive = val);
                },
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Aktivitas & Kustomisasi',
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
                  color: Colors.purple,
                  title: 'Media Kustom',
                  subtitle: 'Foto/GIF Jeda (FR-03)',
                  onTap: () {

                  },
                ),
                _buildActionCard(
                  icon: Icons.alarm,
                  color: Colors.amber.shade800,
                  title: 'Alarm Jeda',
                  subtitle: 'Kelola Alarm (FR-04)',
                  onTap: () {

                  },
                ),
                _buildActionCard(
                  icon: Icons.calendar_today_outlined,
                  color: Colors.teal,
                  title: 'Jadwal Aktivitas',
                  subtitle: 'Makan/Olahraga (FR-05)',
                  onTap: () {

                  },
                ),
                _buildActionCard(
                  icon: Icons.bar_chart_rounded,
                  color: Colors.indigo,
                  title: 'Statistik Penuh',
                  subtitle: 'Riwayat Jeda (FR-07)',
                  onTap: () {

                  },
                ),
              ],
            ),
          ],
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
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, color: color, size: 20),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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