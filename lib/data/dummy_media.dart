import 'package:flutter/material.dart';
import '../models/media_model.dart';
import '../theme/app_colors.dart';

List<MediaModel> dummyMedia = [
  MediaModel(id: 'm1', nama: 'Kucing Tidur', icon: Icons.pets, color: AppColors.skyBlue),
  MediaModel(id: 'm2', nama: 'Kucing Meregang', icon: Icons.self_improvement, color: AppColors.tealMint),
  MediaModel(id: 'm3', nama: 'Kucing Bermain', icon: Icons.sports_esports, color: AppColors.goldenYellow),
  MediaModel(id: 'm4', nama: 'Pemandangan Tenang', icon: Icons.landscape, color: AppColors.deepCyan),
  MediaModel(id: 'm5', nama: 'Pesan Rehat', icon: Icons.spa, color: AppColors.primaryBlue),
];

// Menyimpan media yang sedang dipakai untuk pop-up jeda (simulasi, tanpa backend)
String activeMediaId = 'm1';