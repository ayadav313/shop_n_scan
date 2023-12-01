import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/Item.dart';

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

const defaultFirebaseOptions = FirebaseOptions(
  apiKey: 'AIzaSyAZUChIYen40je1Tn-ZiWTH0-iNjONZrSM',
  appId: '1:954628617989:android:2f2522000d401840eae96c',
  messagingSenderId: '954628617989',
  projectId: 'shopnscan-6c111',
  databaseURL: 'https://shopnscan-6c111-default-rtdb.firebaseio.com/',
);