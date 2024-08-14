import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nganteur/screens/dashboard_screen.dart';
import 'package:nganteur/screens/login_screen.dart';
import 'package:nganteur/screens/order_kurir_screen.dart';
import 'package:nganteur/screens/permission_screen.dart';
import 'package:nganteur/screens/pesan_makanan_screen.dart';
import 'package:nganteur/screens/profile_screen.dart';
import 'package:nganteur/screens/register_screen.dart';
import 'package:nganteur/screens/riwayat_transaksi_screen.dart';
import 'package:nganteur/screens/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_permission.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Geolocator.requestPermission();
  await AppPermissions.requestAllPermissions();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  runApp(MyApp(token: token));
}

class MyApp extends StatelessWidget {
  final String? token;

  MyApp({this.token});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/pesan-makanan': (context) => PesanMakanScreen(),
        '/pesan-kurir': (context) => PesanKurirScreen(),
        '/riwayat-transaksi': (context) => RiwayatTransaksiScreen(),
        '/profil': (context) => ProfileScreen(),
        '/permissions': (context) => PermissionScreen(),
      },
    );
  }
}
