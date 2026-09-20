import 'package:flutter/material.dart';

class JadwalModel {
  final String id;
  final String label;
  final TimeOfDay time;
  final String kategoriId;
  bool isActive;

  JadwalModel({
    required this.id,
    required this.label,
    required this.time,
    required this.kategoriId,
    this.isActive = true,
  });
}