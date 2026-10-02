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
    _labelController =
        TextEditingController(text: widget.existingJadwal?.label ?? '');
    _selectedTime = widget.existingJadwal?.time ?? TimeOfDay.now();
    _selectedKategoriId =
        widget.existingJadwal?.kategoriId ?? dummyKategori.first.id;
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked =
        await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _saveJadwal() {
    if (!_formKey.currentState!.validate()) return;

    final result = JadwalModel(
      id: widget.existingJadwal?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      label: _labelController.text.trim(),
      time: _selectedTime,
      kategoriId: _selectedKategoriId,
      isActive: widget.existingJadwal?.isActive ?? true,
    );

    Navigator.pop(context, result);
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.tealMint),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: border(Colors.grey.shade300),
      focusedBorder: border(AppColors.tealMint, 2),
      errorBorder: border(Colors.redAccent),
      focusedErrorBorder: border(Colors.redAccent, 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Jadwal' : 'Tambah Jadwal',
          style: const TextStyle(
              fontWeight: FontWeight.w800, color: AppColors.primaryBlue),
        ),
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primaryBlue),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: _pickTime,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withOpacity(0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Waktu',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _selectedTime.format(context),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Ketuk untuk ubah waktu',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _labelController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration:
                      _inputDecoration('Label Jadwal', Icons.edit_outlined),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Label tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedKategoriId,
                  borderRadius: BorderRadius.circular(14),
                  decoration:
                      _inputDecoration('Kategori', Icons.category_outlined),
                  items: dummyKategori
                      .map((k) => DropdownMenuItem(
                            value: k.id,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(k.icon,
                                    size: 18, color: AppColors.tealMint),
                                const SizedBox(width: 8),
                                Text(k.nama),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedKategoriId = value);
                    }
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.tealMint,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: AppColors.tealMint.withOpacity(0.4),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _saveJadwal,
                    icon: Icon(_isEditMode ? Icons.check : Icons.add),
                    label: Text(
                        _isEditMode ? 'Simpan Perubahan' : 'Tambah Jadwal'),
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