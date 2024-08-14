import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../app_permission.dart';

class PermissionScreen extends StatefulWidget {
  @override
  _PermissionScreenState createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  bool _isLocationGranted = false;
  bool _isNotificationGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    _isLocationGranted = await AppPermissions.isLocationPermissionGranted();
    _isNotificationGranted = await AppPermissions.isNotificationPermissionGranted();
    setState(() {});
  }

  Future<void> _requestNotificationPermission() async {
    PermissionStatus status = await Permission.notification.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      openAppSettings();
    } else {
      _isNotificationGranted = await AppPermissions.isNotificationPermissionGranted();
      setState(() {});
      _showPermissionStatusDialog();
    }
  }

  void _showPermissionStatusDialog() {
    String message = 'Permissions granted: \n'
        'Location: ${_isLocationGranted ? 'Granted' : 'Denied'}\n'
        'Notification: ${_isNotificationGranted ? 'Granted' : 'Denied'}';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permission Status'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                if (_isLocationGranted && _isNotificationGranted) {
                  Navigator.pushReplacementNamed(context, '/');
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Permission Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isNotificationGranted)
              ElevatedButton(
                onPressed: _requestNotificationPermission,
                child: Text('Izinkan Notifikasi'),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_isLocationGranted && _isNotificationGranted) {
                  Navigator.pushReplacementNamed(context, '/');
                } else {
                  _showPermissionStatusDialog();
                }
              },
              child: Text('Cek Izin'),
            ),
          ],
        ),
      ),
    );
  }
}
