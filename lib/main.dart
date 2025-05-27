// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'dashboard_page.dart';
import 'rutinas_page.dart';
import 'progreso_page.dart';
import 'settings_page.dart';
import 'screens/progress_chart_page.dart'; // ✅ Import correcto

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rutina Tracker',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (ctx) => const SplashScreen(),
        '/dashboard': (ctx) => const DashboardPage(),
        '/rutinas': (ctx) => const RutinasPage(),
        '/progreso': (ctx) => const ProgresoPage(),
        '/settings': (ctx) => const SettingsPage(),
         '/progresoGrafica': (ctx) => const ProgresoGraficaPage(),
      },
    );
  }
}
