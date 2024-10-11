import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kapture_ticketing_sdk/flutter_kapture_ticketing_sdk.dart';
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
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap
        _handleKaptureNotification(response, navigationKey);
      },
    );

    if (payload != null) {
      Timer(const Duration(seconds: 3), () {
        _handleKaptureNotification(payload, navigationKey);
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
    GlobalKey<NavigatorState> navigationKey) async {
    try {
      String fixedJsonString = KaptureUtils().fixPayload(message.payload??'{}');
      Map<String, dynamic> response = jsonDecode(fixedJsonString);
      navigationKey.currentState?.pushNamed('/kapture', arguments: {
        'url':(response.containsKey("url") && response["url"]!=null)?response["url"]:"https://goldenrama.kapturecrm.com/nui_develop/qk_2",
      },);
    } catch(error) {}
  }

  String fixPayload(String payload) {
    // Use regex to fix the payload format
    String fixedJson = payload.replaceAllMapped(
      RegExp(r'(\w+)\s*:\s*("[^"]*"|[^,\s}]+(?:\s+[^,\s}]+)*)'),
          (match) {
        String key = '"${match[1]}"'; // Wrap key in quotes
        String value = match[2].toString(); // Get the value

        // Check if the value is not quoted and wrap it in quotes if necessary
        if (!value.startsWith('"')) {
          value = '"$value"'; // Add quotes around non-quoted values
        }

        return '$key: $value'; // Return the formatted key-value pair
      },
    );

    // Ensure the string is properly closed with a brace
    return fixedJson.trim().endsWith('}') ? fixedJson : '$fixedJson}';
  }

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      '/kapture': (context) {
        // Extract the arguments from the route settings
        final args = ModalRoute
            .of(context)
            ?.settings
            .arguments as Map<String, dynamic>;
        // Return the widget with the extracted arguments
        return KapturePackage(url: args.containsKey("url") ? args['url']: "https://goldenrama.kapturecrm.com/nui_develop/qk_2", fcmToken: args.containsKey("fcmToken")?args['fcmToken']:"",);
      }
    };
  }
}
