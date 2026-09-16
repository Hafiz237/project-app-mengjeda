import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
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