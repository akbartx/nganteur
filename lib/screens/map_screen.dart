import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  final LatLng initialLocation;
  final Function(LatLng) onLocationPicked;

  MapScreen({required this.initialLocation, required this.onLocationPicked});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  LatLng? _pickedLocation;

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialLocation;
  }

  void _selectLocation(LatLng position) {
    setState(() {
      _pickedLocation = position;
    });
  }

  void _confirmLocation() {
    if (_pickedLocation != null) {
      widget.onLocationPicked(_pickedLocation!);
      Navigator.of(context).pop();
    }
  }

  void _moveToLocation(LatLng location) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: location, zoom: 15),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lokasi Ambil Paket'),
        actions: [
          IconButton(
            icon: Icon(Icons.my_location),
            onPressed: () {
              _moveToLocation(widget.initialLocation);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.initialLocation,
              zoom: 15,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: _selectLocation,
            markers: _pickedLocation == null
                ? {}
                : {
              Marker(
                markerId: MarkerId('pickedLocation'),
                position: _pickedLocation!,
              ),
            },
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: FloatingActionButton.extended(
              onPressed: _confirmLocation,
              label: Text('Kirim'),
              icon: Icon(Icons.check),
            ),
          ),
        ],
      ),
    );
  }
}
