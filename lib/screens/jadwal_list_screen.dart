import 'package:flutter/material.dart';
import '../models/jadwal_model.dart';
import '../models/kategori_model.dart';
import '../data/dummy_jadwal.dart';
import '../data/dummy_kategori.dart';
import '../theme/app_colors.dart';
import '../widgets/app_bottom_nav.dart';
import 'jadwal_form_screen.dart';

class JadwalListScreen extends StatefulWidget {
  const JadwalListScreen({super.key});

  @override
  State<JadwalListScreen> createState() => _JadwalListScreenState();
}

class _JadwalListScreenState extends State<JadwalListScreen> {
  static const int _navIndex = 3;

  late List<JadwalModel> _jadwalList;
  String? _filterKategoriId;

  @override
  void initState() {
    super.initState();
    _jadwalList = dummyJadwal;
  }
   KategoriModel _getKategori(String kategoriId) {
    return dummyKategori.firstWhere(
      (k) => k.id == kategoriId,
      orElse: () => dummyKategori.first,
    );
  }

  int _minutes(TimeOfDay t) => t.hour * 60 + t.minute;
  List<JadwalModel> get _visibleList {
    final list = _jadwalList
        .where((j) =>
            _filterKategoriId == null || j.kategoriId == _filterKategoriId)
        .toList()
      ..sort((a, b) => _minutes(a.time).compareTo(_minutes(b.time)));
    return list;
  }

  int get _activeCount => _jadwalList.where((j) => j.isActive).length;

  JadwalModel? get _nextJadwal {
    final aktif = _jadwalList.where((j) => j.isActive).toList()
      ..sort((a, b) => _minutes(a.time).compareTo(_minutes(b.time)));
    if (aktif.isEmpty) return null;
    final now = _minutes(TimeOfDay.now());
    return aktif.firstWhere(
      (j) => _minutes(j.time) >= now,
      orElse: () => aktif.first,
    );
  }
   void _toggleJadwal(String id, bool value) {
    setState(() {
      _jadwalList.firstWhere((j) => j.id == id).isActive = value;
    });
  }

  Future<void> _addJadwal() async {
    final result = await Navigator.push<JadwalModel>(
      context,
      MaterialPageRoute(builder: (context) => const JadwalFormScreen()),
    );
    if (result != null && mounted) {
      setState(() => _jadwalList.add(result));
    }
  }

  Future<void> _editJadwal(JadwalModel jadwal) async {
    final result = await Navigator.push<JadwalModel>(
      context,
      MaterialPageRoute(
          builder: (context) => JadwalFormScreen(existingJadwal: jadwal)),
    );
    if (result != null && mounted) {
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Jadwal?',
            style: TextStyle(
                fontWeight: FontWeight.w800, color: AppColors.primaryBlue)),
        content: Text('Jadwal "${jadwal.label}" akan dihapus permanen.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
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
    setState(() => _jadwalList.removeWhere((j) => j.id == id));
  }
 Widget _buildSummaryCard() {
    final next = _nextJadwal;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jadwal berikutnya',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    next == null ? '--:--' : next.time.format(context),
                    style: const TextStyle(
                      fontSize: 32,
                      height: 1.1,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    next == null ? 'Tidak ada jadwal aktif' : next.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Text(
                    '$_activeCount',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'dari ${_jadwalList.length}\naktif',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.2,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    Widget chip(String label, String? id, IconData? icon) {
      final selected = _filterKategoriId == id;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          selected: selected,
          showCheckmark: false,
          avatar: icon == null
              ? null
              : Icon(icon,
                  size: 16,
                  color: selected ? Colors.white : AppColors.tealMint),
          label: Text(label),
          labelStyle: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: selected ? Colors.white : AppColors.primaryBlue,
          ),
          backgroundColor: Colors.white,
          selectedColor: AppColors.primaryBlue,
          side: BorderSide(
            color: selected
                ? AppColors.primaryBlue
                : AppColors.tealMint.withValues(alpha: 0.3),
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          onSelected: (_) => setState(() => _filterKategoriId = id),
        ),
      );
    }

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          chip('Semua', null, null),
          ...dummyKategori.map((k) => chip(k.nama, k.id, k.icon)),
        ],
      ),
    );
  }

  Widget _buildJadwalCard(JadwalModel jadwal) {
    final kategori = _getKategori(jadwal.kategoriId);
    final aktif = jadwal.isActive;
    final accent = aktif ? AppColors.tealMint : Colors.grey.shade400;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: ValueKey(jadwal.id),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) => _confirmDelete(jadwal),
        onDismissed: (_) => _deleteJadwal(jadwal.id),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Icon(Icons.delete_outline, color: Colors.white),
        ),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: aktif ? 1 : 0.6,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: accent.withValues(alpha: aktif ? 0.4 : 0.25),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () => _editJadwal(jadwal),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 78,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Icon(kategori.icon, size: 18, color: accent),
                            const SizedBox(height: 4),
                            Text(
                              jadwal.time.format(context),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: aktif
                                    ? AppColors.primaryBlue
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              jadwal.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.skyBlue.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                kategori.nama,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: aktif,
                        activeThumbColor: AppColors.tealMint,
                        onChanged: (val) => _toggleJadwal(jadwal.id, val),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty({required bool filtered}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy_outlined,
                size: 56, color: AppColors.skyBlue.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text(
              filtered
                  ? 'Tidak ada jadwal di kategori ini.'
                  : 'Belum ada jadwal. Tambah jadwal baru.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final visible = _visibleList;

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        title: const Text('Jadwal Aktivitas',
            style: TextStyle(
                fontWeight: FontWeight.w800, color: AppColors.primaryBlue)),
        centerTitle: true,
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryBlue),
      ),
      body: Column(
        children: [
          _buildSummaryCard(),
          const SizedBox(height: 14),
          _buildFilterChips(),
          const SizedBox(height: 6),
          Expanded(
            child: visible.isEmpty
                ? _buildEmpty(filtered: _jadwalList.isNotEmpty)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 90),
                    itemCount: visible.length,
                    itemBuilder: (context, index) =>
                        _buildJadwalCard(visible[index]),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: _navIndex),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.tealMint,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: _addJadwal,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}