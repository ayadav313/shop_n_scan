import 'dart:io';
import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';

import '../services/firestore_service.dart';
import '../models/Sale.dart';
import '../models/Item.dart';
import 'receipt_screen.dart';

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