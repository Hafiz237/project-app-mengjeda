import 'dart:convert';

class DayUsage {
  final DateTime day;
  final int seconds;
  const DayUsage(this.day, this.seconds);
}

class AppUsage {
  final String pkg;
  final int seconds;
  const AppUsage(this.pkg, this.seconds);
}

class UsageSummary {
  final List<DayUsage> days;
  final List<AppUsage> apps;
  const UsageSummary(this.days, this.apps);

  int get todaySeconds => days.isEmpty ? 0 : days.last.seconds;

  factory UsageSummary.fromJson(String raw) {
    final m = jsonDecode(raw) as Map<String, dynamic>;
    final days = (m['days'] as List)
        .map((e) => DayUsage(
      DateTime.fromMillisecondsSinceEpoch((e['ts'] as num).toInt()),
      (e['total'] as num).toInt(),
    ))
        .toList();
    final apps = (m['apps'] as Map<String, dynamic>)
        .entries
        .map((e) => AppUsage(e.key, (e.value as num).toInt()))
        .toList();
    return UsageSummary(days, apps);
  }
}

class JedaEntry {
  final DateTime time;
  final String source;
  final String pkg;
  final int seconds;
  final bool done;
  const JedaEntry({
    required this.time,
    required this.source,
    required this.pkg,
    required this.seconds,
    required this.done,
  });

  factory JedaEntry.fromJson(Map<String, dynamic> j) => JedaEntry(
    time: DateTime.fromMillisecondsSinceEpoch((j['ts'] as num).toInt()),
    source: j['src'] as String,
    pkg: j['pkg'] as String,
    seconds: (j['secs'] as num).toInt(),
    done: j['done'] as bool,
  );
}

class AutoProgress {
  final bool on;
  final int activeMs;
  final int intervalMs;
  const AutoProgress(this.on, this.activeMs, this.intervalMs);

  int get remainingSeconds {
    final r = ((intervalMs - activeMs) / 1000).ceil();
    return r < 0 ? 0 : r;
  }
}