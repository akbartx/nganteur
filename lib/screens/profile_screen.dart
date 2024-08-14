import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _noteleponController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? _imageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      // Handle the case where the token is not available
      print('Token kosong');
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final response = await http.get(
      Uri.parse('http://192.168.1.13:5006/api/profile'), // Ganti dengan alamat IP server Anda
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body); // Asumsikan data adalah array
      print('Data profil: $data');

      if (data.isNotEmpty) {
        setState(() {
          final profile = data[0]; // Ambil elemen pertama dari array
          _usernameController.text = profile['username'];
          _noteleponController.text = profile['no_telepon'];
          _emailController.text = profile['email'];
          _imageUrl = profile['images'] != null ? 'http://192.168.1.13:5006/${profile['images']}' : null; // Lengkapi URL gambar
        });
      } else {
        print('Data profil kosong');
      }
    } else {
      print('Gagal mendapatkan profil');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  Future<void> _updateProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      print('Token kosong');
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final response = await http.put(
      Uri.parse('http://192.168.1.13:5006/api/profile'), // Ganti dengan alamat IP server Anda
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'username': _usernameController.text,
        'no_telepon': _noteleponController.text,
        'email': _emailController.text,
        'images': _imageUrl != null ? _imageUrl!.replaceFirst('http://192.168.1.13:5006/', '') : null, // Simpan path gambar relatif
      }),
    );

    if (response.statusCode == 200) {
      print('Profile updated successfully');
      // Navigasi ke DashboardScreen
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      print('Gagal memperbarui profil');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: _imageUrl != null
                  ? CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(_imageUrl!), // Gunakan URL gambar lengkap
              )
                  : CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.grey[800],
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _noteleponController,
              decoration: InputDecoration(
                labelText: 'No telepon',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _updateProfile,
              child: Text('Kirim'),
            ),
          ],
        ),
      ),
    );
  }
}
