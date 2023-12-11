import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import './screens/home_screen.dart';
import './services/places_service.dart';
import './services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Connect to firebase
  await Firebase.initializeApp(options: defaultFirebaseOptions);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Method to retrieve places based on location
  final Future<List<PlacesSearchResult>> places = searchPlaces();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shop and Scan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepOrange),
      ),
      home: FutureBuilder(
        future: places,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While data is being fetched, show a loading indicator or placeholder
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasError) {
            // Handle errors if any
            return const Scaffold(
              body: Center(
                child: Text('Error fetching data'),
              ),
            );
          } else {
            // If data is fetched successfully, show the home page
            return MyHomePage(
              title: 'Home',
              // Use fetched data or empty list
              places: snapshot.data ?? [], 
            );
          }
        },
      ),
    );
  }
}