import 'package:flutter/material.dart';
import '../models/jadwal_model.dart';

List<JadwalModel> dummyJadwal = [
  JadwalModel(id: 'j1', label: 'Sarapan Pagi', time: const TimeOfDay(hour: 7, minute: 0), kategoriId: 'k2'),
  JadwalModel(id: 'j2', label: 'Blokir Jam Kuliah', time: const TimeOfDay(hour: 8, minute: 0), kategoriId: 'k1'),
  JadwalModel(id: 'j3', label: 'Makan Siang', time: const TimeOfDay(hour: 12, minute: 0), kategoriId: 'k2'),
  JadwalModel(id: 'j4', label: 'Olahraga Sore', time: const TimeOfDay(hour: 16, minute: 0), kategoriId: 'k3'),
  JadwalModel(id: 'j5', label: 'Waktu Tidur', time: const TimeOfDay(hour: 22, minute: 0), kategoriId: 'k4', isActive: false),
];