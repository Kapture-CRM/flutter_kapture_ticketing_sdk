import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_kapture_ticketing_sdk_method_channel.dart';

abstract class FlutterKaptureTicketingSdkPlatform extends PlatformInterface {
  /// Constructs a FlutterKaptureTicketingSdkPlatform.
  FlutterKaptureTicketingSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterKaptureTicketingSdkPlatform _instance = MethodChannelFlutterKaptureTicketingSdk();

  /// The default instance of [FlutterKaptureTicketingSdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterKaptureTicketingSdk].
  static FlutterKaptureTicketingSdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterKaptureTicketingSdkPlatform] when
  /// they register themselves.
  static set instance(FlutterKaptureTicketingSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
