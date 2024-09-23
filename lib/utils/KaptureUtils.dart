import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      // iOS: IOSInitializationSettings(),
    );

    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
      // Handle notification tap
      print("####");
      _handleKaptureNotification(response, navigationKey, "");
    },
        onDidReceiveBackgroundNotificationResponse:
            _handleBackgroundNotification);

    Fluttertoast.showToast(
        msg: payload.toString(),
        // The message to display
        toastLength: Toast.LENGTH_LONG,
        // Duration (short or long)
        gravity: ToastGravity.BOTTOM,
        // Position of the toast (bottom, center, top)
        backgroundColor: Colors.black,
        // Background color of the toast
        textColor: Colors.white,
        // Text color
        fontSize: 16.0 // Font size of the message
        );

    if (payload != null) {
      Timer(Duration(seconds: 3), () {
        _handleKaptureNotification(payload, navigationKey, "");
      });
    }
  }

  // Make sure this is static
  @pragma('vm:entry-point')
  static Future<void> _handleBackgroundNotification(
      NotificationResponse response) async {
    // Handle background notification tap
    Fluttertoast.showToast(
        msg: "This is a Toast message",
        // The message to display
        toastLength: Toast.LENGTH_LONG,
        // Duration (short or long)
        gravity: ToastGravity.BOTTOM,
        // Position of the toast (bottom, center, top)
        backgroundColor: Colors.black,
        // Background color of the toast
        textColor: Colors.white,
        // Text color
        fontSize: 16.0 // Font size of the message
        );
    print("Background notification tapped: ${response.payload}");
    // _handleKaptureNotification(response, navigatorKey, "");
    // CommonUtils.handleNotification(response.payload, navigatorKey);  // Use the appropriate utility function
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

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        // iOS: IOSNotificationDetails(),
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
    print("#################");
    String? route = '/yourRoute';
    if (route != null) {
      Fluttertoast.showToast(
          msg: "payload--".toString(),
          // The message to display
          toastLength: Toast.LENGTH_LONG,
          // Duration (short or long)
          gravity: ToastGravity.BOTTOM,
          // Position of the toast (bottom, center, top)
          backgroundColor: Colors.black,
          // Background color of the toast
          textColor: Colors.white,
          // Text color
          fontSize: 16.0 // Font size of the message
          );
      navigationKey.currentState?.pushNamed('/yourRoute');
    }
  }

  // KaptureUtils class
  static Future<void> handleTerminatedNotification(
      RemoteMessage message) async {
    Fluttertoast.showToast(
        msg: "This is a Toast message",
        // The message to display
        toastLength: Toast.LENGTH_LONG,
        // Duration (short or long)
        gravity: ToastGravity.BOTTOM,
        // Position of the toast (bottom, center, top)
        backgroundColor: Colors.black,
        // Background color of the toast
        textColor: Colors.white,
        // Text color
        fontSize: 16.0 // Font size of the message
        );
    // Check if the message contains data
    if (message.data.isNotEmpty) {
      String? route =
          message.data['route']; // Assuming you have a 'route' in your data
      if (route != null) {
        // Navigate to the desired route
        // navigationKey.currentState?.pushNamed(route);
      }
    }
  }

  static void openStore(String androidId, String iosId) {
    if (Platform.isAndroid || Platform.isIOS) {
      final appId = Platform.isAndroid ? androidId : iosId;
      final url = Uri.parse(
        Platform.isAndroid
            ? "market://details?id=$appId"
            : "https://apps.apple.com/app/id$appId",
      );
    }
  }
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
