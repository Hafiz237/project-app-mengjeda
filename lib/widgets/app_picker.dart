import 'package:flutter/material.dart';
import '../models/app_limit_model.dart';

class AppPicker extends StatefulWidget {
  final List<InstalledApp> apps;
  const AppPicker({super.key, required this.apps});
  @override
  State<AppPicker> createState() => _AppPickerState();
}

class _AppPickerState extends State<AppPicker> {
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