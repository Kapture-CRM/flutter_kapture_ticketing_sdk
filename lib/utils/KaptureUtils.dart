import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kapture_ticketing_sdk/flutter_kapture_ticketing_sdk.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class KaptureUtils {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static void initializeKaptureNotifications(GlobalKey<NavigatorState> navigationKey, String? route, String? baseUrl) async {
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
        _handleKaptureNotification(response, navigationKey, route, baseUrl);
      },
    );

    if (payload != null) {
      Timer(const Duration(seconds: 3), () {
        _handleKaptureNotification(payload, navigationKey, route, baseUrl);
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
          payload: jsonEncode(message.data),
        );
        return true;
      }
      else if(message.data.containsKey("message")){
        Map<String, dynamic> messageObj = jsonDecode(message.data["message"]);
        if(messageObj["task"]["taskTitle"]!=null) {
          await _flutterLocalNotificationsPlugin.show(
            0,
            messageObj["task"]["taskTitle"],
            "",
            notificationDetails,
            payload: jsonEncode(message.data),
          );
          return true;
        }
      }
      else if (message.data.containsKey("notification")) {
        Map<String, dynamic> notification = jsonDecode(message.data["notification"]);
        Map<String, dynamic> parsedData = {
          ...message.data,
          "notification": notification,
        };
        print("Notification Data: $parsedData");
        return false;
      }
      return false;
    }
    return false;
  }

  static Future<void> _handleKaptureNotification(NotificationResponse message, GlobalKey<NavigatorState> navigationKey, String? route, String? baseUrl) async {
    if(route!=null && baseUrl!=null) {
      try {
        Map<String, dynamic> response = jsonDecode(message.payload ?? "");
        if (response.containsKey("message")) {
          var messageObj = jsonDecode(response["message"]);
          if (messageObj["task"]["ticketId"] != null && messageObj["task"]["ticketId"] != "") {
            navigationKey.currentState?.pushNamed(route, arguments: {
              'url': baseUrl + "/tickets/assigned_to_me/5/-1/0/detail/" +
                  messageObj["task"]["ticketId"],
            },);
          } else {
            navigationKey.currentState?.pushNamed(route, arguments: {
              'url': baseUrl,
            },);
          }
        }
        else if (response.containsKey("notification")) {
          navigationKey.currentState?.pushNamed(route, arguments: {
            'url': baseUrl,
          },);
        }
        else if (response.containsKey("url")) {
          navigationKey.currentState?.pushNamed(route, arguments: {
            'url': (response.containsKey("url") && response["url"] != null)
                ? response["url"]
                : baseUrl,
          },);
        }
        else {
          navigationKey.currentState?.pushNamed(route, arguments: {
            'url': baseUrl,
          },);
        }
      } catch (error) {
        navigationKey.currentState?.pushNamed(route, arguments: {
          'url': baseUrl,
        },);
      }
    }
  }
}
