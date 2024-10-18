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



// import 'dart:convert';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:location/location.dart';
// import 'package:maplibre_gl/maplibre_gl.dart';

// class NavigationPage extends StatefulWidget {
//   const NavigationPage({super.key});

//   @override
//   State<NavigationPage> createState() => _NavigationPageState();
// }

// class _NavigationPageState extends State<NavigationPage> {
//   MapLibreMapController? _controller;
//   LocationData? _currentLocation;
//   LocationData? _previousLocation;
//   List<LatLng> routePoints = [];
//   String? currentRouteId;
//   final TextEditingController _startController = TextEditingController();
//   final TextEditingController _endController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _getLocationStream();
//   }

//   // Stream for continuously tracking user location
//   void _getLocationStream() async {
//     Location location = Location();
//     location.onLocationChanged.listen((LocationData currentLocation) {
//       setState(() {
//         _previousLocation = _currentLocation;
//         _currentLocation = currentLocation;
//       });

//       // Re-center the map on current location
//       _controller?.animateCamera(
//         CameraUpdate.newLatLng(
//           LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
//         ),
//       );

//       // Update map's bearing based on direction of movement
//       if (_previousLocation != null) {
//         _updateBearing(_currentLocation!, _previousLocation!);
//       }
//     });
//   }

//   // Update the map bearing (rotation)
//   void _updateBearing(LocationData newLocation, LocationData oldLocation) {
//     double bearing = _calculateBearing(
//       oldLocation.latitude!,
//       oldLocation.longitude!,
//       newLocation.latitude!,
//       newLocation.longitude!,
//     );

//     _controller?.animateCamera(
//       CameraUpdate.newCameraPosition(
//         CameraPosition(
//           target: LatLng(newLocation.latitude!, newLocation.longitude!),
//           bearing: bearing,
//           zoom: 15,
//         ),
//       ),
//     );
//   }

//   double _calculateBearing(
//       double startLat, double startLon, double endLat, double endLon) {
//     double deltaLon = (endLon - startLon);
//     double y = sin(deltaLon) * cos(endLat);
//     double x = cos(startLat) * sin(endLat) -
//         sin(startLat) * cos(endLat) * cos(deltaLon);
//     double bearing = atan2(y, x);
//     return bearing * 180 / pi; // Convert to degrees
//   }

//   // Request the route from GraphHopper and update the map
//   Future<void> _requestRoute(LatLng start, LatLng end) async {
//     final String apiUrl =
//         'https://graphhopper.com/api/1/route?point=${start.latitude},${start.longitude}&point=${end.latitude},${end.longitude}&vehicle=car&key=806c21d6-616f-431e-b185-ce16f3a85cda&instructions=false';

//     try {
//       final response = await http.get(Uri.parse(apiUrl));

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         final String encodedPolyline = data['paths'][0]['points'];
//         routePoints = _decodePolyline(encodedPolyline);

//         // If there's an existing route, remove it
//         if (currentRouteId != null) {
//           _controller?.removeLine(currentRouteId! as Line);
//         }

//         // Add new route to the map
//         Line line = _controller!.addLine(
//           LineOptions(
//             geometry: routePoints,
//             lineColor: '#FF0000',
//             lineWidth: 5.0,
//           ),
//         ) as Line;

//         // Save the new route ID for future reference
//         currentRouteId = line.id;
//       } else {
//         print('Failed to load route data');
//       }
//     } catch (e) {
//       print('Error: $e');
//     }
//   }

//   // Decode the polyline from GraphHopper response
//   List<LatLng> _decodePolyline(String encoded) {
//     List<LatLng> points = [];
//     int index = 0, len = encoded.length;
//     int lat = 0, lon = 0;

//     while (index < len) {
//       int b, shift = 0, result = 0;
//       do {
//         b = encoded.codeUnitAt(index++) - 63;
//         result |= (b & 0x1f) << shift;
//         shift += 5;
//       } while (b >= 0x20);
//       int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
//       lat += dlat;

//       shift = 0;
//       result = 0;
//       do {
//         b = encoded.codeUnitAt(index++) - 63;
//         result |= (b & 0x1f) << shift;
//         shift += 5;
//       } while (b >= 0x20);
//       int dlon = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
//       lon += dlon;

//       points.add(LatLng(lat / 1E5, lon / 1E5));
//     }

//     return points;
//   }

//   // Recenter the map to the current location
//   void _recenterMap() {
//     if (_currentLocation != null) {
//       _controller?.animateCamera(
//         CameraUpdate.newLatLng(
//           LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Navigation Page'),
//       ),
//       body: _currentLocation == null
//           ? const Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: _startController,
//                           decoration: InputDecoration(
//                             labelText: 'Start Location',
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: TextField(
//                           controller: _endController,
//                           decoration: InputDecoration(
//                             labelText: 'End Location',
//                           ),
//                         ),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.search),
//                         onPressed: () {
//                           if (_startController.text.isNotEmpty &&
//                               _endController.text.isNotEmpty) {
//                             LatLng startLocation = LatLng(
//                                 _currentLocation!.latitude!,
//                                 _currentLocation!.longitude!);
//                             // You would perform geocoding for the end location
//                             // For simplicity, let's assume end location is given by LatLng(19.876, 75.343)
//                             LatLng endLocation = LatLng(19.876, 75.343);
//                             _requestRoute(startLocation, endLocation);
//                           }
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: MapLibreMap(
//                     initialCameraPosition: CameraPosition(
//                       target: LatLng(_currentLocation!.latitude!,
//                           _currentLocation!.longitude!),
//                       zoom: 15,
//                     ),
//                     styleString:
//                         "https://api.maptiler.com/maps/openstreetmap/style.json?key=dWavgdQGYhQi3IrgbwAh",
//                     myLocationEnabled: true,
//                     myLocationTrackingMode: MyLocationTrackingMode.tracking,
//                     onMapCreated: (controller) {
//                       _controller = controller;
//                     },
//                   ),
//                 ),
//               ],
//             ),
//       floatingActionButton: Stack(
//         children: [
//           Positioned(
//             bottom: 80,
//             right: 16,
//             child: FloatingActionButton(
//               onPressed: _recenterMap,
//               child: const Icon(Icons.my_location),
//             ),
//           ),
//           Positioned(
//             bottom: 140,
//             right: 16,
//             child: FloatingActionButton(
//               onPressed: () {
//                 // Trigger navigation logic, for example, request a route
//                 Navigator.pop(context);
//               },
//               child: const Icon(Icons.directions),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



