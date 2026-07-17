import 'package:flutter/material.dart';

class ApiConfig {
  ApiConfig._();
  static const String baseUrl = 'http://192.168.31.220/tugasakhirsampah/bank_sampah/';

  static const String authLogin = '${baseUrl}modules/api/auth_api.php?action=login';
  static const String authRegister = '${baseUrl}modules/api/auth_api.php?action=register';
  static const String authForgotPassword = '${baseUrl}modules/api/auth_api.php?action=forgot_password';
  static const String driverActiveTask = '${baseUrl}modules/api/driver_api.php?action=get_active_task';
  static const String driverNotifications = '${baseUrl}modules/api/driver_api.php?action=get_notifications';
  static const String driverStats = '${baseUrl}modules/api/driver_api.php?action=get_dashboard_stats';
  static const String driverOrders = '${baseUrl}modules/api/driver_api.php?action=get_orders';
  static const String driverSchedules = '${baseUrl}modules/api/driver_api.php?action=get_schedules';
  static const String driverHistory = '${baseUrl}modules/api/driver_api.php?action=get_history';
  static const String driverProfile = '${baseUrl}modules/api/driver_api.php?action=get_profile';
  static const String driverUpdateProfile = '${baseUrl}modules/api/driver_api.php?action=update_profile';
  static const String ordersUpdateStatus = '${baseUrl}modules/api/orders_api.php';
  static const String ping = '${baseUrl}modules/api/ping.php';
}

class DriverColors {
  // Blue System matching Citizen App
  static const primary = Color(0xFF2D5BFF);
  static const secondary = Color(0xFF4A7BFF);
  static const softBlue = Color(0xFFEAF1FB);
  
  // Background & Surface
  static const background = Color(0xFFF8FAF8);
  static const surface = Colors.white;
  static const surfaceVariant = Color(0xFFF1F5F9);
  
  // Text
  static const textDark = Color(0xFF1B1B1B);
  static const textMuted = Color(0xFF7B7B7B);
  
  // Border
  static const border = Color(0xFFEAEAEA);

  // Status Badges
  static const badgePending = Color(0xFF2D5BFF);     // Blue
  static const badgeAccepted = Color(0xFFF59E0B);    // Orange
  static const badgeOnTheWay = Color(0xFF8B5CF6);    // Purple
  static const badgeCompleted = Color(0xFF10B981);   // Green
  static const badgeCancelled = Color(0xFFEF4444);   // Red
}

class DriverStyles {
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static BorderRadius get cardRadius => BorderRadius.circular(20);

  static Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return DriverColors.badgePending;
      case 'accepted':
        return DriverColors.badgeAccepted;
      case 'on_the_way':
      case 'ontheway':
      case 'picked_up':
        return DriverColors.badgeOnTheWay;
      case 'completed':
      case 'selesai':
        return DriverColors.badgeCompleted;
      case 'cancelled':
      case 'dibatalkan':
        return DriverColors.badgeCancelled;
      default:
        return DriverColors.primary;
    }
  }

  static String getStatusLabel(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'on_the_way':
      case 'ontheway':
      case 'picked_up':
        return 'On The Way';
      case 'completed':
      case 'selesai':
        return 'Completed';
      case 'cancelled':
      case 'dibatalkan':
        return 'Cancelled';
      default:
        return status ?? 'Unknown';
    }
  }
}
