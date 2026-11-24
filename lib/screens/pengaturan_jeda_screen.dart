import 'package:flutter/material.dart';
import '../data/jeda_settings.dart';
import '../theme/app_colors.dart';
import 'pengecualian_app_screen.dart';

class PengaturanJedaScreen extends StatefulWidget {
  const PengaturanJedaScreen({super.key});

  @override
  State<PengaturanJedaScreen> createState() => _PengaturanJedaScreenState();
}

class _PengaturanJedaScreenState extends State<PengaturanJedaScreen> {
  late Duration _interval;
  late Duration _durasi;
  late bool _otomatisAktif;
  late int _ukuran;

  final List<Duration> _intervalOptions = const [
    Duration(seconds: 30),
    Duration(minutes: 1),
    Duration(minutes: 2),
    Duration(minutes: 5),
    Duration(minutes: 10),
    Duration(minutes: 15),
    Duration(minutes: 30),
    Duration(hours: 1),
    Duration(hours: 2),
  ];

  final List<Duration> _durasiOptions = const [
    Duration(seconds: 10),
    Duration(seconds: 15),
    Duration(seconds: 20),
    Duration(seconds: 30),
    Duration(seconds: 45),
    Duration(minutes: 1),
    Duration(minutes: 2),
    Duration(minutes: 5),
    Duration(minutes: 10),
  ];

  @override
  void initState() {
    super.initState();
    _interval = JedaSettings.interval;
    _durasi = JedaSettings.durasi;
    _otomatisAktif = JedaSettings.otomatisAktif;
    _ukuran = JedaSettings.ukuranPopupPersen;
  }

  void _simpan() {
    JedaSettings.interval = _interval;
    JedaSettings.durasi = _durasi;
    JedaSettings.otomatisAktif = _otomatisAktif;
    JedaSettings.ukuranPopupPersen = _ukuran;
    JedaSettings.save(); // simpan permanen

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Pengaturan disimpan')));
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        title: const Text(
          'Pengaturan Jeda',
          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryBlue),
        ),
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryBlue),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _otomatisAktif
                      ? [AppColors.tealMint, AppColors.deepCyan]
                      : [Colors.grey.shade300, Colors.grey.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
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
                      _otomatisAktif ? Icons.timer : Icons.timer_off,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pemantauan Otomatis',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _otomatisAktif ? 'Aktif' : 'Nonaktif',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _otomatisAktif,
                    activeThumbColor: Colors.white,
                    activeTrackColor: Colors.white.withValues(alpha: 0.5),
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                    onChanged: (v) => setState(() => _otomatisAktif = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionHeader(
              icon: Icons.repeat,
              title: 'Interval Kemunculan',
              subtitle: 'Seberapa sering pop-up jeda muncul',
              color: AppColors.deepCyan,
            ),
            const SizedBox(height: 10),
            _buildDropdownCard<Duration>(
              value: _interval,
              options: _intervalOptions,
              labelBuilder: (d) => 'Tiap ${JedaSettings.formatDuration(d)}',
              color: AppColors.deepCyan,
              onChanged: (v) => setState(() => _interval = v),
            ),

            const SizedBox(height: 24),

            _buildSectionHeader(
              icon: Icons.hourglass_bottom,
              title: 'Durasi Pop-up',
              subtitle: 'Berapa lama pop-up tampil di layar',
              color: AppColors.skyBlue,
            ),
            const SizedBox(height: 10),
            _buildDropdownCard<Duration>(
              value: _durasi,
              options: _durasiOptions,
              labelBuilder: (d) => JedaSettings.formatDuration(d),
              color: AppColors.skyBlue,
              onChanged: (v) => setState(() => _durasi = v),
            ),

            const SizedBox(height: 24),
            _buildSectionHeader(
              icon: Icons.aspect_ratio,
              title: 'Ukuran Pop-up',
              subtitle: 'Seberapa besar pop-up menutupi layar',
              color: AppColors.tealMint,
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 25, label: Text('Seperempat')),
                  ButtonSegment(value: 50, label: Text('Setengah')),
                  ButtonSegment(value: 100, label: Text('Penuh')),
                ],
                selected: {_ukuran},
                onSelectionChanged: (s) => setState(() => _ukuran = s.first),
              ),
            ),

            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.skyBlue, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Pop-up jeda akan muncul tiap '
                      '${JedaSettings.formatDuration(_interval)}, '
                      'dan tampil selama ${JedaSettings.formatDuration(_durasi)}.',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PengecualianAppScreen()),
              ),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.tealMint.withValues(alpha: 0.3), width: 1.5),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_outlined, color: AppColors.tealMint),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Aplikasi Pengecualian',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Jeda rutin tidak muncul saat aplikasi ini dibuka',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _simpan,
                icon: const Icon(Icons.save),
                label: const Text(
                  'Simpan Pengaturan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownCard<T>({
    required T value,
    required List<T> options,
    required String Function(T) labelBuilder,
    required Color color,
    required ValueChanged<T> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: color),
          items: options
              .map((o) => DropdownMenuItem<T>(
                    value: o,
                    child: Text(
                      labelBuilder(o),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}