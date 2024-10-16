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
          // Accessing first result safely
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
        'https://graphhopper.com/api/1/route?point=${start.latitude},${start.longitude}&point=${end.latitude},${end.longitude}&vehicle=car&key=YOUR_API_KEY';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('GraphHopper response: $data'); // Debug output
        if (data['paths'] != null && data['paths'].isNotEmpty) {
          // Ensure this line correctly accesses the data
          final List<dynamic> path = data['paths'][0]['points']['coordinates'];
          List<LatLng> routePoints = path
              .map((point) => LatLng(point[1], point[0])) // Reverse the order
              .toList();

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
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:location/location.dart';
// import 'package:maplibre_gl/maplibre_gl.dart';

// class NavigationPage extends StatefulWidget {
//   @override
//   _NavigationPageState createState() => _NavigationPageState();
// }

// class _NavigationPageState extends State<NavigationPage> {
//   MapLibreMapController? _controller;
//   LocationData? _currentLocation;
//   final TextEditingController _endPointController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//   }

//   // Function to get the user's current location
//   Future<void> _getCurrentLocation() async {
//     Location location = Location();
//     _currentLocation = await location.getLocation();
//     setState(() {});
//   }

//   // Function to fetch coordinates from Nominatim based on the location name
//   Future<LatLng?> getCoordinates(String location) async {
//     final String apiUrl =
//         'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(location)}&format=json';

//     try {
//       final response = await http.get(Uri.parse(apiUrl));
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data.isNotEmpty) {
//           // Print the data for debugging
//           print(data);

//           // Ensure lat and lon are available and correct
//           String latString = data[0]['lat'] as String? ?? '';
//           String lonString = data[0]['lon'] as String? ?? '';

//           if (latString.isNotEmpty && lonString.isNotEmpty) {
//             return LatLng(double.parse(latString), double.parse(lonString));
//           } else {
//             print('Latitude or Longitude is empty');
//           }
//         } else {
//           print('No results found for $location');
//         }
//       } else {
//         print('Failed to load location data: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error: $e');
//     }
//     return null;
//   }

//   // Function to fetch route from GraphHopper
//   Future<void> getRoute(LatLng start, LatLng end) async {
//     final String apiUrl =
//         'https://graphhopper.com/api/1/route?point=${start.latitude},${start.longitude}&point=${end.latitude},${end.longitude}&vehicle=car&key=806c21d6-616f-431e-b185-ce16f3a85cda';

//     try {
//       final response = await http.get(Uri.parse(apiUrl));
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['paths'].isNotEmpty) {
//           final List<dynamic> path = data['paths'][0]['points']['coordinates'];
//           List<LatLng> routePoints = path
//               .map((point) => LatLng(point[1], point[0])) // Reverse the order
//               .toList();

//           // Draw the route on the map
//           _drawRoute(routePoints);
//         } else {
//           print('No paths found');
//         }
//       } else {
//         print('Failed to load route data');
//       }
//     } catch (e) {
//       print('Error: $e');
//     }
//   }

//   Future<void> _drawRoute(List<LatLng> routePoints) async {
//     print('Drawing route with ${routePoints.length} points');
//     await _controller?.addLine(LineOptions(
//       geometry: routePoints,
//       lineColor: "#FF0000", // Color for the route line
//       lineWidth: 5.0,
//     ));
//   }

//   // Function to handle navigation request
//   Future<void> handleNavigation() async {
//     final endLocation = _endPointController.text;

//     LatLng? endCoords = await getCoordinates(endLocation);

//     if (endCoords != null && _currentLocation != null) {
//       LatLng startCoords = LatLng(
//         _currentLocation!.latitude!,
//         _currentLocation!.longitude!,
//       );
//       getRoute(startCoords, endCoords);
//     } else {
//       print('Invalid end location or current location unavailable');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Navigation'),
//       ),
//       body: _currentLocation == null
//           ? const Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: TextField(
//                     controller: _endPointController,
//                     decoration: InputDecoration(
//                       labelText: 'End Point (Name)',
//                     ),
//                   ),
//                 ),
//                 ElevatedButton(
//                   onPressed: handleNavigation,
//                   child: const Text('Get Route'),
//                 ),
//                 Expanded(
//                   child: MapLibreMap(
//                     initialCameraPosition: CameraPosition(
//                       target: LatLng(
//                         _currentLocation!.latitude!,
//                         _currentLocation!.longitude!,
//                       ),
//                       zoom: 15,
//                     ),
//                     styleString:
//                         "https://api.maptiler.com/maps/openstreetmap/style.json?key=dWavgdQGYhQi3IrgbwAh",
//                     myLocationEnabled: true,
//                     myLocationTrackingMode: MyLocationTrackingMode.tracking,
//                     onMapCreated: (controller) {
//                       _controller = controller; // Store the map controller
//                     },
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
// }







// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:location/location.dart';
// import 'package:maplibre_gl/maplibre_gl.dart';

// class NavigationPage extends StatefulWidget {
//   @override
//   _NavigationPageState createState() => _NavigationPageState();
// }

// class _NavigationPageState extends State<NavigationPage> {
//   MapLibreMapController? _controller;
//   LocationData? _currentLocation;
//   final TextEditingController _startPointController = TextEditingController();
//   final TextEditingController _endPointController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//   }

//   // Function to get the user's current location
//   Future<void> _getCurrentLocation() async {
//     Location location = Location();
//     _currentLocation = await location.getLocation();
//     setState(() {});
//   }

//   // Function to search for a location
//   Future<void> searchLocation(String locationName) async {
//     final String apiUrl =
//         'https://nominatim.openstreetmap.org/search?q=$locationName&format=json&addressdetails=1';

//     try {
//       final response = await http.get(Uri.parse(apiUrl));

//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         if (data.isNotEmpty) {
//           final latitude = double.parse(data[0]['lat']);
//           final longitude = double.parse(data[0]['lon']);
//           // Center the map on the searched location
//           _controller
//               ?.moveCamera(CameraUpdate.newLatLng(LatLng(latitude, longitude)));
//         } else {
//           print('No results found');
//         }
//       } else {
//         print('Failed to load location data');
//       }
//     } catch (e) {
//       print('Error: $e');
//     }
//   }

//   // Function to fetch route from GraphHopper
//   Future<void> getRoute(LatLng start, LatLng end) async {
//     final String apiUrl =
//         'https://graphhopper.com/api/1/route?point=${start.latitude},${start.longitude}&point=${end.latitude},${end.longitude}&vehicle=car&key=YOUR_API_KEY';

//     try {
//       final response = await http.get(Uri.parse(apiUrl));
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['paths'].isNotEmpty) {
//           final List<dynamic> path = data['paths'][0]['points']['coordinates'];
//           List<LatLng> routePoints = path
//               .map((point) => LatLng(point[1], point[0])) // Reverse the order
//               .toList();

//           // Draw the route on the map
//           _drawRoute(routePoints);
//         } else {
//           print('No paths found');
//         }
//       } else {
//         print('Failed to load route data');
//       }
//     } catch (e) {
//       print('Error: $e');
//     }
//   }

//   // Function to draw the route on the map
//   Future<void> _drawRoute(List<LatLng> routePoints) async {
//     await _controller?.addLine(LineOptions(
//       geometry: routePoints,
//       lineColor: "#FF0000", // Color for the route line
//       lineWidth: 5.0,
//     ));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Navigation'),
//       ),
//       body: _currentLocation == null
//           ? const Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: TextField(
//                     controller: _startPointController,
//                     decoration: InputDecoration(
//                       labelText: 'Start Point (Lat, Lng)',
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: TextField(
//                     controller: _endPointController,
//                     decoration: InputDecoration(
//                       labelText: 'End Point (Lat, Lng)',
//                     ),
//                   ),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     final startPoint = _startPointController.text.split(',');
//                     final endPoint = _endPointController.text.split(',');
//                     if (startPoint.length == 2 && endPoint.length == 2) {
//                       LatLng start = LatLng(double.parse(startPoint[0]),
//                           double.parse(startPoint[1]));
//                       LatLng end = LatLng(
//                           double.parse(endPoint[0]), double.parse(endPoint[1]));
//                       getRoute(start, end);
//                     }
//                   },
//                   child: const Text('Get Route'),
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
//                       _controller = controller; // Store the map controller
//                     },
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
// }
