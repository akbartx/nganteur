import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'map_screen.dart'; // Pastikan untuk mengimpor MapScreen

class OrderMakananScreen extends StatefulWidget {
  final dynamic place;

  OrderMakananScreen({required this.place});

  @override
  _OrderMakananScreenState createState() => _OrderMakananScreenState();
}

class _OrderMakananScreenState extends State<OrderMakananScreen> {
  final TextEditingController _pickupAddressController = TextEditingController();
  final TextEditingController _recipientAddressController = TextEditingController();
  final TextEditingController _recipientPhoneController = TextEditingController();
  List<TextEditingController> _productControllers = [TextEditingController()];
  List<TextEditingController> _priceControllers = [TextEditingController()];
  bool _isLoading = false;
  LatLng? _deliveryLocation;
  double _totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _pickupAddressController.text = widget.place['name'] + ', ' + widget.place['vicinity'];
    _getCurrentLocation();
    _calculateTotalPrice();
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _deliveryLocation = LatLng(position.latitude, position.longitude);
      _recipientAddressController.text = '${position.latitude}, ${position.longitude}';
    });
  }

  void _calculateTotalPrice() {
    double total = 0.0;
    for (var controller in _priceControllers) {
      total += double.tryParse(controller.text) ?? 0.0;
    }
    setState(() {
      _totalPrice = total;
    });
  }

  void _addProductField() {
    if (_productControllers.length < 5) {
      setState(() {
        _productControllers.add(TextEditingController());
        _priceControllers.add(TextEditingController());
      });
    }
  }

  void _removeProductField(int index) {
    if (_productControllers.length > 1) {
      setState(() {
        _productControllers.removeAt(index);
        _priceControllers.removeAt(index);
        _calculateTotalPrice();
      });
    }
  }

  void _pickDeliveryLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    LatLng initialLocation = LatLng(position.latitude, position.longitude);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          initialLocation: initialLocation,
          onLocationPicked: (pickedLocation) {
            setState(() {
              _deliveryLocation = pickedLocation;
              _recipientAddressController.text = '${pickedLocation.latitude}, ${pickedLocation.longitude}';
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

    List<Map<String, dynamic>> products = [];
    for (int i = 0; i < _productControllers.length; i++) {
      products.add({
        'product_item': _productControllers[i].text,
        'price': double.tryParse(_priceControllers[i].text) ?? 0.0,
      });
    }

    final response = await http.post(
      Uri.parse('http://192.168.1.13:5006/api/food-orders'), // Ganti dengan alamat IP server Anda
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'transaction_id': DateTime.now().millisecondsSinceEpoch.toString(),
        'user_phone': _recipientPhoneController.text,
        'estimated_price': _totalPrice,
        'product_items': products, // Kirim sebagai objek JSON
        'store_location': widget.place['vicinity'],
        'delivery_location': _recipientAddressController.text,
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
        title: Text('Order Makanan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: _pickupAddressController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Alamat Pengambilan',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              ...List.generate(_productControllers.length, (index) {
                return Column(
                  children: [
                    TextField(
                      controller: _productControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Produk ${index + 1}',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _priceControllers[index],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Harga Perkiraan',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        _calculateTotalPrice();
                      },
                    ),
                    SizedBox(height: 10),
                    if (index > 0)
                      TextButton.icon(
                        onPressed: () => _removeProductField(index),
                        icon: Icon(Icons.remove),
                        label: Text('Hapus Produk'),
                      ),
                    SizedBox(height: 10),
                  ],
                );
              }),
              if (_productControllers.length < 5)
                TextButton.icon(
                  onPressed: _addProductField,
                  icon: Icon(Icons.add),
                  label: Text('Tambah Produk'),
                ),
              TextField(
                controller: _recipientAddressController,
                readOnly: true,
                onTap: _pickDeliveryLocation,
                decoration: InputDecoration(
                  labelText: 'Alamat Pengantaran',
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
              SizedBox(height: 10),
              Text(
                'Total Harga: $_totalPrice',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
      ),
    );
  }
}
