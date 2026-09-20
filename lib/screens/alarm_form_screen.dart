import 'package:flutter/material.dart';
import '../models/alarm_model.dart';
import '../theme/app_colors.dart';

class AlarmFormScreen extends StatefulWidget {
  final AlarmModel? existingAlarm;

  const AlarmFormScreen({super.key, this.existingAlarm});

  @override
  State<AlarmFormScreen> createState() => _AlarmFormScreenState();
}

class _AlarmFormScreenState extends State<AlarmFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _labelController;
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedTone = 'Default';

  final List<String> _toneOptions = ['Default', 'Lembut', 'Klasik'];

  bool get _isEditMode => widget.existingAlarm != null;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.existingAlarm?.label ?? '');
    _selectedTime = widget.existingAlarm?.time ?? TimeOfDay.now();
    _selectedTone = widget.existingAlarm?.tone ?? 'Default';
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _saveAlarm() {
    if (!_formKey.currentState!.validate()) return;

    final result = AlarmModel(
      id: widget.existingAlarm?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      label: _labelController.text.trim(),
      time: _selectedTime,
      tone: _selectedTone,
      isActive: widget.existingAlarm?.isActive ?? true,
    );

    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Alarm' : 'Tambah Alarm',
          style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryBlue),
        ),
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryBlue),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _labelController,
                decoration: const InputDecoration(labelText: 'Label Alarm'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Label tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Waktu'),
                subtitle: Text(_selectedTime.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: _pickTime,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedTone,
                decoration: const InputDecoration(labelText: 'Nada'),
                items: _toneOptions
                    .map((tone) => DropdownMenuItem(value: tone, child: Text(tone)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedTone = value);
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.skyBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _saveAlarm,
                  child: Text(_isEditMode ? 'Simpan Perubahan' : 'Tambah Alarm'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}