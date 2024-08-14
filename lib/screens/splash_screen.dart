import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_permission.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    await AppPermissions.requestAllPermissions();

    bool isLocationGranted = await AppPermissions.isLocationPermissionGranted();
    bool isNotificationGranted = await AppPermissions.isNotificationPermissionGranted();

    if (!isLocationGranted || !isNotificationGranted) {
      Navigator.pushReplacementNamed(context, '/permissions');
    } else {
      _checkToken();
    }
  }

  Future<void> _checkToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    await Future.delayed(Duration(seconds: 3)); // Simulasi waktu loading
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset('assets/animations/splash_animation.json'),
      ),
    );
  }
}
