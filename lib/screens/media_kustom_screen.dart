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
import '../widgets/app_bottom_nav.dart';

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
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
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
      final XFile? picked =
          await _picker.pickImage(source: ImageSource.gallery);
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

  Future<bool> _confirmDelete(String judul, String nama) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(judul,
            style: const TextStyle(
                fontWeight: FontWeight.w800, color: AppColors.primaryBlue)),
        content: Text('"$nama" akan dihapus dari daftar.'),
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
    return confirmed == true;
  }

  Future<void> _deleteMedia(MediaModel media) async {
    if (media.id == _activeMediaId) {
      _showMessage('Media yang sedang dipakai tidak bisa dihapus.');
      return;
    }
    if (await _confirmDelete('Hapus Media?', media.nama)) {
      setState(() => _mediaList.removeWhere((m) => m.id == media.id));
    }
  }

  Future<void> _deleteAudio(AudioModel audio) async {
    if (audio.id == _activeAudioId) {
      _showMessage('Audio yang sedang dipakai tidak bisa dihapus.');
      return;
    }
    if (await _confirmDelete('Hapus Audio?', audio.nama)) {
      if (_playingAudioId == audio.id) {
        await _player.stop();
        _playingAudioId = null;
      }
      setState(() => _audioList.removeWhere((a) => a.id == audio.id));
    }
  }
 Widget _buildThumb(MediaModel media) {
    Widget broken() => Container(
          color: Colors.grey.shade200,
          child: const Icon(Icons.broken_image, color: Colors.grey),
        );

    if (media.isUploaded) {
      return Image.file(
        File(media.filePath!),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, _, _) => broken(),
      );
    }

    if (media.isAsset) {
      return Image.asset(
        media.assetPath!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, _, _) => broken(),
      );
    }

    return Container(
      color: media.color.withValues(alpha: 0.15),
      child: Center(child: Icon(media.icon, size: 44, color: media.color)),
    );
  }

  Widget _buildBadge(String text, {Color color = AppColors.skyBlue}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildEmpty(IconData icon, String text) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: AppColors.skyBlue.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text(text, style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
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
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: _buildThumb(_activeMedia),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dipakai di pop-up jeda',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _activeMedia.nama,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.music_note,
                            size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _activeAudio.nama,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildTabSwitcher() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: TabBar(
          controller: _tabController,
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey.shade600,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700),
          tabs: const [
            Tab(
              height: 42,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_outlined, size: 18),
                  SizedBox(width: 6),
                  Text('Gambar'),
                ],
              ),
            ),
            Tab(
              height: 42,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.music_note_outlined, size: 18),
                  SizedBox(width: 6),
                  Text('Audio'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaTab() {
    if (_mediaList.isEmpty) {
      return _buildEmpty(
          Icons.photo_library_outlined, 'Belum ada media. Unggah dari galeri.');
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isActive ? AppColors.skyBlue : Colors.transparent,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
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
                      padding: const EdgeInsets.fromLTRB(10, 18, 10, 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                      child: Text(
                        media.nama,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (isActive)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _buildBadge('Dipakai'),
                    ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      color: Colors.white,
                      visualDensity: VisualDensity.compact,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.35),
                      ),
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
      return _buildEmpty(
          Icons.library_music_outlined, 'Belum ada audio. Unggah file MP3.');
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
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
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isActive ? AppColors.tealMint : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            onTap: () => _selectAudio(audio),
            contentPadding: const EdgeInsets.fromLTRB(10, 4, 4, 4),
            leading: IconButton.filled(
              onPressed: () => _playPauseAudio(audio),
              style: IconButton.styleFrom(
                backgroundColor: isPlaying
                    ? AppColors.tealMint
                    : AppColors.tealMint.withValues(alpha: 0.15),
                foregroundColor:
                    isPlaying ? Colors.white : AppColors.tealMint,
              ),
              icon: Icon(isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded),
            ),
            title: Row(
              children: [
                Flexible(
                  child: Text(
                    audio.nama,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
                if (isActive) ...[
                  const SizedBox(width: 8),
                  _buildBadge('Dipakai', color: AppColors.tealMint),
                ],
              ],
            ),
            subtitle: Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline,
                  size: 22, color: Colors.redAccent),
              onPressed: () => _deleteAudio(audio),
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
          _buildPreviewCard(),
          _buildTabSwitcher(),
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
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (context, _) {
          final isAudioTab = _tabController.index == 1;
          return FloatingActionButton.extended(
            backgroundColor:
                isAudioTab ? AppColors.tealMint : AppColors.deepCyan,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            onPressed: isAudioTab ? _uploadAudio : _uploadMedia,
            icon: Icon(
              isAudioTab ? Icons.library_music : Icons.upload,
              color: Colors.white,
            ),
            label: Text(
              isAudioTab ? 'Unggah MP3' : 'Unggah',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }
}