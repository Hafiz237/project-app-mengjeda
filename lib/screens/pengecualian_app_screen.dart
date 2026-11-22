import 'package:flutter/material.dart';
import '../models/app_limit_model.dart';
import '../services/app_limit_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_picker.dart';

class PengecualianAppScreen extends StatefulWidget {
  const PengecualianAppScreen({super.key});

  @override
  State<PengecualianAppScreen> createState() => _PengecualianAppScreenState();
}

class _PengecualianAppScreenState extends State<PengecualianAppScreen> {
  final _svc = AppLimitService.instance;
  List<InstalledApp> _apps = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _svc.getExclusions();
    if (!mounted) return;
    setState(() {
      _apps = data;
      _loading = false;
    });
  }

  Future<void> _tambah() async {
    final all = await _svc.installedApps();
    if (!mounted) return;
    final dipakai = _apps.map((e) => e.pkg).toSet();
    final pilih = await showModalBottomSheet<InstalledApp>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          AppPicker(apps: all.where((a) => !dipakai.contains(a.pkg)).toList()),
    );
    if (pilih == null || !mounted) return;
    setState(() => _apps.add(pilih));
    await _svc.saveExclusions(_apps);
  }

  Future<void> _hapus(InstalledApp app) async {
    setState(() => _apps.removeWhere((e) => e.pkg == app.pkg));
    await _svc.saveExclusions(_apps);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        title: const Text(
          'Aplikasi Pengecualian',
          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryBlue),
        ),
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryBlue),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tambah,
        backgroundColor: AppColors.tealMint,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah aplikasi',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.skyBlue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Saat salah satu aplikasi di bawah sedang dibuka, jeda rutin '
                        'ditunda dan muncul begitu kamu pindah ke aplikasi lain. '
                        'Batas waktu per aplikasi tetap berlaku.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_apps.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('Belum ada aplikasi pengecualian.')),
            ),
          for (final app in _apps)
            Dismissible(
              key: ValueKey(app.pkg),
              direction: DismissDirection.endToStart,
              background: Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.red.shade300,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) => _hapus(app),
              child: Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.tealMint.withValues(alpha: 0.15),
                    child: Text(
                      app.label.isEmpty ? '?' : app.label[0].toUpperCase(),
                      style: const TextStyle(
                          color: AppColors.tealMint, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(app.label,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, color: AppColors.primaryBlue)),
                  subtitle: Text(app.pkg, style: const TextStyle(fontSize: 11)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}