// import 'package:flutter/material.dart';
// import 'package:location/location.dart';
// import 'package:maplibre_gl/maplibre_gl.dart';

// class MapPage extends StatefulWidget {
//   const MapPage({super.key});

//   @override
//   State<MapPage> createState() => _MapPageState();
// }

// class _MapPageState extends State<MapPage> {
//   MapLibreMapController? _controller;
//   LocationData? _currentLocation;

//   @override
//   void initState() {
//     super.initState();
//     _getLocation();
//   }

// // Function to get the user's current location
//   void _getLocation() async {
//     Location location = Location();
//     _currentLocation = await location.getLocation();
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text('Navigation_app'), //app title bar
//         ),
//         body: _currentLocation == null
//             ? const Center(child: CircularProgressIndicator())
//             : MapLibreMap(
//                 initialCameraPosition: CameraPosition(
//                     target: LatLng(_currentLocation!.latitude!,
//                         _currentLocation!.longitude!),
//                     zoom: 15),
//                 styleString:
//                     "https://api.maptiler.com/maps/openstreetmap/style.json?key=dWavgdQGYhQi3IrgbwAh",
//                 // "https://api.maptiler.com/maps/streets-v2/style.json?key=dWavgdQGYhQi3IrgbwAh", //https:demotiles.maplibre.org/style.json https://maptiler.server/styles/satellite.json", (for sattelite map)  used for map styling
//                 myLocationEnabled: true,
//                 myLocationTrackingMode: MyLocationTrackingMode.tracking,
//                 onMapCreated: (controller) {
//                   _controller =
//                       controller; // Store the map controller for future interactions.
//                 },
//               ));
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:navigation_app/pages/navigationpage.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapLibreMapController? _controller;
  LocationData? _currentLocation;
  final TextEditingController _searchController = TextEditingController();

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

  // Function to search for a location
  Future<void> searchLocation(String locationName) async {
    final String apiUrl =
        'https://nominatim.openstreetmap.org/search?q=$locationName&format=json&addressdetails=1';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final latitude = double.parse(data[0]['lat']);
          final longitude = double.parse(data[0]['lon']);
          // Center the map on the searched location
          _controller
              ?.moveCamera(CameraUpdate.newLatLng(LatLng(latitude, longitude)));
        } else {
          print('No results found');
        }
      } else {
        print('Failed to load location data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation App'), // App title bar
      ),
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Enter location name',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          searchLocation(_searchController.text);
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: MapLibreMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(_currentLocation!.latitude!,
                          _currentLocation!.longitude!),
                      zoom: 15,
                    ),
                    styleString:
                        "https://api.maptiler.com/maps/openstreetmap/style.json?key=dWavgdQGYhQi3IrgbwAh",
                    myLocationEnabled: true,
                    myLocationTrackingMode: MyLocationTrackingMode.tracking,
                    onMapCreated: (controller) {
                      _controller =
                          controller; // Store the map controller for future interactions.
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => NavigationPage()));
        },
        child: Icon(Icons.directions),
      ),
    );
  }
}
