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
import 'constants/api_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'iTrashy Driver',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Plus Jakarta Sans',
        colorScheme: ColorScheme.fromSeed(
          seedColor: DriverColors.primary,
          primary: DriverColors.primary,
          secondary: DriverColors.secondary,
          surface: DriverColors.surface,
          error: const Color(0xFFEF4444),
        ),
        scaffoldBackgroundColor: DriverColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: DriverColors.background,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: DriverColors.textDark),
          titleTextStyle: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: DriverColors.textDark,
          ),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
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
