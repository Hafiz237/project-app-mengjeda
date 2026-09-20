import 'package:flutter/material.dart';
import '../models/alarm_model.dart';
import '../data/dummy_alarms.dart';
import '../theme/app_colors.dart';
import 'alarm_form_screen.dart';

class AlarmListScreen extends StatefulWidget {
  const AlarmListScreen({super.key});

  @override
  State<AlarmListScreen> createState() => _AlarmListScreenState();
}

class _AlarmListScreenState extends State<AlarmListScreen> {
  late List<AlarmModel> _alarms;

  @override
  void initState() {
    super.initState();
    _alarms = dummyAlarms;
  }

  void _toggleAlarm(String id, bool value) {
    setState(() {
      final alarm = _alarms.firstWhere((a) => a.id == id);
      alarm.isActive = value;
    });
  }

  Future<void> _addAlarm() async {
    final result = await Navigator.push<AlarmModel>(
      context,
      MaterialPageRoute(builder: (context) => const AlarmFormScreen()),
    );
    if (result != null) {
      setState(() => _alarms.add(result));
    }
  }

  Future<void> _editAlarm(AlarmModel alarm) async {
    final result = await Navigator.push<AlarmModel>(
      context,
      MaterialPageRoute(builder: (context) => AlarmFormScreen(existingAlarm: alarm)),
    );
    if (result != null) {
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
        title: const Text('Hapus Alarm?'),
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
    setState(() {
      _alarms.removeWhere((a) => a.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        title: const Text(
          'Alarm Jeda',
          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryBlue),
        ),
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryBlue),
      ),
      body: _alarms.isEmpty
          ? const Center(child: Text('Belum ada alarm. Tambah alarm baru.'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _alarms.length,
        itemBuilder: (context, index) {
          final alarm = _alarms[index];
          return Dismissible(
            key: ValueKey(alarm.id),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) => _confirmDelete(alarm),
            onDismissed: (_) => _deleteAlarm(alarm.id),
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.goldenYellow.withValues(alpha: 0.3), width: 1.5),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.goldenYellow.withValues(alpha: 0.15),
                  child: const Icon(Icons.alarm, color: AppColors.goldenYellow),
                ),
                title: Text(
                  alarm.label,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                ),
                subtitle: Text('${alarm.time.format(context)} · Nada: ${alarm.tone}'),
                trailing: Switch(
                  value: alarm.isActive,
                  activeThumbColor: AppColors.tealMint,
                  onChanged: (val) => _toggleAlarm(alarm.id, val),
                ),
                onTap: () => _editAlarm(alarm),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.skyBlue,
        onPressed: _addAlarm,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}