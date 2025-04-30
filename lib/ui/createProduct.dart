import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class Createproduct extends StatefulWidget {
  const Createproduct({super.key});

  @override
  State<Createproduct> createState() => _CreateproductState();
}

class _CreateproductState extends State<Createproduct> {
  TextEditingController name = TextEditingController();
  TextEditingController price = TextEditingController();
  String? base64Image;

  Future<void> createProduct({
    required String name,
    required String price,
    required String base64Image,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('products').add({
        'name': name,
        'price': price,
        'image': base64Image,
      });
      print("Product created successfully");
    } catch (e) {
      print("Error creating product: $e");
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 70);

    if (pickedFile != null) {
      final compressed = await FlutterImageCompress.compressWithFile(
        pickedFile.path,
        quality: 70,
      );

      if (compressed != null) {
        setState(() {
          base64Image = base64Encode(compressed);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Product")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),
            TextFormField(
              controller: price,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Camera"),
                ),
                ElevatedButton.icon(
                  onPressed: () => pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Gallery"),
                ),
              ],
            ),
            if (base64Image != null)
              Column(
                children: [
                  const SizedBox(height: 10),
                  const Text("Preview:"),
                  Image.memory(base64Decode(base64Image!), height: 150),
                ],
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (base64Image != null && name.text.isNotEmpty && price.text.isNotEmpty) {
                  createProduct(
                    name: name.text,
                    price: price.text,
                    base64Image: base64Image!,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please fill all fields and select an image")),
                  );
                }
              },
              child: const Text("Create"),
            ),
          ],
        ),
      ),
    );
  }
}
