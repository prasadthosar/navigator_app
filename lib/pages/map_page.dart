import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapLibreMapController? _controller;
  LocationData? _currentLocation;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

// Function to get the user's current location
  void _getLocation() async {
    Location location = Location();
    _currentLocation = await location.getLocation();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Navigation_app'), //app title bar
        ),
        body: _currentLocation == null
            ? const Center(child: CircularProgressIndicator())
            : MapLibreMap(
                initialCameraPosition: CameraPosition(
                    target: LatLng(_currentLocation!.latitude!,
                        _currentLocation!.longitude!),
                    zoom: 16),
                styleString:
                    "https://api.maptiler.com/maps/streets-v2/style.json?key=dWavgdQGYhQi3IrgbwAh", //https:demotiles.maplibre.org/style.json https://maptiler.server/styles/satellite.json", (for sattelite map)  used for map styling
                onMapCreated: (controller) {
                  _controller =
                      controller; // Store the map controller for future interactions.
                },
              ));
  }
}
