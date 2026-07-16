class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'http://192.168.31.220/tugasakhirsampah/bank_sampah/';

  static const String authLogin = '${baseUrl}modules/api/auth_api.php?action=login';
  static const String authRegister = '${baseUrl}modules/api/auth_api.php?action=register';
  static const String driverActiveTask = '${baseUrl}modules/api/driver_api.php?action=get_active_task';
  static const String driverNotifications = '${baseUrl}modules/api/driver_api.php?action=get_notifications';
  static const String ordersUpdateStatus = '${baseUrl}modules/api/orders_api.php';
}
