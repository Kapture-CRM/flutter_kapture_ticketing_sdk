import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_kapture_ticketing_sdk/flutter_kapture_ticketing_sdk.dart';
import 'package:flutter_kapture_ticketing_sdk/flutter_kapture_ticketing_sdk_platform_interface.dart';
import 'package:flutter_kapture_ticketing_sdk/flutter_kapture_ticketing_sdk_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterKaptureTicketingSdkPlatform
    with MockPlatformInterfaceMixin
    implements FlutterKaptureTicketingSdkPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterKaptureTicketingSdkPlatform initialPlatform = FlutterKaptureTicketingSdkPlatform.instance;

  test('$MethodChannelFlutterKaptureTicketingSdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterKaptureTicketingSdk>());
  });

  test('getPlatformVersion', () async {
    // FlutterKaptureTicketingSdk flutterKaptureTicketingSdkPlugin = FlutterKaptureTicketingSdk();
    // MockFlutterKaptureTicketingSdkPlatform fakePlatform = MockFlutterKaptureTicketingSdkPlatform();
    // FlutterKaptureTicketingSdkPlatform.instance = fakePlatform;
    //
    // expect(await flutterKaptureTicketingSdkPlugin.getPlatformVersion(), '42');
  });
}
