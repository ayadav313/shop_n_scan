import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import './cart_screen.dart';
import '../services/places_service.dart';

class MyHomePage extends StatefulWidget {
  final String title;
  final List<PlacesSearchResult> places;

  const MyHomePage({Key? key, required this.title, required this.places})
      : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // TODO: Handle the case when the whole ListView is tapped
                  },
                  child: ListView.builder(
                    itemCount: widget.places.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          // Handle tap on individual list item
                          _handleListItemTap(index);
                        },
                        child: Column(
                          children: [
                            Image(
                                image: Image.network(widget
                                            .places[index].photos.isNotEmpty
                                        ? 'https://maps.googleapis.com/maps/api/place/photo?photoreference=${widget.places[index].photos[0].photoReference}&maxwidth=300&key=$apiKey'
                                        : 'https://upload.wikimedia.org/wikipedia/commons/b/b1/Missing-image-232x150.png')
                                    .image),
                            ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.places[index].name,
                                    style: const TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleListItemTap(int index) async {
    // Handle the tap on the list item with the given index
    print('Tapped on item at index: ${widget.places[index].name}');
    // Add your logic here to navigate or perform actions based on the tapped item
    //widget.inventory=fetchItemsFromFirestore(widget.places[index].name).then((value) => value) as List<Item>;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(
          collection: widget
              .places[index].name, // Pass the selected index to the next screen
        ),
      ),
    );
  }
}