import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_kapture_ticketing_sdk_platform_interface.dart';

/// An implementation of [FlutterKaptureTicketingSdkPlatform] that uses method channels.
class MethodChannelFlutterKaptureTicketingSdk extends FlutterKaptureTicketingSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_kapture_ticketing_sdk');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
