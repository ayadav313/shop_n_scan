import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../utils/handle_api.dart';

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
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Process form data (e.g., save to database, use for payment, etc.)
                      // Access the entered card details: _cardNumber, _expirationDate, _cvv
                      // For example: print('Card Number: $_cardNumber');
                      if (kDebugMode) {
                        print('Submit');
                      }
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
                                title: const Text('Payment Receipt'),
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
                                    child: const Text('Close'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      });
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            )),
          ),
        ));
  }
}