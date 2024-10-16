// // lib/geocoding_service.dart

// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class GeocodingService {
//   final String apiKey =
//       'dWavgdQGYhQi3IrgbwAh'; // Replace with your MapTiler API key

//   Future<String> reverseGeocode(double latitude, double longitude) async {
//     final url =
//         'https://api.maptiler.com/geocoding/$longitude,$latitude.json?key=$apiKey';

//     final response = await http.get(Uri.parse(url));
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       if (data['features'].isNotEmpty) {
//         return data['features'][0]['place_name'];
//       }
//     }
//     return 'No address found for the coordinates.';
//   }

//   Future<String> geocode(String address) async {
//     final url = 'https://api.maptiler.com/geocoding/$address.json?key=$apiKey';

//     final response = await http.get(Uri.parse(url));
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       if (data['features'].isNotEmpty) {
//         final lat = data['features'][0]['geometry']['coordinates'][1];
//         final lng = data['features'][0]['geometry']['coordinates'][0];
//         return 'Coordinates: Lat: $lat, Lng: $lng';
//       }
//     }
//     return 'No results found for the address.';
//   }
// }

import 'dart:convert';
import 'package:http/http.dart' as http;

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
        // Use the coordinates for your map
        print('Latitude: $latitude, Longitude: $longitude');
      } else {
        print('No results found');
      }
    } else {
      throw Exception('Failed to load location data');
    }
  } catch (e) {
    print(e);
  }
}
