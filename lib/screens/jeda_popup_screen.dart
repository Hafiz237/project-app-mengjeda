import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../data/dummy_media.dart';
import '../data/dummy_audio.dart';
import '../models/media_model.dart';
import '../models/audio_model.dart';
import '../theme/app_colors.dart';

class JedaPopupScreen extends StatefulWidget {
  final Duration durasi;

  const JedaPopupScreen({super.key, this.durasi = const Duration(minutes: 1)});

  @override
  State<JedaPopupScreen> createState() => _JedaPopupScreenState();
}

class _JedaPopupScreenState extends State<JedaPopupScreen>
    with SingleTickerProviderStateMixin {
  late Duration _sisa;
  Timer? _timer;
  final AudioPlayer _player = AudioPlayer();
  late AnimationController _pulseController;

  MediaModel get _activeMedia {
    try {
      return dummyMedia.firstWhere((m) => m.id == activeMediaId);
    } catch (_) {
      return dummyMedia.first;
    }
  }

  AudioModel? get _activeAudio {
    try {
      return dummyAudio.firstWhere((a) => a.id == activeAudioId);
    } catch (_) {
      return dummyAudio.isEmpty ? null : dummyAudio.first;
    }
  }

  @override
  void initState() {
    super.initState();
    _sisa = widget.durasi;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _playSound();

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_sisa.inSeconds <= 1) {
        t.cancel();
        _finish();
      } else {
        setState(() => _sisa -= const Duration(seconds: 1));
      }
    });
  }

  Future<void> _playSound() async {
    final audio = _activeAudio;
    if (audio == null) return;
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      if (audio.isUploaded) {
        await _player.play(DeviceFileSource(audio.filePath!));
      } else if (audio.isAsset) {
        await _player.play(
          AssetSource(audio.assetPath!.replaceFirst('assets/', '')),
        );
      }
    } catch (_) {}
  }

  void _finish() async {
    await _player.stop();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _player.dispose();
    _pulseController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  String _format(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          fit: StackFit.expand,
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(color: Colors.black.withValues(alpha: 0.45)),
            ),

            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Waktunya Jeda Sejenak',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Letakkan HP-mu, istirahatkan matamu.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ScaleTransition(
                        scale: Tween<double>(begin: 0.95, end: 1.05).animate(
                          CurvedAnimation(
                            parent: _pulseController,
                            curve: Curves.easeInOut,
                          ),
                        ),
                        child: Container(
                          width: 260,
                          height: 260,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: AppColors.skyBlue,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.skyBlue.withValues(alpha: 0.5),
                                blurRadius: 30,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: _buildMedia(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        _format(_sisa),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sisa waktu jeda',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.lock_outline,
                              color: Colors.white70,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Jeda belum selesai — tidak dapat dilewati',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedia() {
    final media = _activeMedia;
    if (media.isUploaded) {
      return Image.file(
        File(media.filePath!),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, _, _) => _fallback(media),
      );
    }
    if (media.isAsset) {
      return Image.asset(
        media.assetPath!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, _, _) => _fallback(media),
      );
    }
    return _fallback(media);
  }

  Widget _fallback(MediaModel media) {
    return Container(
      color: media.color.withValues(alpha: 0.3),
      child: Center(child: Icon(media.icon, size: 100, color: Colors.white)),
    );
  }
}