import 'package:flutter/material.dart';
import 'app_colors.dart';
export 'app_colors.dart';

class ApiConfig {
  ApiConfig._();
  static const String baseUrl = 'http://192.168.31.220/tugasakhirsampah/bank_sampah/';

  // Auth
  static const String authLogin           = '${baseUrl}modules/api/auth_api.php?action=login';
  static const String authRegister        = '${baseUrl}modules/api/auth_api.php?action=register';
  static const String authForgotPassword  = '${baseUrl}modules/api/auth_api.php?action=forgot_password';

  // Driver API
  static const String driverActiveTask      = '${baseUrl}modules/api/driver_api.php?action=get_active_task';
  static const String driverNotifications   = '${baseUrl}modules/api/driver_api.php?action=get_notifications';
  static const String driverStats           = '${baseUrl}modules/api/driver_api.php?action=get_dashboard_stats';
  static const String driverOrders          = '${baseUrl}modules/api/driver_api.php?action=get_orders';
  static const String driverSchedules       = '${baseUrl}modules/api/driver_api.php?action=get_schedules';
  static const String driverHistory         = '${baseUrl}modules/api/driver_api.php?action=get_history';
  static const String driverProfile         = '${baseUrl}modules/api/driver_api.php?action=get_profile';
  static const String driverUpdateProfile   = '${baseUrl}modules/api/driver_api.php?action=update_profile';
  static const String driverGetDailyVehicle = '${baseUrl}modules/api/driver_api.php?action=get_daily_vehicle';
  static const String driverSaveDailyVehicle= '${baseUrl}modules/api/driver_api.php?action=save_daily_vehicle';
  static const String driverUpdateDriverStatus='${baseUrl}modules/api/driver_api.php?action=update_driver_status';

  // Orders
  static const String ordersUpdateStatus  = '${baseUrl}modules/api/orders_api.php';

  // Profile (supports multipart photo upload)
  static const String profileUpdate       = '${baseUrl}modules/api/profile_api.php';

  static const String ping                = '${baseUrl}modules/api/ping.php';
}

class DriverStyles {
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static BorderRadius get cardRadius => BorderRadius.circular(20);

  static Color getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'MENUNGGU_KONFIRMASI':
      case 'PENDING':
        return AppColors.badgePending;
      case 'DRIVER_DITUGASKAN':
      case 'ACCEPTED':
        return AppColors.badgeAccepted;
      case 'DRIVER_MENUJU_LOKASI':
      case 'ON_THE_WAY':
      case 'ONTHEWAY':
        return AppColors.badgeOnTheWay;
      case 'DRIVER_TIBA':
        return const Color(0xFF8B5CF6);
      case 'SAMPAH_DIJEMPUT':
      case 'PICKED_UP':
        return const Color(0xFFF59E0B);
      case 'VALIDASI_BANK_SAMPAH':
        return const Color(0xFF06B6D4);
      case 'SELESAI':
      case 'COMPLETED':
        return AppColors.badgeCompleted;
      case 'DIBATALKAN':
      case 'CANCELLED':
        return AppColors.badgeCancelled;
      default:
        return AppColors.primary;
    }
  }

  static String getStatusLabel(String? status) {
    switch (status?.toUpperCase()) {
      case 'MENUNGGU_KONFIRMASI':
        return 'Menunggu Konfirmasi';
      case 'DRIVER_DITUGASKAN':
        return 'Driver Ditugaskan';
      case 'DRIVER_MENUJU_LOKASI':
        return 'Menuju Lokasi';
      case 'DRIVER_TIBA':
        return 'Driver Tiba';
      case 'SAMPAH_DIJEMPUT':
        return 'Sampah Dijemput';
      case 'VALIDASI_BANK_SAMPAH':
        return 'Validasi Bank Sampah';
      case 'SELESAI':
        return 'Selesai';
      case 'DIBATALKAN':
        return 'Dibatalkan';
      case 'PENDING':
        return 'Pending';
      case 'ACCEPTED':
        return 'Diterima';
      case 'ON_THE_WAY':
      case 'ONTHEWAY':
        return 'Dalam Perjalanan';
      case 'PICKED_UP':
        return 'Terjemput';
      case 'COMPLETED':
        return 'Selesai';
      case 'CANCELLED':
        return 'Dibatalkan';
      default:
        return status ?? 'Unknown';
    }
  }
}
