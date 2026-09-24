import 'package:flutter/material.dart';

class MediaKustomScreen extends StatefulWidget {
  const MediaKustomScreen({super.key});

  @override
  State<MediaKustomScreen> createState() => _MediaKustomScreenState();
}

class _MediaKustomScreenState extends State<MediaKustomScreen> {
  String _selectedTone = 'Lonceng';
  double _volume = 0.7;
  
  // Variabel untuk menyimpan warna yang dipilih (bawaan merah)
  Color _selectedColor = Colors.red.shade600; 

  final List<Map<String, dynamic>> _tones = [
    {'name': 'Hening', 'icon': Icons.volume_off},
    {'name': 'Lonceng', 'icon': Icons.notifications_active},
    {'name': 'Hutan', 'icon': Icons.park},
    {'name': 'Musik Santai', 'icon': Icons.music_note},
  ];

  final List<Color> _themeColors = [
    Colors.red.shade400,
    Colors.red.shade500,
    Colors.red.shade600,
    Colors.red.shade800,
    Colors.red.shade900,
    Colors.pink.shade300,
    Colors.brown.shade800,
    Colors.pink.shade100,
    Colors.red.shade100,
    Colors.grey.shade400,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _selectedColor.withValues(alpha: 0.4),
              _selectedColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2), 
                    blurRadius: 10, 
                    offset: const Offset(0, 5)
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Media Jeda (Kustomisasi)',
                          style: TextStyle(
                            fontSize: 20, 
                            fontWeight: FontWeight.bold, 
                            color: _selectedColor
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Halaman: MediaKustomScreen(), Tema: Kustom',
                          style: TextStyle(
                            fontSize: 12, 
                            color: Colors.grey.shade600
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: Colors.grey.shade300, thickness: 1),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        const SizedBox(height: 8),
                        const Text(
                          'Pilih Nada Jeda', 
                          style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.volume_up, size: 40, color: _selectedColor),
                            const SizedBox(width: 32),
                            Icon(Icons.volume_off, size: 40, color: _selectedColor.withValues(alpha: 0.3)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ..._tones.map((tone) {
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(tone['icon'], color: _selectedColor),
                            title: Text(tone['name']),
                            trailing: Radio<String>(
                              value: tone['name'],
                              groupValue: _selectedTone,
                              activeColor: _selectedColor,
                              onChanged: (value) => setState(() => _selectedTone = value!),
                            ),
                          );
                        }),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _selectedColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tema Warna App', 
                                style: TextStyle(fontWeight: FontWeight.bold)
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _themeColors.map((color) {
                                  final isSelected = _selectedColor == color;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() => _selectedColor = color);
                                    },
                                    child: Container(
                                      width: 35,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: color,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isSelected ? Colors.black : Colors.grey.shade300,
                                          width: isSelected ? 2 : 1,
                                        ),
                                      ),
                                      child: isSelected 
                                          ? const Icon(Icons.check, color: Colors.white, size: 20) 
                                          : null,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Durasi & Volume Jeda', 
                          style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.access_time, color: _selectedColor),
                            const Spacer(),
                            const Text(
                              '00:00', 
                              style: TextStyle(fontWeight: FontWeight.bold)
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.volume_up, color: _selectedColor),
                            Expanded(
                              child: Slider(
                                value: _volume,
                                activeColor: _selectedColor,
                                inactiveColor: _selectedColor.withValues(alpha: 0.2),
                                onChanged: (val) => setState(() => _volume = val),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context, _selectedColor);
                      },
                      child: const Text(
                        'Simpan & Terapkan', 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}