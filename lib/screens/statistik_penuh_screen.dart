import 'package:flutter/material.dart';
import '../models/statistik_model.dart';
import '../services/app_limit_service.dart';
import '../theme/app_colors.dart';

class StatistikPenuhScreen extends StatefulWidget {
  const StatistikPenuhScreen({super.key});

  @override
  State<StatistikPenuhScreen> createState() => _StatistikPenuhScreenState();
}

class _StatistikPenuhScreenState extends State<StatistikPenuhScreen>
    with WidgetsBindingObserver {
  static const int _batasHarianDetik = 3 * 3600;
  static const _hari = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  static const _bulan = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];

  final _svc = AppLimitService.instance;
  bool _loading = true;
  bool _hasPermission = false;
  UsageSummary? _summary;
  List<JedaEntry> _log = [];
  Map<String, String> _labels = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load();
  }

  Future<void> _load() async {
    final ok = await _svc.hasUsagePermission();
    UsageSummary? summary;
    Map<String, String> labels = {};
    if (ok) {
      summary = await _svc.usageSummary(7);
      final apps = await _svc.installedApps();
      labels = {for (final a in apps) a.pkg: a.label};
    }
    final log = await _svc.jedaLog();
    log.sort((a, b) => b.time.compareTo(a.time));
    if (!mounted) return;
    setState(() {
      _hasPermission = ok;
      _summary = summary;
      _log = log;
      _labels = labels;
      _loading = false;
    });
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  String _fmtLong(int s) {
    if (s < 60) return '$s detik';
    final m = s ~/ 60;
    if (m < 60) return '$m menit';
    final h = m ~/ 60, mm = m % 60;
    return mm == 0 ? '$h jam' : '$h jam $mm menit';
  }

  String _fmtHours(int s) =>
      '${(s / 3600).toStringAsFixed(1).replaceAll('.', ',')}j';

  String _label(String pkg) =>
      _labels[pkg] ?? (pkg.isEmpty ? '-' : pkg.split('.').last);

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _statusText(int s) {
    if (s == 0) return 'Tidak ada data';
    if (s <= _batasHarianDetik * 0.75) return 'Sehat';
    if (s <= _batasHarianDetik) return 'Normal';
    return 'Melebihi batas';
  }

  Color _statusColor(int s) {
    if (s == 0) return Colors.grey;
    if (s <= _batasHarianDetik * 0.75) return AppColors.tealMint;
    if (s <= _batasHarianDetik) return AppColors.skyBlue;
    return Colors.redAccent;
  }

  Widget _card({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) =>
      Container(
        width: double.infinity,
        padding: padding,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: child,
      );

  Widget _title(String t) => Padding(
    padding: const EdgeInsets.only(top: 4, bottom: 10),
    child: Text(
      t,
      style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryBlue),
    ),
  );

  Widget _statCard(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            const SizedBox(height: 2),
            Text(value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.primaryBlue)),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionCard() {
    return _card(
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.orange),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Aktifkan akses data penggunaan agar statistik screen time bisa dihitung.',
              style: TextStyle(fontSize: 12),
            ),
          ),
          TextButton(
            onPressed: _svc.openUsageSettings,
            child: const Text('Aktifkan'),
          ),
        ],
      ),
    );
  }

  Widget _bar(DayUsage d, bool isToday, int maxSec, double area) {
    final h = maxSec == 0 ? 0.0 : (d.seconds / maxSec) * area;
    final over = d.seconds > _batasHarianDetik;
    final color = over
        ? Colors.redAccent
        : (isToday ? AppColors.skyBlue : AppColors.tealMint);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          d.seconds == 0 ? '-' : _fmtHours(d.seconds),
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Container(
          height: (d.seconds > 0 && h < 4) ? 4 : h,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _hari[d.day.weekday - 1],
          style: TextStyle(
            fontSize: 11,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            color: AppColors.primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildChart(List<DayUsage> days) {
    const area = 110.0;
    final maxSec = days.fold<int>(
        _batasHarianDetik, (m, d) => d.seconds > m ? d.seconds : m);
    return SizedBox(
      height: area + 50,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < days.length; i++)
            Expanded(child: _bar(days[i], i == days.length - 1, maxSec, area)),
        ],
      ),
    );
  }

  Widget _appTile(AppUsage a, int maxSec) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(_label(a.pkg),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue)),
              ),
              Text(_fmtLong(a.seconds),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: maxSec == 0 ? 0 : a.seconds / maxSec,
              minHeight: 8,
              backgroundColor: Colors.grey.shade100,
              color: AppColors.skyBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dayTile(DayUsage d, bool isToday) {
    final jedaCount = _log.where((e) => _sameDay(e.time, d.day)).length;
    final warna = _statusColor(d.seconds);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 44,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: warna.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(_hari[d.day.weekday - 1],
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: warna)),
                Text('${d.day.day}',
                    style: TextStyle(fontSize: 11, color: warna)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.seconds == 0 ? 'Tidak ada data' : _fmtLong(d.seconds),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlue),
                ),
                const SizedBox(height: 2),
                Text('$jedaCount jeda${isToday ? ' · hari ini' : ''}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: warna.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(_statusText(d.seconds),
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700, color: warna)),
          ),
        ],
      ),
    );
  }

  Widget _jedaTile(JedaEntry e) {
    final isLimit = e.source == 'limit';
    final warna = isLimit ? AppColors.goldenYellow : AppColors.deepCyan;
    final judul = isLimit ? 'Batas ${_label(e.pkg)}' : 'Jeda rutin';
    final t = e.time;
    final waktu =
        '${_hari[t.weekday - 1]}, ${t.day} ${_bulan[t.month - 1]} · ${_two(t.hour)}:${_two(t.minute)}';
    final di = (!isLimit && e.pkg.isNotEmpty) ? ' · di ${_label(e.pkg)}' : '';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: warna.withValues(alpha: 0.15),
            child: Icon(isLimit ? Icons.block : Icons.timer_outlined,
                size: 18, color: warna),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(judul,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue)),
                const SizedBox(height: 2),
                Text('$waktu · ${_fmtLong(e.seconds)}$di',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Icon(
            e.done ? Icons.check_circle : Icons.warning_amber_rounded,
            size: 20,
            color: e.done ? AppColors.tealMint : Colors.orange,
          ),
        ],
      ),
    );
  }

  // ---------- bagian layar ----------
  List<Widget> _buildUsageSections(UsageSummary s) {
    final days = s.days;
    final withData = days.where((d) => d.seconds > 0).toList();
    final totalSec = withData.fold<int>(0, (a, d) => a + d.seconds);
    final avg = withData.isEmpty ? 0 : totalSec ~/ withData.length;

    DayUsage? longest;
    for (final d in withData) {
      if (longest == null || d.seconds > longest.seconds) longest = d;
    }

    final from = days.first.day;
    final weekLog = _log.where((e) => !e.time.isBefore(from)).toList();
    final doneCount = weekLog.where((e) => e.done).length;

    final apps = [...s.apps]..sort((a, b) => b.seconds.compareTo(a.seconds));
    final topApps = apps.take(5).toList();

    return [
      Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryBlue, AppColors.skyBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.white, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pencapaian Mingguan',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(
                    weekLog.isEmpty
                        ? 'Belum ada jeda tercatat. Riwayat mulai terisi setelah pop-up jeda muncul.'
                        : '${weekLog.length} jeda dalam 7 hari terakhir, $doneCount selesai sampai akhir.',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      Row(
        children: [
          _statCard(Icons.av_timer, 'Rata-rata harian',
              avg == 0 ? '-' : _fmtLong(avg), AppColors.skyBlue),
          const SizedBox(width: 8),
          _statCard(
              Icons.trending_up,
              'Hari terlama',
              longest == null
                  ? '-'
                  : '${_hari[longest.day.weekday - 1]} · ${_fmtHours(longest.seconds)}',
              Colors.redAccent),
          const SizedBox(width: 8),
          _statCard(
              Icons.check_circle_outline,
              'Jeda selesai',
              weekLog.isEmpty
                  ? '-'
                  : '${(doneCount * 100 / weekLog.length).round()}%',
              AppColors.tealMint),
        ],
      ),
      const SizedBox(height: 16),
      _title('Screen Time 7 Hari'),
      _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChart(days),
            const SizedBox(height: 8),
            Text(
              'Merah = melebihi batas harian ${_fmtLong(_batasHarianDetik)}. '
                  'Angka adalah perkiraan dari waktu aplikasi di layar.',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
      _title('Aplikasi Terlama (7 hari)'),
      _card(
        child: topApps.isEmpty
            ? Text('Belum ada data aplikasi.',
            style: TextStyle(color: Colors.grey.shade600))
            : Column(
          children: [
            for (final a in topApps) _appTile(a, topApps.first.seconds),
          ],
        ),
      ),
      _title('Rincian Harian'),
      _card(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            for (var i = days.length - 1; i >= 0; i--) ...[
              _dayTile(days[i], i == days.length - 1),
              if (i > 0) Divider(height: 1, color: Colors.grey.shade200),
            ],
          ],
        ),
      ),
    ];
  }

  Widget _buildJedaSection() {
    final entries = _log.take(20).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title('Riwayat Jeda'),
        if (entries.isEmpty)
          _card(
            child: Text(
              'Belum ada jeda tercatat. Riwayat mulai terisi setelah pop-up jeda muncul.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          )
        else
          _card(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < entries.length; i++) ...[
                  _jedaTile(entries[i]),
                  if (i < entries.length - 1)
                    Divider(height: 1, color: Colors.grey.shade200),
                ],
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Text(
            'Centang hijau = jeda selesai sampai akhir, tanda peringatan = ditutup sebelum selesai.',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        title: const Text(
          'Statistik Penuh',
          style: TextStyle(
              fontWeight: FontWeight.w800, color: AppColors.primaryBlue),
        ),
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryBlue),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            if (!_hasPermission) _buildPermissionCard(),
            if (_summary != null && _summary!.days.isNotEmpty)
              ..._buildUsageSections(_summary!),
            _buildJedaSection(),
          ],
        ),
      ),
    );
  }
}