import 'package:flutter/material.dart';
import '../models/jadwal_model.dart';
import '../data/dummy_kategori.dart';
import '../theme/app_colors.dart';

class JadwalFormScreen extends StatefulWidget {
  final JadwalModel? existingJadwal;

  const JadwalFormScreen({super.key, this.existingJadwal});

  @override
  State<JadwalFormScreen> createState() => _JadwalFormScreenState();
}

class _JadwalFormScreenState extends State<JadwalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _labelController;
  TimeOfDay _selectedTime = TimeOfDay.now();
  late String _selectedKategoriId;

  bool get _isEditMode => widget.existingJadwal != null;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.existingJadwal?.label ?? '');
    _selectedTime = widget.existingJadwal?.time ?? TimeOfDay.now();
    _selectedKategoriId = widget.existingJadwal?.kategoriId ?? dummyKategori.first.id;
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

  void _saveJadwal() {
    if (!_formKey.currentState!.validate()) return;

    final result = JadwalModel(
      id: widget.existingJadwal?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      label: _labelController.text.trim(),
      time: _selectedTime,
      kategoriId: _selectedKategoriId,
      isActive: widget.existingJadwal?.isActive ?? true,
    );

    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Jadwal' : 'Tambah Jadwal',
            style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryBlue)),
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
                decoration: const InputDecoration(labelText: 'Label Jadwal'),
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
                value: _selectedKategoriId,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: dummyKategori
                    .map((k) => DropdownMenuItem(
                  value: k.id,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(k.icon, size: 18, color: AppColors.tealMint),
                      const SizedBox(width: 8),
                      Text(k.nama),
                    ],
                  ),
                ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedKategoriId = value);
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tealMint,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _saveJadwal,
                  child: Text(_isEditMode ? 'Simpan Perubahan' : 'Tambah Jadwal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}