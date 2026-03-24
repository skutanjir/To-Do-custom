import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:pdbl_testing_custom_mobile/core/utils/notification_helper.dart';
import 'dart:developer';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  log('Title: ${message.notification?.title}');
  log('Body: ${message.notification?.body}');
  log('Payload: ${message.data}');
  
  // Optionally, show a local notification here if the payload dictates it.
  // But by default, Firebase handles background notification UI automatically
  // if the notification object is present.
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    try {
      // 1. Request permission from user (required for iOS and Android 13+)
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        log('User granted permission for Push Notifications');
      }

      // 2. Fetch the FCM Token for this device (Send this to your Laravel Backend)
      final fcmToken = await _firebaseMessaging.getToken();
      log('====================================');
      log('FCM Token: $fcmToken');
      log('====================================');
      // TODO: Send this token to your Laravel backend (e.g. users table -> fcm_token)

      // 3. Initialize push notification listeners
      initPushNotifications();
    } catch (e) {
      log('Failed to initialize Firebase Messaging: $e');
    }
  }

  void initPushNotifications() {
    // A. App is closed completely, and opened via a push notification
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

    // B. App is in the background, but running, and opened via a push notification
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);

    // C. Handle background messages (when the app is closed/in background)
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    // D. App is in the FOREGROUND (currently being used)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification == null) return;

      // Because FCM does not automatically show a popup if the app is in the foreground,
      // we must use our Local Notifications to show it manually.
      NotificationHelper.showInstant(
        id: notification.hashCode,
        title: notification.title ?? 'New Notification',
        body: notification.body ?? '',
        payload: message.data.toString(),
      );
    });
  }

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;
    
    // Navigate to a specific screen when the user taps the notification
    log('Notification Tapped! Navigate to related screen. Payload: ${message.data}');
    // Example: if (message.data['type'] == 'chat') { Navigator.push(...) }
  }
}
