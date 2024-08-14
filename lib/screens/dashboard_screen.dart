import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../app_permission.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<String> imgList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  Future<void> _fetchImages() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(
      Uri.parse('http://192.168.1.13:5006/api/slider/images'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        imgList = data.cast<String>();
      });
    } else {
      print('Failed to fetch images');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _requestPermissions() async {
    await AppPermissions.requestAllPermissions();

    bool isLocationGranted = await AppPermissions.isLocationPermissionGranted();
    bool isNotificationGranted = await AppPermissions.isNotificationPermissionGranted();

    String message = 'Permissions granted: \n'
        'Location: ${isLocationGranted ? 'Granted' : 'Denied'}\n'
        'Notification: ${isNotificationGranted ? 'Granted' : 'Denied'}';

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
        title: Text('Nganteur'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout(context);
              }
            },
            itemBuilder: (BuildContext context) {
              return {'Logout'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: 'logout',
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchImages,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: 200.0,
                    autoPlay: true,
                    enlargeCenterPage: true,
                  ),
                  items: imgList
                      .map((item) => Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.network(item,
                          fit: BoxFit.cover, width: 1000),
                    ),
                  ))
                      .toList(),
                ),
                SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari layanan',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    _buildDashboardItem(
                      icon: Icons.fastfood,
                      title: 'Pesan Makanan',
                      onTap: () {
                        Navigator.pushNamed(context, '/pesan-makanan');
                      },
                    ),
                    _buildDashboardItem(
                      icon: Icons.delivery_dining,
                      title: 'Pesan Kurir',
                      onTap: () {
                        Navigator.pushNamed(context, '/pesan-kurir');
                      },
                    ),
                    _buildDashboardItem(
                      icon: Icons.history,
                      title: 'Transaksi',
                      onTap: () {
                        Navigator.pushNamed(context, '/riwayat-transaksi');
                      },
                    ),
                    _buildDashboardItem(
                      icon: Icons.person,
                      title: 'Profil',
                      onTap: () {
                        Navigator.pushNamed(context, '/profil');
                      },
                    ),
                    _buildDashboardItem(
                      icon: Icons.settings,
                      title: 'Request Permissions',
                      onTap: () {
                        _requestPermissions();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.pushReplacementNamed(context, '/login');
  }

  Widget _buildDashboardItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.purple[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.purple),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
