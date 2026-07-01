import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/pickup_detail_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/pickup_verification_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/alert_detail_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/history_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/pickup-detail': (context) => const PickupDetailScreen(),
        '/schedule': (context) => const ScheduleScreen(),
        '/pickup-verify': (context) => const PickupVerificationScreen(),
        '/alerts': (context) => const AlertsScreen(),
        '/alert-detail': (context) => const AlertDetailScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/history': (context) => const HistoryScreen(),
      },
    );
  }
}
