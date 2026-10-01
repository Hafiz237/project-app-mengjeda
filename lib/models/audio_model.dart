class AudioModel {
  final String id;
  final String nama;
  final String? assetPath;
  final String? filePath;

  const AudioModel({
    required this.id,
    required this.nama,
    this.assetPath,
    this.filePath,
  });

  bool get isUploaded => filePath != null;
  bool get isAsset => assetPath != null;
}