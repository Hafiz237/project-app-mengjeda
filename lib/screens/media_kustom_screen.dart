import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/media_model.dart';
import '../data/dummy_media.dart';
import '../theme/app_colors.dart';

class MediaKustomScreen extends StatefulWidget {
  const MediaKustomScreen({super.key});

  @override
  State<MediaKustomScreen> createState() => _MediaKustomScreenState();
}

class _MediaKustomScreenState extends State<MediaKustomScreen> {
  final ImagePicker _picker = ImagePicker();
  late List<MediaModel> _mediaList;
  late String _activeId;

  @override
  void initState() {
    super.initState();
    _mediaList = dummyMedia;
    _activeId = activeMediaId;
  }

  MediaModel get _activeMedia => _mediaList.firstWhere((m) => m.id == _activeId);

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  void _selectMedia(MediaModel media) {
    setState(() {
      _activeId = media.id;
      activeMediaId = media.id;
    });
    _showMessage('"${media.nama}" dipakai untuk pop-up jeda');
  }

  Future<void> _uploadMedia() async {
    try {
      final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return; // pengguna membatalkan

      final media = MediaModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nama: picked.name,
        filePath: picked.path,
        icon: Icons.image,
        color: AppColors.deepCyan,
      );
      setState(() => _mediaList.add(media));
      _showMessage('Media berhasil diunggah');
    } catch (e) {
      if (!mounted) return;
      _showMessage('Gagal membuka galeri');
    }
  }

  Future<void> _deleteMedia(MediaModel media) async {
    // Validasi: media yang sedang aktif tidak boleh dihapus
    if (media.id == _activeId) {
      _showMessage('Media yang sedang dipakai tidak bisa dihapus. Pilih media lain dulu.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Media?'),
        content: Text('"${media.nama}" akan dihapus dari daftar.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _mediaList.removeWhere((m) => m.id == media.id));
    }
  }

  // Menampilkan gambar: file asli kalau hasil unggah, kotak berwarna kalau media contoh
  Widget _buildThumb(MediaModel media) {
    if (media.isUploaded) {
      return Image.file(
        File(media.filePath!),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey.shade200,
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    }
    return Container(
      color: media.color.withValues(alpha: 0.15),
      child: Center(child: Icon(media.icon, size: 44, color: media.color)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        title: const Text(
          'Media Kustom',
          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryBlue),
        ),
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryBlue),
      ),
      body: Column(
        children: [
          // Pratinjau media yang sedang aktif
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.skyBlue.withValues(alpha: 0.3), width: 2),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(width: 72, height: 72, child: _buildThumb(_activeMedia)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Media Pop-up Jeda Aktif',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.skyBlue),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _activeMedia.nama,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Pustaka Media', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: _mediaList.isEmpty
                ? const Center(child: Text('Belum ada media. Unggah dari galeri.'))
                : GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
              itemCount: _mediaList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final media = _mediaList[index];
                final isActive = media.id == _activeId;
                return GestureDetector(
                  onTap: () => _selectMedia(media),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive ? AppColors.skyBlue : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(17),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _buildThumb(media),
                          // Label nama di bagian bawah
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              color: Colors.black.withValues(alpha: 0.45),
                              child: Text(
                                media.nama,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ),
                          // Tanda centang untuk media aktif
                          if (isActive)
                            const Positioned(
                              top: 8,
                              left: 8,
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: AppColors.skyBlue,
                                child: Icon(Icons.check, size: 16, color: Colors.white),
                              ),
                            ),
                          // Tombol hapus
                          Positioned(
                            top: 4,
                            right: 4,
                            child: IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20),
                              color: Colors.white,
                              style: IconButton.styleFrom(backgroundColor: Colors.black.withValues(alpha: 0.35)),
                              onPressed: () => _deleteMedia(media),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.deepCyan,
        onPressed: _uploadMedia,
        icon: const Icon(Icons.upload, color: Colors.white),
        label: const Text('Unggah', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}