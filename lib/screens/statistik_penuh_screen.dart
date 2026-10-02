import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_bottom_nav.dart';

class StatistikPenuhScreen extends StatelessWidget {
  const StatistikPenuhScreen({super.key});

  static const int _navIndex = 4;

  static const List<Map<String, dynamic>> _riwayatMingguan = [
    {'hari': 'Senin', 'waktu_layar': '4 Jam 12 Menit', 'menit': 252, 'sesi_jeda': 3, 'status': 'Over limit'},
    {'hari': 'Selasa', 'waktu_layar': '2 Jam 45 Menit', 'menit': 165, 'sesi_jeda': 4, 'status': 'Sehat'},
    {'hari': 'Rabu', 'waktu_layar': '3 Jam 10 Menit', 'menit': 190, 'sesi_jeda': 5, 'status': 'Normal'},
    {'hari': 'Kamis', 'waktu_layar': '2 Jam 15 Menit', 'menit': 135, 'sesi_jeda': 4, 'status': 'Sehat'},
  ];

  int get _totalSesi => _riwayatMingguan.fold(
      0, (sum, d) => sum + (d['sesi_jeda'] as int));

  int get _rataMenit {
    final total =
        _riwayatMingguan.fold<int>(0, (sum, d) => sum + (d['menit'] as int));
    return (total / _riwayatMingguan.length).round();
  }

  int get _maxMenit => _riwayatMingguan
      .map((d) => d['menit'] as int)
      .reduce((a, b) => a > b ? a : b);

  String _formatMenit(int menit) => '${menit ~/ 60}j ${menit % 60}m';

  Color _statusColor(String status) {
    switch (status) {
      case 'Sehat':
        return AppColors.tealMint;
      case 'Normal':
        return AppColors.goldenYellow;
      default:
        return Colors.red;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Sehat':
        return Icons.check_circle_outline;
      case 'Normal':
        return Icons.thumb_up_alt_outlined;
      default:
        return Icons.warning_amber_rounded;
    }
  }

  
  Widget _buildAchievementCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.skyBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emoji_events,
                color: Colors.white, size: 36),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pencapaian Mingguan',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Anda berhasil melakukan $_totalSesi sesi jeda minggu ini. Lanjutkan!',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCard(Map<String, dynamic> data) {
    final status = data['status'] as String;
    final color = _statusColor(status);
    final menit = data['menit'] as int;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(_statusIcon(status), color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['hari'] as String,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Waktu layar: ${data['waktu_layar']}',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.skyBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text(
                      '${data['sesi_jeda']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const Text('Jeda',
                        style: TextStyle(
                            fontSize: 10, color: AppColors.primaryBlue)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: menit / _maxMenit,
                    minHeight: 8,
                    backgroundColor: color.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        title: const Text(
          'Statistik Penuh',
          style: TextStyle(
              fontWeight: FontWeight.w800, color: AppColors.primaryBlue),
        ),
        centerTitle: true,
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryBlue),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _buildAchievementCard(),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildStatTile(
                icon: Icons.self_improvement,
                color: AppColors.tealMint,
                value: '$_totalSesi',
                label: 'Total sesi jeda',
              ),
              const SizedBox(width: 12),
              _buildStatTile(
                icon: Icons.phone_android,
                color: AppColors.skyBlue,
                value: _formatMenit(_rataMenit),
                label: 'Rata-rata layar/hari',
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Rincian Harian',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
          ..._riwayatMingguan.map(_buildDayCard),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: _navIndex),
    );
  }
}