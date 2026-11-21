import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/jeda_popup_screen.dart';
import 'data/jeda_settings.dart';
import 'services/app_limit_service.dart';
import 'services/notification_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('MengJeda: main mulai');

  try {
    await NotificationService.instance
        .init()
        .timeout(const Duration(seconds: 5));
    debugPrint('MengJeda: notifikasi siap');
  } catch (e) {
    debugPrint('MengJeda: Init notifikasi gagal: $e');
  }
  AppLimitService.instance.onJedaRequested = (pkg, label) {
    navigatorKey.currentState?.push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        pageBuilder: (_, _, _) => JedaPopupScreen(durasi: JedaSettings.durasi),
      ),
    );
  };

  try {
    AppLimitService.instance.init();
  } catch (e) {
    debugPrint('MengJeda: AppLimitService gagal: $e');
  }

  debugPrint('MengJeda: runApp');
  runApp(const MengJedaApp());
}

class MengJedaApp extends StatelessWidget {
  const MengJedaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'MengJeda',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const SplashScreen(),
    );
  }
}
