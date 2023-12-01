

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';

const apiKey = 'AIzaSyDbVBgQl-2vGpNSFzlx_Ocez5TD1U4PDVc';
final places = GoogleMapsPlaces(apiKey: apiKey);

Future<List<PlacesSearchResult>> searchPlaces() async {
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);

  final result = await places.searchNearbyWithRadius(
    Location(lat: position.latitude, lng: position.longitude),
    5000,
    type: "supermarket",
  );
  if (result.status == "OK") {
    return result.results;
  } else {
    throw Exception(result.errorMessage);
  }
}