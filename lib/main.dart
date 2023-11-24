import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class Item {
  // This class represents grocery store items

  final String name, barcode;
  final int price;
  const Item(this.name, this.barcode, this.price);
}

class Sale {
  final Item item;
  int quantity;

  Sale(this.item, this.quantity);
}

//TODO connect to firebase

//TODO get firestore inventory collection

//TODO handle payments

class MyApp extends StatelessWidget {
  final List<Item> items = [
    Item("apple", "barcode", 1),
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
  void _scanBarcode() {
    // TODO: Add barcode scanning logic here
    print('Scanning barcode...');
    // TODO: if good, check if barcode in inventory and open item details screen with item
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
                  itemCount: widget.inventory.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Text("${widget.inventory[index].price}\$"),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.inventory[index].name),
                        ],
                      ),
                      subtitle: Text(
                          "Quantity: ${widget.cart.where((sale) => sale.item == widget.inventory[index]).length}"),
                      onTap: () {
                        // Implement onTap action if needed
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

//TODO item detail screen

class DetailScreen extends StatelessWidget {
  final Item item;

  DetailScreen(this.item);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Item Details'),
      ),
      body: Container(
          padding: const EdgeInsets.all(45),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(item.name),
              Text("${item.price}\$"),
              TextField(
                decoration: InputDecoration(labelText: "Enter quantity"),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ], // Only numbers can be entered
              ),
            ],
          )),
    );
  }
}
