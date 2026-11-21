class AppLimitModel {
  final String pkg;
  final String label;
  final int seconds;

  const AppLimitModel({
    required this.pkg,
    required this.label,
    required this.seconds,
  });

  Map<String, dynamic> toJson() => {
        'pkg': pkg,
        'label': label,
        'seconds': seconds,
        'minutes': (seconds / 60).ceil(),
      };

  factory AppLimitModel.fromJson(Map<String, dynamic> j) => AppLimitModel(
        pkg: j['pkg'] as String,
        label: j['label'] as String,
        seconds: j['seconds'] != null
            ? j['seconds'] as int
            : (j['minutes'] as int) * 60,
      );
}

class InstalledApp {
  final String pkg;
  final String label;
  const InstalledApp(this.pkg, this.label);
}
