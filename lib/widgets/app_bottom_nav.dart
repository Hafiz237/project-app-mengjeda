import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../screens/media_kustom_screen.dart';
import '../screens/alarm_list_screen.dart';
import '../screens/jadwal_list_screen.dart';
import '../screens/statistik_penuh_screen.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({super.key, required this.currentIndex});

  Widget? _screenFor(int index) => switch (index) {
        1 => const MediaKustomScreen(),
        2 => const AlarmListScreen(),
        3 => const JadwalListScreen(),
        4 => const StatistikPenuhScreen(),
        _ => null,
      };

  void _onSelected(BuildContext context, int index) {
    if (index == currentIndex) return;

    final navigator = Navigator.of(context);
    if (index == 0) {
      navigator.popUntil((route) => route.isFirst);
      return;
    }

    final tujuan = _screenFor(index);
    if (tujuan == null) return;
    final route = MaterialPageRoute(builder: (_) => tujuan);

    if (navigator.canPop()) {
      navigator.pushReplacement(route);
    } else {
      navigator.push(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (i) => _onSelected(context, i),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          height: 68,
          indicatorColor: AppColors.tealMint.withValues(alpha: 0.18),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: AppColors.tealMint),
              label: 'Beranda',
            ),
            NavigationDestination(
              icon: Icon(Icons.photo_library_outlined),
              selectedIcon:
                  Icon(Icons.photo_library, color: AppColors.tealMint),
              label: 'Media',
            ),
            NavigationDestination(
              icon: Icon(Icons.alarm),
              selectedIcon: Icon(Icons.alarm_on, color: AppColors.tealMint),
              label: 'Alarm',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined),
              selectedIcon:
                  Icon(Icons.calendar_month, color: AppColors.tealMint),
              label: 'Jadwal',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_rounded),
              selectedIcon:
                  Icon(Icons.insert_chart, color: AppColors.tealMint),
              label: 'Statistik',
            ),
          ],
        ),
      ),
    );
  }
}