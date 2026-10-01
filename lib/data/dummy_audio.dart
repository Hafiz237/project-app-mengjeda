import '../models/audio_model.dart';

List<AudioModel> dummyAudio = [
  AudioModel(id: 'a1', nama: 'Usagi Nyanyi', assetPath: 'assets/audio/usagi_singing.mp3'),
  AudioModel(id: 'a2', nama: 'Senam Chiikawa', assetPath: 'assets/audio/chiikawa_senam_ringtone.mp3'),
];

String activeAudioId = 'a1';