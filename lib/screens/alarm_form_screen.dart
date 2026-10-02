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
    _labelController =
        TextEditingController(text: widget.existingAlarm?.label ?? '');
    _selectedTime = widget.existingAlarm?.time ?? TimeOfDay.now();
    _selectedTone = widget.existingAlarm?.tone ?? 'Default';
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked =
        await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null && mounted) setState(() => _selectedTime = picked);
  }

  void _saveAlarm() {
    if (!_formKey.currentState!.validate()) return;

    final result = AlarmModel(
      id: widget.existingAlarm?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      label: _labelController.text.trim(),
      time: _selectedTime,
      tone: _selectedTone,
      isActive: widget.existingAlarm?.isActive ?? true,
    );

    Navigator.pop(context, result);
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryBlue.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _buildTimeCard() {
    return GestureDetector(
      onTap: _pickTime,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
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
        child: Column(
          children: [
            Text(
              _selectedTime.format(context),
              style: const TextStyle(
                fontSize: 44,
                height: 1.1,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    'Ketuk untuk ubah waktu',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

  Widget _buildLabelField() {
    return TextFormField(
      controller: _labelController,
      textCapitalization: TextCapitalization.sentences,
      style: const TextStyle(
          fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
      decoration: InputDecoration(
        hintText: 'Contoh: Istirahat mata',
        prefixIcon:
            const Icon(Icons.label_outline, color: AppColors.goldenYellow),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
              color: AppColors.goldenYellow.withValues(alpha: 0.3), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
              color: AppColors.goldenYellow.withValues(alpha: 0.3), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: AppColors.goldenYellow, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red.shade400, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Label tidak boleh kosong';
        }
        return null;
      },
    );
  }

  IconData _toneIcon(String tone) {
    switch (tone) {
      case 'Lembut':
        return Icons.spa_outlined;
      case 'Klasik':
        return Icons.notifications_active_outlined;
      default:
        return Icons.music_note_outlined;
    }
  }

  Widget _buildToneSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _toneOptions.map((tone) {
        final selected = _selectedTone == tone;
        return ChoiceChip(
          selected: selected,
          showCheckmark: false,
          avatar: Icon(
            _toneIcon(tone),
            size: 18,
            color: selected ? Colors.white : AppColors.tealMint,
          ),
          label: Text(tone),
          labelStyle: TextStyle(
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppColors.primaryBlue,
          ),
          backgroundColor: Colors.white,
          selectedColor: AppColors.primaryBlue,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          side: BorderSide(
            color: selected
                ? AppColors.primaryBlue
                : AppColors.tealMint.withValues(alpha: 0.3),
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          onSelected: (_) => setState(() => _selectedTone = tone),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Alarm' : 'Tambah Alarm',
          style: const TextStyle(
              fontWeight: FontWeight.w800, color: AppColors.primaryBlue),
        ),
        centerTitle: true,
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryBlue),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTimeCard(),
                const SizedBox(height: 24),
                _sectionLabel('Label alarm'),
                _buildLabelField(),
                const SizedBox(height: 24),
                _sectionLabel('Nada'),
                _buildToneSelector(),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.skyBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      textStyle: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                    onPressed: _saveAlarm,
                    icon: Icon(_isEditMode ? Icons.check : Icons.add),
                    label:
                        Text(_isEditMode ? 'Simpan Perubahan' : 'Tambah Alarm'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}