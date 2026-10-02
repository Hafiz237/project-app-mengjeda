import 'package:flutter/material.dart';
import '../models/alarm_model.dart';
import '../data/dummy_alarms.dart';
import '../theme/app_colors.dart';
import '../widgets/app_bottom_nav.dart';
import 'alarm_form_screen.dart';

class AlarmListScreen extends StatefulWidget {
  const AlarmListScreen({super.key});

  @override
  State<AlarmListScreen> createState() => _AlarmListScreenState();
}

class _AlarmListScreenState extends State<AlarmListScreen> {
  static const int _navIndex = 2;

  late List<AlarmModel> _alarms;

  @override
  void initState() {
    super.initState();
    _alarms = dummyAlarms;
  }

  int _minutes(TimeOfDay t) => t.hour * 60 + t.minute;

  List<AlarmModel> get _sortedAlarms => _alarms.toList()
    ..sort((a, b) => _minutes(a.time).compareTo(_minutes(b.time)));

  int get _activeCount => _alarms.where((a) => a.isActive).length;

  AlarmModel? get _nextAlarm {
    final aktif = _alarms.where((a) => a.isActive).toList()
      ..sort((a, b) => _minutes(a.time).compareTo(_minutes(b.time)));
    if (aktif.isEmpty) return null;
    final now = _minutes(TimeOfDay.now());
    return aktif.firstWhere(
      (a) => _minutes(a.time) >= now,
      orElse: () => aktif.first,
    );
  }

void _toggleAlarm(String id, bool value) {
    setState(() {
      _alarms.firstWhere((a) => a.id == id).isActive = value;
    });
  }

  Future<void> _addAlarm() async {
    final result = await Navigator.push<AlarmModel>(
      context,
      MaterialPageRoute(builder: (context) => const AlarmFormScreen()),
    );
    if (result != null && mounted) {
      setState(() => _alarms.add(result));
    }
  }

  Future<void> _editAlarm(AlarmModel alarm) async {
    final result = await Navigator.push<AlarmModel>(
      context,
      MaterialPageRoute(
          builder: (context) => AlarmFormScreen(existingAlarm: alarm)),
    );
    if (result != null && mounted) {
      setState(() {
        final index = _alarms.indexWhere((a) => a.id == result.id);
        if (index != -1) _alarms[index] = result;
      });
    }
  }

  Future<bool> _confirmDelete(AlarmModel alarm) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Alarm?',
            style: TextStyle(
                fontWeight: FontWeight.w800, color: AppColors.primaryBlue)),
        content: Text('Alarm "${alarm.label}" akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  void _deleteAlarm(String id) {
    setState(() => _alarms.removeWhere((a) => a.id == id));
  }

 Widget _buildSummaryCard() {
    final next = _nextAlarm;
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
                    'Alarm berikutnya',
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
                    next == null ? 'Tidak ada alarm aktif' : next.label,
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
                    'dari ${_alarms.length}\naktif',
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

  Widget _buildAlarmCard(AlarmModel alarm) {
    final aktif = alarm.isActive;
    final accent = aktif ? AppColors.goldenYellow : Colors.grey.shade400;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: ValueKey(alarm.id),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) => _confirmDelete(alarm),
        onDismissed: (_) => _deleteAlarm(alarm.id),
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
                color: accent.withValues(alpha: aktif ? 0.45 : 0.25),
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
                onTap: () => _editAlarm(alarm),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 78,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.alarm, size: 18, color: accent),
                            const SizedBox(height: 4),
                            Text(
                              alarm.time.format(context),
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
                              alarm.label,
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
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.music_note,
                                      size: 12, color: AppColors.primaryBlue),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      alarm.tone,
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
                          ],
                        ),
                      ),
                      Switch(
                        value: aktif,
                        activeThumbColor: AppColors.tealMint,
                        onChanged: (val) => _toggleAlarm(alarm.id, val),
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

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.alarm_off_outlined,
                size: 56, color: AppColors.skyBlue.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text('Belum ada alarm. Tambah alarm baru.',
                style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

@override
  Widget build(BuildContext context) {
    final sorted = _sortedAlarms;

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        title: const Text(
          'Alarm Jeda',
          style: TextStyle(
              fontWeight: FontWeight.w800, color: AppColors.primaryBlue),
        ),
        centerTitle: true,
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryBlue),
      ),
      body: Column(
        children: [
          _buildSummaryCard(),
          const SizedBox(height: 8),
          Expanded(
            child: sorted.isEmpty
                ? _buildEmpty()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 90),
                    itemCount: sorted.length,
                    itemBuilder: (context, index) =>
                        _buildAlarmCard(sorted[index]),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: _navIndex),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.skyBlue,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: _addAlarm,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}