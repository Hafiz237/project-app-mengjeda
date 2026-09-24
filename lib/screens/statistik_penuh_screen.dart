import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StatistikPenuhScreen extends StatelessWidget {
  const StatistikPenuhScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Data dummy (simulasi) untuk daftar riwayat
    final List<Map<String, dynamic>> riwayatMingguan = [
      {'hari': 'Senin', 'waktu_layar': '4 Jam 12 Menit', 'sesi_jeda': 3, 'status': 'Over limit'},
      {'hari': 'Selasa', 'waktu_layar': '2 Jam 45 Menit', 'sesi_jeda': 4, 'status': 'Sehat'},
      {'hari': 'Rabu', 'waktu_layar': '3 Jam 10 Menit', 'sesi_jeda': 5, 'status': 'Normal'},
      {'hari': 'Kamis', 'waktu_layar': '2 Jam 15 Menit', 'sesi_jeda': 4, 'status': 'Sehat'},
    ];

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        title: const Text(
          'Statistik Penuh',
          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryBlue),
        ),
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryBlue),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.skyBlue,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Row(
                children: [
                  Icon(Icons.emoji_events, color: Colors.white, size: 40),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pencapaian Mingguan',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Anda berhasil melakukan 16 sesi jeda minggu ini. Lanjutkan!',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Rincian Harian',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: riwayatMingguan.length,
                itemBuilder: (context, index) {
                  final data = riwayatMingguan[index];
                  final isHealthy = data['status'] == 'Sehat' || data['status'] == 'Normal';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isHealthy ? AppColors.tealMint.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
                        child: Icon(
                          isHealthy ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                          color: isHealthy ? AppColors.tealMint : Colors.red,
                        ),
                      ),
                      title: Text(data['hari'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Waktu Layar: ${data['waktu_layar']}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${data['sesi_jeda']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const Text('Jeda', style: TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}