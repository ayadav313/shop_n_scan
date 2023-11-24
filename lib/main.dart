import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Barcode Scanning Package
import 'package:barcode_scan2/barcode_scan2.dart';

//TODO: search button to search with text to find and add items

//TODO: Animate buttons to expand (show text when clicked)

void main() {
  runApp(MyApp());
}

class Item {
  // This class represents grocery store items

  final String name, barcode, nutritionLabel;
  final double price;
  const Item(this.name, this.barcode, this.price, this.nutritionLabel);
}

class Sale {
  final Item item;
  int quantity;

  Sale(this.item, this.quantity);
}

//TODO Get Inventory from Firebase Firestore
// Currently hardcoded, List<item> inventory needs to be filled from firestore

//TODO Handle payments with Firebase

class MyApp extends StatelessWidget {
  final List<Item> items = [
    const Item("apple", "079737210150", 1.09, "temp/apple.jpg"),
    const Item("guava", "020357122682", 2.25, "temp/guava.jpg"),
    const Item("Korean pear", "4337185143489", 5.25, "temp/korean_pear.jpg"),

    // Add more items to the items list if needed
  ];

  final List<Sale> cart = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shop and Scan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple),
      ),
      home: MyHomePage(title: 'Home', inventory: items, cart: cart),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final List<Item> inventory;
  final List<Sale> cart;

  MyHomePage(
      {Key? key,
      required this.title,
      required this.inventory,
      required this.cart})
      : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<void> _scanBarcode() async {
    // TODO: barcode scanning logic here
    // print('Scanning barcode...');
    var result = await BarcodeScanner.scan();

    // if good, check if barcode in inventory and open item details screen with item
    if (result.type == ResultType.Barcode) {
      // Success
      setState(() {
        for (int i = 0; i < widget.inventory.length; i++) {
          if (result.rawContent == widget.inventory[i].barcode) {
            // if already in cart
            bool inCart = false;
            for (int j = 0; j < widget.cart.length; j++) {
              if (result.rawContent == widget.cart[j].item.barcode) {
                widget.cart[j].quantity += 1;
                inCart = true;
              }
            }

            //if not already in cart
            if (!inCart) {
              widget.cart.add(Sale(widget.inventory[i], 1));
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
        title: Text(widget.title),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: widget.cart.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Text(
                        // "${widget.cart[index].item.price * widget.cart[index].quantity}\$",
                        "${(widget.cart[index].item.price * widget.cart[index].quantity).toStringAsFixed(2)}\$",
                        style: TextStyle(
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
                      subtitle:
                          Text("Quantity: ${widget.cart[index].quantity}"),
                      onTap: () async {
                        final updatedQuantity = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetailScreen(widget.cart[index]),
                          ),
                        );

                        if (updatedQuantity != null) {
                          setState(() {
                            widget.cart[index].quantity = updatedQuantity;
                          });
                        }
                      },
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
                    child: Text(
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
                    icon: Icon(Icons.shopping_cart),
                    label: Text('Checkout'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//TODO sale detail screen

class DetailScreen extends StatefulWidget {
  final Sale sale;

  DetailScreen(this.sale);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late TextEditingController _quantityController;

  @override
  void initState() {
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
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  widget.sale.item.nutritionLabel.isNotEmpty
                      ? Image.asset(
                          widget.sale.item.nutritionLabel,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        )
                      : SizedBox(), // Placeholder if no image available
                  SizedBox(height: 20.0),
                  Text(
                    "${widget.sale.item.price}\$",
                    textAlign: TextAlign.center,
                    style: TextStyle(
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
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20.0),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextField(
                    controller: _quantityController,
                    decoration: InputDecoration(
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
                SizedBox(height: 10.0),
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
                  child: Text('Update Quantity'),
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
    //TODO: fix main to handle newQuantity
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
        title: Text('Receipt'),
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
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pre-tax Total:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${preTaxTotal.toStringAsFixed(2)}\$',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tax: ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${taxAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Price: ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  totalPriceController.text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Implement your payment logic here
                _processPayment();
              },
              child: Text('Pay'),
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
