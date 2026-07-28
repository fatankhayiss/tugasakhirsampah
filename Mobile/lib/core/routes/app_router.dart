import 'package:flutter/material.dart';
import '../navigation/app_page_transitions.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/verification_code_screen.dart';
import '../../features/auth/screens/reset_password_screen.dart';

import '../../features/deposit/screens/manual_deposit_screen.dart';
import '../../features/home/screens/main_navigation_screen.dart';
import '../../features/deposit/screens/scan_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/profile/screens/transfer_point_page.dart';
import '../../features/orders/screens/order_detail_screen.dart';
import 'app_routes.dart';

/// Central route generator — clean, scalable, production-ready.
class AppRouter {
  AppRouter._();

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
      case AppRoutes.intro:
        return AppPageTransitions.fadeSlide(
          settings: settings,
          page: const SplashScreen(),
        );
      case AppRoutes.login:
        final args = settings.arguments;
        final initialEmail = args is String ? args : null;
        return AppPageTransitions.fadeSlide(
          settings: settings,
          page: LoginScreen(initialEmail: initialEmail),
        );
      case AppRoutes.register:
        return AppPageTransitions.fadeSlide(
          settings: settings,
          page: const RegisterScreen(),
        );
      case AppRoutes.forgotPassword:
        return AppPageTransitions.fadeSlide(
          settings: settings,
          page: const ForgotPasswordScreen(),
        );
      case AppRoutes.verification:
        final args = settings.arguments;
        final email = args is String ? args : '';
        return AppPageTransitions.fadeSlide(
          settings: settings,
          page: VerificationCodeScreen(email: email),
        );
      case AppRoutes.resetPassword:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final email = args['email'] as String? ?? '';
        final resetToken = args['reset_token'] as String? ?? '';
        return AppPageTransitions.fadeSlide(
          settings: settings,
          page: ResetPasswordScreen(email: email, resetToken: resetToken),
        );
      case AppRoutes.main:
        return AppPageTransitions.fadeSlide(
          settings: settings,
          page: const MainNavigationScreen(),
        );
      case AppRoutes.home:
        return AppPageTransitions.fadeSlide(
          settings: settings,
          page: const MainNavigationScreen(initialIndex: 0),
        );
      case AppRoutes.orders:
        return AppPageTransitions.fadeSlide(
          settings: settings,
          page: const MainNavigationScreen(initialIndex: 1),
        );
      case AppRoutes.alerts:
        return AppPageTransitions.fadeSlide(
          settings: settings,
          page: const MainNavigationScreen(initialIndex: 2),
        );
      case AppRoutes.profile:
        return AppPageTransitions.fadeSlide(
          settings: settings,
          page: const MainNavigationScreen(initialIndex: 3),
        );
      case AppRoutes.scan:
        return AppPageTransitions.fadeSlide(
          settings: settings,
          page: const ScanScreen(),
        );
      case AppRoutes.manualDeposit:
        return AppPageTransitions.fadeSlide(
          settings: settings,
          page: const ManualDepositScreen(),
        );
      case AppRoutes.transfer:
        return AppPageTransitions.fadeSlide(
          settings: settings,
          page: const TransferPointPage(),
        );
      case AppRoutes.orderDetail:
        final args = settings.arguments;
        final orderId = args is String ? args : '';
        return AppPageTransitions.fadeSlide(
          settings: settings,
          page: OrderDetailScreen(orderId: orderId),
        );
      default:
        return AppPageTransitions.fadeSlide(
          settings: settings,
          page: const SplashScreen(),
        );
    }
  }

  static Route<dynamic>? onUnknownRoute(RouteSettings settings) {
    return AppPageTransitions.fadeSlide(
      settings: settings,
      page: const SplashScreen(),
    );
  }
}
