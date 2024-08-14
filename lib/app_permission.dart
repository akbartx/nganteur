import 'package:permission_handler/permission_handler.dart';

class AppPermissions {
  static Future<void> requestAllPermissions() async {
    await [
      Permission.location,
      Permission.notification,
    ].request();
  }

  static Future<bool> isLocationPermissionGranted() async {
    return await Permission.location.isGranted;
  }

  static Future<bool> isNotificationPermissionGranted() async {
    return await Permission.notification.isGranted;
  }
}
