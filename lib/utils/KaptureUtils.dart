import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class KaptureUtils {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static void initializeKaptureNotifications(
      // Listen for local notification taps
      GlobalKey<NavigatorState> navigationKey) async {
    NotificationAppLaunchDetails? notificationResponse =
        await _flutterLocalNotificationsPlugin
            .getNotificationAppLaunchDetails();

    var payload = notificationResponse?.notificationResponse;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: DarwinInitializationSettings(
                requestAlertPermission: true,
                requestBadgePermission: true,
                requestSoundPermission: true
            )
        );

    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        _handleKaptureNotification(response, navigationKey, "");
      },
    );

    if (payload != null) {
      Timer(Duration(seconds: 3), () {
        _handleKaptureNotification(payload, navigationKey, "");
      });
    }
  }

  static Future<bool> kaptureNotificationService(RemoteMessage message) async {
    if (true) {
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'your_channel_id',
        'your_channel_name',
        channelDescription: 'Your channel description',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
              presentAlert: true, presentBadge: true, presentSound: true);

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: iOSPlatformChannelSpecifics,
      );
      await _flutterLocalNotificationsPlugin.show(
        0,
        message.data["title"],
        message.data["body"],
        notificationDetails,
        payload: message.data.toString(),
      );
      return true;
    }
    return false;
  }

  static Future<void> _handleKaptureNotification(NotificationResponse message,
      GlobalKey<NavigatorState> navigationKey, String route) async {
    String? route = '/yourRoute';
    if (route != null) {
      navigationKey.currentState?.pushNamed('/yourRoute');
    }
  }
}
