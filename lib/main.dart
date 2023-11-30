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
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

// Barcode Scanning Package
import 'package:barcode_scan2/barcode_scan2.dart';

//detect platform: iphone or android
import 'dart:io'
    show HttpClient, HttpClientRequest, HttpClientResponse, Platform;

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
      return Item(data['name'] ?? '', data['barcode'] ?? '',
          data['price'] ?? 0.0, data['label'] ?? '', data['url'] ?? '');
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

  String currentCollection =
      ''; // Define a variable to hold the collection name
  Future<List<Item>> marketInv = Future<List<Item>>.value([]);
  @override
  void initState() {
    super.initState();
    currentCollection = widget.collection;
    marketInv =
        fetchItemsFromFirestore(currentCollection).then((value) => value);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<bool> _scanBarcode() async {
    print('Scanning barcode...');
    var result = await BarcodeScanner.scan();
    print(result.type);
    // if good, check if barcode in inventory and open item details screen with item
    // result.type == ResultType.Barcode
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
      print(_marketInv.length);
      for (int i = 0; i < _marketInv.length; i++) {
        // String check = marketInv[i].barcode;
        print(_marketInv[i].barcode);
        print(scannedBarcode);
        if (scannedBarcode == _marketInv[i].barcode) {
          bool inCart =
              widget.cart.any((sale) => sale.item.barcode == scannedBarcode);
          if (inCart) {
            setState(() {
              widget.cart
                  .firstWhere((sale) => sale.item.barcode == scannedBarcode)
                  .quantity += 1;
            });
          } else {
            setState(() {
              widget.cart.add(Sale(_marketInv[i], 1));
            });
          }
          return true;
        }
      }
      // print("Added an item?");
      // print(result.rawContent);
    }
    return false;
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
                  GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Remove Item'),
                              content: const Text(
                                  'Do you want to remove this item from the cart?'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text('Remove'),
                                  onPressed: () {
                                    setState(() {
                                      widget.cart.removeAt(
                                          index); // Remove the item from the cart list
                                    });
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Image(
                          image:
                              Image.network(widget.cart[index].item.url).image,
                          width: 200.00)),
                  Column(children: [
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
                        subtitle: Row(children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () {
                              _decreaseQuantity(index);
                            },
                          ),
                          Text("Quantity: ${widget.cart[index].quantity}"),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              _increaseQuantity(index);
                            },
                          ),
                        ]))
                  ])
                ]);
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
                  _scanBarcode().then((value) {
                    if (value == false) {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Item Not Found'),
                              content: const Text(
                                  'The scanned item is not available in the inventory.'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          }).catchError(throw Error());
                    }
                  });
                },
                child: const Text(
                  '+',
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Add your logic for the cart button here
                  widget.cart.isNotEmpty
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReceiptScreen(widget.cart),
                          ),
                        )
                      : '';
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

  void _increaseQuantity(int index) {
    setState(() {
      widget.cart[index].quantity++;
    });
  }

  void _decreaseQuantity(int index) {
    if (widget.cart[index].quantity > 1) {
      setState(() {
        widget.cart[index].quantity--;
      });
    } else {
      setState(() {
        widget.cart.removeAt(index);
      });
    }
  }
}

class DetailScreen extends StatefulWidget {
  final double total;

  DetailScreen({Key? key, required this.total}) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late TextEditingController _quantityController;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _cardNumber = '';
  String _expirationDate = '';
  String _cvv = '';

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
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Card Number',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color.fromARGB(0, 255, 255, 255),
                    hintText: 'Enter Card Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 16,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Card is required';
                    }
                    if (value.length != 16) {
                      return 'Card must be 16 digits';
                    }
                    return null; // Return null for no validation error
                  },
                  // Add any necessary logic here for handling card number input
                ),
                const SizedBox(height: 20),
                const Text(
                  'Expiration Date',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color.fromARGB(0, 255, 255, 255),
                    hintText: 'MM/YY',
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: [
                    // Use a LengthLimitingTextInputFormatter to limit the input length
                    LengthLimitingTextInputFormatter(5),
                    // Restrict the input to only accept valid expiration date format (MM/YY)
                    MaskTextInputFormatter(
                        mask: '##/##', filter: {'#': RegExp(r'[0-9]')}),
                  ],
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                const Text(
                  'CVV',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color.fromARGB(0, 255, 255, 255),
                    hintText: 'Enter CVV',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'CVV is required';
                    }
                    if (value.length != 3) {
                      return 'CVV must be 3 digits';
                    }
                    return null; // Return null for no validation error
                  },
                  // Add any necessary logic here for handling CVV input
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Process form data (e.g., save to database, use for payment, etc.)
                      // Access the entered card details: _cardNumber, _expirationDate, _cvv
                      // For example: print('Card Number: $_cardNumber');
                      print('Submit');
                      handleApi(widget.total).then((value) {
                        Map<String, dynamic> parsedValue = json.decode(value);

                        Map<String, dynamic> paymentReceipt =
                            parsedValue['paymentReceipt'];
                        // Map<String, dynamic> paymentReceipt = json.decode(paymentReceiptString);
                        if (true) {
                          // Extracting paymentReceipt from the JSON data
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Payment Receipt'),
                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Approved Amount: \$${paymentReceipt['approvedAmount']['total'].toStringAsFixed(2)} ${paymentReceipt['approvedAmount']['currency']}',
                                      style: const TextStyle(
                                        fontSize:
                                            18.0, // Adjust the font size as desired
                                        fontWeight: FontWeight
                                            .bold, // You can modify the font weight if needed
                                      ),
                                    ),
                                    Text(
                                      'Processor: ${paymentReceipt['processorResponseDetails']['processor']}',
                                      style: const TextStyle(
                                        fontSize:
                                            18.0, // Adjust the font size as desired
                                        fontWeight: FontWeight
                                            .bold, // You can modify the font weight if needed
                                      ),
                                    ),
                                    Text(
                                      'Approval Status: ${paymentReceipt['processorResponseDetails']['approvalStatus']}',
                                      style: const TextStyle(
                                        fontSize:
                                            18.0, // Adjust the font size as desired
                                        fontWeight: FontWeight
                                            .bold, // You can modify the font weight if needed
                                      ),
                                    ),
                                    // Add other details you want to display here...
                                  ],
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Close'),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          throw (Error());
                        }
                      });
                    }
                  },
                  child: Text('Submit'),
                ),
              ],
            )),
          ),
        ));
  }

  Future<String> handleApi(total) async {
    var jsonBody = {
      "amount": {"total": total, "currency": "USD"},
      "source": {
        "sourceType": "PaymentCard",
        "card": {
          "cardData": "4005550000000016",
          "expirationMonth": "02",
          "expirationYear": "2035"
        }
      },
      "transactionDetails": {"captureFlag": true},
      "transactionInteraction": {
        "origin": "ECOM",
        "eciIndicator": "CHANNEL_ENCRYPTED",
        "posConditionCode": "CARD_NOT_PRESENT_ECOM"
      },
      "merchantDetails": {
        "merchantId": "100008000003683",
        "terminalId": "10000001"
      }
    };

    // var jsonBody = {};
    var key = 'ZxmiHz3CxGmUzWZ1SJZPcx0JHhCSPGYT';
    var secret = 'xwn4X2VAN8ug4Jmvuj1kZbCEL7yoTBCnH3AicTtMEtx';
    var clientRequestId = DateTime.now().millisecondsSinceEpoch;
    var time = DateTime.now().millisecondsSinceEpoch;
    var method = 'POST'; // Change this according to your request method
    var rawSignature = '$key$clientRequestId$time${jsonEncode(jsonBody)}';
    var hmacSha256 = Hmac(sha256, utf8.encode(secret));
    var signatureBytes = hmacSha256.convert(utf8.encode(rawSignature)).bytes;
    var computedHmac = base64.encode(signatureBytes);
    // Now you can use the variables in your Flutter code

    var headers = {
      "Content-Type": "application/json",
      "Authorization": computedHmac,
      "Api-Key": key,
      "Client-Request-Id": clientRequestId.toString(),
      "Timestamp": time.toString(),
      "Auth-Token-Type": "HMAC",
      "Accept": "application/json",
      "Accept-Language": "en"
    };

    var url = 'https://cert.api.fiservapps.com/ch/payments/v1/charges';

    HttpClient httpClient = HttpClient();

    // var response = await http.post(
    //   Uri.parse(url),
    //   body: requestBody,
    //   headers: {
    //   "Content-Type": "application/json",
    //   "Authorization": computedHmac,
    //   "Api-Key": key,
    //   "Client-Request-Id": clientRequestId.toString(),
    //   "Timestamp": time.toString(),
    //   "Auth-Token-Type": "HMAC",
    //   "Accept": 'application/json',
    //   "Accept-Language": "en"
    // },

    // );

    HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));

    // Set headers
    headers.forEach((header, value) {
      request.headers.set(header, value);
    });

    // Set the request body
    request.write(jsonEncode(jsonBody));

    // Get the response
    HttpClientResponse response = await request.close();

    // Read the response
    Future<String> responseBody = response.transform(utf8.decoder).join();

    return responseBody;
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
                double total = 0;
                for (int i = 0; i < widget.cart.length; i++) {
                  total += widget.cart[i].item.price * widget.cart[i].quantity;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(
                      total:
                          total, // Pass the selected index to the next screen
                    ),
                  ),
                );
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