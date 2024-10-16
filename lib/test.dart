// // lib/main.dart

// import 'package:flutter/material.dart';
// import 'geocoading.dart'; // Import your geocoding service

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Location Search App',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: TestGeocoding(), // Change this to TestGeocoding
//     );
//   }
// }

// class TestGeocoding extends StatefulWidget {
//   @override
//   _TestGeocodingState createState() => _TestGeocodingState();
// }

// class _TestGeocodingState extends State<TestGeocoding> {
//   final GeocodingService _geocodingService = GeocodingService();
//   String _result = '';

//   @override
//   void initState() {
//     super.initState();
//     _testGeocoding(); // Call the test function
//   }

//   void _testGeocoding() async {
//     // Test geocoding by name
//     String address = 'Bhopal';
//     String result = await _geocodingService.geocode(address);
//     print('Geocoding Result: $result'); // Print the result to the console
//     setState(() {
//       _result = result;
//     });

//     // Test reverse geocoding by coordinates
//     double latitude = 23.259933; // Example latitude
//     double longitude = 77.412613; // Example longitude
//     String reverseResult =
//         await _geocodingService.reverseGeocode(latitude, longitude);
//     print(
//         'Reverse Geocoding Result: $reverseResult'); // Print the result to the console
//     setState(() {
//       _result += '\n' + reverseResult; // Append the result to the UI
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Geocoding Test')),
//       body: Center(
//         child: Text(_result.isEmpty ? 'Testing...' : _result),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Search',
      home: SearchPage(),
    );
  }
}

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  String _result = '';

  Future<void> searchLocation(String locationName) async {
    final String apiUrl =
        'https://nominatim.openstreetmap.org/search?q=$locationName&format=json&addressdetails=1';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final latitude = data[0]['lat'];
          final longitude = data[0]['lon'];
          setState(() {
            _result = 'Latitude: $latitude, Longitude: $longitude';
          });
        } else {
          setState(() {
            _result = 'No results found';
          });
        }
      } else {
        setState(() {
          _result = 'Failed to load location data';
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Location Search')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Enter location name'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                searchLocation(_controller.text);
              },
              child: Text('Search'),
            ),
            SizedBox(height: 20),
            Text(_result),
          ],
        ),
      ),
    );
  }
}
