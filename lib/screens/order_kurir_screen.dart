import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

import 'map_screen.dart';

class PesanKurirScreen extends StatefulWidget {
  @override
  _PesanKurirScreenState createState() => _PesanKurirScreenState();
}

class _PesanKurirScreenState extends State<PesanKurirScreen> {
  final TextEditingController _pickupAddressController = TextEditingController();
  final TextEditingController _senderPhoneController = TextEditingController();
  final TextEditingController _recipientAddressController = TextEditingController();
  final TextEditingController _recipientPhoneController = TextEditingController();
  bool _isLoading = false;
  LatLng? _pickedLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
  }

  Future<void> _getCurrentLocation() async {
    await _checkLocationPermission();

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _pickedLocation = LatLng(position.latitude, position.longitude);
      _pickupAddressController.text = '${_pickedLocation!.latitude}, ${_pickedLocation!.longitude}';
    });
  }

  void _pickLocation() async {
    await _checkLocationPermission();

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    LatLng initialLocation = LatLng(position.latitude, position.longitude);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          initialLocation: initialLocation,
          onLocationPicked: (pickedLocation) {
            setState(() {
              _pickedLocation = pickedLocation;
              _pickupAddressController.text = '${pickedLocation.latitude}, ${pickedLocation.longitude}';
            });
          },
        ),
      ),
    );
  }

  Future<void> _createOrder() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      print('Token not found');
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse('http://192.168.1.13:5006/api/orders'), // Ganti dengan alamat IP server Anda
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'pickup_address': _pickupAddressController.text,
        'sender_phone': _senderPhoneController.text,
        'recipient_address': _recipientAddressController.text,
        'recipient_phone': _recipientPhoneController.text,
        'status': 0,
      }),
    );

    if (response.statusCode == 201) {
      print('Order created successfully');
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      print('Failed to create order');
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
        title: Text('Pesan Kurir'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _pickupAddressController,
              readOnly: true,
              onTap: _pickLocation,
              decoration: InputDecoration(
                labelText: 'Alamat Penjemputan',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _senderPhoneController,
              decoration: InputDecoration(
                labelText: 'Nomor HP Pengirim',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _recipientAddressController,
              decoration: InputDecoration(
                labelText: 'Alamat Lengkap Penerima',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _recipientPhoneController,
              decoration: InputDecoration(
                labelText: 'Nomor HP Penerima',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _createOrder,
              child: Text('Kirim'),
            ),
          ],
        ),
      ),
    );
  }
}
