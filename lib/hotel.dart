// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:location/location.dart'; // Add location package

// class SearchPage extends StatefulWidget {
//   @override
//   _SearchPageState createState() => _SearchPageState();
// }

// class _SearchPageState extends State<SearchPage> {
//   final TextEditingController _searchController = TextEditingController();
//   bool _isLoading = false;
//   List _restaurants = [];
//   LocationData? _currentLocation;
//   final Location location = Location(); // Create Location instance

//   @override
//   void initState() {
//     super.initState();
//     _fetchCurrentLocation(); // Fetch the current location when the page loads
//   }

//   // Function to get the user's current location
//   Future<void> _fetchCurrentLocation() async {
//     try {
//       // Directly get the current location as permission is already granted
//       LocationData currentLocation = await location.getLocation();

//       setState(() {
//         _currentLocation = currentLocation;
//       });
//     } catch (e) {
//       print("Error fetching location: $e");
//     }
//   }

//   Future<void> searchRestaurants(String dishName) async {
//     if (_currentLocation == null) {
//       print("Location not available yet.");
//       return;
//     }

//     setState(() {
//       _isLoading = true; // Show loading spinner
//     });

//     // Replace with your Foursquare API key
//     String apiKey =
//         'YOUR_FOURSQUARE_API_KEY'; // Add your Foursquare API key here
//     String apiUrl =
//         'https://api.foursquare.com/v3/places/search?query=$dishName&ll=${_currentLocation!.latitude},${_currentLocation!.longitude}&radius=12000';

//     var response = await http.get(Uri.parse(apiUrl), headers: {
//       'Authorization': 'Bearer $apiKey',
//     });

//     if (response.statusCode == 200) {
//       var jsonResponse = json.decode(response.body);
//       print(jsonResponse);
//       setState(() {
//         _restaurants =
//             jsonResponse['results']; // Extract restaurants from API response
//         _isLoading = false; // Stop loading
//       });
//     } else {
//       // Handle errors
//       setState(() {
//         _isLoading = false;
//       });
//       print("Failed to load data: ${response.statusCode}");
//     }
//   }

//   // Function to handle the search API call
//   // Future<void> searchRestaurants(String dishName) async {
//   //   if (_currentLocation == null) {
//   //     print("Location not available yet.");
//   //     return;
//   //   }

//   //   setState(() {
//   //     _isLoading = true; // Show loading spinner
//   //   });

//   //   // Replace with your API URL and key
//   //   String apiUrl =
//   //       'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
//   //   double userLatitude = _currentLocation!.latitude!;
//   //   double userLongitude = _currentLocation!.longitude!;
//   //   String apiKey = 'YOUR_API_KEY'; // Replace with your API key

//   //   var response = await http.get(
//   //     Uri.parse(
//   //         '$apiUrl?location=$userLatitude,$userLongitude&radius=12000&type=restaurant&keyword=$dishName&key=$apiKey'),
//   //   );

//   //   if (response.statusCode == 200) {
//   //     var jsonResponse = json.decode(response.body);
//   //     setState(() {
//   //       _restaurants =
//   //           jsonResponse['results']; // Extract restaurants from API response
//   //       _isLoading = false; // Stop loading
//   //     });
//   //   } else {
//   //     // Handle errors
//   //     setState(() {
//   //       _isLoading = false;
//   //     });
//   //     print("Failed to load data: ${response.statusCode}");
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Search for a Dish'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Search bar input
//             TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'Enter dish name (e.g., Pasta)',
//                 border: OutlineInputBorder(),
//                 suffixIcon: IconButton(
//                   onPressed: () {
//                     _searchController.clear();
//                   },
//                   icon: Icon(Icons.clear),
//                 ),
//               ),
//             ),
//             SizedBox(height: 16),
//             // Search button
//             ElevatedButton(
//               onPressed: () {
//                 String dishName = _searchController.text;
//                 if (dishName.isNotEmpty) {
//                   searchRestaurants(dishName); // Call search function
//                 }
//               },
//               child: Text('Search'),
//             ),
//             SizedBox(height: 16),
//             // Display loading indicator
//             if (_isLoading)
//               CircularProgressIndicator()
//             else
//               // Display search results
//               Expanded(
//                 child: _restaurants.isEmpty
//                     ? Center(child: Text('No restaurants found.'))
//                     : ListView.builder(
//                         itemCount: _restaurants.length,
//                         itemBuilder: (context, index) {
//                           var restaurant = _restaurants[index];
//                           return ListTile(
//                             title: Text(restaurant['name'] ?? 'No name'),
//                             subtitle:
//                                 Text(restaurant['vicinity'] ?? 'No address'),
//                           );
//                         },
//                       ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  LocationData? _currentLocation;
  List _restaurants = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  Location location = Location(); // Initialize Location instance

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  // Function to get the user's current location
  Future<void> _fetchCurrentLocation() async {
    try {
      // Directly get the current location as permission is already granted
      LocationData currentLocation = await location.getLocation();

      setState(() {
        _currentLocation = currentLocation;
      });

      // Automatically search for restaurants around the user's location
      searchRestaurants(
          ""); // Empty string triggers the search for all nearby restaurants
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  Future<void> searchRestaurants(String dishName) async {
    if (_currentLocation == null) {
      print("Location not available yet.");
      return;
    }

    setState(() {
      _isLoading = true; // Show loading spinner
    });

    // Replace with your Geoapify API key
    String apiKey = '5af3a8ea12dc4d76b6f5f1547ad2e318';
    String apiUrl = 'https://api.geoapify.com/v2/places';

    double userLatitude = _currentLocation!.latitude!;
    double userLongitude = _currentLocation!.longitude!;

    // Build the URL for the API request
    String requestUrl =
        '$apiUrl?categories=catering.restaurant&filter=circle:$userLongitude,$userLatitude,12000&apiKey=$apiKey';

    // If a dish name is provided, search using it as a keyword
    if (dishName.isNotEmpty) {
      requestUrl += '&name=$dishName';
    }

    var response = await http.get(Uri.parse(requestUrl));

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      setState(() {
        _restaurants = jsonResponse['features']; // Extract restaurant data
        _isLoading = false; // Stop loading
      });
    } else {
      // Handle errors
      setState(() {
        _isLoading = false;
      });
      print("Failed to load data: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Restaurants'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for a dish',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    // Trigger a search with the dish name entered
                    searchRestaurants(_searchController.text);
                  },
                ),
              ),
            ),
          ),
          _isLoading
              ? Center(child: CircularProgressIndicator()) // Show loader
              : Expanded(
                  child: _restaurants.isEmpty
                      ? Center(child: Text("No restaurants found"))
                      : ListView.builder(
                          itemCount: _restaurants.length,
                          itemBuilder: (context, index) {
                            var restaurant = _restaurants[index]['properties'];
                            return ListTile(
                              title: Text(restaurant['name'] ?? 'Unknown'),
                              subtitle: Text(restaurant['address_line1'] ?? ''),
                            );
                          },
                        ),
                ),
        ],
      ),
    );
  }
}
