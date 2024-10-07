import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class KaptureUtils {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static void initializeKaptureNotifications(
      // Listen for local notification taps
      GlobalKey<NavigatorState> navigationKey, String? route) async {
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
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap
        _handleKaptureNotification(response, navigationKey, route);
      },
    );

    if (payload != null) {
      Timer(const Duration(seconds: 3), () {
        _handleKaptureNotification(payload, navigationKey, route);
      });
    }
  }

  static Future<bool> kaptureNotificationService(RemoteMessage message) async {
    if (message.data["type"]=="KAPTURE_NOTIFICATION_SERVICE") {
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
      if (message.data.containsKey("title") && message.data.containsKey("body")) {
        await _flutterLocalNotificationsPlugin.show(
          0,
          message.data["title"],
          message.data["body"],
          notificationDetails,
          payload: message.data.toString(),
        );
      } else{
        return false;
      }
      return true;
    }
    return false;
  }

  static Future<void> _handleKaptureNotification(NotificationResponse message,
      GlobalKey<NavigatorState> navigationKey, String? route) async {
    if (route != null) {
      navigationKey.currentState?.pushNamed(route);
    }
  }
}
