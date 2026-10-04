import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

import '../../../../data/models/response_model/notifications/remote_notification/remote_notification_model.dart';
import '../../../../presentation/pages/notifications/bloc/notifications_bloc.dart';
import '../../di/app_component/app_component.dart';
import '../helpers/cache/cache_manager.dart';
import 'notification_handler.dart';
import 'notification_navigation.dart';

class FCMHandler {
  static final FCMHandler _instance = FCMHandler._internal();

  factory FCMHandler() => _instance;
  FCMHandler._internal();

  /// Initialize Firebase Cloud Messaging
  Future<void> initializeFCM() async {
    await FirebaseMessaging.instance.requestPermission();

    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
    FirebaseMessaging.onMessage.listen(_onMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // App launched from a terminated state by tapping a push.
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      NotificationNavigation.handleData(initialMessage.data);
    }

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: false,
      sound: true,
    );

    try {
      final deviceToken = await FirebaseMessaging.instance.getToken();
      debugPrint('FCM Device Token: $deviceToken');
      CacheManager.instance.setFCMDeviceToken(deviceToken);
      await FirebaseMessaging.instance.subscribeToTopic('general');
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
  }

  Future<void> _onMessage(RemoteMessage message) async {
    await _handleMessage(message);
  }

  Future<void> _onMessageOpenedApp(RemoteMessage message) async {
    NotificationNavigation.handleData(message.data);
  }

  Future<void> _handleMessage(RemoteMessage message) async {
    try {
      debugPrint("Handling a message: ${message.toMap()}");
      // Refresh the red badges while the app is open.
      locator<NotificationsBloc>().add(GetUnreadCountEvent());
      if (Platform.isAndroid) {
        await LocalNotificationHandler.displayNotification(
          message.notification?.title ?? '',
          message.notification?.body ?? '',
          payload: message.data,
        );
      }
    } catch (e) {
      debugPrint("Error handling message: $e");
    }
  }
}

@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.data}");

  // The OS already shows pushes that carry a `notification` block; showing a
  // local one too would duplicate it.
  if (message.notification != null) return;

  // ✅ Initialize plugin before showing notifications
  await LocalNotificationHandler.initializeNotifications();

  final data = _decodeMessageData(message.data);
  final notification = RemoteNotificationModel.fromJson(data);

  await LocalNotificationHandler.displayNotification(
    notification.title ?? '',
    notification.body ?? '',
    payload: message.data,
  );
}

Map<String, dynamic> _decodeMessageData(Map<String, dynamic> data) {
  if (data.containsKey('MessageData') && data['MessageData'] is String) {
    data['MessageData'] = jsonDecode(data['MessageData']);
  }
  return data;
}
