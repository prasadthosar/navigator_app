import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class NavigationPage extends StatefulWidget {
  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  MapLibreMapController? _controller;
  LocationData? _currentLocation;
  final TextEditingController _endPointController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Function to get the user's current location
  Future<void> _getCurrentLocation() async {
    Location location = Location();
    _currentLocation = await location.getLocation();
    setState(() {});
  }

  // Function to fetch coordinates from Nominatim based on the location name
  Future<LatLng?> getCoordinates(String location) async {
    final String apiUrl =
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(location)}&format=json';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Nominatim response: $data'); // Debug output
        if (data.isNotEmpty) {
          var firstResult = data[0];
          String latString = firstResult['lat'] as String;
          String lonString = firstResult['lon'] as String;

          return LatLng(double.parse(latString), double.parse(lonString));
        } else {
          print('No results found for $location');
        }
      } else {
        print('Failed to load location data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }

  // Function to fetch route from GraphHopper
  Future<void> getRoute(LatLng start, LatLng end) async {
    final String apiUrl =
        'https://graphhopper.com/api/1/route?point=${start.latitude},${start.longitude}&point=${end.latitude},${end.longitude}&vehicle=car&key=806c21d6-616f-431e-b185-ce16f3a85cda'; // Replace YOUR_API_KEY

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('GraphHopper response: $data'); // Debug output

        if (data['paths'] != null && data['paths'].isNotEmpty) {
          final String encodedPolyline = data['paths'][0]['points'];

          // Decode the polyline
          List<LatLng> routePoints = decodePolyline(encodedPolyline);

          // Draw the route on the map
          await _drawRoute(routePoints);
        } else {
          print('No paths found in the response');
        }
      } else {
        print('Failed to load route data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Function to decode the polyline
  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lon = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lon += dlng;

      polyline.add(LatLng(lat / 1E5, lon / 1E5));
    }

    return polyline;
  }

  // Function to draw the route on the map
  Future<void> _drawRoute(List<LatLng> routePoints) async {
    print('Drawing route with ${routePoints.length} points');
    await _controller?.addLine(LineOptions(
      geometry: routePoints,
      lineColor: "#FF0000", // Color for the route line
      lineWidth: 5.0,
    ));
  }

  // Function to handle navigation request
  Future<void> handleNavigation() async {
    final endLocation = _endPointController.text;

    LatLng? endCoords = await getCoordinates(endLocation);

    if (endCoords != null && _currentLocation != null) {
      LatLng startCoords = LatLng(
        _currentLocation!.latitude!,
        _currentLocation!.longitude!,
      );
      await getRoute(startCoords, endCoords);
    } else {
      print('Invalid end location or current location unavailable');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation'),
      ),
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _endPointController,
                    decoration: InputDecoration(
                      labelText: 'End Point (Name)',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: handleNavigation,
                  child: const Text('Get Route'),
                ),
                Expanded(
                  child: MapLibreMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        _currentLocation!.latitude!,
                        _currentLocation!.longitude!,
                      ),
                      zoom: 15,
                    ),
                    styleString:
                        "https://api.maptiler.com/maps/openstreetmap/style.json?key=dWavgdQGYhQi3IrgbwAh",
                    myLocationEnabled: true,
                    myLocationTrackingMode: MyLocationTrackingMode.tracking,
                    onMapCreated: (controller) {
                      _controller = controller; // Store the map controller
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
