import 'package:flutter/material.dart';
import '../models/jadwal_model.dart';
import '../models/kategori_model.dart';
import '../data/dummy_jadwal.dart';
import '../data/dummy_kategori.dart';
import '../theme/app_colors.dart';
import 'jadwal_form_screen.dart';

class JadwalListScreen extends StatefulWidget {
  const JadwalListScreen({super.key});

  @override
  State<JadwalListScreen> createState() => _JadwalListScreenState();
}

class _JadwalListScreenState extends State<JadwalListScreen> {
  late List<JadwalModel> _jadwalList;

  @override
  void initState() {
    super.initState();
    _jadwalList = dummyJadwal;
  }

  KategoriModel _getKategori(String kategoriId) {
    return dummyKategori.firstWhere((k) => k.id == kategoriId);
  }

  void _toggleJadwal(String id, bool value) {
    setState(() {
      final jadwal = _jadwalList.firstWhere((j) => j.id == id);
      jadwal.isActive = value;
    });
  }

  Future<void> _addJadwal() async {
    final result = await Navigator.push<JadwalModel>(
      context,
      MaterialPageRoute(builder: (context) => const JadwalFormScreen()),
    );
    if (result != null) {
      setState(() => _jadwalList.add(result));
    }
  }

  Future<void> _editJadwal(JadwalModel jadwal) async {
    final result = await Navigator.push<JadwalModel>(
      context,
      MaterialPageRoute(builder: (context) => JadwalFormScreen(existingJadwal: jadwal)),
    );
    if (result != null) {
      setState(() {
        final index = _jadwalList.indexWhere((j) => j.id == result.id);
        if (index != -1) _jadwalList[index] = result;
      });
    }
  }

  Future<bool> _confirmDelete(JadwalModel jadwal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Jadwal?'),
        content: Text('Jadwal "${jadwal.label}" akan dihapus permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  void _deleteJadwal(String id) {
    setState(() {
      _jadwalList.removeWhere((j) => j.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        title: const Text('Jadwal Aktivitas',
            style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryBlue)),
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryBlue),
      ),
      body: _jadwalList.isEmpty
          ? const Center(child: Text('Belum ada jadwal. Tambah jadwal baru.'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _jadwalList.length,
        itemBuilder: (context, index) {
          final jadwal = _jadwalList[index];
          final kategori = _getKategori(jadwal.kategoriId);
          return Dismissible(
            key: ValueKey(jadwal.id),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) => _confirmDelete(jadwal),
            onDismissed: (_) => _deleteJadwal(jadwal.id),
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.tealMint.withValues(alpha: 0.3), width: 1.5),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.tealMint.withValues(alpha: 0.15),
                  child: Icon(kategori.icon, color: AppColors.tealMint),
                ),
                title: Text(jadwal.label,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                subtitle: Text('${jadwal.time.format(context)} · Kategori: ${kategori.nama}'),
                trailing: Switch(
                  value: jadwal.isActive,
                  activeThumbColor: AppColors.tealMint,
                  onChanged: (val) => _toggleJadwal(jadwal.id, val),
                ),
                onTap: () => _editJadwal(jadwal),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.tealMint,
        onPressed: _addJadwal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}