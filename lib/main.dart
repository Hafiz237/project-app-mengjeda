import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'package:project_pemmob/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  // jika langkah database sudah dipasang, baris DatabaseHelper tetap dipertahankan di sini
  runApp(const MengJedaApp());
}

class MengJedaApp extends StatelessWidget {
  const MengJedaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MengJeda',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}