// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages, unused_field
import 'package:flutter/material.dart';
// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages, unused_field
import 'package:firebase_core/firebase_core.dart';
// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages, unused_field
import 'core/routes/app_routes.dart';
// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages, unused_field
import 'core/routes/app_router.dart';
// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages, unused_field
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'iTrashy',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
      onUnknownRoute: AppRouter.onUnknownRoute,
    );
  }
}
