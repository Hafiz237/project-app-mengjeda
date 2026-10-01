import 'package:flutter/material.dart';
import '../models/media_model.dart';
import '../theme/app_colors.dart';

List<MediaModel> dummyMedia = [
  MediaModel(
    id: 'm1',
    nama: 'Meng1',
    assetPath: 'assets/images/catmeme1.jpg',
    icon: Icons.pets,
    color: AppColors.skyBlue,
  ),
  MediaModel(
    id: 'm2',
    nama: 'Meng2',
    assetPath: 'assets/images/catmeme2.jpg',
    icon: Icons.self_improvement,
    color: AppColors.tealMint,
  ),
  MediaModel(
    id: 'm3',
    nama: 'MengNerd',
    assetPath: 'assets/images/catmeme3.jpg',
    icon: Icons.sports_esports,
    color: AppColors.goldenYellow,
  ),
  MediaModel(
    id: 'm4',
    nama: 'MengBengong',
    assetPath: 'assets/images/catmeme4.jpg',
    icon: Icons.landscape,
    color: AppColors.deepCyan,
  ),
  MediaModel(
    id: 'm5',
    nama: 'Ngehehe',
    assetPath: 'assets/images/catmeme5.jpg',
    icon: Icons.spa,
    color: AppColors.primaryBlue,
  ),
];

String activeMediaId = 'm1';