import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_config.dart';
import 'api_service.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  static FCMService get instance => _instance;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  bool _isInitialized = false;

  FCMService._internal();

  /// Initialize FCM, request permissions, and start listening to token changes
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // 1. Request Permission (especially for iOS)
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('[FCMService] User granted permission: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized || 
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        
        // 2. Get initial token
        final token = await _firebaseMessaging.getToken();
        if (token != null) {
          debugPrint('[FCMService] Initial FCM Token: $token');
          await sendTokenToBackend(token);
        }

        // 3. Listen to token refresh
        _firebaseMessaging.onTokenRefresh.listen((newToken) async {
          debugPrint('[FCMService] FCM Token Refreshed: $newToken');
          await sendTokenToBackend(newToken);
        });

        // 4. Set up message handlers (optional, can be expanded later)
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          debugPrint('[FCMService] Received foreground message: ${message.messageId}');
          // Handle foreground notification display here if needed
        });

        _isInitialized = true;
      } else {
        debugPrint('[FCMService] User declined or has not accepted permission');
      }
    } catch (e) {
      debugPrint('[FCMService] Initialization Error: $e');
    }
  }

  /// Sends the FCM token to the backend
  Future<void> sendTokenToBackend(String fcmToken) async {
    try {
      // Only send if the user is logged in (has API token)
      final isLoggedIn = await ApiService.instance.isLoggedIn();
      if (!isLoggedIn) {
        debugPrint('[FCMService] User not logged in. Skipping token sync to backend.');
        return;
      }

      debugPrint('[FCMService] Syncing token to backend...');
      final response = await ApiService.instance.post(
        ApiConfig.fcmApi,
        body: {
          'action': 'update_token',
          'fcm_token': fcmToken,
        },
      );

      if (response.success) {
        debugPrint('[FCMService] Successfully synced FCM Token to backend');
      } else {
        debugPrint('[FCMService] Failed to sync FCM Token: ${response.message}');
      }
    } catch (e) {
      debugPrint('[FCMService] Sync Error: $e');
    }
  }
}
