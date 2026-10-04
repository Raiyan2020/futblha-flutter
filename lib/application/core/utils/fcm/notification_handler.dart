import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/cupertino.dart';

import 'notification_navigation.dart';

class LocalNotificationHandler {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'futblha', // id
    'futblha Notifications', // name
    description: 'Channel for important notifications.',
    importance: Importance.high,
  );

  /// Initialize the local notification system
  static Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) => _onTap(response.payload),
    );

    // App launched by tapping a local notification.
    final launchDetails = await _flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      _onTap(launchDetails?.notificationResponse?.payload);
    }

    // ✅ Create Android notification channel (required for Android 8+)
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // ✅ Request iOS permissions
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Display a local notification
  static void _onTap(String? payload) {
    if (payload == null || payload.isEmpty) return;
    try {
      NotificationNavigation.handleData(Map<String, dynamic>.from(jsonDecode(payload)));
    } catch (e) {
      debugPrint('Error handling notification tap: $e');
    }
  }

  static Future<void> displayNotification(String title, String body, {Map<String, dynamic>? payload}) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'futblha',
        'futblha Notifications',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
      );

      // ✅ Use unique ID so notifications don’t overwrite each other
      final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      await _flutterLocalNotificationsPlugin.show(
        notificationId,
        title,
        body,
        platformChannelSpecifics,
        payload: payload == null ? null : jsonEncode(payload),
      );
    } catch (e) {
      debugPrint('Error displaying notification: $e');
    }
  }
}
