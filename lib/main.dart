import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class Item {
  final String name;
  const Item(this.name);
}

class MyApp extends StatelessWidget {
  final List<Item> itemList = const [
    Item('Item 1'),
    Item('Item 2'),
    Item('Item 3'),
    // Add more items as needed
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shop and Scan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple),
        // Adjust the theme as needed
      ),
      home: MyHomePage(title: 'Home', itemList: itemList),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final List<Item> itemList;

  MyHomePage({Key? key, required this.title, required this.itemList})
      : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _scanBarcode() {
    // Add barcode scanning logic here
    print('Scanning barcode...');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Add your logic for the plus button here
                print('Plus button pressed!');
              },
              child: Text(
                '+',
                style: TextStyle(fontSize: 20.0),
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton.icon(
              onPressed: () {
                // Add your logic for the cart button here
                print('Cart button pressed!');
              },
              icon: Icon(Icons.shopping_cart),
              label: Text('Checkout'),
            ),
            SizedBox(height: 20.0),
            Expanded(
              child: ListView.builder(
                itemCount: widget.itemList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.star),
                    title: Text(widget.itemList[index].name),
                    onTap: () {
                      // Navigate to a new view
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailScreen(widget.itemList[index]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final Item item;

  DetailScreen(this.item);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Item Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Item: ${item.name}',
              style: TextStyle(fontSize: 20.0),
            ),
            // You can add more details or widgets here
          ],
        ),
      ),
    );
  }
}
