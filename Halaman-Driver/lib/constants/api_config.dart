import 'package:flutter/material.dart';
import 'app_colors.dart';
export 'app_colors.dart';

class ApiConfig {
  ApiConfig._();
  static const String baseUrl = 'http://192.168.110.61/tugasakhirsampah/bank_sampah/';

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
  static const String driverOrderDetail     = '${baseUrl}modules/api/driver_api.php?action=get_order_detail';
  static const String notifikasiUpdate = '${baseUrl}modules/api/notifikasi_api.php';

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
        return const Color(0xFFD97706);
      case 'DRIVER_DITUGASKAN':
      case 'ACCEPTED':
      case 'DRIVER_MENUJU_LOKASI':
      case 'ON_THE_WAY':
      case 'ONTHEWAY':
      case 'DRIVER_TIBA':
        return const Color(0xFF16A34A);
      case 'SAMPAH_DIJEMPUT':
      case 'PICKED_UP':
        return const Color(0xFF16A34A);
      case 'VALIDASI_BANK_SAMPAH':
        return const Color(0xFF0D9488);
      case 'SELESAI':
      case 'COMPLETED':
        return const Color(0xFF16A34A);
      case 'DIBATALKAN':
      case 'CANCELLED':
        return const Color(0xFFDC2626);
      default:
        return AppColors.primary;
    }
  }

  static String getStatusLabel(String? status) {
    switch (status?.toUpperCase()) {
      case 'MENUNGGU_KONFIRMASI':
        return 'Menunggu Konfirmasi';
      case 'DRIVER_DITUGASKAN':
        return 'Picker Ditugaskan';
      case 'DRIVER_MENUJU_LOKASI':
        return 'Picker Menuju Lokasi';
      case 'DRIVER_TIBA':
        return 'Picker Sudah Dekat';
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

  static String formatPickupSchedule(dynamic rawDate, dynamic rawTimeFrom) {
    if (rawDate == null && rawTimeFrom == null) return 'Jadwal -';
    String datePart = rawDate?.toString().trim() ?? '';
    String timePart = rawTimeFrom?.toString().trim() ?? '';

    if (datePart.contains(' ')) {
      datePart = datePart.split(' ').first;
    }

    String formattedDate = datePart;
    if (datePart.contains('-')) {
      final parts = datePart.split('-');
      if (parts.length == 3) {
        final year = parts[0];
        final monthIdx = int.tryParse(parts[1]) ?? 1;
        final day = int.tryParse(parts[2]) ?? 1;
        final months = [
          'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
          'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
        ];
        if (monthIdx >= 1 && monthIdx <= 12) {
          formattedDate = '$day ${months[monthIdx - 1]} $year';
        }
      }
    }

    String formattedTime = timePart;
    if (timePart.contains(':')) {
      final parts = timePart.split(':');
      if (parts.length >= 2) {
        formattedTime = '${parts[0].padLeft(2, '0')}.${parts[1].padLeft(2, '0')} WIB';
      }
    } else if (timePart.isEmpty) {
      formattedTime = '08.00 WIB';
    }

    return '$formattedDate, $formattedTime';
  }
}
