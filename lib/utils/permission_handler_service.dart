import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';


class PermissionHandlerService {
  Future<bool> checkAndRequestPermissions() async {
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      int sdkInt = androidInfo.version.sdkInt ?? 0;
      if (sdkInt >= 33) {
        // For Android 13 (SDK 33) and above
        var permissions = await [
          Permission.camera,
          Permission.photos,
          Permission.videos,
          Permission.notification,
          Permission.mediaLibrary, // For managing media files
        ].request();
        return permissions.values.every((status) => status.isGranted);
      } else {
        // For older Android versions
        var permissions = await [
          Permission.camera,
          Permission.storage,
          Permission.photos,
          Permission.notification,
          Permission.videos,
          // Note: Media permissions are not necessary for older versions
        ].request();
        return permissions.values.every((status) => status.isGranted);
      }
    } else if (Platform.isIOS) {
      // iOS specific permission handling
      var permissions = await [
        Permission.photos,
        Permission.camera,
        Permission.notification,
      ].request();
      return permissions.values.every((status) => status.isGranted);
    }
    return false;
  }

  Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}
