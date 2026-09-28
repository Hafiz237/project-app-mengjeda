import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MediaModel {
  final String id;
  final String nama;
  final String? filePath;
  final IconData icon;
  final Color color;

  const MediaModel({
    required this.id,
    required this.nama,
    this.filePath,
    this.icon = Icons.pets,
    this.color = AppColors.skyBlue,
  });

  bool get isUploaded => filePath != null;
}