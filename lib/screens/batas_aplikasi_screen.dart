import 'package:flutter/material.dart';
import '../data/jeda_settings.dart';
import '../models/app_limit_model.dart';
import '../services/app_limit_service.dart';
import '../theme/app_colors.dart';

class BatasAplikasiScreen extends StatefulWidget {
  const BatasAplikasiScreen({super.key});

  @override
  State<BatasAplikasiScreen> createState() => _BatasAplikasiScreenState();
}

class _BatasAplikasiScreenState extends State<BatasAplikasiScreen>
    with WidgetsBindingObserver {
  final _svc = AppLimitService.instance;
  List<AppLimitModel> _limits = [];
  Map<String, int> _usage = {};
  bool _usageOk = false, _overlayOk = false, _monitorOn = false;

  static const _presets = [15, 30, 60, 900, 1800, 3600, 5400, 7200, 10800, 14400];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (s == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    _svc.saveJedaDuration(JedaSettings.durasi.inSeconds);
    final r = await Future.wait([
      _svc.getLimits(),
      _svc.todayUsage(),
      _svc.hasUsagePermission(),
      _svc.hasOverlayPermission(),
      _svc.isMonitorOn(),
    ]);
    if (!mounted) return;
    setState(() {
      _limits = r[0] as List<AppLimitModel>;
      _usage = r[1] as Map<String, int>;
      _usageOk = r[2] as bool;
      _overlayOk = r[3] as bool;
      _monitorOn = r[4] as bool;
    });
  }

  Future<void> _save() => _svc.saveLimits(_limits);

  String _fmt(int s) {
    if (s < 60) return '$s detik';
    final m = s ~/ 60;
    if (m < 60) return s % 60 == 0 ? '$m menit' : '$m menit ${s % 60} detik';
    final h = m ~/ 60, mm = m % 60;
    return mm == 0 ? '$h jam' : '$h jam $mm menit';
  }

  Future<int?> _pickMinutes(String label, {int? current}) {
    return showModalBottomSheet<int>(
      context: context,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Batas harian $label',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            for (final m in _presets)
              ListTile(
                title: Text(_fmt(m)),
                trailing: m == current ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(context, m),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _tambah() async {
    final apps = await _svc.installedApps();
    if (!mounted) return;
    final dipakai = _limits.map((e) => e.pkg).toSet();
    final pilih = await showModalBottomSheet<InstalledApp>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AppPicker(
          apps: apps.where((a) => !dipakai.contains(a.pkg)).toList()),
    );
    if (pilih == null || !mounted) return;
    final menit = await _pickMinutes(pilih.label);
    if (menit == null) return;
    setState(() => _limits.add(
        AppLimitModel(pkg: pilih.pkg, label: pilih.label, seconds: menit)));
    await _save();
  }

  Future<void> _toggleMonitor(bool on) async {
    if (on && !_usageOk) {
      await _svc.openUsageSettings();
      return;
    }
    on ? await _svc.startMonitor() : await _svc.stopMonitor();
    _refresh();
  }

  Widget _izin(String judul, String ket, bool ok, VoidCallback buka) => Card(
        child: ListTile(
          leading: Icon(ok ? Icons.check_circle : Icons.error_outline,
              color: ok ? AppColors.tealMint : Colors.orange),
          title: Text(judul),
          subtitle: Text(ket),
          trailing:
              ok ? null : TextButton(onPressed: buka, child: const Text('Aktifkan')),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        title: const Text('Batas Aplikasi'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tambah,
        backgroundColor: AppColors.skyBlue,
        icon: const Icon(Icons.add),
        label: const Text('Tambah aplikasi'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            _izin('Akses data penggunaan',
                'Wajib, untuk menghitung lama pakai tiap aplikasi', _usageOk,
                _svc.openUsageSettings),
            _izin('Tampil di atas aplikasi lain',
                'Agar popup jeda muncul langsung di atas aplikasi', _overlayOk,
                _svc.openOverlaySettings),
            SwitchListTile(
              value: _monitorOn,
              onChanged: _toggleMonitor,
              title: const Text('Aktifkan pemantauan'),
              subtitle: const Text('Berjalan di latar belakang'),
            ),
            const Divider(),
            if (_limits.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                    child: Text(
                        'Belum ada batas. Aplikasi yang tidak ditambahkan tidak dibatasi.')),
              ),
            for (final l in _limits)
              Dismissible(
                key: ValueKey(l.pkg),
                direction: DismissDirection.endToStart,
                background: Container(
                    color: Colors.red.shade300,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white)),
                onDismissed: (_) {
                  setState(() => _limits.removeWhere((e) => e.pkg == l.pkg));
                  _save();
                },
                child: Card(
                  child: ListTile(
                    title: Text(l.label),
                    subtitle: Builder(builder: (_) {
                      final used = _usage[l.pkg] ?? 0;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${_fmt(used)} dari ${_fmt(l.seconds)} hari ini'),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(
                              value: (used / l.seconds).clamp(0.0, 1.0),
                              color: used >= l.seconds
                                  ? Colors.red
                                  : AppColors.skyBlue),
                        ],
                      );
                    }),
                    onTap: () async {
                      final m = await _pickMinutes(l.label, current: l.seconds);
                      if (m == null) return;
                      setState(() {
                        final i = _limits.indexWhere((e) => e.pkg == l.pkg);
                        _limits[i] = AppLimitModel(
                            pkg: l.pkg, label: l.label, seconds: m);
                      });
                      _save();
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AppPicker extends StatefulWidget {
  final List<InstalledApp> apps;
  const _AppPicker({required this.apps});
  @override
  State<_AppPicker> createState() => _AppPickerState();
}

class _AppPickerState extends State<_AppPicker> {
  String _q = '';
  @override
  Widget build(BuildContext context) {
    final list = widget.apps
        .where((a) => a.label.toLowerCase().contains(_q.toLowerCase()))
        .toList();
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            autofocus: true,
            decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search), hintText: 'Cari aplikasi'),
            onChanged: (v) => setState(() => _q = v),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) => ListTile(
              title: Text(list[i].label),
              subtitle: Text(list[i].pkg, style: const TextStyle(fontSize: 11)),
              onTap: () => Navigator.pop(context, list[i]),
            ),
          ),
        ),
      ]),
    );
  }
}
