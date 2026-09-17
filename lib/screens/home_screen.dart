import 'dart:math';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- PALET WARNA "BIRU CERAH & SEGAR" ---
  final Color primaryBlue = const Color(0xFF2D5972); // Biru tua logo
  final Color bgColor = const Color(0xFFF0F9FF);     // Background biru sangat muda
  
  // Warna Aksen yang Matching dengan Biru
  final Color skyBlue = const Color(0xFF38BDF8);     // Biru langit cerah
  final Color tealMint = const Color(0xFF2DD4BF);    // Tosca/Mint segar
  final Color goldenYellow = const Color(0xFFFBBF24); // Kuning keemasan
  final Color deepCyan = const Color(0xFF06B6D4);    // Cyan tua
  // ------------------------------------------

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
      backgroundColor: bgColor,
      // --- APP BAR YANG SUDAH DIPERCANTIK ---
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo Kucing
            Image.asset(
              'assets/images/logofinish.png',
              height: 38,
              width: 38,
            ),
            const SizedBox(width: 10),
            // Tulisan MengJeda
            const Text(
              'MengJeda',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 22,
                letterSpacing: 1.2,
                color: Color(0xFF2D5972), // Warna biru tua logo
              ),
            ),
          ],
        ),
        elevation: 0,
        // Menggunakan warna background yang sama dengan body agar menyatu
        backgroundColor: bgColor, 
        // Atau jika ingin putih bersih dengan bayangan tipis:
        // backgroundColor: Colors.white,
        // shadowColor: Colors.black.withValues(alpha: 0.05),
        // surfaceTintColor: Colors.transparent,
        
        actions: [
          // Ikon Settings di Kanan (Bukan Paw lagi)
          IconButton(
            icon: const Icon(Icons.settings_rounded), // Ikon setting bulat
            color: skyBlue, // Warna biru langit
            iconSize: 26,
            onPressed: () {
              // Aksi ketika tombol settings ditekan
            },
          ),
          const SizedBox(width: 8), // Sedikit jarak dari tepi kanan
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Card Motivasi dengan Telinga Kucing ---
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: skyBlue.withValues(alpha: 0.3), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: skyBlue.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome, color: skyBlue, size: 28),
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
                                color: skyBlue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _activeMotivation,
                              style: TextStyle(
                                fontSize: 14,
                                color: primaryBlue.withValues(alpha: 0.9),
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 20),
                        color: skyBlue,
                        onPressed: _pickRandomMotivation,
                      ),
                    ],
                  ),
                ),
                // Hiasan Telinga Kucing
                Positioned(
                  top: 0,
                  left: 20,
                  child: Row(
                    children: [
                      _buildEar(skyBlue),
                      const SizedBox(width: 4),
                      _buildEar(skyBlue),
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
            
            // --- Card Statistik ---
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
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: primaryBlue,
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
                        valueColor: AlwaysStoppedAnimation<Color>(tealMint),
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

            // --- Switch List Tile ---
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
                activeThumbColor: tealMint,
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
            
            // --- Grid Action Cards (Variasi Warna Cerah) ---
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
                  color: deepCyan,
                  title: 'Media Kustom',
                  subtitle: 'Foto/GIF Jeda',
                  onTap: () {},
                ),
                _buildActionCard(
                  icon: Icons.alarm,
                  color: goldenYellow,
                  title: 'Alarm Jeda',
                  subtitle: 'Kelola Alarm',
                  onTap: () {},
                ),
                _buildActionCard(
                  icon: Icons.calendar_today_outlined,
                  color: tealMint,
                  title: 'Jadwal Aktivitas',
                  subtitle: 'Makan/Olahraga',
                  onTap: () {},
                ),
                _buildActionCard(
                  icon: Icons.bar_chart_rounded,
                  color: skyBlue,
                  title: 'Statistik Penuh',
                  subtitle: 'Riwayat Jeda',
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget khusus untuk membuat telinga kucing
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
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primaryBlue)),
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primaryBlue),
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