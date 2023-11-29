import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/geocoding.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:geolocator/geolocator.dart';

// Barcode Scanning Package
import 'package:barcode_scan2/barcode_scan2.dart';

//detect platform: iphone or android
import 'dart:io' show Platform;

import 'package:shop_n_scan/firebase_options.dart';

//TODO: Make search button to search with text to find and add items

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Connect to firebase
  await Firebase.initializeApp(options: defaultFirebaseOptions);
  runApp(MyApp());
}

class Item {
  // This class represents grocery store items
  final String name, barcode, nutritionLabel, url;
  final double price;
  Item(this.name, this.barcode, this.price, this.nutritionLabel, this.url);
}

class Sale {
  final Item item;
  int quantity;

  Sale(this.item, this.quantity);
}

// Reference to collection
final itemsRef = FirebaseFirestore.instance.collection('ALDI');
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

//TODO : Get Inventory from Firebase Firestore
Future<List<Item>> fetchItemsFromFirestore(String a) async {
  final itemsRef = FirebaseFirestore.instance.collection(a);

  try {
    // Access the 'inventory' collection and get the documents
    QuerySnapshot querySnapshot = await itemsRef.get();

    // Extract the documents into Item objects
    List<Item> items = querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      print(data['price'].runtimeType);
      // print(data['name'].runtimeType);
      // print(data['label'].runtimeType);
      // print(data['barcode'].runtimeType);
      return Item(
        data['name'] ?? '',
        data['barcode'] ?? '',
        data['price'] ?? 0.0,
        data['label'] ?? '',
        data['url'] ?? ''
      );
    }).toList();

    return items;
  } catch (error) {
    // Handle errors here if needed
    print('Error fetching items: $error');
    return []; // Return an empty list in case of error
  }
}

class MyApp extends StatelessWidget {
  //create method to get items from firestore and populate list
  Future<List<PlacesSearchResult>> places = searchPlaces();

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
              places: snapshot.data ?? [], // Use fetched data or empty list
            );
          }
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final List<PlacesSearchResult> places;

  const MyHomePage(
      {Key? key,
      required this.title,
      required this.places
      })
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
                                  .image
                            ),
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
          collection: widget.places[index].name, // Pass the selected index to the next screen
        ),
      ),
    );
  }
  

  /*@override
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
                    // TODO: ADD CART SCREEN ON TAP
                    onTap: () {
                      //print(widget.places[0].name);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CartScreen(inventory: widget.inventory),
                        ),
                      );
                    },
                    child: ListView.builder(
                      itemCount: widget.places.length,
                      itemBuilder: (context, index) {
                        return Column(children: [
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
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          )
                        ]);
                      },
                    )),
              ),
             ],
          ),
        ),
      ),
    );
  }*/
}

//sale detail screen

class CartScreen extends StatefulWidget {
  String collection;
  List<Sale> cart = [];

  CartScreen({Key? key, required this.collection}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late TextEditingController _quantityController;

  String currentCollection = ''; // Define a variable to hold the collection name
  Future<List<Item>> marketInv = Future<List<Item>>.value([]);
  @override
  void initState() {
    super.initState();
    currentCollection = widget.collection;
    marketInv = fetchItemsFromFirestore(currentCollection).then((value) => value);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    // print('Scanning barcode...');
    var result = await BarcodeScanner.scan();
    print(result.type);

    // if good, check if barcode in inventory and open item details screen with item
    if (result.type == ResultType.Barcode) {
      String scannedBarcode = result.rawContent;
      // IF IPHONE DELETE ZERO FROM START OF scanned barcode
      // Check if running on iPhone and remove leading zero
      // Weird weird error. on iphones for certain barcodes it adds a 0 to start
      if (Platform.isIOS) {
        if (scannedBarcode.substring(0, 1) == "0") {
          scannedBarcode = scannedBarcode.substring(1);
        }
      }
      // Success
      List<Item> _marketInv = await marketInv;
      setState(() {
        print(_marketInv.length);
        for (int i = 0; i < _marketInv.length; i++) {
          // String check = marketInv[i].barcode;
          print(_marketInv[i].barcode);
          if (scannedBarcode == _marketInv[i].barcode) {
            // if already in cart

            bool inCart = false;
            for (int j = 0; j < widget.cart.length; j++) {
              if (scannedBarcode == widget.cart[j].item.barcode) {
                widget.cart[j].quantity += 1;
                inCart = true;
              }
            }

            //if not already in cart
            if (!inCart) {
              widget.cart.add(Sale(_marketInv[i], 1));
            }
          }
        }
        // print("Added an item?");
        // print(result.rawContent);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.cart.length,
              itemBuilder: (context, index) {
                return Column(children: [
                  Image(image: Image.network(widget.cart[index].item.url).image, width: 200.00),
                  ListTile(
                  leading: Text(
                    // "${widget.cart[index].item.price * widget.cart[index].quantity}\$",
                    "${(widget.cart[index].item.price * widget.cart[index].quantity).toStringAsFixed(2)}\$",
                    style: const TextStyle(
                      
                      fontSize: 18.0, // Adjust the font size as needed
                      fontWeight: FontWeight
                          .bold, // Optional: Modify the font weight if desired
                    ),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.cart[index].item.name),
                    ],
                  ),
                  subtitle: Text("Quantity: ${widget.cart[index].quantity}"),
                  onTap: () async {
                    final updatedQuantity = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(widget.cart[index]),
                      ),
                    );

                    if (updatedQuantity != null) {
                      setState(() {
                        widget.cart[index].quantity = updatedQuantity;
                      });
                    }
                  },
                )
                ]
                );
              },
            ),
          ),
           Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Add your logic for the plus button here
                      print('Plus button pressed!');
                      _scanBarcode();
                    },
                    child: const Text(
                      '+',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Add your logic for the cart button here
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReceiptScreen(widget.cart),
                        ),
                      );
                      print('Cart button pressed!');
                    },
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('Checkout'),
                  ),
                ],
              ),
        ],
      ),
    );
  }
}

class DetailScreen extends StatefulWidget {
  final Sale sale;

  DetailScreen(this.sale);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late TextEditingController _quantityController;

  @override
  void initState() async {
    super.initState();
    _quantityController =
        TextEditingController(text: widget.sale.quantity.toString());
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.sale.item.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  widget.sale.item.nutritionLabel.isNotEmpty
                      ? Image.asset(
                          widget.sale.item.nutritionLabel,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        )
                      : const SizedBox(), // Placeholder if no image available
                  const SizedBox(height: 20.0),
                  Text(
                    "${widget.sale.item.price}\$",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Quantity: ${widget.sale.quantity}\nTotal price: ${widget.sale.item.price * widget.sale.quantity}\$",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: "Edit quantity",
                      border: OutlineInputBorder(),
                    ),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                  ),
                ),
                const SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: _updateQuantity,
                  // () {
                  //   // Update the quantity based on the entered value
                  //   setState(() {
                  //     widget.sale.quantity =
                  //         int.tryParse(_quantityController.text) ??
                  //             widget.sale.quantity;
                  //   });
                  // }
                  child: const Text('Update Quantity'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _updateQuantity() {
    int newQuantity =
        int.tryParse(_quantityController.text) ?? widget.sale.quantity;
    setState(() {
      widget.sale.quantity = newQuantity;
    });
    Navigator.pop(context, newQuantity); // Send back the updated quantity
  }
}

class ReceiptScreen extends StatefulWidget {
  final List<Sale> cart;

  ReceiptScreen(this.cart);

  @override
  _ReceiptScreenState createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  TextEditingController taxController = TextEditingController();
  TextEditingController totalPriceController = TextEditingController();
  late double preTaxTotal;
  double taxAmount = 0.0;

  @override
  void initState() {
    super.initState();
    preTaxTotal = _calculateTotal(widget.cart);
    taxAmount = _calculateTax(preTaxTotal);
    totalPriceController.text = _calculateTotalPrice(preTaxTotal, taxAmount);
  }

  @override
  void dispose() {
    taxController.dispose();
    totalPriceController.dispose();
    super.dispose();
  }

  double _calculateTotal(List<Sale> cart) {
    double total = 0;
    for (var sale in cart) {
      total += sale.item.price * sale.quantity;
    }
    return total;
  }

  double _calculateTax(double preTaxTotal) {
    // Your tax calculation logic here
    return preTaxTotal * 0.1; // For example, calculating 10% tax
  }

  String _calculateTotalPrice(double preTaxTotal, double taxAmount) {
    return (preTaxTotal + taxAmount).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt'),
      ),
      body: ListView.builder(
        itemCount: widget.cart.length,
        itemBuilder: (context, index) {
          final sale = widget.cart[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(sale.item.name),
              subtitle: Text(
                  'Price: ${sale.item.price}\$  |  Quantity: ${sale.quantity}'),
              trailing: Text(
                  '${(sale.item.price * sale.quantity).toStringAsFixed(2)}\$'),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pre-tax Total:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${preTaxTotal.toStringAsFixed(2)}\$',
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tax: ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${taxAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Price: ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  totalPriceController.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Implement your payment logic here
                _processPayment();
              },
              child: const Text('Pay'),
            ),
          ],
        ),
      ),
    );
  }

  void _processPayment() {
    // Add your payment processing logic here
    print('Payment processed!');
    // Example: You might navigate to a success screen or perform further actions
  }
}

const defaultFirebaseOptions = FirebaseOptions(
  apiKey: 'AIzaSyAZUChIYen40je1Tn-ZiWTH0-iNjONZrSM',
  appId: '1:954628617989:android:2f2522000d401840eae96c',
  messagingSenderId: '954628617989',
  projectId: 'shopnscan-6c111',
  databaseURL: 'https://shopnscan-6c111-default-rtdb.firebaseio.com/',
);

  // --- ON TAP ---
  // onTap: () async {
  //   final updatedQuantity = await Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) =>
  //           DetailScreen(widget.cart[index]),
  //     ),
  //   );

  //   if (updatedQuantity != null) {
  //     setState(() {
  //       widget.cart[index].quantity = updatedQuantity;
  //     });
  //   }
  // },

  // DISAPLAYH ITEMS
  // Expanded(
  //   child: ListView.builder(
  //     itemCount: widget.cart.length,
  //     itemBuilder: (context, index) {
  //       return ListTile(
  //         leading: Text(
  //           // "${widget.cart[index].item.price * widget.cart[index].quantity}\$",
  //           "${(widget.cart[index].item.price * widget.cart[index].quantity).toStringAsFixed(2)}\$",
  //           style: const TextStyle(
  //             fontSize: 18.0, // Adjust the font size as needed
  //             fontWeight: FontWeight
  //                 .bold, // Optional: Modify the font weight if desired
  //           ),
  //         ),
  //         title: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(widget.cart[index].item.name),
  //           ],
  //         ),
  //         subtitle:
  //             Text("Quantity: ${widget.cart[index].quantity}"),
  //         onTap: () async {
  //           final updatedQuantity = await Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) =>
  //                   DetailScreen(widget.cart[index]),
  //             ),
  //           );

  //           if (updatedQuantity != null) {
  //             setState(() {
  //               widget.cart[index].quantity = updatedQuantity;
  //             });
  //           }
  //         },
  //       );
  //     },
  //   ),
  // ),

  // --- MOCK DATA ---
  // final List<Item> items = [
  //   const Item("apple", "079737210150", 1.09, "temp/apple.jpg"),
  //   const Item("guava", "020357122682", 2.25, "temp/guava.jpg"),
  //   const Item("Korean pear", "4337185143489", 5.25, "temp/korean_pear.jpg"),
  //   const Item("Adapter","SMBHAA27715", 10.50, "temp/charge.jpg"),
  //   const Item("Orbit Gum","02248400", 2.50, "temp/gum.jpg")
  // ];
    //DatabaseReference database = FirebaseDatabase.instance.ref();
    /*for (var item in items) {
      database.child('items').push().set({
        'name': item.name,
        'barcode': item.barcode,
        'price': item.price,
        'nutritionLabel': item.nutritionLabel,
      });
    }*/