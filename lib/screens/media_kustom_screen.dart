import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/media_model.dart';
import '../models/audio_model.dart';
import '../data/dummy_media.dart';
import '../data/dummy_audio.dart';
import '../theme/app_colors.dart';

class MediaKustomScreen extends StatefulWidget {
  const MediaKustomScreen({super.key});

  @override
  State<MediaKustomScreen> createState() => _MediaKustomScreenState();
}

class _MediaKustomScreenState extends State<MediaKustomScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();
  final AudioPlayer _player = AudioPlayer();

  late List<MediaModel> _mediaList;
  late List<AudioModel> _audioList;
  late String _activeMediaId;
  late String _activeAudioId;
  String? _playingAudioId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _mediaList = dummyMedia;
    _audioList = dummyAudio;
    _activeMediaId = activeMediaId;
    _activeAudioId = activeAudioId;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _player.dispose();
    super.dispose();
  }

  MediaModel get _activeMedia =>
      _mediaList.firstWhere((m) => m.id == _activeMediaId);

  AudioModel get _activeAudio =>
      _audioList.firstWhere((a) => a.id == _activeAudioId);

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  void _selectMedia(MediaModel media) {
    setState(() {
      _activeMediaId = media.id;
      activeMediaId = media.id;
    });
    _showMessage('"${media.nama}" dipakai untuk pop-up jeda');
  }

  void _selectAudio(AudioModel audio) {
    setState(() {
      _activeAudioId = audio.id;
      activeAudioId = audio.id;
    });
    _showMessage('"${audio.nama}" dipakai untuk pop-up jeda');
  }

  Future<void> _playPauseAudio(AudioModel audio) async {
    if (_playingAudioId == audio.id) {
      await _player.stop();
      setState(() => _playingAudioId = null);
      return;
    }
    try {
      await _player.stop();
      if (audio.isUploaded) {
        await _player.play(DeviceFileSource(audio.filePath!));
      } else if (audio.isAsset) {
        await _player.play(
          AssetSource(audio.assetPath!.replaceFirst('assets/', '')),
        );
      }
      setState(() => _playingAudioId = audio.id);
    } catch (_) {
      if (!mounted) return;
      _showMessage('Gagal memutar audio');
    }
  }

  Future<void> _uploadMedia() async {
    try {
      final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

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

  Future<void> _uploadAudio() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3'],
      );

      if (result == null || result.files.single.path == null) return;

      final file = result.files.single;
      final lower = file.name.toLowerCase();

      if (!lower.endsWith('.mp3')) {
        _showMessage('Hanya file MP3 yang diizinkan');
        return;
      }

      final audio = AudioModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nama: file.name,
        filePath: file.path,
      );
      setState(() => _audioList.add(audio));
      _showMessage('Audio berhasil diunggah');
    } catch (e) {
      if (!mounted) return;
      _showMessage('Gagal memilih file audio');
    }
  }

  Future<void> _deleteMedia(MediaModel media) async {
    if (media.id == _activeMediaId) {
      _showMessage('Media yang sedang dipakai tidak bisa dihapus.');
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

  Future<void> _deleteAudio(AudioModel audio) async {
    if (audio.id == _activeAudioId) {
      _showMessage('Audio yang sedang dipakai tidak bisa dihapus.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Audio?'),
        content: Text('"${audio.nama}" akan dihapus dari daftar.'),
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
      setState(() => _audioList.removeWhere((a) => a.id == audio.id));
    }
  }

  Widget _buildThumb(MediaModel media) {
    if (media.isUploaded) {
      return Image.file(
        File(media.filePath!),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, _, _) => Container(
          color: Colors.grey.shade200,
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    }

    if (media.isAsset) {
      return Image.asset(
        media.assetPath!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, _, _) => Container(
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

  Widget _buildPreviewCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
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
              child: SizedBox(
                width: 72,
                height: 72,
                child: _buildThumb(_activeMedia),
              ),
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
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.music_note, size: 14, color: AppColors.tealMint),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _activeAudio.nama,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: AppColors.tealMint, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaTab() {
    return _mediaList.isEmpty
        ? const Center(child: Text('Belum ada media. Unggah dari galeri.'))
        : GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
            itemCount: _mediaList.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final media = _mediaList[index];
              final isActive = media.id == _activeMediaId;
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
          );
  }

  Widget _buildAudioTab() {
    if (_audioList.isEmpty) {
      return const Center(child: Text('Belum ada audio. Unggah dari file MP3.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
      itemCount: _audioList.length,
      itemBuilder: (context, index) {
        final audio = _audioList[index];
        final isActive = audio.id == _activeAudioId;
        final isPlaying = audio.id == _playingAudioId;
        final subtitle = audio.isUploaded
            ? audio.filePath!.split('/').last
            : (audio.assetPath ?? '').split('/').last;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? AppColors.tealMint : Colors.grey.shade200,
              width: isActive ? 2 : 1,
            ),
          ),
          child: ListTile(
            onTap: () => _selectAudio(audio),
            leading: CircleAvatar(
              backgroundColor: isActive
                  ? AppColors.tealMint
                  : AppColors.tealMint.withValues(alpha: 0.15),
              child: Icon(
                isActive ? Icons.check : Icons.music_note,
                color: isActive ? Colors.white : AppColors.tealMint,
              ),
            ),
            title: Text(
              audio.nama,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
            ),
            subtitle: Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.stop_circle : Icons.play_circle_outline,
                    color: AppColors.tealMint,
                    size: 30,
                  ),
                  onPressed: () => _playPauseAudio(audio),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 22, color: Colors.redAccent),
                  onPressed: () => _deleteAudio(audio),
                ),
              ],
            ),
          ),
        );
      },
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.skyBlue,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(icon: Icon(Icons.image_outlined), text: 'Gambar'),
            Tab(icon: Icon(Icons.music_note_outlined), text: 'Audio'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildPreviewCard(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMediaTab(),
                _buildAudioTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (context, _) {
          final isAudioTab = _tabController.index == 1;
          return FloatingActionButton.extended(
            backgroundColor: isAudioTab ? AppColors.tealMint : AppColors.deepCyan,
            onPressed: isAudioTab ? _uploadAudio : _uploadMedia,
            icon: Icon(
              isAudioTab ? Icons.library_music : Icons.upload,
              color: Colors.white,
            ),
            label: Text(
              isAudioTab ? 'Unggah MP3' : 'Unggah',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }
}