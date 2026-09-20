import 'package:flutter/material.dart';

class AlarmModel {
  final String id;
  final String label;
  final TimeOfDay time;
  final String tone;
  bool isActive;

  AlarmModel({
    required this.id,
    required this.label,
    required this.time,
    required this.tone,
    this.isActive = true,
  });
}