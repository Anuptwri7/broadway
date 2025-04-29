import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Createproduct extends StatefulWidget {
  const Createproduct({super.key});

  @override
  State<Createproduct> createState() => _CreateproductState();
}

class _CreateproductState extends State<Createproduct> {
  TextEditingController name = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController image = TextEditingController();
  Future<void> createProduct({
    required String name,
    required String price,
    required String imageUrl,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('products').add({
        'name': name,
        'price': price,
        'image': imageUrl,
      });
      print("Product created successfully");
    } catch (e) {
      print("Error creating product: $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextFormField(
            controller: name,
          ),
          TextFormField(
            controller: price,
          ),
          TextFormField(
            controller: image,
          ),
          ElevatedButton(onPressed: (){
            createProduct(
              name: name.text,
              price: price.text,
              imageUrl: "https://example.com/laptop.jpg",
            );
          }, child: Text(
            "Create"
          ))
        ],
      ),
    );
  }
}


