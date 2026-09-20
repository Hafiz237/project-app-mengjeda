import 'package:flutter/material.dart';
import '../models/alarm_model.dart';

List<AlarmModel> dummyAlarms = [
  AlarmModel(id: '1', label: 'Istirahat Pagi', time: const TimeOfDay(hour: 9, minute: 0), tone: 'Lembut'),
  AlarmModel(id: '2', label: 'Jeda Setelah Kuliah', time: const TimeOfDay(hour: 11, minute: 30), tone: 'Default'),
  AlarmModel(id: '3', label: 'Istirahat Siang', time: const TimeOfDay(hour: 13, minute: 0), tone: 'Klasik'),
  AlarmModel(id: '4', label: 'Peregangan Sore', time: const TimeOfDay(hour: 15, minute: 30), tone: 'Lembut'),
  AlarmModel(id: '5', label: 'Jeda Sebelum Makan Malam', time: const TimeOfDay(hour: 18, minute: 0), tone: 'Default', isActive: false),
];