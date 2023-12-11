import 'package:flutter/material.dart';
import '../models/Sale.dart';
import 'payment_screen.dart';

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