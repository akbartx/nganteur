import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'order_makanan_screen.dart';

class PesanMakanScreen extends StatefulWidget {
  @override
  _PesanMakanScreenState createState() => _PesanMakanScreenState();
}

class _PesanMakanScreenState extends State<PesanMakanScreen> {
  List<dynamic> places = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPlaces();
  }

  Future<void> _fetchPlaces() async {
    setState(() {
      _isLoading = true;
    });

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    String location = '${position.latitude},${position.longitude}';

    try {
      var response = await Dio().get('http://192.168.1.13:5006/api/places', // Ganti dengan alamat IP server Anda
          queryParameters: {
            'location': location,
            'radius': 500, // Radius dalam meter
            'type': 'restaurant|cafe|grocery_or_supermarket'
          });

      setState(() {
        places = response.data['results'];
      });
    } catch (e) {
      print(e);
      _showErrorDialog('Failed to fetch places. Please try again later.');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToOrderScreen(place) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderMakananScreen(place: place),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pesan Makanan'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: places.length,
        itemBuilder: (context, index) {
          var place = places[index];
          return Card(
            child: ListTile(
              leading: place['photoUrl'] != null
                  ? Image.network(
                place['photoUrl'],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
                  : Container(
                width: 50,
                height: 50,
                color: Colors.grey,
                child: Icon(Icons.image, color: Colors.white),
              ),
              title: Text(place['name']),
              subtitle: Text(place['vicinity']),
              onTap: () => _navigateToOrderScreen(place),
            ),
          );
        },
      ),
    );
  }
}
